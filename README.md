# Live Background

Fondos animados para Omarchy. Video en loop, sin audio, desde un archivo o una URL de YouTube.

Si el fondo actual es `X.jpg` y al lado hay un `X.mp4` (o `X.webm`), el plugin reproduce
el video encima. El sistema sigue viendo solo el `.jpg`, así que `omarchy theme bg next`,
el selector de fondos y la pantalla de bloqueo funcionan igual que siempre.

El video solo corre en un monitor cuyo workspace está vacío; con cualquier ventana
encima (o en pantalla completa) se pausa, como el "pausar con otra app maximizada" de
Wallpaper Engine. Medido en una RX 6800: en pausa la GPU queda igual que con un fondo
estático; reproduciendo un 1080p60 cuesta ~6–16 W según cuántos monitores lo muestren.

## Instalar

```bash
omarchy plugin add https://github.com/CristoSolar/omarchy-live-background --enable
ln -s ~/.config/omarchy/plugins/io.github.cristosolar.livebg/bin/livebg ~/.local/bin/livebg
```

Reemplaza al fondo de fábrica (`omarchy.background`). Para volver al original:
`omarchy plugin disable io.github.cristosolar.livebg`.

Requiere `ffmpeg` y, para YouTube, `yt-dlp`.

## Uso

```bash
livebg add ~/Videos/lluvia.mp4
livebg add "https://www.youtube.com/watch?v=..."
```

Copia o descarga el video (YouTube: ≤1080p, solo video, primeros 5 minutos), genera el póster y deja ambos en
`~/.config/omarchy/backgrounds/<tema>/`. Para quitar un fondo, borra los dos archivos.

Para hacerlo a mano, pon `nombre.mp4` y un `nombre.jpg` (cualquier imagen; idealmente el
primer frame) en esa carpeta.

## Límites

- Un decodificador por monitor que esté mostrando el video. Compartir uno no se puede en
  QML puro: `MediaPlayer.videoOutput` acepta una sola salida, `VideoSink` no es creable
  ni expone `setVideoFrame`, y cada monitor es otra ventana. Haría falta un módulo C++.
- No se pausa con la pantalla bloqueada (el estado de bloqueo no es accesible para
  plugins de terceros sin hacer polling).
- Descargar de YouTube va contra sus términos de uso. Si `yt-dlp` falla, actualízalo.
- `Background.qml` es una copia del de fábrica más la capa de video. Si Omarchy lo
  cambia, hay que sincronizarlo.

## Pruebas

```bash
./test.sh
```

## Licencia

MIT
