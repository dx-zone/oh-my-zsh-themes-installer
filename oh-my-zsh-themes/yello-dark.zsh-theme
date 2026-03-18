# Violet Light Zsh Theme — readable on violet backgrounds

typeset -a DESKTOP_CHASSIS_TYPES=(3 6 7 12 13)
typeset -a LAPTOP_CHASSIS_TYPES=(8 9 10 14)

array_contains() {
  local seeking="$1"
  shift
  local item

  for item in "$@"; do
    [[ "$item" == "$seeking" ]] && return 0
  done

  return 1
}

get_device_label() {
  local os_name chassis

  os_name="$(uname -s 2>/dev/null)"

  case "$os_name" in
    Darwin)
      printf ' at'
      ;;
    Linux)
      if [[ -r /sys/class/dmi/id/chassis_type ]]; then
        chassis="$(< /sys/class/dmi/id/chassis_type)"
      else
        chassis=""
      fi

      if array_contains "$chassis" "${DESKTOP_CHASSIS_TYPES[@]}"; then
        printf '⌸ at'
      elif array_contains "$chassis" "${LAPTOP_CHASSIS_TYPES[@]}"; then
        printf '💻 at'
      elif [[ "$chassis" == "5" ]]; then
        printf '🍕 at'
      else
        printf '⌬ at'
      fi
      ;;
    *)
      printf '⌬ at'
      ;;
  esac
}

get_venv_label() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local venv_name
    venv_name="$(basename "$VIRTUAL_ENV")"
    printf ' %%F{white}[venv: %%F{yellow}%s%%F{white}]%%f' "$venv_name"
  fi
}

DEVICE_LABEL="$(get_device_label)"

generate_prompt_path() {
  local user_name="${USER:-$(whoami)}"

  if [[ "$EUID" -eq 0 || "$user_name" == "root" ]]; then
    printf '%%F{red}[ROOT] %%F{white}%s %%F{cyan}%%m %%F{white}in %%F{yellow}%%2~%%f' "$DEVICE_LABEL"
  else
    printf '%%F{white}%s %%F{white}%s %%F{cyan}%%m %%F{white}in %%F{yellow}%%2~%%f' "$user_name" "$DEVICE_LABEL"
  fi
}

# Git prompt styling
ZSH_THEME_GIT_PROMPT_PREFIX="%B%F{white} %F{white}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{white} %f"
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{red}✗✗✗%f"
ZSH_THEME_GIT_PROMPT_CLEAN=" %F{green}✓✓✓%f"

# Ruby prompt styling
ZSH_THEME_RUBY_PROMPT_PREFIX=" %F{white}using %F{yellow}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%f"

# Make the entire visible prompt bold
PROMPT='
%B$(generate_prompt_path) $(git_prompt_info)$(get_venv_label)
%F{white}➜ %f%b'

RPROMPT='%(?.%B%F{green}✔%f%b.%B%F{red}✘%f%b) %B%F{white}[%D{%I:%M:%S%p}]%f%b'

# Set LS_COLORS for better readability on violet backgrounds
export LS_COLORS="di=1;97:fi=97:ln=96:ex=92"