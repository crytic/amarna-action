#!/usr/bin/env bash
set -e

# smoelius: `get` works for non-standard variable names like `INPUT_CORPUS-DIR`.
get() {
    env | sed -n "s/^$1=\(.*\)/\1/;T;p"
}

TARGET="$1"
SARIFOUT="$2"
AMARNAVER="$3"
AMARNAARGS="$(get INPUT_AMARNA-ARGS)"

install_amarna()
{
    AMARNAPKG="amarna"
    if [[ -n "$AMARNAVER" ]]; then
        AMARNAPKG="amarna==$AMARNAVER"
        echo "[-] AMARNAVER provided, installing $AMARNAPKG"
    fi

    python3 -m venv /opt/amarna
    export PATH="/opt/amarna/bin:$PATH"
    pip3 install wheel
    pip3 install "$AMARNAPKG"
}

install_amarna

SARIFFLAG=
if [[ -n "$SARIFOUT" ]]; then
    echo "[-] SARIF output enabled, writing to $SARIFOUT."
    echo "::set-output name=sarif::$SARIFOUT"
    SARIFFLAG="-o $SARIFOUT"
fi

if [[ -z "$AMARNAARGS" ]]; then
    amarna "$TARGET" $SARIFFLAG
else
    echo "[-] AMARNAARGS provided. Running amarna with extra arguments"
    printf "%s\n" "$AMARNAARGS" | xargs amarna "$TARGET" $SARIFFLAG
fi
