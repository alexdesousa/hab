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

###########
# Functions

# Prints an error
function hab_error() {
  local message="$1"

  (>&2 echo -e "\033[1;91m[ERROR]    $message\033[0;0m")
}

# Prints a warning
function hab_warn() {
  local message="$1"

  (>&2 echo -e "\033[1;93m[WARN]     $message\033[0;0m")
}

# Prints a success message
function hab_success() {
  local message="$1"

  (echo -e "\033[1;92m[SUCCESS]  $message\033[0;0m")
}

# Gets the name of the env file
function get_hab_file() {
  local hab_type="$1"
  local current_path=""
  local hab_file=""

  current_path="$(pwd)"

  if [ -n "$hab_type" ] && [ -r "$current_path/$HAB_BASE.$hab_type" ]
  then
    hab_file="$current_path/$HAB_BASE.$hab_type"
  elif [ -n "$hab_type" ] && [ -r "$current_path/$HAB_BASE" ]
  then
    hab_error "File not found [$current_path/$HAB_BASE.$hab_type]"
    hab_warn "Using default instead [$current_path/$HAB_BASE]"
    hab_file="$current_path/$HAB_BASE"
  elif [ -r "$current_path/$HAB_BASE" ]
  then
    hab_file="$current_path/$HAB_BASE"
  fi

  echo "$hab_file"
}

# Unloads variables
function unload_variables() {
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
    hab_warn "Unloaded variable $line"
  done <<<"$(echo "$unload")"
}

# Unloads functions
function unload_functions() {
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
    hab_warn "Unloaded function $line"
  done <<<"$(echo "$unload")"
}

# Unloads current hab
function unload_current_hab() {
  local unload=""

  if [ -n "$CURRENT_HAB" ] && [ -r "$CURRENT_HAB" ]
  then
    unload_variables "$CURRENT_HAB"
    unload_functions "$CURRENT_HAB"
  fi

  export CURRENT_HAB=""
}

# Loads new hab
function load_new_hab() {
  export CURRENT_HAB="$1"
  source "$CURRENT_HAB"
  hab_success "Loaded hab [$CURRENT_HAB]"
}

# Loads a new
function load_hab() {
  local hab_type="$1"
  local hab_file=""

  hab_file=$(get_hab_file "$hab_type")

  unload_current_hab

  if [ -n "$hab_file" ]
  then
    load_new_hab "$hab_file"
  fi
}

##############
# Installation

# Loads hab on `cd`
chpwd_functions=(${chpwd_functions[@]} "load_hab")

# Loads hab when openning a TMUX pane.
[ -n "$TMUX" ] && load_hab
