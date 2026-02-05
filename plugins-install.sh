#!/bin/bash

# Script de instalación de plugins para Noctalia Shell
# Plugins: Media Panel y Animated Wallpaper
# Repositorio: https://github.com/mikuri12/My-lazy-plugins-for-Noctalia
# Uso: curl -fsSL https://raw.githubusercontent.com/mikuri12/My-lazy-plugins-for-Noctalia/main/install.sh | bash

set -e  # Detener el script si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# Directorio de plugins de Noctalia
NOCTALIA_CONFIG_DIR="$HOME/.config/noctalia"
NOCTALIA_PLUGINS_DIR="$NOCTALIA_CONFIG_DIR/plugins"
PLUGINS_JSON="$NOCTALIA_CONFIG_DIR/plugins.json"
REPO_URL="https://github.com/mikuri12/My-lazy-plugins-for-Noctalia.git"
TEMP_DIR="/tmp/noctalia-plugins-install-$$"

# Variables para control de instalación
INSTALL_MEDIA_PANEL=false
INSTALL_ANIMATED_WALLPAPER=false

clear
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}Instalador de Plugins para Noctalia${NC}  ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""

# Función para imprimir mensajes de estado
print_status() {
    echo -e "${YELLOW}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Función para actualizar plugins.json
update_plugins_json() {
    local plugin_name=$1
    local enabled=$2
    
    if [ ! -f "$PLUGINS_JSON" ]; then
        # Crear estructura base si no existe
        cat > "$PLUGINS_JSON" << 'EOF'
{
    "sources": [
        {
            "enabled": true,
            "name": "Noctalia Plugins",
            "url": "https://github.com/noctalia-dev/noctalia-plugins"
        }
    ],
    "states": {},
    "version": 1
}
EOF
        print_status "Archivo plugins.json creado"
    fi
    
    # Usar jq si está disponible, si no, usar sed
    if command -v jq &> /dev/null; then
        # Crear entrada temporal
        local temp_json=$(mktemp)
        jq --arg name "$plugin_name" --argjson enabled "$enabled" \
           '.states[$name] = {"enabled": $enabled, "sourceUrl": "https://github.com/mikuri12/My-lazy-plugins-for-Noctalia"}' \
           "$PLUGINS_JSON" > "$temp_json"
        mv "$temp_json" "$PLUGINS_JSON"
    else
        # Fallback sin jq - método más simple
        print_status "jq no disponible, usando método alternativo..."
        
        # Leer el JSON actual
        local json_content=$(cat "$PLUGINS_JSON")
        
        # Crear la nueva entrada
        local new_entry="\"$plugin_name\": {\"enabled\": $enabled, \"sourceUrl\": \"https://github.com/mikuri12/My-lazy-plugins-for-Noctalia\"}"
        
        # Si states está vacío, agregar directamente
        if echo "$json_content" | grep -q '"states": {}'; then
            json_content=$(echo "$json_content" | sed "s/\"states\": {}/\"states\": {$new_entry}/")
        else
            # Si ya tiene contenido, agregar con coma
            json_content=$(echo "$json_content" | sed "s/\"states\": {/\"states\": {$new_entry, /")
        fi
        
        echo "$json_content" > "$PLUGINS_JSON"
    fi
    
    print_success "Plugin '$plugin_name' agregado al archivo plugins.json"
}

# Menú de selección interactivo
show_menu() {
    echo -e "${BLUE}¿Qué plugin(s) deseas instalar?${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Media Panel"
    echo -e "  ${GREEN}2)${NC} Animated Wallpaper"
    echo -e "  ${GREEN}3)${NC} Ambos plugins"
    echo -e "  ${RED}4)${NC} Cancelar"
    echo ""
    
    # Leer desde /dev/tty para que funcione con curl | bash
    if [ -t 0 ]; then
        read -p "Selecciona una opción [1-4]: " choice
    else
        read -p "Selecciona una opción [1-4]: " choice </dev/tty
    fi
    
    case $choice in
        1)
            INSTALL_MEDIA_PANEL=true
            print_info "Se instalará: Media Panel"
            ;;
        2)
            INSTALL_ANIMATED_WALLPAPER=true
            print_info "Se instalará: Animated Wallpaper"
            ;;
        3)
            INSTALL_MEDIA_PANEL=true
            INSTALL_ANIMATED_WALLPAPER=true
            print_info "Se instalarán ambos plugins"
            ;;
        4)
            print_info "Instalación cancelada"
            exit 0
            ;;
        *)
            print_error "Opción inválida"
            exit 1
            ;;
    esac
    echo ""
}

# Verificar si git está instalado
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado. Por favor instala git primero."
    echo ""
    echo "  En Debian/Ubuntu: ${CYAN}sudo apt install git${NC}"
    echo "  En Arch Linux:    ${CYAN}sudo pacman -S git${NC}"
    echo "  En Fedora:        ${CYAN}sudo dnf install git${NC}"
    echo ""
    exit 1
fi

print_success "Git está instalado"

# Mostrar menú (funciona tanto en ejecución directa como con curl)
show_menu

# Crear directorios si no existen
print_status "Verificando directorios de Noctalia..."
if [ ! -d "$NOCTALIA_CONFIG_DIR" ]; then
    print_status "Creando directorio de configuración: $NOCTALIA_CONFIG_DIR"
    mkdir -p "$NOCTALIA_CONFIG_DIR"
fi

if [ ! -d "$NOCTALIA_PLUGINS_DIR" ]; then
    print_status "Creando directorio de plugins: $NOCTALIA_PLUGINS_DIR"
    mkdir -p "$NOCTALIA_PLUGINS_DIR"
    print_success "Directorio de plugins creado"
else
    print_success "Directorio de plugins existe"
fi

# Limpiar directorio temporal si existe
if [ -d "$TEMP_DIR" ]; then
    print_status "Limpiando directorio temporal..."
    rm -rf "$TEMP_DIR"
fi

# Clonar el repositorio
print_status "Clonando repositorio desde GitHub..."
if git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null; then
    print_success "Repositorio clonado exitosamente"
else
    print_error "Error al clonar el repositorio"
    exit 1
fi

# Instalar Media Panel
if [ "$INSTALL_MEDIA_PANEL" = true ]; then
    print_status "Instalando Media Panel..."
    if [ -d "$TEMP_DIR/media-panel" ]; then
        if [ -d "$NOCTALIA_PLUGINS_DIR/media-panel" ]; then
            print_status "Media Panel ya existe, actualizando..."
            rm -rf "$NOCTALIA_PLUGINS_DIR/media-panel"
        fi
        
        cp -r "$TEMP_DIR/media-panel" "$NOCTALIA_PLUGINS_DIR/"
        print_success "Media Panel instalado en: $NOCTALIA_PLUGINS_DIR/media-panel"
        
        # Actualizar plugins.json
        update_plugins_json "media-panel" "true"
    else
        print_error "No se encontró el directorio media-panel en el repositorio"
    fi
fi

# Instalar Animated Wallpaper
if [ "$INSTALL_ANIMATED_WALLPAPER" = true ]; then
    print_status "Instalando Animated Wallpaper..."
    if [ -d "$TEMP_DIR/animated-wallpaper" ]; then
        if [ -d "$NOCTALIA_PLUGINS_DIR/animated-wallpaper" ]; then
            print_status "Animated Wallpaper ya existe, actualizando..."
            rm -rf "$NOCTALIA_PLUGINS_DIR/animated-wallpaper"
        fi
        
        cp -r "$TEMP_DIR/animated-wallpaper" "$NOCTALIA_PLUGINS_DIR/"
        print_success "Animated Wallpaper instalado en: $NOCTALIA_PLUGINS_DIR/animated-wallpaper"
        
        # Actualizar plugins.json
        update_plugins_json "animated-wallpaper" "true"
    else
        print_error "No se encontró el directorio animated-wallpaper en el repositorio"
    fi
fi

# Limpiar directorio temporal
print_status "Limpiando archivos temporales..."
rm -rf "$TEMP_DIR"
print_success "Limpieza completada"

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}      ${GREEN}¡Instalación completada!${NC}        ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "📁 Plugins instalados en: ${YELLOW}$NOCTALIA_PLUGINS_DIR${NC}"
echo -e "⚙️  Configuración actualizada: ${YELLOW}$PLUGINS_JSON${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC} Reinicia Noctalia Shell para aplicar los cambios"
echo ""
echo ""
