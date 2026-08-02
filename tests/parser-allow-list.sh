#!/usr/bin/env bash
set -euo pipefail

lesspipe=${1:-"$(cd "$(dirname "$0")/.." && pwd)/lesspipe.sh"}
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/lesspipe-allow-list.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT

mkdir "$tmpdir/bin"
cat > "$tmpdir/bin/pandoc" <<'EOF'
#!/usr/bin/env bash
printf 'pandoc-ran\n'
EOF
chmod +x "$tmpdir/bin/pandoc"

cat > "$tmpdir/notebook.ipynb" <<'EOF'
{"cells": [], "metadata": {}, "nbformat": 4, "nbformat_minor": 5}
EOF

run_lesspipe () {
	env PATH="$tmpdir/bin:$PATH" LESS= LESSCOLORIZER= "$@" \
		"$lesspipe" "$tmpdir/notebook.ipynb"
}

legacy=$(run_lesspipe)
[[ $legacy == *pandoc-ran* ]]

disabled=$(run_lesspipe LESSPIPE_ALLOWED_COMMANDS=)
[[ $disabled != *pandoc-ran* ]]
[[ $disabled == *'"nbformat": 4'* ]]

denied=$(run_lesspipe LESSPIPE_ALLOWED_COMMANDS=jq)
[[ $denied != *pandoc-ran* ]]

allowed=$(run_lesspipe LESSPIPE_ALLOWED_COMMANDS='jq,pandoc')
[[ $allowed == *pandoc-ran* ]]
