# fino-custom.zsh-theme
# Terminal customization by Daniel Cruz
function virtualenv_prompt_info {
  [[ -n ${VIRTUAL_ENV} ]] || return
  echo "${ZSH_THEME_VIRTUALENV_PREFIX:=[}${VIRTUAL_ENV:t}${ZSH_THEME_VIRTUALENV_SUFFIX:=]}"
}

function prompt_char {
  command git branch &>/dev/null && echo "±" || echo '○'
}

function box_name {
  local box="${SHORT_HOST:-$HOST}"
  [[ -f ~/.box-name ]] && box="$(< ~/.box-name)"
  echo "${box:gs/%/%%}"
}

#local ruby_env='$(ruby_prompt_info)'
local git_info='$(git_prompt_info)'
local virtualenv_info='$(virtualenv_prompt_info)'
local prompt_char='$(prompt_char)'

# My custom prompt 1 - Example: ➜ MyUser at MyHost in CurrentDir on main ✔
PS1="${FG[226]}➜ ${FG[040]}%n ${FG[239]}at ${FG[033]}$(box_name) ${FG[239]}in %B${FG[226]}%c${git_info} ${ruby_env}${virtualenv_info}
 ${prompt_char}%{$reset_color%} "

RPROMPT="%F{241}%T%f"

# My custom prompt 2 - Example: ➜ MyUser at MyHost in ~/SomeDir/CurrentDir on main ✔
### PS1="${FG[226]}➜ ${FG[040]}%n ${FG[239]}at ${FG[033]}$(box_name) ${FG[239]}in %B${FG[226]}%~%b${git_info} ${ruby_env}${virtualenv_info}
###  ${prompt_char}%{$reset_color%} "

# My custom prompt 3
### PS1="${FG[226]}💾 ${FG[040]}%n ${FG[239]}at ${FG[033]}$(box_name) ${FG[239]}in %B${FG[226]}%~%b${git_info}${ruby_env}${virtualenv_info}
### ╰─${prompt_char}%{$reset_color%} "

ZSH_THEME_GIT_PROMPT_PREFIX=" ${FG[239]}on%{$reset_color%} ${FG[255]}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="${FG[202]} ✘✘✘"
ZSH_THEME_GIT_PROMPT_CLEAN="${FG[040]} ✔"

ZSH_THEME_RUBY_PROMPT_PREFIX=" ${FG[239]}using${FG[243]} ‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%{$reset_color%}"

export VIRTUAL_ENV_DISABLE_PROMPT=1
ZSH_THEME_VIRTUALENV_PREFIX=" ${FG[239]}using${FG[243]} «"
ZSH_THEME_VIRTUALENV_SUFFIX="»%{$reset_color%}"
