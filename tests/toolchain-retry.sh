#!/usr/bin/env bash
set -euo pipefail
source .github/scripts/retry-network.sh
calls=0; waits=()
sleep() { waits+=("$1"); }
immediate() { calls=$((calls+1)); return 0; }
konaet_retry_network immediate
[[ "$calls" == 1 && "${#waits[@]}" == 0 ]]
calls=0; waits=()
transient() { calls=$((calls+1)); ((calls >= 2)); }
konaet_retry_network transient
[[ "$calls" == 2 && "${waits[*]}" == 5 ]]
calls=0; waits=()
permanent() { calls=$((calls+1)); return 42; }
if konaet_retry_network permanent; then
  echo 'Permanent dependency failure was accepted' >&2; exit 1
else
  [[ "$?" == 42 && "$calls" == 3 && "${waits[*]}" == '5 10' ]]
fi
calls=0; waits=()
literal() { [[ "$#" == 1 && "$1" == 'package=1.2;literal' ]]; }
konaet_retry_network literal 'package=1.2;literal'
echo 'Dependency retry: 4 scenarios passed; pinned arguments and failure status preserved.'
