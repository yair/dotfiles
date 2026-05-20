# ~/.config/shell/env.sh — login environment (POSIX, sourced by bash and zsh)
#
# All env vars and PATH live here. Built once, idempotent. Lazy-load tool
# managers; do not eager-source. Guard X-only lines on $DISPLAY so SSH
# sessions (no DISPLAY) load cleanly.
#
# Sourced by:
#   bash:  ~/.profile (login)  and  ~/.bashrc (re-source guarded)
#   zsh:   ~/.zshenv (always, even non-interactive)
#
# Populated incrementally from the line-by-line triage of the legacy ~/.bashrc.

# Re-source guard ------------------------------------------------------------
[ -n "$_SHELL_ENV_LOADED" ] && return 0
_SHELL_ENV_LOADED=1

# PATH helper: prepend $1 to PATH iff it exists and isn't already there ------
_prepend_path() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in *":$1:"*) return 0 ;; esac
    PATH="$1:$PATH"
}

# --- PATH -------------------------------------------------------------------
_prepend_path "$HOME/.local/bin"        # user scripts (brain-mcp, etc.)
# Rust toolchain (rustup/cargo): idempotently adds ~/.cargo/bin to PATH.
# Kept even when not actively writing Rust — intent to return soon.
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# --- Locale -----------------------------------------------------------------
# LANG sets every LC_* category implicitly. We deliberately do NOT set LC_ALL
# (it overrides everything and confuses tools that try to honor per-category
# overrides). LANGUAGE is GNU gettext's message-translation fallback chain.
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"

# --- Editor -----------------------------------------------------------------
export EDITOR=vim
export VISUAL=vim

# --- Project / tool env -----------------------------------------------------
# Cap Node.js heap so Claude Code / TUI tools don't balloon.
export NODE_OPTIONS="--max-old-space-size=4096"

# --- X session (only when DISPLAY is set) -----------------------------------
# Force X11 (not Wayland) backend for GTK apps. Guarded so SSH sessions
# without DISPLAY don't pick up misleading session-type env vars.
if [ -n "$DISPLAY" ]; then
    export XDG_SESSION_TYPE=x11
    export GDK_BACKEND=x11
fi

# --- Host-specific and machine-local overrides (always last) ----------------
# host/<hostname>.sh: per-machine, COMMITTED, distributed via chezmoi.
# local.sh:           per-machine, NEVER committed (chezmoi-ignored). For
#                     secrets, credential paths, and uncommittable one-offs.
_host="$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo unknown)"
[ -r "$HOME/.config/shell/host/$_host.sh" ] && . "$HOME/.config/shell/host/$_host.sh"
[ -r "$HOME/.config/shell/local.sh" ]      && . "$HOME/.config/shell/local.sh"
unset _host

export PATH
