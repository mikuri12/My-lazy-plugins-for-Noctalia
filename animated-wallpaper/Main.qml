import QtQuick
import QtMultimedia
import Quickshell
import Quickshell.Wayland

Scope {
  id: root
  property var pluginApi
  
  readonly property bool enabled: pluginApi.pluginSettings?.enabled ?? false
  readonly property string videoPath: pluginApi.pluginSettings?.videoPath ?? ""
  readonly property string fillMode: pluginApi.pluginSettings?.fillMode ?? "PreserveAspectCrop"
  readonly property real volume: pluginApi.pluginSettings?.volume ?? 0
  readonly property bool loop: pluginApi.pluginSettings?.loop ?? true
  
  readonly property string videoUrl: {
    if (!videoPath) return ""
    if (videoPath.startsWith("file://")) return videoPath
    if (videoPath.startsWith("/")) return "file://" + videoPath
    return videoPath
  }
  
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      implicitWidth: modelData.width
      implicitHeight: modelData.height
      visible: root.enabled && root.videoUrl
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.exclusiveZone: -1
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      anchors { top: true; bottom: true; left: true; right: true }
      color: "transparent"
      
      Rectangle {
        anchors.fill: parent
        color: "black"
        Video {
          anchors.fill: parent
          source: root.videoUrl
          autoPlay: true
          loops: root.loop ? MediaPlayer.Infinite : 1
          volume: root.volume
          fillMode: {
            switch (root.fillMode) {
              case "Stretch": return VideoOutput.Stretch
              case "PreserveAspectFit": return VideoOutput.PreserveAspectFit
              case "PreserveAspectCrop": return VideoOutput.PreserveAspectCrop
              default: return VideoOutput.PreserveAspectCrop
            }
          }
          onErrorOccurred: (e, s) => console.error("Video Error:", s)
          Component.onCompleted: { if (source && root.enabled) play() }
        }
      }
    }
  }
}
