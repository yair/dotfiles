#!/bin/sh
# Arms the chezmoi-autoupdate user timer whenever this script's content
# changes (chezmoi run_onchange_). Idempotent; silent no-op where there is
# no user systemd. Bump the version line to force a re-arm on every box.
# version: 2
set -u
command -v systemctl >/dev/null 2>&1 || exit 0
systemctl --user is-system-running >/dev/null 2>&1 || { echo "chezmoi: no user systemd session — arm chezmoi-autoupdate.timer by hand later"; exit 0; }
systemctl --user daemon-reload
systemctl --user enable --now chezmoi-autoupdate.timer >/dev/null 2>&1 \
  && echo "chezmoi: chezmoi-autoupdate.timer armed (every 30 min)" \
  || echo "chezmoi: could not arm chezmoi-autoupdate.timer — check: systemctl --user status chezmoi-autoupdate.timer"
if [ "$(loginctl show-user "$(id -un)" -p Linger --value 2>/dev/null)" != "yes" ]; then
  echo "chezmoi: NOTE lingering is off — the timer only runs while you are logged in. Headless box? run: sudo loginctl enable-linger $(id -un)"
fi
