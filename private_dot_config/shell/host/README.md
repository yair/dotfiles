# Per-host shell overrides

Files here are sourced at the end of `~/.config/shell/env.sh`, keyed by short
hostname (`hostname -s`). Distributed via chezmoi to all machines; each host
only loads its own file (if present). Missing host file = silent no-op.

Naming: `<hostname>.sh`, e.g. `zhizi.sh`, `bakkies.sh`.

For interactive-only host bits, guard inside the file with `[ -n "$PS1" ]`.

For secrets and uncommittable per-machine settings, use
`~/.config/shell/local.sh` instead — chezmoi-ignored, never distributed.
