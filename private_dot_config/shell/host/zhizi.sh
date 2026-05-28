# Host-specific env for zhizi (committed, chezmoi-distributed).

# OpenClaw TUI connects to the gateway on bakkies directly over the headscale
# mesh (ws://bakkies:18789) instead of the old SSH tunnel to localhost. The
# tailnet is WireGuard-encrypted end-to-end, so plaintext ws over it carries
# the same guarantee the SSH tunnel did. This flag tells OpenClaw the private
# network is trusted, satisfying its remote-ws safety gate.
export OPENCLAW_ALLOW_INSECURE_PRIVATE_WS=1
