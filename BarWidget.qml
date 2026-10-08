import QtQuick
import Quickshell
import qs.Ui

// Boton de la barra: abre el menu de fondo del tema. El estado y las acciones
// viven en el servicio (Background.qml), que es una sola instancia; este widget
// existe una vez por monitor.
BarWidget {
  id: root
  moduleName: "io.github.cristosolar.livebg"

  readonly property var service: root.bar && root.bar.shell ? root.bar.shell.serviceFor("io.github.cristosolar.livebg") : null
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
    if ("service" in target) target.service = root.service
  }

  onBarChanged: injectPanel()
  onServiceChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.service && root.service.busy ? "󰸉 …" : "󰸉"
    active: root.opened
    tooltipText: "Fondo del tema"
    onPressed: function(b) {
      if (!panelLoader.item) return
      if (root.service) root.service.refreshStatus()
      panelLoader.item.toggle()
    }
  }
}
