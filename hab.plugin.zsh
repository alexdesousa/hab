# # Hab zsh plugin
#
# A Hab is a set of exported OS environment variables. This plugin loads the OS
# environment variables set in the file `.envrc` automatically every time you
# `cd` to a folder or open a new pane in TMUX.
#
# It's possible to change the name of the default file base name setting the
# variable `$HAB_BASE` in your .zshrc

##################
# Global variables

export HAB_CURRENT=""
export HAB_MODIFICATION_DATE=""
[ -z "$HAB_BASE" ] && export HAB_BASE=".envrc"

###################
# Private functions

# Prints an error
function __hab_error() {
  local message="$1"

  (>&2 echo -e "\033[1;91m[ERROR]    $message\033[0;0m")
}

# Prints a warning
function __hab_warn() {
  local message="$1"

  (>&2 echo -e "\033[1;93m[WARN]     $message\033[0;0m")
}

# Prints a success message
function __hab_success() {
  local message="$1"

  (echo -e "\033[1;92m[SUCCESS]  $message\033[0;0m")
}

# Gets the name of the env file
function __hab_get_file() {
  local hab_type="$1"
  local current_path=""
  local hab_file=""

  current_path="$(pwd)"

  if [ -n "$hab_type" ] && [ -r "$current_path/$HAB_BASE.$hab_type" ]
  then
    hab_file="$current_path/$HAB_BASE.$hab_type"
  elif [ -n "$hab_type" ] && [ -r "$current_path/$HAB_BASE" ]
  then
    __hab_error "File not found [$current_path/$HAB_BASE.$hab_type]"
    __hab_warn "Using default instead [$current_path/$HAB_BASE]"
    hab_file="$current_path/$HAB_BASE"
  elif [ -r "$current_path/$HAB_BASE" ]
  then
    hab_file="$current_path/$HAB_BASE"
  fi

  echo "$hab_file"
}

# Unloads variables
function __hab_unload_variables() {
  local current_hab="$1"
  local unload=""

  unload=$(
    cat "$current_hab" |
    grep '^export .*$' |
    sed -e 's/^export \([0-9a-zA-Z\_]*\)=.*$/\1/'
  )

  while read -r line
  do
    if [ -n "$line" ]
    then
      unset "$line"
      __hab_warn "Unloaded variable $line"
    fi
  done <<<"$(echo "$unload")"
}

# Unloads functions
function __hab_unload_functions() {
  local current_hab="$1"
  local unload=""

  unload=$(
    cat "$current_hab" |
    grep '^function .*$' |
    sed -e 's/^function \([0-9a-zA-Z\_]*\).*$/\1/'
  )

  while read -r line
  do
    if [ -n "$line" ]
    then
      unset -f "$line"
      __hab_warn "Unloaded function $line"
    fi
  done <<<"$(echo "$unload")"
}

# Unloads current hab
function __hab_unload_current() {
  local unload=""

  if [ -n "$HAB_CURRENT" ] && [ -r "$HAB_CURRENT" ]
  then
    __hab_unload_variables "$HAB_CURRENT"
    __hab_unload_functions "$HAB_CURRENT"
  fi

  export HAB_CURRENT=""
  export HAB_MODIFICATION_DATE=""
}

# Loads new hab
function __hab_load_new() {
  export HAB_CURRENT="$1"
  export HAB_MODIFICATION_DATE=$(date -r "$HAB_CURRENT")

  source "$HAB_CURRENT"
  __hab_success "Loaded hab [$HAB_CURRENT] (Last modified $HAB_MODIFICATION_DATE)"
}

# Updates hab plugin
function __hab_update() {
  if [ -d "$ZSH_CUSTOM/plugins/hab/.git" ]
  then
    (
      cd "$ZSH_CUSTOM/plugins/hab" &&
      git pull origin master
    )
  fi
}

# Unloads current hab
function __hab_unload() {
  __hab_unload_current
}

# Loads a new hab
function __hab_load() {
  local hab_type="$1"
  local hab_file=""

  hab_file=$(__hab_get_file "$hab_type")

  __hab_unload_current

  if [ -n "$hab_file" ]
  then
    __hab_load_new "$hab_file"
  fi
}

# Reloads a hab
function __hab_reload() {
  local hab_type="$(basename "$HAB_CURRENT")"

  hab_type="${hab_type##*.}"
  if [ ".$hab_type" = "$HAB_BASE" ]
  then
    hab_type=""
  fi

  if [ -n "$HAB_CURRENT" ] &&
     [ "$(date -r "$HAB_CURRENT")" != "$HAB_MODIFICATION_DATE" ]
  then
    __hab_load "$hab_type"
  fi
}

# Hab usage
function __hab_usage() {
  echo "\033[1;1mUsage:\033[0;0m

    ~ $ hab [load [environment] | reload | unload | update | help]
"
}

# Hab environment list
function __hab_env_list() {
  local envs=""

  envs=$(
    ls -a .envrc.* |
    sed 's/'$HAB_BASE'\.\(.*\)/\1/g' |
    tr '\n' ' '
  )

  echo "$envs"
}

# Hab completions
function __hab() {
  local current=""
  local previous=""
  local cmd=""
  local cmds="load reload unload update help"
  local envs=""

  COMPREPLY=()
  envs=$(__hab_env_list)
  current="${COMP_WORDS[COMP_CWORD]}"
  previous="${COMP_WORDS[COMP_CWORD - 1]}"

  if [ "$COMP_CWORD" -eq 1 ]
  then
    case "$current" in
      reload | unload | update | help)
        ;;
      load)
        COMPREPLY=($(compgen -W "$envs" -- "$current"))
        ;;
      *)
        COMPREPLY=($(compgen -W "$cmds $envs" -- "$current"))
        ;;
    esac
  elif [ "$COMP_CWORD" -eq  2]
  then
    case "$previous" in
      load)
        COMPREPLY=($(compgen -W "$envs" -- "$current"))
        ;;
      *)
        ;;
    esac
  fi

  return 0
}

##################
# Public functions

# Main hab function.
function hab() {
  local cmd="$1"
  local env="$2"

  if [ -z "$cmd" ]
  then
    cmd="load"
  fi

  case "$cmd" in
    load)
      __hab_load "$env"
      ;;
    reload)
      __hab_reload
      ;;
    unload)
      __hab_unload
      ;;
    update)
      __hab_update
      ;;
    help)
      __hab_usage
      ;;
    *)
      __hab_load "$cmd"
      ;;
  esac
}

##############
# Installation

# Loads hab on `cd`
add-zsh-hook chpwd __hab_load
add-zsh-hook precmd __hab_reload

# Completions
complete -F __hab hab

# Loads hab when starting zsh
__hab_load
