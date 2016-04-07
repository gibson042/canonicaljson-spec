#!/bin/sh
# Usage: $0 processor

# Exit immediately upon failure.
set -e

# Verify processor executability.
which "$1" >/dev/null || readlink -ve "$1" >/dev/null

res=0
for test in "`dirname "$0"`"/test/test-*.sh; do
	$test "$@" || res=$?
done
[ $res = 0 ] && echo "PASS: $@" || echo "FAIL: $@"
exit $res
