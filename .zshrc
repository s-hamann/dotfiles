# automatically start X11 when running on TTY 1
if [[ -o login && -t 0 && "${TTY}" == '/dev/tty1' && -z "$DISPLAY" ]] && command -v startx &>/dev/null; then
    exec startx -- "vt${TTY#/dev/tty}"
fi
# Note:
# In order to automatically unlock the gnome keyring, something like the following needs to be added to /etc/pam.d/login
# -----
# # automatically start and unlock gnome keyring
# auth       [default=1 success=ignore] pam_succeed_if.so quiet tty = /dev/tty1 user ingroup users
#   auth       optional pam_gnome_keyring.so
# session    [default=1 success=ignore] pam_succeed_if.so quiet tty = /dev/tty1 user ingroup users
#   session    optional pam_gnome_keyring.so auto_start
# -----

# Completion settings

# Notes:
# zstyle ':completion:function:completer:command:argument:tag'
# <function> is usually blank
# <completer> is the completer used (e.g. complete, correct, ...)
# <command> is the command or -context-

#zstyle ':completion:history-words' list false

# completion cache to speed up slow completions like eix
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${HOME}/.zcompcache"

# insert all expansions for expand completer
#zstyle ':completion:*:expand:*' tag-order all-expansions

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# define files to ignore for zcompile
zstyle ':completion:*:*:zcompile:*' ignored-patterns '(*~|*.zwc)'

# ignore completion functions for commands you don't have:
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

zstyle ':completion:*:*:vi(m|ew):*:*files' ignored-patterns '*.(aux|pdf)'

# ignore parents when completing paths
#zstyle ':completion:*' ignore-parents parent pwd ..

# complete manual by their section
zstyle ':completion:*:manuals'   separate-sections true
zstyle ':completion:*:manuals.*' insert-sections   true

# run rehash on completion so new installed program are found automatically:
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1
}

# correction
# try to be smart about when to use what completer...
zstyle -e ':completion:*' completer '
    if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] ; then
        _last_try="$HISTNO$BUFFER$CURSOR"
        reply=(_complete _match _ignored _prefix _files)
    else
        if [[ $words[1] == (rm|mv) ]] ; then
            reply=(_complete _files)
        else
            reply=(_oldlist _expand _force_rehash _complete _ignored _correct _approximate _files)
        fi
    fi'

# host completion
[[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${(s: :)${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}//,/ }) || _ssh_hosts=()
[[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
    "$_ssh_hosts[@]"
    "$_etc_hosts[@]"
)
zstyle ':completion:*:hosts' hosts $hosts
unset -v _ssh_hosts _etc_hosts hosts

# use generic completion system for programs not yet defined; (_gnu_generic
# works with commands that provide a --help option with "standard" gnu-like
# output.)
for compcom in head mv tail; do
    [[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
done; unset compcom


# source vte.sh, so new tabs in gnome-terminal start in the working directry of the pervious tab
if [[ -e /etc/profile.d/vte.sh ]]; then
    source /etc/profile.d/vte.sh
elif [[ -e /etc/profile.d/vte-2.91.sh ]]; then
    source /etc/profile.d/vte-2.91.sh
fi


# set the vcsh-specific base prompt
zsh_prompt_base[VCSH_REPO_NAME]='%F{yellow}${VCSH_REPO_NAME}%f'


# send a notification if a long-running command finishes
# Note: only set this up if an X session is running
if ( ( [[ -n $DISPLAY ]] && command -v xdotool &>/dev/null ) || ( [[ -n "${WAYLAND_DISPLAY}" ]] && command -v swaymsg &>/dev/null && command -v python &>/dev/null ) ) && command -v notify-send &>/dev/null; then

    # returns 0 iff the shell running this function is in the foreground
    function shell_has_focus {
        if [[ -n "${WAYLAND_DISPLAY}" ]]; then
            local get_focused_pid="
import json, sys
def get_focused_pid(obj):
  if isinstance(obj, dict):
    if obj.get('focused', False) == True:
      print(obj['pid'])
      return
    if 'nodes' in obj:
      get_focused_pid(obj['nodes'])
  elif isinstance(obj, list):
    for item in obj:
      get_focused_pid(item)
get_focused_pid(json.load(sys.stdin))
"
            if [[ "$PPID" != "$(swaymsg -t get_tree | python -c "${get_focused_pid}")" ]]; then
                # active window is not this window
                return 1
            fi
        else
            if [[ "${WINDOWID}" != "$(xdotool getactivewindow)" ]]; then
                # active window is not this window
                return 1
            fi
        fi
        # TODO: get current tab inside the terminal
        if [[ -n "${TMUX}" ]]; then
            # the shell seems to be running inside a tmux session
            # get the active pane of this tmux session
            # Note: using quotes arount the following expression will frag it up
            local active_pane=${${${(f)"$(tmux list-windows -F '#{window_active} #{session_attached} #{pane_id}')"}:#0 *}##* }
            if [[ "${TMUX_PANE}" != "${active_pane}" ]]; then
                return 1
            fi
        fi
        return 0
    }

    function notify_preexec {
        declare -g notify_command="$1"
        declare -g notify_timestamp="$EPOCHSECONDS"
    }

    function notify_postexec {
        # grab the exit code of the last command, needs to be the very first line
        local exit_code=$?
        # check if there was a last command at all
        [[ -z ${notify_command} ]] && return 0
        # calculate how long it did take to finish
        local run_time=$((EPOCHSECONDS - notify_timestamp))

        # check if the command did run for a long time and if the terminal is in the background
        if [[ "${run_time}" -ge "${NOTIFY_THRESHOLD:-15}" ]] && ! shell_has_focus; then
            local title icon
            if [[ "${exit_code}" -eq 0 ]]; then
                title='Command completed'
                icon='dialog-information'
            else
                title='Command failed'
                icon='dialog-warning'
            fi
            notify-send --icon="${icon}" --urgency=low "${title}" "${notify_command}"
        fi

        # clean up the environment
        unset notify_command notify_timestamp
    }

    autoload add-zsh-hook
    add-zsh-hook preexec notify_preexec
    add-zsh-hook precmd notify_postexec
fi

# zsh-syntax-highlighting plugin
zsh_syntax_highlighting_paths=(
"/usr/share/zsh/site-functions/" # Gentoo
"/usr/share/zsh/plugins/zsh-syntax-highlighting/" # Arch Linux
"/usr/share/zsh-syntax-highlighting/" # Debian
)
for p in "${zsh_syntax_highlighting_paths[@]}"; do
    if [[ -f "${p}/zsh-syntax-highlighting.zsh" ]]; then
        source "${p}/zsh-syntax-highlighting.zsh"
        ZSH_SYNTAX_HIGHLIGHTERS=(main brackets)
        break
    fi
done
unset p zsh_syntax_highlighting_paths

# autojump plugin
if [[ -f '/etc/profile.d/autojump.zsh' ]]; then
    source '/etc/profile.d/autojump.zsh'
elif [[ -f '/usr/share/autojump/autojump.zsh' ]]; then
    source '/usr/share/autojump/autojump.zsh'
fi
if whence j &> /dev/null; then
    compdef jo=j
    compdef jc=j
    compdef jco=j
fi


# some aliases
whence xdg-open >/dev/null && alias o=xdg-open
whence sudo >/dev/null && alias sudo='sudo ' # expand aliases after sudo
whence vim >/dev/null && alias vi='vim -p'


# enable syntax highlighting in less
export LESSCOLOR='yes'

# use vim to view man-pages
[[ -e /usr/bin/vimmanpager ]] && export MANPAGER=/usr/bin/vimmanpager

if whence bat >/dev/null; then
    bat='bat'
elif whence batcat >/dev/null; then
    bat='batcat'
fi
if [[ -n "${bat}" ]]; then
    alias cat="${bat}"
    export BAT_PAGER='less -RF'
    export BAT_THEME='gruvbox-dark'
    [[ "$(tput sitm)" != '' ]] && alias bat="${bat} --italic-text=always"
    export MANPAGER="sh -c 'col -bx | ${bat} -l man -p'"
    unset bat
fi

if whence kitty >/dev/null && [[ "${TERM}" == xterm-kitty* ]]; then
    alias kdiff='kitty +kitten diff'
fi

# add completion for python2 and similar symlinks
for pv in /usr/bin/python[0-9]{,.[0-9]}(N); do
    which "${pv#/usr/bin/}" &>/dev/null && compdef "${pv#/usr/bin/}"=python
done
unset pv


function nmap-top-ports() {
    local proto
    if [[ $# -eq 0 || $# -gt 2 ]]; then
        echo "Usage: nmap-top-ports <number> [tcp|udp]" 2>&1
        return 1
    fi
    if [[ -z "$2" || "$2" = "tcp" || "$2" = "TCP" ]]; then
        proto="tcp"
    elif [[ "$2" = "udp" || "$2" = "UDP" ]]; then
        proto="udp"
    else
        echo "Usage: nmap-top-ports <number> [tcp|udp]" 2>&1
        return 1
    fi
    grep "^\S\+\s\+[0-9]\+/${proto}" /usr/share/nmap/nmap-services | sort -nrk 3 | sed "s/^\S\+\s\+\([0-9]\+\)\/${proto}.*/\1/" | head -n $1 | tr '\n' ',' | sed 's/,$//'
}

[[ -e "${HOME}/.zshrc.local" ]] && source "${HOME}/.zshrc.local"

if which tmux &>/dev/null && [[ -n "${SSH_TTY}" && -z "${TMUX}" ]]; then
    tmux has -t main &>/dev/null && tmux attach -t main || tmux new -s main
fi
