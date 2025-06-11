# Tower Defense Game

A multi-platform tower defense game where players defend their castle against waves of demons.

## Project Description

This game features:
*   Dynamic path generation for unlimited levels.
*   Various defender types: Elemental Mages, Archers, Warriors.
*   Challenging attacker types: Demons and Demon Bosses.
*   A life system and in-game currency for strategic depth.

## Platforms
*   Android
*   iOS
*   Web

This project is being developed using the Godot Engine.

## Configuración del Entorno de Desarrollo

Para contribuir o ejecutar este proyecto localmente, necesitarás instalar Godot Engine.

1.  **Descargar Godot Engine:**
    *   Ve a la [página oficial de descargas de Godot Engine](https://godotengine.org/download/).
    *   Descarga la versión estándar de Godot (no la versión Mono/C# si no planeas usar C#). Se recomienda usar una versión estable reciente (ej: Godot 3.5.x o la última Godot 4.x, aunque los scripts actuales están más alineados con Godot 3.x GDScript). El archivo `docs/DESIGN_CHOICES.md` menciona Godot en general. Para mayor compatibilidad con los scripts generados hasta ahora, Godot 3.5.x sería una apuesta segura.
    *   Godot es portable, así que puedes extraer el ejecutable donde prefieras.

2.  **Clonar el Repositorio:**
    *   Abre una terminal o Git Bash.
    *   Navega al directorio donde quieres clonar el proyecto.
    *   Ejecuta: `git clone <URL_DEL_REPOSITORIO>` (reemplaza `<URL_DEL_REPOSITORIO>` con la URL real del repo).
    *   Navega al directorio del proyecto clonado: `cd <NOMBRE_DEL_DIRECTORIO_DEL_PROYECTO>`.

3.  **Importar el Proyecto en Godot:**
    *   Abre el ejecutable de Godot Engine.
    *   En el Gestor de Proyectos, haz clic en "Importar".
    *   Navega hasta la carpeta raíz del proyecto clonado (la que contiene el archivo `project.godot` - Nota: este archivo aún no ha sido creado por nuestras subtareas, pero Godot lo creará al importar).
    *   Selecciona el archivo `project.godot` (o simplemente la carpeta si Godot lo detecta). Si `project.godot` no existe, Godot te pedirá crearlo al intentar importar la carpeta.
    *   Haz clic en "Importar y Editar".

## (Placeholder) Instrucciones de Ejecución

Una vez que el proyecto está importado en Godot Engine:

1.  **Ejecutar el Juego desde el Editor:**
    *   Dentro del editor de Godot, busca el botón "Ejecutar Proyecto" (generalmente un icono de claqueta o un triángulo de "play") en la esquina superior derecha.
    *   Antes de ejecutar por primera vez, Godot podría pedirte que selecciones una "Escena Principal" para el proyecto. Deberás designar la escena principal del juego (ej: `Level_1.tscn` o `MainMenu.tscn`, la cual aún no hemos creado explícitamente como una escena de nivel completa).
    *   Haz clic en "Ejecutar Proyecto" para iniciar el juego en una ventana de escritorio.

2.  **Exportar a Web (HTML5):**
    *   En el editor de Godot, ve a `Proyecto -> Exportar...`.
    *   Haz clic en "Añadir..." y selecciona "HTML5".
    *   Configura las opciones de exportación si es necesario. Para una prueba rápida, los valores por defecto suelen ser suficientes.
    *   Asegúrate de tener las plantillas de exportación de HTML5 para tu versión de Godot. Si no las tienes, Godot te mostrará un mensaje para descargarlas desde el menú `Editor -> Gestionar Plantillas de Exportación`.
    *   Haz clic en "Exportar Proyecto". Elige una ubicación y nombre para los archivos exportados (ej: una carpeta `build/web/`).
    *   Una vez exportado, puedes ejecutar un servidor web local en esa carpeta para probar el juego en tu navegador, o subir los archivos a un servicio de hosting web. Por ejemplo, usando Python: `python -m http.server` (Python 3) o `python -m SimpleHTTPServer` (Python 2) desde la carpeta de exportación.

3.  **Exportar a Android/iOS:**
    *   El proceso para Android e iOS es más complejo y requiere la configuración de SDKs específicos (Android SDK, Xcode para iOS).
    *   Desde el menú `Proyecto -> Exportar...`, añade las plantillas para Android e iOS.
    *   Sigue la [documentación oficial de Godot para la exportación a Android](https_docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) y [exportación a iOS](https_docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html) para configurar tu entorno y firmar los paquetes.
    *   (Estas instrucciones son un resumen; la documentación de Godot es la referencia definitiva).

## Próximos Pasos del Desarrollo (Conceptual)

*   Crear la escena principal del juego que ensamble el `PathGenerator`, `WaveManager`, `GameManager`, y la `GameUI`.
*   Implementar la lógica de colocación de defensores en el mapa.
*   Desarrollar los assets visuales y de audio.
*   Refinar la IA de los enemigos y las habilidades de los defensores.
*   Añadir múltiples niveles y mecánicas de progresión.
