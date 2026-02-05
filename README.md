
Install
SH 
Readme
Documento · MD 
Instrucciones
Documento · MD 
con el curl me dice modo no interactivo hay una forma de hacer el script interactivo tambien con curl

6:27 p. m.

Ingenió solución para hacer script interactivo con curl








¡Perfecto! He actualizado el script para que sea interactivo incluso con curl. 🎉

Lo que cambió:
El script ahora usa /dev/tty para leer la entrada del usuario, lo que permite que funcione de forma interactiva aunque se ejecute con curl | bash.

Cómo funciona ahora:
Cuando alguien ejecute:

bash
curl -fsSL https://raw.githubusercontent.com/mikuri12/My-lazy-plugins-for-Noctalia/main/install.sh | bash
```

**Verá el menú interactivo:**
```
╔════════════════════════════════════════════╗
║  Instalador de Plugins para Noctalia  ║
╚════════════════════════════════════════════╝

¿Qué plugin(s) deseas instalar?

  1) Media Panel
  2) Animated Wallpaper
  3) Ambos plugins
  4) Cancelar

Selecciona una opción [1-4]:
El truco está en usar </dev/tty que permite leer directamente del terminal del usuario, incluso cuando stdin está siendo usado por curl. ¡Ahora sí es completamente interactivo! 🚀

Install
SH 
Readme
Documento · MD 
Instrucciones
Documento · MD 





Claude es IA y puede cometer errores. Por favor, verifica nuevamente las respuestas.
Readme · MD
Copiar

# My Noctalia Plugins

Personal plugins for Noctalia Shell: Media Panel and Animated Wallpaper

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/mikuri12/My-lazy-plugins-for-Noctalia/main/plugins-install.sh | bash
```
