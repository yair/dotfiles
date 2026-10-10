#!/bin/sh
# Arms the t3code-autoupdate user timer whenever this script's content
# changes (chezmoi run_onchange_). Armed on every box: the update script is a
# no-op where t3code.service is not installed, so installing t3 later needs
# no re-arm. Bump the version line to force a re-arm on every box.
# version: 1
set -u
command -v systemctl >/dev/null 2>&1 || exit 0
case "$(systemctl --user is-system-running 2>/dev/null)" in
  running|degraded|starting) ;;
  *) echo "chezmoi: no user systemd session — arm t3code-autoupdate.timer by hand later"; exit 0 ;;
esac
systemctl --user daemon-reload
systemctl --user enable --now t3code-autoupdate.timer >/dev/null 2>&1 \
  && echo "chezmoi: t3code-autoupdate.timer armed (hourly 03:00-09:00)" \
  || echo "chezmoi: could not arm t3code-autoupdate.timer — check: systemctl --user status t3code-autoupdate.timer"
