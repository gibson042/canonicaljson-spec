#!/bin/sh
# Usage: $0 processor

# Exit immediately upon failure.
set -e

# Switch to test directory, verifying processor first in case it is relative.
processor="`readlink -ve "$1"`"
cd "`dirname "$0"`"

res=0
for test in malformed/*; do
	if "$processor" "$test"/input.json >/dev/null 2>&1 ; then
		res=1
		echo "$test FAIL"
		cat "$test"/input.json
	else
		echo "$test OK"
	fi
done
exit $res
