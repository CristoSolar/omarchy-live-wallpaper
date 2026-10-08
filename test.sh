#!/bin/bash
# Prueba livebg sin red y sin tocar el sistema real: HOME temporal y un
# `omarchy` falso que registra las llamadas a `theme bg set`.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export HOME=$tmp/home
state=$HOME/.local/state/omarchy/current
mkdir -p "$state/theme/backgrounds" "$tmp/bin"
echo "mi-tema" >"$state/theme.name"
touch "$state/theme/backgrounds/1-a.jpg" "$state/theme/backgrounds/2-b.jpg"
cat >"$tmp/bin/omarchy" <<EOF
#!/bin/bash
echo "\$*" >>"$tmp/omarchy.log"
EOF
chmod +x "$tmp/bin/omarchy"
export PATH=$tmp/bin:$PATH

fail() { echo "FAIL: $*" >&2; exit 1; }
livebg() { "$here/bin/livebg" "$@"; }
last_set() { tail -1 "$tmp/omarchy.log" | sed 's/^theme bg set //'; }
dir=$HOME/.local/share/livebg/mi-tema
st=$HOME/.local/state/livebg/mi-tema

ffmpeg -loglevel error -f lavfi -i testsrc=duration=2:size=320x180:rate=10 "$tmp/Mi Video.mp4"
ffmpeg -loglevel error -f lavfi -i testsrc=duration=2:size=320x180:rate=10 -c:v libvpx-vp9 "$tmp/otro.webm"

# set: un video por tema, se activa
livebg set "$tmp/Mi Video.mp4" >/dev/null
v1=$(last_set)
[[ $v1 == "$dir"/video-*.jpg && -s $v1 && -f ${v1%.jpg}.mp4 ]] || fail "set no dejo el par en $dir: $v1"
[[ $(cat "$dir/title") == "Mi Video" ]] || fail "titulo"

# set otra vez: reemplaza (cambia de extension) y no deja restos
sleep 1
livebg set "$tmp/otro.webm" >/dev/null
v2=$(last_set)
[[ $v2 != "$v1" && -f ${v2%.jpg}.webm ]] || fail "reemplazo"
b=$(basename "${v2%.jpg}")
[[ $(ls -A "$dir" | sort | tr '\n' ' ') == "$(printf '%s\n' "$b.jpg" "$b.webm" title | sort | tr '\n' ' ')" ]] ||
  fail "quedaron restos: $(ls -A "$dir")"

# entradas invalidas: no tocan el video vigente
if livebg set "$tmp/no-existe.mp4" 2>/dev/null; then fail "acepto inexistente"; fi
if livebg set "$tmp/omarchy.log" 2>/dev/null; then fail "acepto no-video"; fi
[[ $(ls -A "$dir" | wc -l) -eq 3 ]] || fail "un fallo dejo restos: $(ls -A "$dir")"

# record: el poster del tema es modo video; cualquier otra cosa es imagen
livebg record "$v2"
[[ $(cat "$st/mode") == video ]] || fail "record video"
livebg record "$state/theme/backgrounds/2-b.jpg"
[[ $(cat "$st/mode") == image && $(cat "$st/last-image") == "$state/theme/backgrounds/2-b.jpg" ]] || fail "record image"

# image: vuelve a la ultima imagen; video: activa el del tema
livebg video && [[ $(last_set) == "$v2" ]] || fail "video"
livebg image && [[ $(last_set) == "$state/theme/backgrounds/2-b.jpg" ]] || fail "image con last-image"
rm "$st/last-image"
livebg image && [[ $(last_set) == "$state/theme/backgrounds/1-a.jpg" ]] || fail "image sin last-image usa la primera"

# restore (hook theme-set)
: >"$tmp/omarchy.log"
echo video >"$st/mode"
livebg restore mi-tema && [[ $(last_set) == "$v2" ]] || fail "restore video"
echo image >"$st/mode"; echo "$state/theme/backgrounds/2-b.jpg" >"$st/last-image"
livebg restore mi-tema && [[ $(last_set) == "$state/theme/backgrounds/2-b.jpg" ]] || fail "restore image"
: >"$tmp/omarchy.log"
livebg restore otro-tema
[[ ! -s $tmp/omarchy.log ]] || fail "restore sin estado no debe tocar nada"
echo image >"$st/mode"; echo "/no/existe.jpg" >"$st/last-image"
livebg restore mi-tema
[[ ! -s $tmp/omarchy.log ]] || fail "restore con imagen borrada no debe tocar nada"

# status: lo que lee el menu
livebg record "$v2"
s=$(livebg status)
[[ $(jq -r '.theme, .mode, .hasVideo, .videoTitle' <<<"$s" | tr '\n' ' ') == "mi-tema video true otro " ]] || fail "status: $s"

echo "ok"
