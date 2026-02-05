import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  property var pluginApi
  spacing: Style.marginM

  NLabel {
    label: "Wallpaper Animado"
    description: "Reproduce videos como fondo de pantalla"
  }

  NToggle {
    Layout.fillWidth: true
    label: "Activar wallpaper"
    checked: pluginApi.pluginSettings?.enabled ?? false
    onCheckedChanged: {
      if (pluginApi.pluginSettings) {
        pluginApi.pluginSettings.enabled = checked
        pluginApi.saveSettings()
      }
    }
  }

  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS

    NLabel {
      label: "Ruta del video"
      description: "Escribe o pega la ruta completa del archivo de video"
    }

    Rectangle {
      Layout.fillWidth: true
      height: 40
      color: Color.mSurface
      radius: Style.radiusM
      border.width: 1
      border.color: videoInput.activeFocus ? Color.mPrimary : Color.mOutline

      TextInput {
        id: videoInput
        anchors.fill: parent
        anchors.leftMargin: Style.marginM
        anchors.rightMargin: Style.marginM
        verticalAlignment: TextInput.AlignVCenter
        text: pluginApi.pluginSettings?.videoPath ?? ""
        color: Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeS
        selectByMouse: true

        onEditingFinished: {
          pluginApi.pluginSettings.videoPath = text
          pluginApi.saveSettings()
        }
      }

      Text {
        anchors.fill: parent
        anchors.leftMargin: Style.marginM
        anchors.rightMargin: Style.marginM
        verticalAlignment: Text.AlignVCenter
        text: "Ejemplo: /home/usuario/Videos/wallpaper.mp4"
        color: Color.mOnSurfaceVariant
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeS
        visible: !videoInput.text && !videoInput.activeFocus
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      Text {
        text: "💡 Tip: Puedes pegar la ruta completa del archivo"
        color: Color.mOnSurfaceVariant
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeXS
      }

      Item { Layout.fillWidth: true }

      Button {
        text: "Limpiar"
        visible: (pluginApi.pluginSettings?.videoPath ?? "") !== ""
        onClicked: {
          videoInput.text = ""
          pluginApi.pluginSettings.videoPath = ""
          pluginApi.saveSettings()
        }

        background: Rectangle {
          color: parent.hovered ? Color.mSurfaceVariant : "transparent"
          radius: Style.radiusS
        }

        contentItem: Text {
          text: parent.text
          color: Color.mPrimary
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSizeS
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
      }
    }
  }

  NComboBox {
    Layout.fillWidth: true
    label: "Modo de ajuste"
    model: ListModel {
      ListElement { name: "Recortar (Recomendado)"; key: "PreserveAspectCrop" }
      ListElement { name: "Ajustar"; key: "PreserveAspectFit" }
      ListElement { name: "Estirar"; key: "Stretch" }
    }
    currentKey: pluginApi.pluginSettings?.fillMode ?? "PreserveAspectCrop"
    onSelected: function(key) {
      pluginApi.pluginSettings.fillMode = key
      pluginApi.saveSettings()
    }
  }

  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS

    RowLayout {
      Layout.fillWidth: true

      NLabel {
        Layout.fillWidth: true
        label: "Volumen"
        description: "Nivel de audio del video"
      }

      Text {
        text: Math.round((pluginApi.pluginSettings?.volume ?? 0) * 100) + "%"
        color: Color.mPrimary
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeM
        font.weight: Font.Medium
      }
    }

    NSlider {
      Layout.fillWidth: true
      from: 0
      to: 100
      value: {
        const vol = pluginApi.pluginSettings?.volume ?? 0
        return vol * 100
      }
      onValueChanged: {
        if (pluginApi.pluginSettings) {
          pluginApi.pluginSettings.volume = value / 100
          pluginApi.saveSettings()
        }
      }
    }
  }

  NToggle {
    Layout.fillWidth: true
    label: "Reproducción en bucle"
    description: "Repetir el video continuamente"
    checked: pluginApi.pluginSettings?.loop ?? true
    onCheckedChanged: {
      if (pluginApi.pluginSettings) {
        pluginApi.pluginSettings.loop = checked
        pluginApi.saveSettings()
      }
    }
  }
}
