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

is_installed() { pacman -Qi "$1" &>/dev/null
}

is_group_installed() {
  pacman -Qg "$1" &>/dev/null
}

system_upgrade() {
  local -a args=(-Syu)
  [[ "${YES_ALL:-0}" == "1" ]] && args+=(--noconfirm)
  sudo pacman "${args[@]}"
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

# Microsoft's Visual Studio Tools for Unity debug adapter, used by nvim-dap to
# attach to a running Unity Editor. Not on Mason, so it is pulled straight from
# the marketplace. `dir` must match VSTUC_DIR in
# stow/nvim/.config/nvim/lua/plugins/dap.lua; change both together.
install_vstuc() {
  local dir=~/.local/share/vstuc
  local dll="$dir/content/extension/bin/UnityDebugAdapter.dll"
  if [[ -f "$dll" ]]; then
    echo "  unchanged: $dll"
    return 0
  fi

  local tmp
  tmp="$(mktemp -d)"
  if ! curl -fsSL --compressed -o "$tmp/vstuc.vsix" \
    "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/visualstudiotoolsforunity/vsextensions/vstuc/latest/vspackage"; then
    echo "  WARNING: vstuc download failed; Unity attach will be unavailable." >&2
    rm -rf "$tmp"
    return 0
  fi

  mkdir -p "$dir"
  unzip -qo "$tmp/vstuc.vsix" -d "$dir"
  rm -rf "$tmp"

  if [[ -f "$dll" ]]; then
    echo "  installed:  $dll"
  else
    echo "  WARNING: vstuc extracted but UnityDebugAdapter.dll not found." >&2
  fi
}

# Roslyn analyzers that teach the language server about Unity semantics, so it
# stops suggesting `readonly` on [SerializeField] fields or reporting Unity
# message methods such as Update() as unused. `dir` is what Unity's
# "Add/Remove C# analyzers" points at, and is also baked into
# assets/unity/nvim-unity-config.json; change both together.
install_unity_analyzers() {
  local dir=~/dev/unity/analyzers
  local dll="$dir/Microsoft.Unity.Analyzers.dll"
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
    mkdir -p "$dir"
    cp "$tmp/x/analyzers/dotnet/cs/Microsoft.Unity.Analyzers.dll" "$dir/"
    echo "  installed:  $dll (v$version)"
  else
    echo "  WARNING: Microsoft.Unity.Analyzers download failed." >&2
  fi
  rm -rf "$tmp"
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

  if pgrep -x "Unity|unityhub-unity-" >/dev/null 2>&1; then
    echo "  WARNING: Unity Editor is running. Quit it and re-run, or Unity will" >&2
    echo "           overwrite these settings on exit. Skipping." >&2
    return 0
  fi

  mkdir -p "$(dirname "$prefs")"
  UNITY_PREFS="$prefs" UNITY_TEMPLATE="$template" python3 - <<'PY'
import base64, os, sys, xml.etree.ElementTree as ET

prefs = os.environ["UNITY_PREFS"]
template = os.environ["UNITY_TEMPLATE"]
key = "NvimUnityConfigJson"

payload = open(template, encoding="utf-8").read().replace("{{HOME}}", os.path.expanduser("~"))
encoded = base64.b64encode(payload.encode("utf-8")).decode("ascii")

if os.path.exists(prefs) and os.path.getsize(prefs) > 0:
    try:
        tree = ET.parse(prefs)
    except ET.ParseError as err:
        print(f"  WARNING: {prefs} is malformed ({err}); skipping.", file=sys.stderr)
        raise SystemExit(0)
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

# Point unity-cli at ~/dev/unity/editor so a hand-installed Editor lands there
# rather than in Unity's ~/Unity/Hub/Editor default. Must be set before any
# `unity install`, which is left manual.
set_unity_install_path() {
  if ! command -v unity >/dev/null 2>&1; then
    echo "  WARNING: unity-cli not installed (unity-cli-bin); skipping." >&2
    return 0
  fi

  if unity install-path --set ~/dev/unity/editor --no-banner >/dev/null 2>&1; then
    echo "  install path: ~/dev/unity/editor"
  else
    echo "  WARNING: could not set Unity install path." >&2
  fi
}

# Everything a machine needs to edit Unity C# in Neovim, beyond the packages in
# GAME_DEV: the debug adapter, the Unity-aware analyzers, and the Neovim
# integration settings. The Editor itself is installed by hand.
setup_unity_dev() {
  local repo_dir="$1"

  mkdir -p ~/dev/unity/{editor,projects}
  echo "  vstuc debug adapter:"
  install_vstuc
  echo "  Unity Roslyn analyzers:"
  install_unity_analyzers
  echo "  Unity Editor install path:"
  set_unity_install_path
  echo "  Neovim integration settings:"
  configure_unity_prefs "$repo_dir/assets/unity/nvim-unity-config.json"

  cat <<'EOF'
  Manual steps:
    1. Install a Unity Editor (install path is already set):
         unity auth login && unity license activate --personal
         unity install <version>
  Per-project (Unity cannot do these from the CLI):
    2. Add to <project>/Packages/manifest.json dependencies:
         "com.walcht.ide.neovim": "https://github.com/walcht/com.walcht.ide.neovim.git"
    3. Edit > Preferences > External Tools > External Script Editor > Neovim
    4. Neovim > Settings > Regenerate project files
EOF
}

setup_cs50() {
  install_packages "${CS50[@]}"

  cat <<'EOF'
  Manual steps:
    1. Authorize your GitHub account for submissions once, in a browser.
    2. The first `submit50` run then does the GitHub login interactively;
       there is nothing to configure ahead of time.
  Usage:
    Build with `make50 <program>` (alias in ~/.zshrc), or compile by hand:
      clang foo.c -lcs50 -o foo
EOF
}

stow_packages() {
  local repo_dir
  repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

  local -a sys_dirs=(etc usr lib lib64 var opt srv run)
  local pkg dir top sys src rel target_path target

  for pkg in "$@"; do
    target="$HOME"

    for dir in "$repo_dir/stow/$pkg"/*/; do
      [[ -d "$dir" ]] || continue
      top="$(basename "$dir")"
      for sys in "${sys_dirs[@]}"; do
        [[ "$top" == "$sys" ]] && { target="/"; break 2; }
      done
    done

    # Clear any real file sitting where a symlink needs to go, or stow refuses
    # to adopt the package. Paths are used as-is: packages store literal
    # dotfiles (stow/nvim/.config/...), not stow's dot- prefix form.
    while IFS= read -r -d '' src; do
      rel="${src#"$repo_dir/stow/$pkg/"}"
      target_path="${target%/}/$rel"
      if [[ -f "$target_path" && ! -L "$target_path" ]]; then
        if [[ "$target" == "/" ]]; then
          sudo rm -f "$target_path"
        else
          rm -f "$target_path"
        fi
      fi
    done < <(find "$repo_dir/stow/$pkg" -type f -print0)

    if [[ "$target" == "/" ]]; then
      sudo stow --no-folding -R --override='.*' -d "$repo_dir/stow" -t "$target" "$pkg"
    else
      stow --no-folding -R --override='.*' -d "$repo_dir/stow" -t "$target" "$pkg"
    fi
  done
}
