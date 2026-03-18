# dx-neoncore.zsh-theme
# Aggressively neon Monokai Spectrum-inspired theme for dark backgrounds

# Terminal background + foreground
# Background: very dark charcoal
# Foreground: bright off-white
#printf '\033]11;#1C1B1A\007\033]10;#F8F8F2\007'  # Very dark charcoal background for maximum neon contrast

# Alternative background shades to experiment with:
#printf '\033]11;#121212\007\033]10;#F8F8F2\007'  # Slightly lighter charcoal
printf '\033]11;#14111B\007\033]10;#F8F8F2\007'   # Slightly more purple-tinged charcoal
#printf '\033]11;#101014\007\033]10;#F8F8F2\007'  # Slightly more blue-tinged charcoal
#printf '\033]11;#121212\007\033]10;#F8F8F2\007'   # Balanced charcoal with a hint of purple, for maximum neon contrast

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
    printf ' %%B%%F{15}[venv: %%F{201}%s%%F{15}]%%f%%b' "$venv_name"
  fi
}

DEVICE_LABEL="$(get_device_label)"

generate_prompt_path() {
  local user_name="${USER:-$(whoami)}"

  if [[ "$EUID" -eq 0 || "$user_name" == "root" ]]; then
    printf '%%B%%F{196}[ROOT] %%F{15}%s %%F{51}%%m %%F{15}in %%F{226}%%2~%%f%%b' "$DEVICE_LABEL"
  else
    printf '%%B%%F{46}%s %%F{15}%s %%F{51}%%m %%F{15}in %%F{226}%%2~%%f%%b' "$user_name" "$DEVICE_LABEL"
  fi
}

# Git prompt styling
# 46  = neon green
# 51  = electric cyan
# 201 = hot magenta
# 226 = laser yellow
# 15  = bright white
# 196 = strong neon red/orange
ZSH_THEME_GIT_PROMPT_PREFIX="%B%F{15} %F{46}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{15} %f%b"
ZSH_THEME_GIT_PROMPT_DIRTY=" %B%F{201}✗✗✗%f%b"
ZSH_THEME_GIT_PROMPT_CLEAN=" %B%F{51}✓✓✓%f%b"




# Ruby prompt styling
ZSH_THEME_RUBY_PROMPT_PREFIX=" %B%F{15}using %F{226}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%f%b"

PROMPT='
%B$(generate_prompt_path) $(git_prompt_info)$(get_venv_label)
%F{201}➜ %f%b'

RPROMPT='%(?.%B%F{46}✔%f%b.%B%F{196}✘%f%b) %B%F{15}[%D{%I:%M:%S%p}]%f%b'

# LS_COLORS tuned for aggressive neon contrast
export LS_COLORS="di=1;51:fi=15:ln=1;201:ex=1;46:*.sh=1;46:*.py=1;46:*.go=1;46:*.rb=1;46:*.js=1;46:*.ts=1;46:*.md=1;226:*.json=1;226:*.yaml=1;226:*.yml=1;226:*.toml=1;226:*.xml=1;226:*.ini=1;226:*.zip=1;196:*.tar=1;196:*.gz=1;196:*.tgz=1;196:*.bz2=1;196:*.xz=1;196"