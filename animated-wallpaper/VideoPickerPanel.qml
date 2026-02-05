import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Widgets

Scope {
  id: root
  
  property string currentPath: Qt.platform.os === "linux" ? 
    (Qt.application.arguments[0] ? Qt.application.arguments[0].replace(/\/[^\/]*$/, "") : "/home") : "/home"
  property var pathHistory: []
  property bool panelVisible: false
  
  signal videoSelected(string path)
  
  Component.onCompleted: {
    // Intentar obtener el home del usuario
    const homeVar = Qt.application.arguments.find(arg => arg.startsWith("HOME="))
    if (homeVar) {
      currentPath = homeVar.replace("HOME=", "")
    } else {
      // Fallback a carpeta común de videos
      currentPath = "/home"
    }
    pathHistory = [currentPath]
  }
  
  function show() {
    panelVisible = true
  }
  
  function hide() {
    panelVisible = false
  }
  
  function goBack() {
    if (pathHistory.length > 1) {
      pathHistory.pop()
      currentPath = pathHistory[pathHistory.length - 1]
      pathHistory = pathHistory.slice() // Force update
    }
  }
  
  function goToPath(path) {
    pathHistory.push(path)
    currentPath = path
    pathHistory = pathHistory.slice() // Force update
  }
  
  function goHome() {
    currentPath = pathHistory[0]
    pathHistory = [currentPath]
  }
  
  PanelWindow {
    id: floatingPanel
    
    visible: root.panelVisible
    implicitWidth: 900
    implicitHeight: 620
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    color: "transparent"
    
    Shortcut {
      sequence: "Escape"
      onActivated: root.panelVisible = false
    }
    
    Rectangle {
      anchors.fill: parent
      anchors.margins: 16
      color: Color.mSurface || "#1e1e1e"
      radius: 12
      border.width: 1
      border.color: Color.mOutline || "#3a3a3a"
      
      ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Header con navegación
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 56
          color: Color.mSurfaceVariant || "#2a2a2a"
          
          Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Color.mOutlineVariant || "#3a3a3a"
          }
          
          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8
            
            // Botón atrás
            Button {
              Layout.preferredWidth: 36
              Layout.preferredHeight: 36
              enabled: root.pathHistory.length > 1
              opacity: enabled ? 1.0 : 0.3
              
              onClicked: root.goBack()
              
              background: Rectangle {
                color: parent.enabled && parent.hovered ? (Color.mSurfaceVariant || "#3a3a3a") : "transparent"
                radius: 6
              }
              
              contentItem: Text {
                text: "←"
                color: Color.mOnSurface || "#e0e0e0"
                font.pixelSize: 18
                font.family: "monospace"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }
            }
            
            // Separador
            Rectangle {
              Layout.preferredWidth: 1
              Layout.preferredHeight: 24
              color: Color.mOutlineVariant || "#3a3a3a"
            }
            
            // Ruta actual
            Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: 36
              color: Color.mSurface || "#252525"
              radius: 6
              border.width: 1
              border.color: Color.mOutlineVariant || "#3a3a3a"
              
              Text {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                text: root.currentPath || ""
                color: Color.mOnSurface || "#e0e0e0"
                font.family: "monospace"
                font.pixelSize: 13
                elide: Text.ElideMiddle
                verticalAlignment: Text.AlignVCenter
              }
            }
            
            // Separador
            Rectangle {
              Layout.preferredWidth: 1
              Layout.preferredHeight: 24
              color: Color.mOutlineVariant || "#3a3a3a"
            }
            
            // Botón home
            Button {
              Layout.preferredWidth: 36
              Layout.preferredHeight: 36
              
              onClicked: root.goHome()
              
              background: Rectangle {
                color: parent.hovered ? (Color.mSurfaceVariant || "#3a3a3a") : "transparent"
                radius: 6
              }
              
              contentItem: Text {
                text: "~"
                color: Color.mOnSurface || "#e0e0e0"
                font.pixelSize: 18
                font.family: "monospace"
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }
            }
            
            // Botón cerrar
            Button {
              Layout.preferredWidth: 36
              Layout.preferredHeight: 36
              
              onClicked: root.panelVisible = false
              
              background: Rectangle {
                color: parent.hovered ? (Color.mError || "#dc3545") : "transparent"
                radius: 6
              }
              
              contentItem: Text {
                text: "×"
                color: parent.parent.hovered ? "#ffffff" : (Color.mOnSurface || "#e0e0e0")
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }
            }
          }
        }
        
        // Área de contenido
        ScrollView {
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          
          GridView {
            id: grid
            cellWidth: 180
            cellHeight: 160
            model: folderModel
            
            Label {
              anchors.centerIn: parent
              text: folderModel.count === 0 ? "Empty folder" : ""
              color: Color.mOnSurfaceVariant || "#888888"
              font.family: "sans-serif"
              font.pixelSize: 14
              visible: folderModel.count === 0
            }
            
            delegate: Item {
              width: 170
              height: 150
              
              Rectangle {
                id: itemCard
                anchors.fill: parent
                anchors.margins: 6
                color: itemMouse.containsMouse ? (Color.mSurfaceVariant || "#2a2a2a") : "transparent"
                radius: 8
                border.width: 1
                border.color: itemMouse.containsMouse ? (Color.mPrimary || "#4a9eff") : "transparent"
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on border.color { ColorAnimation { duration: 100 } }
                
                ColumnLayout {
                  anchors.fill: parent
                  anchors.margins: 8
                  spacing: 6
                  
                  // Thumbnail área
                  Rectangle {
                    id: thumbnailArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Color.mSurface || "#1a1a1a"
                    radius: 6
                    border.width: 1
                    border.color: Color.mOutlineVariant || "#2a2a2a"
                    clip: true
                    
                    // Icono de carpeta - exactamente como el SVG
                    Canvas {
                      anchors.centerIn: parent
                      width: 64
                      height: 64
                      visible: model.fileIsDir
                      
                      property color folderColor: Color.mPrimary || "#4a9eff"
                      
                      onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.fillStyle = folderColor;
                        
                        // Escalar de 16x16 a 64x64
                        var scale = 4;
                        ctx.scale(scale, scale);
                        
                        // Primera parte del path: la forma base con bordes redondeados
                        // m2 2c-1.108 0-2 0.892-2 2v9c0 1.108 0.892 2 2 2h12c1.108 0 2-0.892 2-2v-8c0-1.108-0.892-2-2-2h-2-5.6289...
                        ctx.beginPath();
                        ctx.moveTo(2, 2);
                        // Esquina superior izquierda redondeada
                        ctx.bezierCurveTo(0.892, 2, 0, 2.892, 0, 4);
                        ctx.lineTo(0, 13);
                        // Esquina inferior izquierda redondeada
                        ctx.bezierCurveTo(0, 14.108, 0.892, 15, 2, 15);
                        ctx.lineTo(14, 15);
                        // Esquina inferior derecha redondeada
                        ctx.bezierCurveTo(15.108, 15, 16, 14.108, 16, 13);
                        ctx.lineTo(16, 5);
                        // Esquina superior derecha redondeada
                        ctx.bezierCurveTo(16, 3.892, 15.108, 3, 14, 3);
                        // Pestaña
                        ctx.lineTo(8, 3);
                        ctx.lineTo(6.37, 3);
                        ctx.bezierCurveTo(5.79, 2.977, 5.765, 3.077, 5.33, 2.643);
                        ctx.bezierCurveTo(4.897, 2.209, 4.718, 2.001, 4, 2);
                        ctx.lineTo(2, 2);
                        ctx.closePath();
                        ctx.fill();
                        
                        // Segunda parte: el relleno superior (zm0 1h2c0.31116...)
                        ctx.beginPath();
                        ctx.moveTo(2, 3);
                        ctx.lineTo(4, 3);
                        ctx.bezierCurveTo(4.311, 3, 4.52, 3, 4.998, 3.471);
                        ctx.bezierCurveTo(5.477, 3.942, 5.637, 4, 5.998, 4);
                        ctx.lineTo(12, 4);
                        ctx.lineTo(14, 4);
                        ctx.bezierCurveTo(14.554, 4, 15, 4.446, 15, 5);
                        ctx.lineTo(15, 6);
                        ctx.lineTo(1, 6);
                        ctx.lineTo(1, 4);
                        ctx.bezierCurveTo(1, 3.446, 1.446, 3, 2, 3);
                        ctx.closePath();
                        ctx.fill();
                        
                        // Tercera parte: el cuerpo inferior (zm-1 4h14v6...)
                        ctx.beginPath();
                        ctx.moveTo(1, 7);
                        ctx.lineTo(15, 7);
                        ctx.lineTo(15, 13);
                        ctx.bezierCurveTo(15, 13.554, 14.554, 14, 14, 14);
                        ctx.lineTo(2, 14);
                        ctx.bezierCurveTo(1.446, 14, 1, 13.554, 1, 13);
                        ctx.lineTo(1, 7);
                        ctx.closePath();
                        ctx.fill();
                      }
                      
                      onFolderColorChanged: requestPaint()
                    }
                    
                    // Video preview - solo primer frame, sin overlay
                    VideoOutput {
                      id: videoOutput
                      anchors.fill: parent
                      visible: !model.fileIsDir
                      fillMode: VideoOutput.PreserveAspectCrop
                    }
                    
                    AudioOutput {
                      id: audioOutput
                      muted: true
                    }
                    
                    MediaPlayer {
                      id: mediaPlayer
                      videoOutput: videoOutput
                      audioOutput: audioOutput
                      source: !model.fileIsDir ? ("file://" + model.filePath) : ""
                      
                      // Cargar solo el primer frame
                      Component.onCompleted: {
                        if (!model.fileIsDir && source) {
                          // Esperar un poco para que se cargue
                          loadTimer.start()
                        }
                      }
                      
                      onSourceChanged: {
                        if (!model.fileIsDir && source) {
                          loadTimer.start()
                        }
                      }
                    }
                    
                    Timer {
                      id: loadTimer
                      interval: 100
                      onTriggered: {
                        if (mediaPlayer && mediaPlayer.source) {
                          mediaPlayer.pause()
                          mediaPlayer.setPosition(0)
                        }
                      }
                    }
                    
                    // Badge de formato
                    Rectangle {
                      anchors.right: parent.right
                      anchors.bottom: parent.bottom
                      anchors.margins: 6
                      width: fileTypeText.width + 12
                      height: 20
                      color: "#cc000000"
                      radius: 4
                      visible: !model.fileIsDir
                      
                      Text {
                        id: fileTypeText
                        anchors.centerIn: parent
                        text: {
                          const fileName = model.fileName || ""
                          const ext = fileName.split('.').pop().toUpperCase()
                          return ext || "VIDEO"
                        }
                        color: "#ffffff"
                        font.family: "monospace"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                      }
                    }
                  }
                  
                  // Nombre
                  Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    text: model.fileName || ""
                    color: Color.mOnSurface || "#e0e0e0"
                    font.family: "sans-serif"
                    font.pixelSize: 12
                    font.weight: model.fileIsDir ? Font.Medium : Font.Normal
                    elide: Text.ElideMiddle
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    verticalAlignment: Text.AlignVCenter
                  }
                }
                
                MouseArea {
                  id: itemMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  
                  onClicked: {
                    if (model.fileIsDir) {
                      root.goToPath(model.filePath)
                    } else {
                      root.videoSelected(model.filePath)
                      root.panelVisible = false
                    }
                  }
                }
                
                scale: itemMouse.pressed ? 0.96 : 1.0
                Behavior on scale { NumberAnimation { duration: 80 } }
              }
            }
          }
        }
        
        // Footer
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          color: Color.mSurfaceVariant || "#2a2a2a"
          
          Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Color.mOutlineVariant || "#3a3a3a"
          }
          
          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16
            
            Text {
              text: {
                let videos = 0
                let dirs = 0
                for (let i = 0; i < folderModel.count; i++) {
                  if (folderModel.get(i, "fileIsDir")) {
                    dirs++
                  } else {
                    videos++
                  }
                }
                return videos + " videos · " + dirs + " folders"
              }
              color: Color.mOnSurfaceVariant || "#888888"
              font.family: "sans-serif"
              font.pixelSize: 12
              Layout.fillWidth: true
            }
            
            Text {
              text: "Click to select video"
              color: Color.mOnSurfaceVariant || "#666666"
              font.family: "sans-serif"
              font.pixelSize: 11
              opacity: 0.7
            }
          }
        }
      }
    }
  }
  
  FolderListModel {
    id: folderModel
    folder: root.currentPath ? ("file://" + root.currentPath) : ""
    nameFilters: ["*.mp4", "*.MP4", "*.webm", "*.WebM", "*.mkv", "*.MKV", "*.mov", "*.MOV", "*.avi", "*.AVI"]
    showDirs: true
    showDotAndDotDot: false
    showHidden: false
    sortField: FolderListModel.Name
  }
}
