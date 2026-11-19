#!/usr/bin/env bash
# GitHub CI-gated pull deployment for a PUBLIC training repository.
# Installed as root-owned /usr/local/sbin/devops-lab-cd.sh.
set -euo pipefail

REPO="GITHUB_USER/devops-team-lab"  # CHANGE THIS before enabling the timer.
APP_DIR="/home/deploylab/app"
STATE_DIR="/var/lib/devops-lab"
STATE_FILE="$STATE_DIR/last_deployed_sha"

if [[ "$REPO" == GITHUB_USER/* ]]; then
  echo "Replace GITHUB_USER in $0 with your actual GitHub account name" >&2
  exit 1
fi

# The workflow must have finished successfully for the current main SHA.
API_URL="https://api.github.com/repos/$REPO/actions/workflows/ci.yml/runs?branch=main&event=push&status=success&per_page=1"
CI_SHA="$(curl --fail --silent --show-error --location --retry 2 \
  -H 'Accept: application/vnd.github+json' "$API_URL" \
  | jq -r '.workflow_runs[0].head_sha // empty')"
if [[ -z "$CI_SHA" ]]; then
  echo "No successful CI run for a main-branch push yet"
  exit 0
fi

REMOTE_SHA="$(sudo -u deploylab git -C "$APP_DIR" ls-remote origin refs/heads/main | awk '{print $1}')"
if [[ -z "$REMOTE_SHA" ]]; then
  echo "Could not resolve origin/main" >&2
  exit 1
fi
if [[ "$CI_SHA" != "$REMOTE_SHA" ]]; then
  echo "The current main commit has not passed CI; deployment skipped"
  exit 0
fi

mkdir -p "$STATE_DIR"
PREVIOUS_SHA="$(cat "$STATE_FILE" 2>/dev/null || true)"
if [[ "$REMOTE_SHA" == "$PREVIOUS_SHA" ]]; then
  echo "Already deployed: $REMOTE_SHA"
  exit 0
fi

sudo -u deploylab git -C "$APP_DIR" fetch --prune origin main
sudo -u deploylab git -C "$APP_DIR" merge --ff-only origin/main
sudo -u deploylab "$APP_DIR/.venv/bin/python" -m pip install -r "$APP_DIR/requirements.txt"
systemctl restart devops-lab.service

HEALTHY=0
for i in 1 2 3 4 5; do
  if curl --fail --silent --show-error http://127.0.0.1:5055/health >/dev/null; then
    HEALTHY=1
    break
  fi
  sleep 2
done
if [[ "$HEALTHY" -ne 1 ]]; then
  echo "Health check failed. Manual recovery needed; timer should be stopped." >&2
  exit 1
fi
printf '%s\n' "$REMOTE_SHA" > "$STATE_FILE"
echo "Deployed successfully: $REMOTE_SHA"
