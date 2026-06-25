# Host-specific env for zhizi (committed, chezmoi-distributed).

# OpenClaw TUI connects to the gateway on bakkies directly over the headscale
# mesh (ws://bakkies:18789) instead of the old SSH tunnel to localhost. The
# tailnet is WireGuard-encrypted end-to-end, so plaintext ws over it carries
# the same guarantee the SSH tunnel did. This flag tells OpenClaw the private
# network is trusted, satisfying its remote-ws safety gate.
export OPENCLAW_ALLOW_INSECURE_PRIVATE_WS=1

# Host location for the Claude Code UserPromptSubmit hook that trys to estimate
# sunrise/sunset times, and injects it as context (with the time of day and
# elapsed time since last turn), so the agent can know roughly what to expect
# with regards to ambient light contamination in Handwave OM measurements.
export CLAUDE_SITE_LAT=41.3275
export CLAUDE_SITE_LON=19.8187
export CLAUDE_SITE_NAME="Tirana"
