# ~/.config/shell/interactive.sh — interactive shell config (bash + zsh shared)
#
# History settings, aliases, completion bootstrap, dynamic-title hook,
# tmux helpers. Shell-specific bits (PS1, bind, shopt, precmd/preexec) live
# in ~/.bashrc and ~/.zshrc.

# Re-source guard ------------------------------------------------------------
[ -n "$_SHELL_RC_LOADED" ] && return 0
_SHELL_RC_LOADED=1

# --- History ----------------------------------------------------------------
# (set during triage)

# --- Aliases ----------------------------------------------------------------
alias whatismyip='dig +short myip.opendns.com @resolver1.opendns.com'
alias dual='autorandr dual'   # switch to saved 'dual' monitor profile (X-only)

# --- Multiplexer helpers ----------------------------------------------------
# Attach-or-create a tmux session by name. Replaces the legacy `za` (zellij).
ta() { tmux new-session -A -s "${1:-default}"; }
