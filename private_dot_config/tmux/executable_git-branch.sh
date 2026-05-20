#!/bin/sh
# tmux status-right helper: print 🌿<branch> when in a git repo on a branch,
# nothing otherwise. Called as `#(~/.config/tmux/git-branch.sh '#{pane_current_path}')`.

cd "$1" 2>/dev/null || exit 0
branch=$(git branch --show-current 2>/dev/null) || exit 0
[ -n "$branch" ] && printf '🌿%s ' "$branch"
