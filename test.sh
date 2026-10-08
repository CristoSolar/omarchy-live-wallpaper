#!/bin/bash
# Prueba livebg add sin red y sin tocar el sistema real: HOME temporal y un
# `omarchy` falso que registra la llamada a `theme bg set`.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export HOME=$tmp/home
mkdir -p "$HOME/.local/state/omarchy/current" "$tmp/bin"
echo "mi-tema" >"$HOME/.local/state/omarchy/current/theme.name"
cat >"$tmp/bin/omarchy" <<EOF
#!/bin/bash
echo "\$*" >>"$tmp/omarchy.log"
EOF
chmod +x "$tmp/bin/omarchy"
export PATH=$tmp/bin:$PATH

ffmpeg -loglevel error -f lavfi -i testsrc=duration=2:size=320x180:rate=10 "$tmp/Mi Video.mp4"

fail() { echo "FAIL: $*" >&2; exit 1; }
dest=$HOME/.config/omarchy/backgrounds/mi-tema

"$here/bin/livebg" add "$tmp/Mi Video.mp4" >/dev/null
[[ -f $dest/mi-video.mp4 ]] || fail "falta el video"
[[ -s $dest/mi-video.jpg ]] || fail "falta el poster"
grep -qx "theme bg set $dest/mi-video.jpg" "$tmp/omarchy.log" || fail "no fijo el fondo"

"$here/bin/livebg" add "$tmp/Mi Video.mp4" >/dev/null
[[ -f $dest/mi-video-2.mp4 && -f $dest/mi-video-2.jpg ]] || fail "piso un fondo existente"

if "$here/bin/livebg" add "$tmp/no-existe.mp4" 2>/dev/null; then fail "acepto un archivo inexistente"; fi
if "$here/bin/livebg" add "$tmp/omarchy.log" 2>/dev/null; then fail "acepto un archivo que no es video"; fi
[[ $(ls -A "$dest" | wc -l) -eq 4 ]] || fail "quedaron archivos a medias: $(ls -A "$dest")"

echo "ok"
