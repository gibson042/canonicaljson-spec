#!/bin/sh
# Usage: $0 processor

# Exit immediately upon failure.
set -e

# Verify processor executability.
processor="`which -a "$1" || readlink -ve "$1"`"
shift
set -- "$processor" "$@"

# Switch to the test directory for just long enough to get short test names
wd="`pwd`"
dir="`dirname "$0"`"
cd "$dir"
res=
for test in malformed/*; do
	[ x$res = x ] && { res=0 ; cd "$wd"; }
	if "$@" "$dir/$test"/input.json >/dev/null 2>&1 ; then
		res=1
		echo "$test FAIL"
		cat "$dir/$test"/input.json
	else
		echo "$test OK"
	fi
done
exit $res
