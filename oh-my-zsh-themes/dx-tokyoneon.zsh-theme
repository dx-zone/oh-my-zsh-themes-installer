# dx-tokyoneon.zsh-theme
# Tokyo Night base + Monokai neon accents

# Tokyo Night background
printf '\033]11;#1a1b26\007\033]10;#c0caf5\007'

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
    Darwin) printf ' at' ;;
    Linux)
      [[ -r /sys/class/dmi/id/chassis_type ]] && chassis="$(< /sys/class/dmi/id/chassis_type)"
      if array_contains "$chassis" "${DESKTOP_CHASSIS_TYPES[@]}"; then
        printf '⌸ at'
      elif array_contains "$chassis" "${LAPTOP_CHASSIS_TYPES[@]}"; then
        printf '💻 at'
      else
        printf '⌬ at'
      fi
      ;;
    *) printf '⌬ at' ;;
  esac
}

get_venv_label() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local venv_name="$(basename "$VIRTUAL_ENV")"
    printf ' %%F{7}[%%B%%F{5}%s%%b%%F{7}]%%f' "$venv_name"
  fi
}

DEVICE_LABEL="$(get_device_label)"

generate_prompt_path() {
  local user_name="${USER:-$(whoami)}"

  if [[ "$EUID" -eq 0 ]]; then
    printf '%%F{1}[ROOT] %%F{7}%s %%F{6}%%m %%F{8}in %%B%%F{3}%%2~%%b%%f' "$DEVICE_LABEL"
  else
    printf '%%F{2}%s %%F{7}%s %%F{6}%%m %%F{8}in %%B%%F{3}%%2~%%b%%f' "$user_name" "$DEVICE_LABEL"
  fi
}

# Git prompt
ZSH_THEME_GIT_PROMPT_PREFIX="%F{8}<< %B%F{2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%b%F{8} >>%f"
ZSH_THEME_GIT_PROMPT_DIRTY=" %B%F{5}✗✗✗%f%b"
ZSH_THEME_GIT_PROMPT_CLEAN=" %B%F{6}✓✓✓%f%b"

PROMPT='
%B$(generate_prompt_path) $(git_prompt_info)$(get_venv_label)
%F{5}➜ %f%b'

RPROMPT='%(?.%B%F{2}✔%f%b.%B%F{1}✘%f%b) %B%F{7}[%D{%I:%M:%S%p}]%f%b'

# Use system LS_COLORS
eval "$(dircolors -b)"