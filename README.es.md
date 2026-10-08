# Omarchy Live Wallpaper

*[Read in English](README.md)*

[![Video](brag-output/brag.jpg)](brag-output/brag.mp4)

Fondos animados para Omarchy: cada tema puede tener **un video** (archivo local o URL de
YouTube) y se elige desde la barra entre la **imagen del tema** o ese video.

- El video corre en loop, sin audio, y **se pausa cuando hay ventanas encima** (como el
  "pausar con otra app maximizada" de Wallpaper Engine). En pausa, la GPU queda igual que
  con un fondo estático; reproduciendo un 1080p60 cuesta ~6–16 W según cuántos monitores
  lo muestren (medido en una RX 6800).
- Al cambiar de tema y volver, se reaplica lo que tenía: su video, o la misma imagen que
  habías elegido.
- La pantalla de bloqueo, `omarchy theme bg next` y el selector de imágenes siguen igual:
  para Omarchy el video es su póster (una imagen).

## Instalar

```bash
omarchy plugin add https://github.com/CristoSolar/omarchy-live-wallpaper --enable
omarchy hook install theme-set ~/.config/omarchy/plugins/io.github.cristosolar.livebg/hooks/theme-set
```

Al habilitarlo, el botón 󰸉 se agrega solo a la derecha de la barra; muévelo con
`omarchy bar move io.github.cristosolar.livebg`. El hook es opcional: sin él todo funciona
salvo que al volver a un tema no se reaplica su video o su imagen.

La interfaz del menú está en español.

Reemplaza al fondo de fábrica (`omarchy.background`). Para volver al original:
`omarchy plugin disable io.github.cristosolar.livebg`.

Requiere `ffmpeg`, `jq` y, para YouTube, `yt-dlp`.

Para desinstalar: `omarchy plugin remove io.github.cristosolar.livebg` y borrar
`~/.config/omarchy/hooks/theme-set.d/theme-set`. Los videos quedan en
`~/.local/share/livebg/` hasta que los borres.

## Uso

Desde la barra: 󰸉 → **Imagen del tema** / **Video** → **Archivo…** o pega una URL de YouTube.

Desde la terminal (`bin/livebg`):

```bash
livebg set ~/Videos/lluvia.mp4                    # asigna/reemplaza el video del tema actual
livebg set "https://www.youtube.com/watch?v=..."  # ≤1080p, solo video, primeros 5 min
livebg video                                      # activa el video del tema
livebg image                                      # vuelve a la última imagen elegida
```

Archivos:
- Video: `~/.local/share/livebg/<tema>/video-<n>.{mp4,webm}` + póster `.jpg`.
- Lo recordado por tema: `~/.local/state/livebg/<tema>/{mode,last-image}`.

## Límites

- Un decodificador por monitor que esté mostrando el video. Compartir uno no se puede en
  QML puro: `MediaPlayer.videoOutput` acepta una sola salida, `VideoSink` no es creable
  ni expone `setVideoFrame`, y cada monitor es otra ventana. Haría falta un módulo C++.
- No se pausa con la pantalla bloqueada (el estado de bloqueo no es accesible para
  plugins de terceros sin hacer polling).
- Al volver a un tema hay un parpadeo: Omarchy pone su imagen por defecto y el hook la
  corrige medio segundo después.
- La descarga de YouTube muestra MB, no porcentaje: con `--download-sections` yt-dlp no
  informa el total.
- Descargar de YouTube va contra sus términos de uso. Si `yt-dlp` falla, actualízalo.
- `Background.qml` es una copia del de fábrica más la capa de video y el estado del
  menú. Si Omarchy lo cambia, hay que sincronizarlo.

## Pruebas

```bash
./test.sh
```

## Licencia

MIT
