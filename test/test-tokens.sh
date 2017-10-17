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
tmp="`mktemp -d XXXXXXXX.$(basename "$0")`"
trap "rm -rf '$tmp' >/dev/null 2>&1 ;"'exit $res' 0

# Switch to the test directory for just long enough to get short test names
wd="`pwd`"
dir="`dirname "$0"`"
cd "$dir"
res=
for test in `find tokens/ -name input.json | env LC_ALL=C sort`; do
	[ x$res = x ] && { res=0 ; cd "$wd"; }
	test="${test%/input.json}"
	if { "$@" "$dir/$test"/input.json | tee "$tmp"/output.json; echo; } |
		diff -q - "$dir/$test"/expected.json ; then

		echo "$test OK"
	else
		res=$?
		"$dir"/prettyjson.awk "$tmp"/output.json > "$tmp"/output.pretty.json
		"$dir"/prettyjson.awk "$dir/$test"/expected.json > "$tmp"/expected.pretty.json
		diff -u "$tmp"/output.pretty.json "$tmp"/expected.pretty.json || true
	fi
done
