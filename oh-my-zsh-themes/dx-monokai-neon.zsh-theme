# dx-monokai-neon.zsh-theme
# Monokai Spectrum inspired, tuned for dark backgrounds and readability

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
    printf ' %%F{white}[venv: %%B%%F{magenta}%s%%b%%F{white}]%%f' "$venv_name"
  fi
}

DEVICE_LABEL="$(get_device_label)"

generate_prompt_path() {
  local user_name="${USER:-$(whoami)}"

  if [[ "$EUID" -eq 0 || "$user_name" == "root" ]]; then
    printf '%%F{red}[ROOT] %%F{white}%s %%F{cyan}%%m %%F{white}in %%B%%F{yellow}%%2~%%b%%f' "$DEVICE_LABEL"
  else
    printf '%%F{green}%s %%F{white}%s %%F{cyan}%%m %%F{white}in %%B%%F{yellow}%%2~%%b%%f' "$user_name" "$DEVICE_LABEL"
  fi
}

# Git prompt styling
# structure = white
# branch = neon green
# dirty = neon pink/magenta
# clean = electric cyan
ZSH_THEME_GIT_PROMPT_PREFIX="%F{white} %B%F{green}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%b%F{white} %f"
ZSH_THEME_GIT_PROMPT_DIRTY=" %B%F{magenta}✗✗✗%f%b"
ZSH_THEME_GIT_PROMPT_CLEAN=" %B%F{cyan}✓✓✓%f%b"

# Ruby prompt styling
ZSH_THEME_RUBY_PROMPT_PREFIX=" %F{white}using %B%F{yellow}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%b%f"

PROMPT='
%B$(generate_prompt_path) $(git_prompt_info)$(get_venv_label)
%F{magenta}➜ %f%b'

RPROMPT='%(?.%B%F{green}✔%f%b.%B%F{red}✘%f%b) %B%F{white}[%D{%I:%M:%S%p}]%f%b'

# Nearly black background with a hint of purple
printf '\033]11;#1E1E1E\007\033]10;#F8F8F2\007'

# Dark alternate background for selection and highlights
#printf '\033]11;#19181A\007\033]10;#F8F8F2\007'
#printf '\033]11;#222222\007\033]10;#F8F8F2\007'
#printf '\033]11;#2D2A2E\007\033]10;#FCFCFA\007'

# LS_COLORS tuned for dark backgrounds
export LS_COLORS="di=1;96:fi=97:ln=1;95:ex=1;92:*.sh=1;92:*.py=1;92:*.go=1;92:*.md=1;93:*.json=1;93:*.yaml=1;93:*.yml=1;93:*.toml=1;93:*.zip=1;91:*.tar=1;91:*.gz=1;91"