#!/bin/sh
# Usage: $0 processor

# Exit immediately upon failure.
set -e

# Switch to test directory, verifying processor first in case it is relative.
processor="`readlink -ve "$1"`"
cd "`dirname "$0"`"

res=0
for test in whitespace/*; do
	if { "$processor" "$test"/input.json; echo; } | diff -u "$test"/expected.json - ; then
		echo "$test OK"
	else
		res=$?
	fi
done
exit $res
