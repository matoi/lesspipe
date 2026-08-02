#!/usr/bin/env bash

set -euo pipefail

repository_root=$(cd "$(dirname "$0")/.." && pwd)
lesspipe=${1:-$repository_root/lesspipe.sh}
test_root=$(mktemp -d "${TMPDIR:-/tmp}/lesspipe-colorizer.XXXXXX")
trap 'rm -rf "$test_root"' EXIT

mkdir -p "$test_root/trusted" "$test_root/poisoned"

cat > "$test_root/trusted/bat" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

case " $* " in
  *' --list-languages '*)
    printf '%s\n' 'Bourne Again Shell: bash,sh'
    exit 0
    ;;
  *' --config-file '*)
    exit 0
    ;;
esac

touch "$LESSPIPE_TEST_MARKER"
input=${!#}
printf '\033[31m'
cat -- "$input"
printf '\033[0m'
EOF

cat > "$test_root/poisoned/bat" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

touch "$LESSPIPE_POISON_MARKER"
exit 99
EOF

chmod +x "$test_root/trusted/bat" "$test_root/poisoned/bat"
printf '#!/bin/sh\nprintf "trusted\\n"\n' > "$test_root/example.sh"

export LESS='-R'
export LESSOPEN="|-$lesspipe %s"
export LESSQUIET=1
export LESSCOLORIZER="$test_root/trusted/bat --style=plain"
export LESSPIPE_TEST_MARKER="$test_root/trusted-ran"
export LESSPIPE_POISON_MARKER="$test_root/poisoned-ran"
export PATH="$test_root/poisoned:$PATH"
export TERM=xterm-256color

output=$(less -F -X "$test_root/example.sh")

[[ -e $LESSPIPE_TEST_MARKER ]]
[[ ! -e $LESSPIPE_POISON_MARKER ]]
[[ $output == *$'\033['* ]]

printf '%s\n' 'ok: absolute LESSCOLORIZER path was preserved'
