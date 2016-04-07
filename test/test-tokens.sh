#!/bin/sh
# Usage: $0 processor

# Exit immediately upon failure.
set -e

# Verify processor executability.
processor="`which -a "$1" || readlink -ve "$1"`"
shift
set -- "$processor" "$@"

# Create and automatically clean up temp space, preserving exit status.
res=70 # EX_SOFTWARE ("internal software error")
tmp="`mktemp -d`"
trap "rm -rf '$tmp' >/dev/null 2>&1 ;"'exit $res' 0

# Switch to the test directory for just long enough to get short test names
wd="`pwd`"
dir="`dirname "$0"`"
cd "$dir"
res=
for test in tokens/*; do
	[ x$res = x ] && { res=0 ; cd "$wd"; }
	if { "$@" "$dir/$test"/input.json | tee "$tmp"/canonical; echo; } |
		diff -q "$dir/$test"/expected.json - ; then

		echo "$test OK"
	else
		res=$?
		"$dir"/prettyjson.awk "$dir/$test"/expected.json > "$tmp"/expected.json
		"$dir"/prettyjson.awk "$tmp"/canonical | diff -u "$tmp"/expected.json - || true
	fi
done
