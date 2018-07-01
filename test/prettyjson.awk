#!/usr/bin/awk -f
BEGIN {
	# define constants
	STRUCTURAL_TOKEN = "^[]{:,}[]"
		# whitespace, punctuator, keyword literal, number, or string
	TOKEN = sprintf(                                                        \
		"[\t\n\r ]+|[]{:,}[]|null|false|true|"                              \
		"-?(0|[1-9][0-9]*)(\\.[0-9]+)?([Ee][+-]?[0-9]+)?|"                  \
		"\"(\\\\[\"\\\\/bfnrt]|\\\\u[0-9a-fA-F]{4}|[^\\%d-\\37\"\\\\])*\"", \

		# ancient awk implementations mishandle NULL characters
		match("", "[\\0]")                                                  \
	)
	MALFORMED = "Non-token input after %d characters: "
	MAX_LINE = 72
	INDENT = "  "

	# be consistent in record splitting
	RS = "\n"

	# minimize work in field splitting
	FS = "^$"

	# tightly control output
	ORS = ""
	OFS = ""

	# define global variables
	invalid = 0
	consumed = 0
	new_line = 0
	indent = ""
}

{
	unconsumed = $0
	$0 = ""
	while ( match(unconsumed, TOKEN) || unconsumed != "" ) {
		if ( invalid || RSTART != 1 ) {
			# capture problematic text
			excess = substr(unconsumed, 1, MAX_LINE)
			sub(/[\n\r].*/, "", excess)

			# generate error message
			err = sprintf(MALFORMED, consumed)
			free = MAX_LINE - length(err)
			if ( free < 5 && length(excess) > free ) {
				err = err "\n" excess
			} else {
				err = err substr(excess, 1, free)
			}

			printf "%s\n", err > "/dev/stderr"
			exit 65 # EX_DATAERR
		}

		# consume token
		token = substr(unconsumed, 1, RLENGTH)
		unconsumed = substr(unconsumed, RLENGTH + 1)
		consumed += RLENGTH

		# skip whitespace (octal \41 is the first non-whitespace non-control character)
		if ( token < "\41" ) continue

		# detect some invalid adjancencies
		if ( unconsumed >= "\41" && unconsumed !~ STRUCTURAL_TOKEN && token !~ STRUCTURAL_TOKEN ) {
			unconsumed = token unconsumed
			consumed -= RLENGTH
			invalid = 1
		}

		# output proper indentation
		if ( token == "]" || token == "}" ) {
			indent = substr(indent, length(INDENT) + 1)
			if ( new_line != "maybe" ) {
				printf "\n%s", indent
			}
		} else if ( new_line ) {
			printf "\n%s", indent
		}

		# output token and remember newline intent
		if ( token == "[" || token == "{" ) {
			printf "%s", token
			indent = indent INDENT
			new_line = "maybe"
		} else if ( token == ":" ) {
			printf ": "
			new_line = 0
		} else {
			printf "%s", token
			new_line = ( token == "," )
		}
	}

	# include trailing newline characters in source indexing
	consumed++
}

END { printf "\n" }
