#!/usr/bin/env bash
#
# install-oh-my-zsh-themes.sh
#
# Description:
#   Install, remove, list, and activate custom Oh My Zsh theme files managed by
#   this repository.
#
# Features:
#   - Interactive confirmation by default
#   - Optional non-interactive mode
#   - Dry-run support
#   - Automatic backup of overwritten files
#   - Install and delete modes
#   - Theme listing support
#   - Optional activation of a selected theme in ~/.zshrc
#   - Optional repository cleanup after successful installation
#   - Clear, human-readable console output
#
# Usage:
#   ./install-oh-my-zsh-themes.sh
#   ./install-oh-my-zsh-themes.sh --yes
#   ./install-oh-my-zsh-themes.sh --dry-run
#   ./install-oh-my-zsh-themes.sh --theme-dir "$HOME/.oh-my-zsh/themes"
#   ./install-oh-my-zsh-themes.sh --delete
#   ./install-oh-my-zsh-themes.sh --list-themes
#   ./install-oh-my-zsh-themes.sh --set-theme mint-dx
#   ./install-oh-my-zsh-themes.sh --clean-up
#   ./install-oh-my-zsh-themes.sh --no-backup
#
# Notes:
#   - Theme files are expected to match: *.zsh-theme
#   - By default, themes are installed into: ~/.oh-my-zsh/themes
#   - Theme activation updates ZSH_THEME="..." in ~/.zshrc
#   - Cleanup only runs after a successful install operation
#

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/oh-my-zsh-themes"
SOURCE_DIR="${SCRIPT_DIR}"
TARGET_DIR="${HOME}/.oh-my-zsh/themes"
ZSHRC_FILE="${HOME}/.zshrc"

DRY_RUN=false
ASSUME_YES=false
CREATE_BACKUP=true
CLEAN_UP=false
DELETE_MODE=false
LIST_ONLY=false
SET_THEME_NAME=""

# ----------------------------- UI helpers ----------------------------- #

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'
  C_CYAN=$'\033[36m'
else
  C_RESET=""
  C_BOLD=""
  C_DIM=""
  C_RED=""
  C_GREEN=""
  C_YELLOW=""
  C_BLUE=""
  C_CYAN=""
fi

log_info() {
  printf "%s[INFO]%s %s\n" "$C_BLUE" "$C_RESET" "$*"
}

log_success() {
  printf "%s[ OK ]%s %s\n" "$C_GREEN" "$C_RESET" "$*"
}

log_warn() {
  printf "%s[WARN]%s %s\n" "$C_YELLOW" "$C_RESET" "$*"
}

log_error() {
  printf "%s[FAIL]%s %s\n" "$C_RED" "$C_RESET" "$*" >&2
}

print_header() {
  local mode="install"

  if [[ "${LIST_ONLY}" == true ]]; then
    mode="list"
  elif [[ "${DELETE_MODE}" == true ]]; then
    mode="delete"
  fi

  cat <<EOF
${C_BOLD}Oh My Zsh Theme Manager${C_RESET}
${C_DIM}Install, remove, list, and activate custom *.zsh-theme files.${C_RESET}

${C_BOLD}Source:${C_RESET} ${SOURCE_DIR}
${C_BOLD}Target:${C_RESET} ${TARGET_DIR}
${C_BOLD}Mode:${C_RESET}   ${mode}

EOF
}

usage() {
  cat <<EOF
Usage:
  ${SCRIPT_NAME} [options]

Options:
  -y, --yes                Run without confirmation prompts
  -n, --dry-run            Show what would be done without making changes
      --no-backup          Do not create backup files before overwriting
  -t, --theme-dir DIR      Target Oh My Zsh themes directory
  -z, --zshrc FILE         Path to the zsh configuration file (default: ~/.zshrc)
  -d, --delete             Remove managed theme files from the target directory
  -L, --list-themes        List repository theme files and exit
  -s, --set-theme THEME    Update ZSH_THEME="..." in ~/.zshrc using the specified theme
  -c, --clean-up           Remove repository theme files and this script after install
  -h, --help               Show this help message

Theme activation:
  --set-theme accepts either:
    - theme name without extension  (example: mint-dx)
    - theme filename with extension (example: mint-dx.zsh-theme)

Examples:
  ${SCRIPT_NAME}
  ${SCRIPT_NAME} --yes
  ${SCRIPT_NAME} --dry-run
  ${SCRIPT_NAME} --list-themes
  ${SCRIPT_NAME} --set-theme mint-dx
  ${SCRIPT_NAME} --theme-dir "\$HOME/.oh-my-zsh/custom/themes"

Exit codes:
  0  Success
  1  Error
EOF
}

confirm() {
  local prompt="${1:-Proceed?}"
  local reply

  if [[ "${ASSUME_YES}" == true ]]; then
    return 0
  fi

  read -r -p "${prompt} [y/N]: " reply
  [[ "${reply}" =~ ^[Yy]([Ee][Ss])?$ ]]
}

backup_file() {
  local file="$1"
  local backup_path="${file}.bak.$(date +%Y%m%d-%H%M%S)"

  if [[ "${DRY_RUN}" == true ]]; then
    log_info "Would back up existing file: ${file} -> ${backup_path}"
  else
    cp -p -- "${file}" "${backup_path}"
    log_info "Backup created: ${backup_path}"
  fi
}

normalize_theme_name() {
  local input="$1"
  input="${input##*/}"
  input="${input%.zsh-theme}"
  printf "%s\n" "${input}"
}

theme_exists_in_repository() {
  local theme_name="$1"
  [[ -f "${SOURCE_DIR}/${theme_name}.zsh-theme" ]]
}

gather_theme_files() {
  local -n _result_ref=$1
  local file

  _result_ref=()

  while IFS= read -r -d '' file; do
    _result_ref+=("$file")
  done < <(find "${SOURCE_DIR}" -maxdepth 1 -type f -name '*.zsh-theme' -print0 | sort -z)
}

list_themes() {
  local theme_files=()
  local file

  gather_theme_files theme_files

  if [[ ${#theme_files[@]} -eq 0 ]]; then
    log_warn "No theme files found in: ${SOURCE_DIR}"
    return 0
  fi

  printf "%sAvailable themes:%s\n" "$C_CYAN" "$C_RESET"
  for file in "${theme_files[@]}"; do
    printf "  - %s\n" "$(basename "${file%.zsh-theme}")"
  done
}

ensure_target_dir() {
  if [[ -d "${TARGET_DIR}" ]]; then
    return 0
  fi

  log_warn "Target directory does not exist: ${TARGET_DIR}"
  if confirm "Create target directory?"; then
    if [[ "${DRY_RUN}" == true ]]; then
      log_info "Would create directory: ${TARGET_DIR}"
    else
      mkdir -p -- "${TARGET_DIR}"
      log_success "Created directory: ${TARGET_DIR}"
    fi
  else
    log_error "Target directory is required for install mode. Aborting."
    exit 1
  fi
}

copy_theme() {
  local src="$1"
  local theme_name
  local dest

  theme_name="$(basename "$src")"
  dest="${TARGET_DIR}/${theme_name}"

  if [[ -e "${dest}" && "${CREATE_BACKUP}" == true ]]; then
    backup_file "${dest}"
  fi

  if [[ "${DRY_RUN}" == true ]]; then
    log_info "Would install: ${theme_name}"
    log_info "  from: ${src}"
    log_info "    to: ${dest}"
  else
    cp -f -- "${src}" "${dest}"
    log_success "Installed: ${theme_name}"
  fi
}

delete_theme() {
  local src="$1"
  local theme_name
  local dest

  theme_name="$(basename "$src")"
  dest="${TARGET_DIR}/${theme_name}"

  if [[ ! -e "${dest}" ]]; then
    log_warn "Not present, skipping: ${theme_name}"
    return 0
  fi

  if [[ "${CREATE_BACKUP}" == true ]]; then
    backup_file "${dest}"
  fi

  if [[ "${DRY_RUN}" == true ]]; then
    log_info "Would remove: ${dest}"
  else
    rm -f -- "${dest}"
    log_success "Removed: ${theme_name}"
  fi
}

set_theme_in_zshrc() {
  local requested_theme="$1"
  local normalized_theme
  local installed_theme_file
  local temp_file

  normalized_theme="$(normalize_theme_name "${requested_theme}")"
  installed_theme_file="${TARGET_DIR}/${normalized_theme}.zsh-theme"

  if ! theme_exists_in_repository "${normalized_theme}"; then
    log_error "Theme not found in repository: ${normalized_theme}"
    log_info "Use --list-themes to view valid theme names."
    exit 1
  fi

  if [[ "${DELETE_MODE}" == true ]]; then
    log_error "--set-theme cannot be used together with --delete."
    exit 1
  fi

  if [[ ! -e "${installed_theme_file}" && "${DRY_RUN}" != true ]]; then
    log_warn "Theme is not installed yet: ${installed_theme_file}"
    log_info "The theme will still be configured in ${ZSHRC_FILE}, but Zsh may fail to load it until installed."
  fi

  if [[ ! -f "${ZSHRC_FILE}" ]]; then
    log_warn "Zsh configuration file does not exist: ${ZSHRC_FILE}"
    if confirm "Create ${ZSHRC_FILE}?"; then
      if [[ "${DRY_RUN}" == true ]]; then
        log_info "Would create file: ${ZSHRC_FILE}"
      else
        : > "${ZSHRC_FILE}"
        log_success "Created file: ${ZSHRC_FILE}"
      fi
    else
      log_error "Cannot activate theme without a zsh configuration file."
      exit 1
    fi
  fi

  if [[ "${CREATE_BACKUP}" == true && -f "${ZSHRC_FILE}" ]]; then
    backup_file "${ZSHRC_FILE}"
  fi

  if grep -Eq '^[[:space:]]*ZSH_THEME="[^"]*"' "${ZSHRC_FILE}" 2>/dev/null; then
    if [[ "${DRY_RUN}" == true ]]; then
      log_info "Would update ZSH_THEME in ${ZSHRC_FILE} to: ${normalized_theme}"
    else
      temp_file="$(mktemp)"
      sed -E 's|^[[:space:]]*ZSH_THEME="[^"]*"|ZSH_THEME="'"${normalized_theme}"'"|' "${ZSHRC_FILE}" > "${temp_file}"
      mv -- "${temp_file}" "${ZSHRC_FILE}"
      log_success "Updated ZSH_THEME in ${ZSHRC_FILE} to: ${normalized_theme}"
    fi
  else
    if [[ "${DRY_RUN}" == true ]]; then
      log_info "Would append ZSH_THEME=\"${normalized_theme}\" to ${ZSHRC_FILE}"
    else
      {
        printf '\n'
        printf 'ZSH_THEME="%s"\n' "${normalized_theme}"
      } >> "${ZSHRC_FILE}"
      log_success "Appended ZSH_THEME=\"${normalized_theme}\" to ${ZSHRC_FILE}"
    fi
  fi

  log_info "Reload your shell with: exec zsh"
}

cleanup_repository() {
  local file
  local removed_count=0

  if [[ "${DELETE_MODE}" == true ]]; then
    log_warn "Cleanup is only applicable after install mode. Skipping cleanup."
    return 0
  fi

  if [[ "${CLEAN_UP}" != true ]]; then
    return 0
  fi

  if ! confirm "Clean up repository theme files and this script from ${SOURCE_DIR}?"; then
    log_warn "Cleanup skipped."
    return 0
  fi

  while IFS= read -r -d '' file; do
    if [[ "${DRY_RUN}" == true ]]; then
      log_info "Would remove repository file: ${file}"
    else
      rm -f -- "${file}"
      log_success "Removed repository file: $(basename "$file")"
    fi
    ((removed_count+=1))
  done < <(find "${SOURCE_DIR}" -maxdepth 1 -type f -name '*.zsh-theme' -print0 | sort -z)

  if [[ "${DRY_RUN}" == true ]]; then
    log_info "Would remove script: ${SCRIPT_DIR}/${SCRIPT_NAME}"
  else
    rm -f -- "${SCRIPT_DIR}/${SCRIPT_NAME}"
    log_success "Removed script: ${SCRIPT_NAME}"
  fi

  ((removed_count+=1))

  if [[ "${DRY_RUN}" == true ]]; then
    log_success "Dry run cleanup complete. ${removed_count} file(s) evaluated."
  else
    log_success "Cleanup complete. ${removed_count} file(s) removed."
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -y|--yes)
        ASSUME_YES=true
        shift
        ;;
      -n|--dry-run)
        DRY_RUN=true
        shift
        ;;
      --no-backup)
        CREATE_BACKUP=false
        shift
        ;;
      -t|--theme-dir)
        [[ $# -lt 2 ]] && {
          log_error "Missing value for --theme-dir"
          exit 1
        }
        TARGET_DIR="$2"
        shift 2
        ;;
      -z|--zshrc)
        [[ $# -lt 2 ]] && {
          log_error "Missing value for --zshrc"
          exit 1
        }
        ZSHRC_FILE="$2"
        shift 2
        ;;
      -d|--delete)
        DELETE_MODE=true
        shift
        ;;
      -L|--list-themes)
        LIST_ONLY=true
        shift
        ;;
      -s|--set-theme)
        [[ $# -lt 2 ]] && {
          log_error "Missing value for --set-theme"
          exit 1
        }
        SET_THEME_NAME="$2"
        shift 2
        ;;
      -c|--clean-up)
        CLEAN_UP=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log_error "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done
}

main() {
  local theme_files=()
  local file
  local count=0
  local action_word="install"

  parse_args "$@"

  if [[ "${LIST_ONLY}" == true ]]; then
    print_header
    list_themes
    exit 0
  fi

  [[ "${DELETE_MODE}" == true ]] && action_word="remove"

  print_header
  gather_theme_files theme_files

  if [[ ${#theme_files[@]} -eq 0 ]]; then
    log_warn "No theme files found in: ${SOURCE_DIR}"
    exit 0
  fi

  if [[ "${DELETE_MODE}" != true ]]; then
    ensure_target_dir
  fi

  printf "%sDiscovered theme files:%s\n" "$C_CYAN" "$C_RESET"
  for file in "${theme_files[@]}"; do
    printf "  - %s\n" "$(basename "$file")"
  done
  echo

  if ! confirm "Proceed to ${action_word} these theme file(s)?"; then
    log_warn "Operation cancelled by user."
    exit 0
  fi

  for file in "${theme_files[@]}"; do
    if [[ "${DELETE_MODE}" == true ]]; then
      delete_theme "${file}"
    else
      copy_theme "${file}"
    fi
    ((count+=1))
  done

  echo
  if [[ "${DRY_RUN}" == true ]]; then
    log_success "Dry run complete. ${count} theme file(s) evaluated."
  else
    if [[ "${DELETE_MODE}" == true ]]; then
      log_success "Completed. ${count} theme file(s) processed for removal."
    else
      log_success "Completed. ${count} theme file(s) installed."
    fi
  fi

  if [[ -n "${SET_THEME_NAME}" ]]; then
    echo
    set_theme_in_zshrc "${SET_THEME_NAME}"
  fi

  cleanup_repository
}

main "$@"