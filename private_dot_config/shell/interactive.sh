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

# --- chezmoi edit-sync ------------------------------------------------------
# Cure the "edit a managed dotfile, forget chezmoi, let it drift until little
# merge barnacles grow" habit. `vim` is wrapped so that AFTER you edit a
# chezmoi-managed file and quit, it offers to re-add + commit + push that
# change. No-op for unmanaged or unchanged files, so ordinary editing is
# untouched. The override exists only in interactive shells (this file isn't
# sourced by non-interactive ones), and anything that execs the editor binary
# (git commit, sudoedit, ...) never sees the function.
#
#   vim ~/.bashrc   edit, :wq -> prompted for a commit message. Empty line or
#                   Ctrl-C skips (the edit stays in place, just unsynced); a
#                   message re-adds, commits, and pushes.
#   vim notes.txt   not managed -> nothing happens.
#   czsync [msg]    flush ALL locally-modified managed files in one commit
#                   (for edits made outside this wrapper).

# Re-add + commit + push the given absolute target paths as one commit.
_chezmoi_commit() {
    printf '\n[chezmoi] managed change(s):\n'
    printf '    %s\n' "$@"
    printf '  commit message (empty / Ctrl-C to skip): '
    _msg=""
    IFS= read -r _msg || { printf '\n[chezmoi] skipped — not synced.\n'; return 0; }
    [ -n "$_msg" ] || { printf '[chezmoi] skipped — not synced.\n'; return 0; }
    chezmoi re-add -- "$@"           || { printf '[chezmoi] re-add failed.\n'; return 1; }
    chezmoi git -- add -A            || return 1
    chezmoi git -- commit -m "$_msg" || { printf '[chezmoi] commit failed.\n'; return 1; }
    if chezmoi git -- push; then
        printf '[chezmoi] re-added, committed & pushed ✓\n'
    else
        printf '[chezmoi] committed locally; push failed — run: chezmoi git -- push\n'
    fi
}

# Inspect the files just edited; sync the managed+changed ones.
_chezmoi_after_edit() {
    command -v chezmoi >/dev/null 2>&1 || return 0
    _changed=""
    for _f in "$@"; do
        case "$_f" in -*|+*) continue ;; esac        # skip editor flags (+N, -c, …)
        [ -f "$_f" ] || continue                      # skip non-files
        _abs=$(cd -- "$(dirname -- "$_f")" 2>/dev/null && printf '%s/%s' "$(pwd)" "$(basename -- "$_f")") || continue
        _src=$(chezmoi source-path -- "$_abs" 2>/dev/null) || continue   # unmanaged -> skip
        case "$_src" in
            *.tmpl|*encrypted_*)
                printf '[chezmoi] %s is templated/encrypted — sync by hand: chezmoi edit --apply %s\n' "$_f" "$_abs"
                continue ;;
        esac
        [ -n "$(chezmoi status -- "$_abs" 2>/dev/null)" ] && _changed="$_changed $_abs"
    done
    [ -n "$_changed" ] && _chezmoi_commit $_changed
    return 0
}

vim() {
    command vim "$@"
    _rc=$?
    _chezmoi_after_edit "$@"
    return $_rc
}

# Flush every locally-modified managed file (for edits made outside `vim`).
czsync() {
    command -v chezmoi >/dev/null 2>&1 || { printf 'chezmoi not found\n'; return 1; }
    _st=$(chezmoi status 2>/dev/null)
    [ -n "$_st" ] || { printf '[chezmoi] clean — nothing to sync.\n'; return 0; }
    # Status col 1 = home-vs-last-written: non-space => locally modified (re-add).
    _readd=$(printf '%s\n' "$_st" | awk 'substr($0,1,1)!=" "' | cut -c4-)
    # col 1 space but col 2 non-space => behind source (pulled, needs `apply`).
    _apply=$(printf '%s\n' "$_st" | awk 'substr($0,1,1)==" " && substr($0,2,1)!=" "' | cut -c4-)
    [ -n "$_apply" ] && printf '[chezmoi] behind source — run `chezmoi apply`:\n%s\n' "$_apply"
    [ -n "$_readd" ] || { printf '[chezmoi] no locally-modified managed files.\n'; return 0; }
    _abs=""
    while IFS= read -r _p; do
        [ -n "$_p" ] && _abs="$_abs $HOME/$_p"
    done <<EOF
$_readd
EOF
    _chezmoi_commit $_abs
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
