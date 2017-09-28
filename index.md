# JSON Canonical Form

[RFC 7159](https://tools.ietf.org/html/rfc7159) defines JSON as "a text format for the serialization of structured data", but allows many distinct serializations to describe the _same_ data.
Such human-friendly flexibility can hinder machine treatment of JSON text, particularly when it is used as input for cryptographic hash functions that are expected to yield identical results for logically equivalent input (as is the case in computation of digital signatures).
This specification defines a unique canonical form for any JSON value, the result being safe for comparison (in that logically equivalent structured data have the same canonical form).

## Definition

JSON text in canonical form:
  1. MUST be encoded in [UTF-8](https://tools.ietf.org/html/rfc3629)
  2. MUST NOT include insignificant (i.e., inter-token) whitespace (defined in [section 2 of RFC 7159](https://tools.ietf.org/html/rfc7159#section-2))
  3. MUST order the members of all objects lexicographically by the UCS (Unicode Character Set) codepoints of their names
  4. MUST represent all integer numbers (those with a zero-valued fractional part)
     1. without leading zeroes, and
     2. without a decimal point, and
     3. without an exponent
  5. MUST represent all non-integer numbers in exponential notation
     1. including a nonzero single-digit significand integer part, and
     2. including a nonempty significand fractional part, and
     3. including no trailing zeroes in the significand fractional part (other than one required to satisfy the preceding point), and
     4. including a capital "E", and
     5. including no plus sign in the exponent, and
     6. including no insignificant leading zeroes in the exponent
  6. MUST represent all strings (including object member names) in their minimal-length encoding
     1. avoiding escape sequences for characters except those otherwise inexpressible in JSON (U+0022 QUOTATION MARK, U+005C REVERSE SOLIDUS, and ASCII control characters U+0000 through U+001F), and
     2. using two-character escape sequences for characters that support them:
        * `\b` U+0008 BACKSPACE
        * `\t` U+0009 CHARACTER TABULATION ("tab")
        * `\n` U+000A LINE FEED ("newline")
        * `\f` U+000C FORM FEED
        * `\r` U+000D CARRIAGE RETURN, and
     3. using six-character `\u00xx` lowercase hexadecimal escape sequences for control characters that require escaping but lack a two-character sequence

### Example

```json
{"0":0,"0.1":1.0E-1,"1":1,"10":10,"10.1":1.01E1,"emoji":"😃","escape":"\u001b","whitespace":" \t\n\r"}
```

## Validating implementations

TODO

## Prior Art

This specification updates the expired [JSON Canonical Form internet draft](https://tools.ietf.org/html/draft-staykov-hu-json-canonical-form-00) to ensure a _unique_ canonical representation of every JSON value.

Representation of non-integer numbers still matches the canonical **float** representation from [section 3.2.4.2 of XML Schema Datatypes](https://www.w3.org/TR/xmlschema-2/#float-canonical-representation), but integer numbers now have a non-exponential representation matching **integer** ([section 3.3.13.2](https://www.w3.org/TR/xmlschema-2/#integer-canonical-repr)) and [RFC 7638 JSON Web Key (JWK) Thumbprint](https://tools.ietf.org/html/rfc7638).

The treatment of strings generalizes [section 3.3 of RFC 7638](https://tools.ietf.org/html/rfc7638#section-3.3) and [Keybase canonical JSON packing](https://keybase.io/docs/api/1.0/canonical_packings#json) (both of which cryptographically hash JSON text) to cover the full range of Unicode characters.