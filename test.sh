#!/bin/sh
# Usage: $0 processor

# Exit immediately upon failure.
set -e

# Switch to test directory, verifying processor first in case it is relative.
processor="`readlink -ve "$1"`"
cd "`dirname "$0"`"

res=0
for test in test/test-*.sh; do
	$test "$processor" || res=$?
done
[ $res = 0 ] && echo "PASS: $@" || echo "FAIL: $@"
exit $res
