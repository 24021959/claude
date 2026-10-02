#!/usr/bin/env bash
# Installa notebooklm-py e fa il login. Da eseguire sul proprio computer.
# Uso: ./setup-notebooklm.sh [--cookies <browser>]
set -euo pipefail

BROWSER_COOKIES=""
if [ "${1:-}" = "--cookies" ]; then
  BROWSER_COOKIES="${2:?Indica il browser, es. chrome}"
fi

# Python 3.10+
if ! command -v python3 >/dev/null; then
  echo "Python 3 non trovato. Installa Python 3.10 o superiore." >&2; exit 1
fi
python3 -c 'import sys; sys.exit(sys.version_info < (3, 10))' \
  || { echo "Serve Python 3.10 o superiore." >&2; exit 1; }

EXTRAS="browser"
[ -n "$BROWSER_COOKIES" ] && EXTRAS="browser,cookies"

# Preferisce uv o pipx (evita externally-managed-environment), poi pip
if command -v uv >/dev/null; then
  uv tool install --force "notebooklm-py[$EXTRAS]"
elif command -v pipx >/dev/null; then
  pipx install --force "notebooklm-py[$EXTRAS]"
else
  python3 -m pip install --upgrade "notebooklm-py[$EXTRAS]"
fi

# Login
if [ -n "$BROWSER_COOKIES" ]; then
  notebooklm login --browser-cookies "$BROWSER_COOKIES"
else
  notebooklm login
fi

# Verifica
notebooklm auth check --test --json
echo "Fatto. Il file di login e' una credenziale: non committarlo e non condividerlo."
