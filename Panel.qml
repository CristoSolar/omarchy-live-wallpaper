import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui

// Menu de fondo por tema: imagen del tema o video. Toda accion la ejecuta el
// servicio; este panel solo muestra `service.status` y llama sus funciones.
Panel {
  id: root
  moduleName: "io.github.cristosolar.livebg"
  ipcTarget: "io.github.cristosolar.livebg"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property var service: null
  readonly property var barIdentity: hostWidget || root

  readonly property var st: service ? service.status : ({})
  readonly property string theme: st.theme || ""
  readonly property bool hasVideo: st.hasVideo === true
  readonly property bool videoActive: hasVideo && st.current === st.poster
  readonly property bool busy: service ? service.busy : false
  property bool addOpen: false

  function baseName(path) {
    var name = String(path || "").split("/").pop()
    return name.replace(/\.[^.]+$/, "")
  }

  onOpenedChanged: if (!opened) { addOpen = false; urlField.text = "" }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(column.implicitHeight + 2 * Style.spacing.panelPadding)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      // Con el campo de URL enfocado, las teclas son del campo.
      blocked: urlField.activeFocus
      onCloseRequested: root.close()

      ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Style.spacing.panelPadding
        spacing: Style.spacing.md

        Text {
          Layout.fillWidth: true
          textFormat: Text.PlainText
          text: "Fondo · " + root.theme
          color: Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.subtitle
          font.bold: true
          elide: Text.ElideRight
        }

        // --- Imagen del tema ---
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.sm
          Button {
            Layout.fillWidth: true
            leftAlign: true
            text: (root.videoActive ? "○  " : "●  ") + "Imagen del tema"
            foreground: Color.foreground
            onClicked: if (root.service && root.videoActive) root.service.useImage()
          }
          Button {
            text: "Elegir…"
            bordered: true
            foreground: Color.foreground
            onClicked: {
              if (root.service) root.service.pickImage()
              root.close()
            }
          }
        }
        Text {
          Layout.fillWidth: true
          Layout.leftMargin: Style.space(24)
          textFormat: Text.PlainText
          text: root.baseName(root.videoActive ? root.st.lastImage : root.st.current) || "la primera del tema"
          color: Color.muted
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          elide: Text.ElideMiddle
        }

        // --- Video ---
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.sm
          Button {
            Layout.fillWidth: true
            leftAlign: true
            text: (root.videoActive ? "●  " : "○  ") + "Video"
            foreground: Color.foreground
            opacity: root.hasVideo ? 1 : 0.4
            onClicked: if (root.service && root.hasVideo && !root.videoActive) root.service.useVideo()
          }
          Button {
            visible: root.hasVideo
            text: root.addOpen ? "Cancelar" : "Cambiar…"
            bordered: true
            foreground: Color.foreground
            onClicked: root.addOpen = !root.addOpen
          }
        }
        Text {
          Layout.fillWidth: true
          Layout.leftMargin: Style.space(24)
          textFormat: Text.PlainText
          text: root.hasVideo ? (root.st.videoTitle || "video") : "sin video"
          color: Color.muted
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          elide: Text.ElideRight
        }

        // --- Asignar video ---
        ColumnLayout {
          Layout.fillWidth: true
          visible: !root.hasVideo || root.addOpen || root.busy
          spacing: Style.spacing.sm

          Text {
            Layout.fillWidth: true
            visible: root.hasVideo
            textFormat: Text.PlainText
            text: "Reemplaza el video actual de este tema."
            color: Color.muted
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.Wrap
          }
          RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacing.sm
            Button {
              text: "Archivo…"
              bordered: true
              foreground: Color.foreground
              opacity: root.busy ? 0.4 : 1
              onClicked: if (root.service && !root.busy) root.service.pickVideoFile()
            }
            TextField {
              id: urlField
              Layout.fillWidth: true
              foreground: Color.foreground
              placeholderText: "URL de YouTube"
              enabled: !root.busy
              onAccepted: download.clicked()
            }
            Button {
              id: download
              text: "↓"
              bordered: true
              foreground: Color.foreground
              opacity: urlField.text.trim() && !root.busy ? 1 : 0.4
              onClicked: {
                if (!root.service || root.busy || !urlField.text.trim()) return
                root.service.setVideo(urlField.text)
                urlField.text = ""
              }
            }
          }
        }

        Text {
          Layout.fillWidth: true
          visible: text !== ""
          textFormat: Text.PlainText
          text: root.busy
            ? (root.service.downloadedMb >= 0 ? "Descargando… " + root.service.downloadedMb + " MB" : "Preparando video…")
            : (root.service ? root.service.errorText : "")
          color: root.busy ? Color.foreground : Color.urgent
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.Wrap
        }

        Text {
          Layout.fillWidth: true
          textFormat: Text.PlainText
          text: "ⓘ El video queda asignado a " + root.theme + "; al volver a este tema se reactiva. Se pausa cuando hay ventanas encima."
          color: Color.muted
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.Wrap
        }
      }
    }
  }
}
