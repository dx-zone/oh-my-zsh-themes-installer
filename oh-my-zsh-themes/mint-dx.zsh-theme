# Mint Custom Zsh Theme
#
# Original author: Falcon aka 草 <x@xtl.tw> (www.xtl.tw)
# Original theme: mint
# Source: https://github.com/FalconLee1011/mint-zsh-theme/blob/main/mint.zsh-theme
#
# Customized by: dx (https://github.com/dx-zone)
#
# Notes:
# - This version preserves the visual spirit of the original Mint theme
#   while improving reliability, readability, and prompt performance.
# - Device detection supports macOS directly and Linux chassis-based
#   classification when DMI information is available.

typeset -a DESKTOP_CHASSIS_TYPES=(3 6 7 12 13)
typeset -a LAPTOP_CHASSIS_TYPES=(8 9 10 14)

# Determine whether the provided value exists in the given array.
# Usage: array_contains <value> "${array[@]}"
array_contains() {
  local seeking="$1"
  shift
  local item

  for item in "$@"; do
    [[ "$item" == "$seeking" ]] && return 0
  done

  return 1
}

# Return a device label appropriate for the current machine.
# macOS returns an Apple symbol directly.
# Linux attempts chassis-based detection using DMI metadata.
get_device_label() {
  local os_name chassis

  os_name="$(uname -s 2>/dev/null)"

  case "$os_name" in
    Darwin)
      echo " at"
      return
      ;;
    Linux)
      if [[ -r /sys/class/dmi/id/chassis_type ]]; then
        chassis="$(< /sys/class/dmi/id/chassis_type)"
      else
        chassis=""
      fi

      if array_contains "$chassis" "${DESKTOP_CHASSIS_TYPES[@]}"; then
        echo "⌸ at"
      elif array_contains "$chassis" "${LAPTOP_CHASSIS_TYPES[@]}"; then
        echo "💻 at"
      elif [[ "$chassis" == "5" ]]; then
        echo "🍕 at"
      else
        echo "⌬ at"
      fi
      return
      ;;
    *)
      echo "⌬ at"
      return
      ;;
  esac
}

# Cache device label once when the theme is loaded to avoid repeating
# system checks on every prompt render.
DEVICE_LABEL="$(get_device_label)"

# Build the left prompt path segment.
# Root is highlighted more aggressively for visibility and safety.
generate_prompt_path() {
  local user_name="${USER:-$(whoami)}"

  if [[ "$EUID" -eq 0 || "$user_name" == "root" ]]; then
    echo "%{$FG[009]%}[ROOT] %{$FG[239]%}${DEVICE_LABEL} %{$FG[157]%}%m %{$FG[239]%}in %{$FG[159]%}%B%1~%b"
  else
    echo "%{$FG[081]%}${user_name} %{$FG[239]%}${DEVICE_LABEL} %{$FG[157]%}%m %{$FG[239]%}in %{$FG[159]%}%B%1~%b"
  fi
}

# Git prompt styling
ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[190]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✘✘✘%f"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%f"

# Ruby prompt styling
ZSH_THEME_RUBY_PROMPT_PREFIX=" %{$FG[239]%}using %{$FG[243]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%{$reset_color%}"

# Primary prompt:
# - First line: user, device, host, directory, and Git information
# - Second line: prompt character
PROMPT='
$(generate_prompt_path) $(git_prompt_info)
➜ '

# Right prompt:
# - Displays command result status
# - Displays current local time in 12-hour format
RPROMPT='%(?.%{$FG[118]%}✔%f.%{$FG[196]%}✘%f) [%D{%I:%M:%S%p}]'
