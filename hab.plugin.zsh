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

export CURRENT_HAB=""
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
    unset "$line"
    __hab_warn "Unloaded variable $line"
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
    unset -f "$line"
    __hab_warn "Unloaded function $line"
  done <<<"$(echo "$unload")"
}

# Unloads current hab
function __hab_unload_current() {
  local unload=""

  if [ -n "$CURRENT_HAB" ] && [ -r "$CURRENT_HAB" ]
  then
    __hab_unload_variables "$CURRENT_HAB"
    __hab_unload_functions "$CURRENT_HAB"
  fi

  export CURRENT_HAB=""
}

# Loads new hab
function __hab_load_new() {
  export CURRENT_HAB="$1"
  source "$CURRENT_HAB"
  __hab_success "Loaded hab [$CURRENT_HAB]"
}

##################
# Public functions

# Updates hab plugin
function hab_update() {
  if [ -d "$ZSH_CUSTOM/plugins/hab/.git" ]
  then
    (
      cd "$ZSH_CUSTOM/plugins/hab" &&
      git pull origin master
    )
  fi
}

# Unloads current hab
function hab_unload() {
  __hab_unload_current
}

# Loads a new hab
function hab_load() {
  local hab_type="$1"
  local hab_file=""

  hab_file=$(__hab_get_file "$hab_type")

  hab_unload

  if [ -n "$hab_file" ]
  then
    __hab_load_new "$hab_file"
  fi
}

##############
# Installation

# Loads hab on `cd`
chpwd_functions=(${chpwd_functions[@]} "hab_load")

# Loads hab when openning a TMUX pane.
[ -n "$TMUX" ] && hab_load
