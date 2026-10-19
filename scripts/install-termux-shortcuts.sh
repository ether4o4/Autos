#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${PREFIX:?Run this in Termux}"
install -m 755 "$(dirname "$0")/llama-serve" "$PREFIX/bin/llama-serve"
install -m 755 "$(dirname "$0")/gemma-gateway" "$PREFIX/bin/gemma-gateway"
printf 'Installed: llama-serve and gemma-gateway\n'
