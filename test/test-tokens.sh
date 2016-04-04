#!/bin/sh
# Usage: $0 processor

# Exit immediately upon failure.
set -e

# Switch to test directory, verifying processor first in case it is relative.
processor="`readlink -ve "$1"`"
cd "`dirname "$0"`"

# Create and automatically clean up temp space, preserving exit status.
res=70 # EX_SOFTWARE ("internal software error")
tmp="`mktemp -d`"
trap "rm -rf '$tmp' >/dev/null 2>&1 ;"'exit $res' 0

res=0
for test in tokens/*; do
	if { "$processor" "$test"/input.json | tee "$tmp"/canonical; echo; } |
		diff -q "$test"/expected.json - ; then

		echo "$test OK"
	else
		res=$?
		./prettyjson.awk "$test"/expected.json > "$tmp"/expected.json
		./prettyjson.awk "$tmp"/canonical | diff -u "$tmp"/expected.json - || true
	fi
done
