## bash profile

export TERM=xterm-color
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

ver="$(uname -r | awk -F '_' '{ print $1 }')"
export PS1='[$(uname -o) ${ver} $(uname -m)] \W# '

alias ll='ls -la'
alias lh='ls -lah'
