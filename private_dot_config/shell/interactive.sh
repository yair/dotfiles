# ~/.config/shell/interactive.sh — interactive shell config (bash + zsh shared)
#
# History settings, aliases, completion bootstrap, dynamic-title hook,
# tmux helpers. Shell-specific bits (PS1, bind, shopt, precmd/preexec) live
# in ~/.bashrc and ~/.zshrc.

# Re-source guard ------------------------------------------------------------
[ -n "$_SHELL_RC_LOADED" ] && return 0
_SHELL_RC_LOADED=1

# --- History (shared) -------------------------------------------------------
# Both bash and zsh honor HISTSIZE for the in-memory history list.
# File size, sync, ignore-rules, and timestamping are shell-specific and live
# in .bashrc / .zshrc.
HISTSIZE=65535

# --- less / lesspipe --------------------------------------------------------
# Make `less` handle archives, PDFs, images, etc. Works in bash and zsh.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# --- X session tweaks (only when DISPLAY is set) ----------------------------
# Disable the X server bell. Cheap to re-run each shell; idempotent.
if [ -n "$DISPLAY" ] && command -v xset >/dev/null 2>&1; then
    xset b 0 2>/dev/null
fi

# --- Color output -----------------------------------------------------------
# Populate LS_COLORS with the dircolors scheme (full palette: dirs, executables,
# symlinks, archives, etc.). ~/.dircolors overrides the built-in defaults if
# present. Legacy used to clobber this with LS_COLORS='di=33;1' (bold yellow
# dirs only) -- a workaround for a long-dead unreadable-dark-blue terminal.
if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
fi

# --- Aliases ----------------------------------------------------------------
# Aliases live in ~/.aliases (shared, both shells). Add new ones there.
[ -r "$HOME/.aliases" ] && . "$HOME/.aliases"

# --- Multiplexer helpers ----------------------------------------------------
# tmux session helper (replaces legacy `za` for zellij):
#   ta         -> list existing sessions
#   ta NAME    -> attach to session NAME, creating it if absent
ta() {
    [ -z "$1" ] && { tmux ls 2>/dev/null || echo "no tmux sessions"; return; }
    tmux new-session -A -s "$1"
}

# --- Fortune (last; the shell-start flourish) -------------------------------
# 20+ year tradition. Guarded so it no-ops on machines without fortune.
if [ -x /usr/games/fortune ]; then
    echo
    echo '                                   >-O-<'
    echo
    /usr/games/fortune
    echo '                                     _'
    echo '                                    / \'
    echo '                                   <-O->'
fi
