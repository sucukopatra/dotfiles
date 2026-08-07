#!/bin/bash

prompt_yn() {
  local msg="$1" default="${2:-y}"
  if [[ "${YES_ALL:-0}" == "1" ]]; then
    echo "$msg [auto: y]"
    return 0
  fi
  local indicator
  [[ "$default" == "y" ]] && indicator="[Y/n]" || indicator="[y/N]"
  read -r -p "$msg $indicator: " ans
  ans="${ans:-$default}"
  [[ "$ans" =~ ^[Yy] ]]
}

enable_services() {
    local service

    for service; do
        sudo systemctl enable --now "$service"
    done
}

enable_user_services() {
    local service

    for service; do
        systemctl --user enable --now "$service"
    done
}

is_installed() {
  pacman -Qi "$1" &>/dev/null
}

is_group_installed() {
  pacman -Qg "$1" &>/dev/null
}

install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
      to_install+=("$pkg")
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "installing: ${to_install[*]}"
    yay -S --needed --noconfirm "${to_install[@]}"
  fi
}

install_yay() {
  if ! is_installed "yay"; then
    local tmpdir
    tmpdir="$(mktemp -d)"

    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (
      cd "$tmpdir/yay"
      makepkg -si --noconfirm
    )
    rm -rf "$tmpdir"
  fi
}

write_rule() {
  local path="$1" content="$2"
  if [[ -f "$path" ]] && [[ "$(cat "$path")" == "$content" ]]; then
    echo "  unchanged: $path"
  else
    printf '%s\n' "$content" | sudo tee "$path" >/dev/null
    echo "  written:   $path"
  fi
}

# Detect Intel/NVIDIA display controllers by PCI vendor and write stable udev
# symlinks (/dev/dri/intel-igpu, /dev/dri/nvidia-dgpu) pinned to PCI addresses
# so they survive card0/card1 renumbering between boots.
setup_gpu_udev() {
  local intel_bdf nvidia_bdf intel_pci nvidia_pci
  intel_bdf="$(lspci -d ::03xx | grep -i 'intel' | head -1 | cut -f1 -d' ')"
  nvidia_bdf="$(lspci -d ::03xx | grep -i 'nvidia' | head -1 | cut -f1 -d' ')"

  if [[ -z "$intel_bdf" || -z "$nvidia_bdf" ]]; then
    echo "  WARNING: could not detect both Intel and NVIDIA display controllers; skipping." >&2
    return 0
  fi

  intel_pci="0000:$intel_bdf"
  nvidia_pci="0000:$nvidia_bdf"
  echo "  iGPU $intel_pci -> /dev/dri/intel-igpu"
  echo "  dGPU $nvidia_pci -> /dev/dri/nvidia-dgpu"

  write_rule /etc/udev/rules.d/intel-igpu-dev-path.rules \
    "KERNEL==\"card*\", KERNELS==\"$intel_pci\", SUBSYSTEM==\"drm\", SUBSYSTEMS==\"pci\", SYMLINK+=\"dri/intel-igpu\""
  write_rule /etc/udev/rules.d/nvidia-dgpu-dev-path.rules \
    "KERNEL==\"card*\", KERNELS==\"$nvidia_pci\", SUBSYSTEM==\"drm\", SUBSYSTEMS==\"pci\", SYMLINK+=\"dri/nvidia-dgpu\""

  sudo udevadm control --reload
  sudo udevadm trigger --subsystem-match=drm
}

# Drive Neovim's own bootstrap headlessly so a fresh machine is ready before
# the first interactive launch: lazy.nvim clones itself and installs plugins
# from lazy-lock.json, nvim-treesitter compiles parsers, and mason-tool-installer
# fetches the LSPs/formatters/debug adapters listed in lua/plugins/mason.lua.
bootstrap_neovim() {
  if ! command -v nvim >/dev/null 2>&1; then
    echo "  WARNING: nvim not installed; skipping." >&2
    return 0
  fi

  echo "  syncing plugins (lazy.nvim)..."
  nvim --headless "+Lazy! sync" +qa 2>&1 | grep -viE "^\s*$|progress|receiving|resolving" | tail -3 || true

  # Mason and nvim-treesitter install asynchronously, so a plain `+qa` would
  # kill them mid-download. Poll until every expected binary resolves.
  echo "  installing LSPs, formatters, debug adapters and parsers..."
  nvim --headless -c 'lua
    local want = { "lua-language-server", "bash-language-server", "basedpyright",
                   "clangd", "clang-format", "ruff", "shfmt", "stylua",
                   "tinymist", "typstyle", "codelldb", "netcoredbg" }
    -- csharpier/roslyn need dotnet; only require them when it is present.
    if vim.fn.executable("dotnet") == 1 then
      table.insert(want, "csharpier")
      table.insert(want, "roslyn")
    end
    local deadline = vim.uv.now() + 900000
    local missing
    repeat
      vim.wait(5000)
      missing = {}
      for _, b in ipairs(want) do
        if vim.fn.exepath(b) == "" then missing[#missing + 1] = b end
      end
    until #missing == 0 or vim.uv.now() > deadline
    if #missing > 0 then
      print("  WARNING: still missing after timeout: " .. table.concat(missing, ", "))
    else
      print("  all mason packages present")
    end
    local ok, ts = pcall(require, "nvim-treesitter")
    if ok then print("  treesitter parsers: " .. #ts.get_installed()) end
    vim.cmd("qa!")' 2>&1 | grep -E "WARNING|present|parsers" || true
}

# Microsoft's Visual Studio Tools for Unity debug adapter, used by nvim-dap to
# attach to a running Unity Editor. Not on Mason, so it is pulled straight from
# the marketplace. Referenced by VSTUC_DLL in lua/plugins/dap.lua.
install_vstuc() {
  local dll="$VSTUC_DIR/content/extension/bin/UnityDebugAdapter.dll"
  if [[ -f "$dll" ]]; then
    echo "  unchanged: $dll"
    return 0
  fi

  local tmp
  tmp="$(mktemp -d)"
  # NOTE: --compressed is required. The endpoint always gzips its response, so
  # without it curl writes a gzip stream that unzip cannot read.
  if ! curl -fsSL --compressed -o "$tmp/vstuc.vsix" \
    "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/visualstudiotoolsforunity/vsextensions/vstuc/latest/vspackage"; then
    echo "  WARNING: vstuc download failed; Unity attach will be unavailable." >&2
    rm -rf "$tmp"
    return 0
  fi

  mkdir -p "$VSTUC_DIR"
  unzip -qo "$tmp/vstuc.vsix" -d "$VSTUC_DIR"
  rm -rf "$tmp"

  if [[ -f "$dll" ]]; then
    echo "  installed:  $dll"
  else
    echo "  WARNING: vstuc extracted but UnityDebugAdapter.dll not found." >&2
  fi
}

# Roslyn analyzers that teach the language server about Unity semantics, so it
# stops suggesting `readonly` on [SerializeField] fields or reporting Unity
# message methods such as Update() as unused.
install_unity_analyzers() {
  local dll="$UNITY_ANALYZER_DIR/Microsoft.Unity.Analyzers.dll"
  if [[ -f "$dll" ]]; then
    echo "  unchanged: $dll"
    return 0
  fi

  local version tmp
  version="$(curl -fsSL https://api.nuget.org/v3-flatcontainer/microsoft.unity.analyzers/index.json \
    | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+"' | tail -1 | tr -d '"')"
  if [[ -z "$version" ]]; then
    echo "  WARNING: could not resolve Microsoft.Unity.Analyzers version." >&2
    return 0
  fi

  tmp="$(mktemp -d)"
  if curl -fsSL -o "$tmp/pkg.nupkg" \
    "https://api.nuget.org/v3-flatcontainer/microsoft.unity.analyzers/$version/microsoft.unity.analyzers.$version.nupkg"; then
    unzip -qo "$tmp/pkg.nupkg" -d "$tmp/x"
    mkdir -p "$UNITY_ANALYZER_DIR"
    cp "$tmp/x/analyzers/dotnet/cs/Microsoft.Unity.Analyzers.dll" "$UNITY_ANALYZER_DIR/"
    echo "  installed:  $dll (v$version)"
  else
    echo "  WARNING: Microsoft.Unity.Analyzers download failed." >&2
  fi
  rm -rf "$tmp"
}

# Ensure a Unity license is active, activating the free Personal one if not.
#
# --accept-eula agrees to Unity's Personal license terms non-interactively. That
# is deliberate: this runs only under the opt-in Unity prompt in run.sh, on a
# machine whose owner asked for it. Return it later with `unity license return`.
#
# Sign-in cannot be automated the same way: `unity auth login` is a browser OAuth
# flow (service-account credentials are the CI alternative), so it is offered
# rather than forced.
ensure_unity_license() {
  local lic_status
  lic_status="$(unity license status --no-banner 2>/dev/null)"

  if grep -q "^License: active" <<<"$lic_status"; then
    echo "  license: already active"
    return 0
  fi

  if ! grep -qi "^Signed in: yes" <<<"$lic_status"; then
    echo "  Not signed in to a Unity account (activation requires one)."
    if prompt_yn "  Run 'unity auth login' now? (opens a browser)"; then
      unity auth login || { echo "  WARNING: sign-in failed." >&2; return 1; }
    else
      echo "  Skipping license activation; run 'unity auth login' then re-run."
      return 1
    fi
  fi

  echo "  activating Unity Personal license (accepting Unity's Personal terms)..."
  if unity license activate --personal --accept-eula --no-banner; then
    echo "  license: activated"
    return 0
  fi

  # A stale session reports "Signed in: yes" but still fails to activate.
  echo "  Activation failed. The session may have expired; try:" >&2
  echo "    unity auth login && unity license activate --personal --accept-eula" >&2
  return 1
}

# Install a Unity Editor via unity-cli. Versions are not pinned, so the
# available releases are listed and chosen interactively; under --yes the
# newest LTS (an "f" release) is taken so unattended runs do not hang.
install_unity_editor() {
  if ! command -v unity >/dev/null 2>&1; then
    echo "  WARNING: unity-cli not installed (unity-cli-bin); skipping editor install." >&2
    return 0
  fi

  local installed
  installed="$(unity editors -i --no-banner --format tsv 2>/dev/null | tail -n +2 | awk 'NF{print $1}')"
  if [[ -n "$installed" ]]; then
    echo "  already installed: $(echo "$installed" | tr '\n' ' ')"
    prompt_yn "  Install an additional Unity Editor?" "n" || return 0
  fi

  local releases
  releases="$(unity editors --releases --no-banner --format tsv 2>/dev/null | tail -n +2 | awk 'NF{print $1}')"
  if [[ -z "$releases" ]]; then
    echo "  WARNING: could not list Unity releases (are you signed in?); skipping." >&2
    return 0
  fi

  local version
  if [[ "${YES_ALL:-0}" == "1" ]]; then
    # Newest stable ("f") release; alpha/beta builds are skipped.
    version="$(echo "$releases" | grep 'f[0-9]*$' | sort -V | tail -1)"
    echo "  auto-selected: $version"
  else
    echo "  available Unity releases:"
    echo "$releases" | nl -w4 -s'. ' | sed 's/^/    /'
    read -r -p "  Version to install (blank to skip): " version
    [[ -z "$version" ]] && { echo "  skipped."; return 0; }
    if ! echo "$releases" | grep -qx "$version"; then
      echo "  WARNING: '$version' is not in the release list; skipping." >&2
      return 0
    fi
  fi

  ensure_unity_license || return 0

  echo "  installing Unity $version (multi-GB, this takes a while)..."
  unity install "$version" --no-banner --non-interactive --accept-eula -y
}

# Write the com.walcht.ide.neovim settings into Unity's global EditorPrefs so a
# fresh machine does not need the Neovim => Settings window filled in by hand.
#
# Unity rewrites this file wholesale when it exits, so any edit made while the
# Editor is running would be silently discarded. Refuse in that case.
configure_unity_prefs() {
  # EditorPrefs live under the XDG *data* dir, not ~/.config/unity3d (which
  # holds Hub state and PlayerPrefs).
  local template="$1" prefs="$HOME/.local/share/unity3d/prefs"

  if [[ ! -f "$template" ]]; then
    echo "  WARNING: template not found: $template" >&2
    return 0
  fi

  # Match process names exactly. `pgrep -f` compares whole command lines and so
  # matches this function's own shell; an unanchored name match catches the
  # long-lived "Unity.Licensing" helper, which runs with no Editor open. The
  # kernel truncates comm to 15 chars, hence the trailing dash on the unity-cli
  # form ("unityhub-unity-editor-6000.3.21f1" -> "unityhub-unity-").
  if pgrep -x "Unity|unityhub-unity-" >/dev/null 2>&1; then
    echo "  WARNING: Unity Editor is running. Quit it and re-run, or Unity will" >&2
    echo "           overwrite these settings on exit. Skipping." >&2
    return 0
  fi

  mkdir -p "$(dirname "$prefs")"
  UNITY_PREFS="$prefs" UNITY_TEMPLATE="$template" python3 - <<'PY'
import base64, os, xml.etree.ElementTree as ET

prefs = os.environ["UNITY_PREFS"]
template = os.environ["UNITY_TEMPLATE"]
key = "NvimUnityConfigJson"

payload = open(template, encoding="utf-8").read().replace("{{HOME}}", os.path.expanduser("~"))
encoded = base64.b64encode(payload.encode("utf-8")).decode("ascii")

if os.path.exists(prefs) and os.path.getsize(prefs) > 0:
    tree = ET.parse(prefs)
    root = tree.getroot()
else:
    root = ET.Element("unity_prefs", {"version_major": "1", "version_minor": "1"})
    tree = ET.ElementTree(root)

node = next((p for p in root.findall("pref") if p.get("name") == key), None)
if node is None:
    node = ET.SubElement(root, "pref", {"name": key, "type": "string"})
    action = "written"
elif node.text == encoded:
    print(f"  unchanged: {key}")
    raise SystemExit(0)
else:
    action = "updated"

node.set("type", "string")
node.text = encoded
tree.write(prefs, encoding="utf-8", xml_declaration=False)
print(f"  {action}:   {key} in {prefs}")
PY
}

# Everything a machine needs to edit Unity C# in Neovim, beyond the packages in
# GAME_DEV: the debug adapter, the Unity-aware analyzers, an Editor, and the
# Neovim integration settings.
setup_unity_dev() {
  local repo_dir="$1"

  echo "  vstuc debug adapter:"
  install_vstuc
  echo "  Unity Roslyn analyzers:"
  install_unity_analyzers
  echo "  Unity Editor:"
  install_unity_editor
  echo "  Neovim integration settings:"
  configure_unity_prefs "$repo_dir/assets/unity/nvim-unity-config.json"

  cat <<'EOF'
  Per-project steps (Unity cannot do these from the CLI):
    1. Add to <project>/Packages/manifest.json dependencies:
         "com.walcht.ide.neovim": "https://github.com/walcht/com.walcht.ide.neovim.git"
    2. Edit > Preferences > External Tools > External Script Editor > Neovim
    3. Neovim > Settings > Regenerate project files
EOF
}

stow_packages() {
  local repo_dir
  repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

  local -a sys_dirs=(etc usr lib lib64 var opt srv run)
  local pkg dir top sys src rel transformed target_path target

  for pkg in "$@"; do
    target="$HOME"

    for dir in "$repo_dir/stow/$pkg"/*/; do
      [[ -d "$dir" ]] || continue
      top="$(basename "$dir")"
      for sys in "${sys_dirs[@]}"; do
        [[ "$top" == "$sys" ]] && { target="/"; break 2; }
      done
    done

    while IFS= read -r -d '' src; do
      rel="${src#"$repo_dir/stow/$pkg/"}"
      transformed="$(printf '%s' "$rel" | sed 's|/dot-|/.|g; s|^dot-|.|')"
      target_path="${target%/}/$transformed"
      if [[ -f "$target_path" && ! -L "$target_path" ]]; then
        [[ "$target" == "/" ]] && sudo rm -f "$target_path" || rm -f "$target_path"
      fi
    done < <(find "$repo_dir/stow/$pkg" -type f -print0)

    if [[ "$target" == "/" ]]; then
      sudo stow --dotfiles --no-folding -R --override='.*' -d "$repo_dir/stow" -t "$target" "$pkg"
    else
      stow --dotfiles --no-folding -R --override='.*' -d "$repo_dir/stow" -t "$target" "$pkg"
    fi
  done
}
