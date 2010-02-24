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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#
## Set environment variables
#

# Don't save lines matching the previous history entry
export HISTCONTROL=ignoredups
# The number of commands to remember in the command history
export HISTSIZE=5000
# The maximum number of lines contained in the history file.
export HISTFILESIZE=$HISTSIZE

export JAVA_HOME="/usr/lib/jvm/java-6-sun"
export PATH=$PATH:~/bin:$JAVA_HOME/bin


#
# Load other files
#

if [ -f ~/.bash_prompt ]; then
   . ~/.bash_prompt
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functons ]; then
   . ~/.bash_functions
fi

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

