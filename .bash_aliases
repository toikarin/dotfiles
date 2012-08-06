#!/usr/bin/env bash

unalias -a

alias tcpdump_www='sudo tcpdump -i eth0 -As 10240'

alias cdd=". ~/bin/find-parent-dir"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias lsl="ls -lhFi"
alias lsa="ls -lahFi"
alias lsll="lsl --color=always | less -R"
alias lsal="lsa --color=always | less -R"

alias ff='find . -iname $*'
alias sd='screen -Udr'
alias se='sudoedit'

alias du1='du -h --max-depth=1'
alias tf='tail -f -n 100'
alias mkdirdate='mkdir $(date +%Y%m%d)'

alias vrecord='ffmpeg -f x11grab -s wxga -r 25 -i :0.0 -sameq'

alias tarsnap-list-archives='sudo tarsnap --configfile /etc/tarsnap.conf --list-archives -vv | sort'
alias tarsnap-list-files='sudo tarsnap --configfile /etc/tarsnap.conf -tv -f'
alias tarsnap-restore-archive='sudo tarsnap --configfile /etc/tarsnap.conf -x -p -f'
alias tarsnap-delete-archive='sudo tarsnap --configfile /etc/tarsnap.conf -d -f'
alias tarsnap-stats='sudo tarsnap --configfile /etc/tarsnap.conf --print-stats'

alias mntssh='sshfs patteri.ath.cx:sshfs /mnt/sshfs/'
alias umntssh='fusermount -u ~/sshfs'
