#!/bin/sh

set -u


DIR="$(dirname $0)"
CMD="${DIR}/../cert-chain-resolver"
TEMP_FILE="$(mktemp)"


(
    set -e

    # it should output certificate bundle in PEM format with certificate from Comodo, PEM leaf, 2x DER intermediate
    $CMD -o "$TEMP_FILE" "$DIR/comodo.crt"
    diff "$TEMP_FILE" "$DIR/comodo.bundle.crt"

    # it should output certificate bundle in PEM format with certificate from Comodo, DER leaf, 2x DER intermediate
    $CMD -o "$TEMP_FILE" "$DIR/comodo.der.crt"
    diff "$TEMP_FILE" "$DIR/comodo.bundle.crt"

    # it should output certificate bundle in PEM format with certificate from GoDaddy, PEM leaf, PEM intermediate
    $CMD -o "$TEMP_FILE" "$DIR/godaddy.crt"
    diff "$TEMP_FILE" "$DIR/godaddy.bundle.crt"

    # it should output certificate bundle in PEM format with certificate with multiple issuer URLs
    $CMD -o "$TEMP_FILE" "$DIR/multiple-issuer-urls.crt"
    diff "$TEMP_FILE" "$DIR/multiple-issuer-urls.bundle.crt"

    # it should output certificate bundle in DER format
    $CMD -d -o "$TEMP_FILE" "$DIR/comodo.crt"
    diff "$TEMP_FILE" "$DIR/comodo.bundle.der.crt"

    # it should output certificate chain in PEM format
    $CMD -i -o "$TEMP_FILE" "$DIR/comodo.crt"
    diff "$TEMP_FILE" "$DIR/comodo.chain.crt"

    # it should output certificate chain in DER format
    $CMD -d -i -o "$TEMP_FILE" "$DIR/comodo.crt"
    diff "$TEMP_FILE" "$DIR/comodo.chain.der.crt"

    # it should output certificate bundle in PEM format, with input from stdin and output to stdout
    $CMD < "$DIR/comodo.crt" > "$TEMP_FILE"
    diff "$TEMP_FILE" "$DIR/comodo.bundle.crt"

    # Append CA root cert to output
    $CMD -s < "$DIR/comodo.crt" > "$TEMP_FILE"
    diff "$TEMP_FILE" "$DIR/comodo.withca.crt"

    # Already has CA root cert
    $CMD -s < "$DIR/multiple-issuer-urls.crt" > "$TEMP_FILE"
    diff "$TEMP_FILE" "$DIR/multiple-issuer-urls.bundle.crt"

    # DST Root CA X3, PKCS#7 package
    $CMD < "$DIR/dstrootcax3.p7c" > "$TEMP_FILE"
    diff "$TEMP_FILE" "$DIR/dstrootcax3.pem"

    # it should detect invalid certificate
    (! echo "xxx" | $CMD)
)
STATUS="$?"


rm -f "$TEMP_FILE"

exit "$STATUS"
