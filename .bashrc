# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#
## Shell options
#

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# argument to the cd builtin command that is not a directory is assumed to be the
# name of a variable whose value is the directory to change to.
shopt -s cdable_vars

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#
## Set environment variables
#

export EDITOR=vim

# Don't save lines matching the previous history entry
export HISTCONTROL=ignoredups
# The number of commands to remember in the command history
export HISTSIZE=5000
# The maximum number of lines contained in the history file.
export HISTFILESIZE=$HISTSIZE

export JAVA_HOME="/usr/lib/jvm/java-6-sun"

export PYTHONSTARTUP=~/.pystartup

#
# Set path
#

if [ -z $PATH_MODIFIED ]; then

   export PATH=$PATH:/sbin:/usr/sbin
   export PATH=$PATH:~/bin
   export PATH=$PATH:$JAVA_HOME/bin

   export PATH_MODIFIED=1
fi

#
# Load other files
#

function load_file() {
   local file=$1

   if [ -f "$file" ]; then
      source $file
   fi
}

load_file ~/.bash_prompt
load_file ~/.bash_bindings
load_file ~/.bash_cdable
load_file ~/.bash_aliases
load_file ~/.bash_aliases-work
load_file ~/.bash_functions
load_file ~/.bash_completion
load_file /etc/bash_completion

