# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

# Keep PATH entries unique
typeset -U path PATH


setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
#bindkey '^[[Z' undo                               # shift + tab undo last action

# enable completion features
#compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
autoload -Uz compinit

compinit
#zstyle ':completion:*' list-suffixes true

autoload -Uz history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end



# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=2000
SAVEHIST=1000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history         # share command history data

setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT


# force zsh to show the complete history
alias history="history 0"

# configure `time` format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'


# function for source
source_if_readable() {
    [[ -r "$1" ]] || return 0
    source "$1"
}


# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


configure_prompt() {
    prompt_symbol=@

    # Skull emoji for root terminal
    #[ "$EUID" -eq 0 ] && prompt_symbol=💀

    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PROMPT=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+(${VIRTUAL_ENV:t})─}(%B%F{%(#.red.blue)}%n'$prompt_symbol$'%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{blue}(*\'д\'%)ノ)%b%F{reset} '
            RPROMPT=

            # Right-side prompt with exit codes and background processes
            #RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'
            ;;

        oneline)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+(${VIRTUAL_ENV:t})}%B%F{%(#.red.blue)}%n@%m%b%F{reset}:%B%F{%(#.blue.green)}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;

        backtrack)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+(${VIRTUAL_ENV:t})}%B%F{red}%n@%m%b%F{reset}:%B%F{blue}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
    esac

}


# The following block is surrounded by two delimiters.
# These delimiters must not be modified. Thanks.
# START KALI CONFIG VARIABLES
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes
# STOP KALI CONFIG VARIABLES

configure_prompt


toggle_oneline_prompt(){
    if [ "$PROMPT_ALTERNATIVE" = oneline ]; then
        PROMPT_ALTERNATIVE=twoline
    else
        PROMPT_ALTERNATIVE=oneline
    fi
    configure_prompt
    zle reset-prompt
}
zle -N toggle_oneline_prompt
bindkey ^P toggle_oneline_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+(${VIRTUAL_ENV:t})}%n@%m: %~\a'
    ;;
*)
    ;;
esac


autoload -Uz add-zsh-hook

update_prompt() {
    print -Pnr -- "$TERM_TITLE"

    if [[ "$NEWLINE_BEFORE_PROMPT" == yes ]]; then
        if [[ -z "$_NEW_LINE_BEFORE_PROMPT" ]]; then
            _NEW_LINE_BEFORE_PROMPT=1
        else
            print
        fi
    fi
}

add-zsh-hook precmd update_prompt


# Color support and aliases
case "$OSTYPE" in
    linux*)
        # GNU dircolors
        if [[ -x /usr/bin/dircolors ]]; then
            if [[ -r "$HOME/.dircolors" ]]; then
                eval "$(dircolors -b "$HOME/.dircolors")"
            else
                eval "$(dircolors -b)"
            fi

            # Fix ls color for directories with 777 permissions
            export LS_COLORS="${LS_COLORS}:ow=30;44:"

            # Use LS_COLORS for completion
            zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
            zstyle ':completion:*:*:kill:*:processes' \
                list-colors '=(#b) #([0-9]#)*=0=01;31'
        fi

        alias ls='ls --color=auto -F'
        alias grep='grep --color=auto'
        alias diff='diff --color=auto'

        # Linux only
        command -v ip >/dev/null && alias ip='ip --color=auto'
        ;;

    darwin*)
        # BSD ls on macOS:
        # -G enables colors
        # -F appends file type indicators
        alias ls='ls -GF'

        # macOS does not provide GNU dircolors/LS_COLORS by default.
        # BSD ls uses LSCOLORS instead.
        # Set LSCOLORS here if you want custom colors.
        # export LSCOLORS='exfxcxdxbxegedabagacad'
        ;;

    *)
        # Generic fallback
        alias ls='ls -F'
        ;;
esac

# Common ls aliases
alias ll='ls -l'
alias la='ls -A'

# less/man colors
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline



# enable command-not-found if installed


source_if_readable /etc/zsh_command_not_found
source_if_readable "$HOME/.local/alias.inc"
source_if_readable "$HOME/.local/path.inc"



[[ -d "$HOME/toolbox/bin" ]] && path=("$HOME/toolbox/bin" $path)


# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && path=("$PYENV_ROOT/bin" $path)

if command -v pyenv >/dev/null; then
    eval "$(pyenv init - zsh)"
fi


if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh)"
fi


export GEF_RC="$HOME/.config/gdb/gef.rc"
alias gdb="gdb -q"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

alias vi="vim"





# SSH Agent
if [[ "$OSTYPE" == "darwin"* ]]; then
    ssh-add --apple-load-keychain 2>/dev/null
else
    SSH_AGENT_FILE="$HOME/.ssh/agent.env"

    _agent_is_running() {
        [[ -n "$SSH_AUTH_SOCK" ]] || return 1
        [[ -S "$SSH_AUTH_SOCK" ]] || return 1
        ssh-add -l &>/dev/null
        [[ $? -ne 2 ]]
    }

    # Use an already available agent first
    if ! _agent_is_running; then
        [[ -r "$SSH_AGENT_FILE" ]] && source "$SSH_AGENT_FILE" >/dev/null
    fi

    # Start a new agent if necessary
    if ! _agent_is_running; then
        ssh-agent -s > "$SSH_AGENT_FILE"
        chmod 600 "$SSH_AGENT_FILE"
        source "$SSH_AGENT_FILE" >/dev/null
        ssh-add
    fi
fi
