# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Disable XON/XOFF control characters (ctrl+s to freeze/ctrl+q to resume)
stty -ixon -ixoff

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

PROMPT_DIRTRIM=3
PS1='\[\033[1;33m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

addToPath ()
{
    if [[ ":$PATH:" != *":$1:"* ]]; then
	export PATH="$PATH:$1"
    fi
}

addToPath '/usr/local/go/bin'
addToPath '/opt/nvim-linux-x86_64/bin/'
addToPath '~/scripts'
addToPath '~/.cargo/bin'
addToPath '~/go/bin'

export EDITOR='/opt/nvim-linux64/bin/nvim'

source ~/programming/repos/alacritty/extra/completions/alacritty.bash
source /usr/share/bash-completion/completions/git
source ${HOME}/.cargo/env
source ${HOME}/.deno/env
