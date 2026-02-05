import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  property var pluginApi
  spacing: Style.marginM || 16
  
  Component.onCompleted: {
    if (!pluginApi.pluginSettings.enabled) {
      pluginApi.pluginSettings.enabled = false
    }
    if (!pluginApi.pluginSettings.videoPath) {
      pluginApi.pluginSettings.videoPath = ""
    }
    if (!pluginApi.pluginSettings.fillMode) {
      pluginApi.pluginSettings.fillMode = "PreserveAspectCrop"
    }
    if (pluginApi.pluginSettings.volume === undefined) {
      pluginApi.pluginSettings.volume = 0
    }
    if (pluginApi.pluginSettings.loop === undefined) {
      pluginApi.pluginSettings.loop = true
    }
    pluginApi.saveSettings()
  }
  
  NLabel {
    label: "Animated Wallpaper"
    description: "Play videos as desktop background"
  }
  
  NToggle {
    Layout.fillWidth: true
    label: "Enable wallpaper"
    checked: pluginApi.pluginSettings.enabled
    onToggled: function(checked) {
      pluginApi.pluginSettings.enabled = checked
      pluginApi.saveSettings()
    }
  }
  
  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS || 12
    
    NLabel {
      label: "Select video"
      description: "Choose your animated wallpaper from the visual browser"
    }
    
    // Botón simple para abrir el selector
    Button {
      Layout.fillWidth: true
      Layout.preferredHeight: 48
      
      onClicked: videoPickerPanel.panelVisible = !videoPickerPanel.panelVisible
      
      background: Rectangle {
        color: parent.hovered ? (Color.mPrimaryContainer || "#2a3f5f") : (Color.mSurfaceVariant || "#2a2a2a")
        radius: Style.radiusM || 8
        border.width: 1
        border.color: parent.hovered ? (Color.mPrimary || "#4a9eff") : (Color.mOutline || "#3a3a3a")
        
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 150 } }
      }
      
      contentItem: Text {
        text: "Browse wallpapers"
        color: Color.mOnSurface || "#e0e0e0"
        font.family: Style.fontFamily || "sans-serif"
        font.pixelSize: Style.fontSizeM || 14
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    
    // Preview del video actual
    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 90
      color: Color.mSurface || "#1e1e1e"
      radius: Style.radiusM || 8
      border.width: 1
      border.color: Color.mOutline || "#3a3a3a"
      visible: pluginApi.pluginSettings.videoPath && pluginApi.pluginSettings.videoPath !== ""
      
      RowLayout {
        anchors.fill: parent
        anchors.margins: Style.marginM || 12
        spacing: Style.marginM || 12
        
        Rectangle {
          Layout.preferredWidth: 120
          Layout.preferredHeight: 68
          color: "#0a0a0a"
          radius: Style.radiusS || 6
          border.width: 1
          border.color: Color.mOutlineVariant || "#2a2a2a"
          
          Text {
            anchors.centerIn: parent
            text: "▶"
            color: "#666666"
            font.pixelSize: 28
            font.family: "sans-serif"
            opacity: 0.5
          }
        }
        
        ColumnLayout {
          Layout.fillWidth: true
          spacing: 4
          
          Text {
            text: "Current video:"
            color: Color.mOnSurfaceVariant || "#888888"
            font.family: Style.fontFamily || "sans-serif"
            font.pixelSize: Style.fontSizeXS || 11
          }
          
          Text {
            text: (pluginApi.pluginSettings.videoPath && pluginApi.pluginSettings.videoPath !== "")
              ? pluginApi.pluginSettings.videoPath.split('/').pop()
              : ""
            color: Color.mOnSurface || "#e0e0e0"
            font.family: Style.fontFamily || "sans-serif"
            font.pixelSize: Style.fontSizeS || 13
            font.weight: Font.Medium
            elide: Text.ElideMiddle
            Layout.fillWidth: true
          }
          
          Text {
            text: (pluginApi.pluginSettings.videoPath && pluginApi.pluginSettings.videoPath !== "")
              ? pluginApi.pluginSettings.videoPath.split('/').slice(0, -1).join('/')
              : ""
            color: Color.mOnSurfaceVariant || "#666666"
            font.family: "monospace"
            font.pixelSize: Style.fontSizeXS || 10
            elide: Text.ElideMiddle
            Layout.fillWidth: true
          }
        }
        
        Button {
          Layout.preferredWidth: 36
          Layout.preferredHeight: 36
          
          onClicked: {
            pluginApi.pluginSettings.videoPath = ""
            pluginApi.saveSettings()
          }
          
          background: Rectangle {
            color: parent.hovered ? (Color.mErrorContainer || "#5c1a1a") : "transparent"
            radius: 6
          }
          
          contentItem: Text {
            text: "×"
            color: parent.parent.hovered ? (Color.mError || "#dc3545") : (Color.mOnSurfaceVariant || "#888888")
            font.pixelSize: 24
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
          }
        }
      }
    }
    
    // Separador
    Rectangle {
      Layout.fillWidth: true
      Layout.topMargin: Style.marginM || 12
      Layout.bottomMargin: Style.marginM || 12
      height: 1
      color: Color.mOutlineVariant || "#2a2a2a"
    }
  }
  
  NComboBox {
    Layout.fillWidth: true
    label: "Fill mode"
    model: ListModel {
      ListElement { name: "Crop (Recommended)"; key: "PreserveAspectCrop" }
      ListElement { name: "Fit"; key: "PreserveAspectFit" }
      ListElement { name: "Stretch"; key: "Stretch" }
    }
    currentKey: pluginApi.pluginSettings.fillMode || "PreserveAspectCrop"
    
    onSelected: {
      pluginApi.pluginSettings.fillMode = key
      pluginApi.saveSettings()
    }
  }
  
  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS || 8
    
    RowLayout {
      Layout.fillWidth: true
      
      NLabel {
        Layout.fillWidth: true
        label: "Volume"
        description: "Video audio level"
      }
      
      Text {
        text: Math.round((pluginApi.pluginSettings.volume || 0) * 100) + "%"
        color: Color.mPrimary || "#4a9eff"
        font.family: Style.fontFamily || "sans-serif"
        font.pixelSize: Style.fontSizeM || 14
        font.weight: Font.Medium
      }
    }
    
    NSlider {
      Layout.fillWidth: true
      from: 0
      to: 100
      value: (pluginApi.pluginSettings.volume || 0) * 100
      
      onMoved: {
        pluginApi.pluginSettings.volume = value / 100
        pluginApi.saveSettings()
      }
    }
  }
  
  NToggle {
    Layout.fillWidth: true
    label: "Loop playback"
    description: "Repeat video continuously"
    checked: pluginApi.pluginSettings.loop !== undefined ? pluginApi.pluginSettings.loop : true
    
    onToggled: function(checked) {
      pluginApi.pluginSettings.loop = checked
      pluginApi.saveSettings()
    }
  }
  
  VideoPickerPanel {
    id: videoPickerPanel
    
    onVideoSelected: function(path) {
      pluginApi.pluginSettings.videoPath = path
      pluginApi.saveSettings()
    }
  }
}
