typeset -U path
path=("$HOME/.local/bin" $path)

# XDG base dirs
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Keep tools out of ~
export npm_config_cache="$XDG_CACHE_HOME/npm"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export COPILOT_HOME="$XDG_CONFIG_HOME/copilot"
