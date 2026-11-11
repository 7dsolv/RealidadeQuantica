#!/usr/bin/env bash
# Bounded retries preserve exit status; never replace pinned dependencies.
konaet_retry_network() {
  local attempt status=1
  for attempt in 1 2 3; do
    if "$@"; then
      return 0
    else
      status=$?
    fi
    if (( attempt < 3 )); then
      printf 'Dependency service unavailable; retry %d/3 in %d seconds.\n' "$attempt" "$((attempt * 5))" >&2
      sleep "$((attempt * 5))"
    fi
  done
  return "$status"
}
