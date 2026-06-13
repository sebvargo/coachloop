#!/usr/bin/env bash
#
# CoachLoop machine check — the gate for "done" (see RUBRIC.md).
# Runs typecheck + lint + the scoring fixture test + a curl of the live URL.
# Exits NON-ZERO if any stage fails. Stages run independently so you see the
# full picture in one pass, not just the first failure.
#
# Usage:   VERIFY_URL=https://your-app.vercel.app bash scripts/verify.sh
#
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

PASS=0
FAIL=0
RESULTS=()

run () {
  local name="$1"; shift
  echo "▶ ${name}"
  if "$@"; then
    echo "  ✓ ${name}"
    RESULTS+=("PASS  ${name}")
    PASS=$((PASS + 1))
  else
    local code=$?
    echo "  ✗ ${name} (exit ${code})"
    RESULTS+=("FAIL  ${name}")
    FAIL=$((FAIL + 1))
  fi
  echo
}

fail_stage () {
  local name="$1"; local msg="$2"
  echo "▶ ${name}"
  echo "  ✗ ${name} — ${msg}"
  RESULTS+=("FAIL  ${name} (${msg})")
  FAIL=$((FAIL + 1))
  echo
}

# 1. Types — requires deps installed (npm install)
run "typecheck" npm run --silent typecheck

# 2. Lint — requires deps installed
run "lint" npm run --silent lint

# 3. Scoring fixture test — zero-dep, runnable any time (Node built-in runner)
run "test (scoring grader)" node --test test/scorer.test.mjs

# 4. Live URL responds
URL="${VERIFY_URL:-}"
if [ -z "${URL}" ]; then
  fail_stage "live url" "VERIFY_URL is not set — point it at the deployed URL"
else
  run "live url (${URL})" curl -fsS -o /dev/null --max-time 15 "${URL}"
fi

echo "──────────── summary ────────────"
for r in "${RESULTS[@]}"; do echo "  ${r}"; done
echo "  ${PASS} passed, ${FAIL} failed"
echo "─────────────────────────────────"

[ "${FAIL}" -eq 0 ]
