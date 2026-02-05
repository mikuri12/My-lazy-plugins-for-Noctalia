import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Media
import qs.Widgets

Item {
  id: root
  
  property var pluginApi: null
  property var screen: null
  property bool isBarVertical: false
  property int barLineSize: 0
  
  readonly property bool hasPlayer: MediaService.currentPlayer !== null
  readonly property bool isPlaying: MediaService.isPlaying
  
  property bool hovering: false
  
  readonly property real barFontSize: Math.min(
    Style.fontSizeM * Style.uiScaleRatio,
    barLineSize * 0.5
  )
  
  Layout.fillWidth: !isBarVertical
  Layout.fillHeight: isBarVertical
  implicitWidth: isBarVertical ? barLineSize : visualCapsule.implicitWidth
  implicitHeight: isBarVertical ? visualCapsule.implicitHeight : barLineSize
  
  Item {
    id: visualCapsule
    anchors.fill: parent
    
    implicitWidth: {
      if (isBarVertical) return barLineSize
      const iconSize = 20 * Style.uiScaleRatio
      if (!hasPlayer || !hovering) return iconSize
      return iconSize + root.barFontSize * 15
    }
    
    implicitHeight: {
      if (!isBarVertical) return barLineSize
      return 28 * Style.uiScaleRatio
    }
    
    RowLayout {
      anchors.fill: parent
      anchors.margins: 2 * Style.uiScaleRatio
      spacing: 6 * Style.uiScaleRatio
      
      NIcon {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 20 * Style.uiScaleRatio
        Layout.preferredHeight: 20 * Style.uiScaleRatio
        icon: "music"
        pointSize: 16 * Style.uiScaleRatio
        color: isPlaying ? Color.mPrimary : Color.mOnSurfaceVariant
        
        Behavior on color { ColorAnimation { duration: 150 } }
      }
    }
  }
  
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    
    onEntered: root.hovering = true
    onExited: root.hovering = false
    
    onClicked: (mouse) => {
      if (mouse.button === Qt.LeftButton && pluginApi) {
        pluginApi.openPanel(root.screen, visualCapsule)
      } else if (mouse.button === Qt.MiddleButton && hasPlayer) {
        MediaService.playPause()
      }
    }
  }
}
