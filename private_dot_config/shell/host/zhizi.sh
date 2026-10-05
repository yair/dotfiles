# Host-specific env for zhizi (committed, chezmoi-distributed).

# Host location for the Claude Code UserPromptSubmit hook that trys to estimate
# sunrise/sunset times, and injects it as context (with the time of day and
# elapsed time since last turn), so the agent can know roughly what to expect
# with regards to ambient light contamination in Handwave OM measurements.
export CLAUDE_SITE_LAT=41.3275
export CLAUDE_SITE_LON=19.8187
export CLAUDE_SITE_NAME="Tirana"
