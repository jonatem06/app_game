# Tower Defense Game

A multi-platform tower defense game where players defend their castle against waves of demons.
Built with Godot Engine.

## Project Status (As of this version)

This project has a foundational set of scripts and logic enabling core gameplay mechanics.
While many systems are scripted, full visual assembly in the Godot editor, asset creation,
and some advanced gameplay interactions are the next major steps.

## Core Features Implemented (Scripts & Logic)

*   **Game Difficulty System:**
    *   Players can select a difficulty (Normal, Difficult, Hard) before starting a level (conceptual UI, logic in `GameManager.gd`).
    *   **Normal:** Standard gameplay.
    *   **Difficult:** Enemy health x2, Player starting coins x2.
    *   **Hard:** Enemy health x4, Player starting coins x4.
    *   `WaveManager.gd` scales enemy health (including bosses) based on this setting.
*   **Dynamic Path Generation:**
    *   `PathGenerator.gd` creates randomized paths for attackers on a grid.
    *   Path characteristics (grid size, seed) can be defined per level via `LevelConfiguration` resources.
*   **Wave Management:**
    *   `WaveManager.gd` controls the flow of enemy oleadas.
    *   Number of oleadas can be set per level (via `LevelConfiguration`) or randomized.
    *   Enemy count per oleada increases progressively.
    *   Bosses appear at regular intervals (e.g., every 3rd oleada).
*   **Entities (Defenders & Attackers):**
    *   **Defensores (`Warrior.gd`, `Archer.gd`, `Mage.gd`):**
        *   Defined stats: attack, range, attack speed, cost.
        *   Placeholder scenes (`.tscn`) for easy instantiation.
        *   **Magos Elementales:** Can apply status effects (10% chance):
            *   Fuego: Burn (Daño por tiempo).
            *   Hielo: Slow (Ralentiza enemigos).
            *   Tierra/Aire: Pushback (Empuja enemigos hacia atrás en el camino).
        *   **Targeting AI:** Defenders can now use different targeting strategies:
            *   `NEAREST_TO_SELF`, `NEAREST_TO_END`, `LOWEST_HEALTH`, `HIGHEST_HEALTH`.
            *   This is configurable per defender type/instance.
        *   **Tower Upgrades (Logic):** Defenders can be upgraded through 4 levels (Base + 3 upgrades).
            *   **Damage:** Increases additively with each upgrade (e.g., Base, Base+3, Base+3+6, Base+3+6+5).
            *   **Range:** Increases additively with each upgrade (e.g., Base, Base+2, Base+2+2, Base+2+2+2).
            *   **Attack Speed (Ataques por Segundo):** Increases additively with each upgrade.
                *   Guerrero: Base 3.0; Mejoras: +4, +4, +4 (Total Nivel 4: 15.0)
                *   Arquero: Base 5.0; Mejoras: +3, +3, +3 (Total Nivel 4: 14.0)
                *   Mago: Base 7.0; Mejoras: +3, +3, +3 (Total Nivel 4: 16.0)
            *   Each defender type defines its own upgrade costs and stat progression.
            *   `GameManager.gd` handles the logic for attempting an upgrade and spending coins. (UI for this is a future step).
    *   **Atacantes (`Demon.gd`, `DemonBoss.gd`):**
        *   Defined stats: health, speed, gold reward upon defeat.
        *   **Vida de Demonios Escala por Oleada:** Demonios normales tienen más vida en oleadas posteriores (base + 5 por oleada).
        *   Atacantes siguen el camino generado y dañan el castillo si llegan al final.
        *   Can be affected by elemental status effects (burn, slow, pushback).
        *   Report their path progress for targeting purposes.
*   **Game State & Economy:**
    *   `GameManager.gd` (Autoload/Singleton) tracks player lives (5 base, -1 por demonio, -2 por jefe) y monedas.
*   **Defender Placement System:**
    *   `MainGame.gd` y `GameUI.gd` interactúan con `GameManager.gd`.
    *   Logic to place defenders on a `TileMap` (conceptual, requiere `TileSet` en editor).
    *   Validación para colocar solo en tiles designados "pasto" (TILE_GRASS).
    *   El camino generado se marca en el `TileMap` como no colocable (TILE_PATH).
*   **Level Configuration:**
    *   `LevelConfiguration.gd` (Resource script) permite definir niveles en archivos `.tres`.
    *   Configurable: nombre, tamaño de mapa, semilla de camino, número de oleadas.
    *   Examples: `level_1.tres`, `level_2.tres`, `level_3.tres` created.
    *   `MainGame.gd` carga estas configuraciones para cada nivel.
*   **Basic UI:**
    *   `GameUI.gd` muestra vidas, monedas, información de oleada.
    *   Botones para iniciar la compra de defensores.
    *   **Tower Unlock UI:** Buttons for purchasing towers are now dynamically enabled/disabled based on which towers the player has unlocked.
*   **Main Game Orchestration:**
    *   `MainGame.gd` ensambla y coordina los diferentes sistemas (pathfinding, oleadas, UI, colocación, inicio de nivel).
*   **Progression Systems (Logic):**
    *   **Tower Unlocking:** Players start with the "Warrior" and can unlock "Archer" and "Mage" by completing specific levels. `GameManager.gd` tracks unlocked towers.

## Estructura del Proyecto (Scripts Clave)

*   `project.godot`: Archivo principal de configuración del proyecto Godot.
*   `src/main_game.gd`: Orquestador principal de la escena del juego.
*   `src/core/game_manager.gd`: Gestiona estado global del juego (vidas, monedas). (Autoload)
*   `src/core/path_generator.gd`: Genera los caminos para los enemigos.
*   `src/core/wave_manager.gd`: Controla las oleadas de enemigos.
*   `src/core/entities/`: Contiene las clases base y específicas para `Entity.gd`, `Attacker.gd`, `Defender.gd`, y todas las unidades.
*   `src/ui/game_ui.gd`: Script para la interfaz de usuario del juego.
*   `src/levels/level_configuration.gd`: Script de Recurso para definir datos de niveles.
*   `src/levels/level_1.tres`: Ejemplo de archivo de configuración de un nivel.
*   `docs/DESIGN_CHOICES.md`: Documenta decisiones de diseño (ej: elección de Godot).
*   `README.md`: Este archivo.

## Configuración del Entorno de Desarrollo

Para contribuir o ejecutar este proyecto localmente, necesitarás instalar Godot Engine.

1.  **Descargar Godot Engine:**
    *   Ve a la [página oficial de descargas de Godot Engine](https://godotengine.org/download/).
    *   Se recomienda Godot 3.5.x para mayor compatibilidad con la sintaxis GDScript actual.
    *   Godot es portable. Extrae el ejecutable donde prefieras.

2.  **Clonar el Repositorio:**
    *   `git clone <URL_DEL_REPOSITORIO>`
    *   `cd <NOMBRE_DEL_DIRECTORIO_DEL_PROYECTO>`

3.  **Importar el Proyecto en Godot:**
    *   Abre Godot Engine.
    *   En el Gestor de Proyectos, clic en "Importar".
    *   Navega y selecciona el archivo `project.godot` del proyecto clonado.
    *   Clic en "Importar y Editar".

## (Placeholder) Instrucciones de Ejecución

Una vez que el proyecto está importado en Godot Engine:

1.  **Escena Principal:**
    *   El proyecto está configurado para ejecutar `res://src/main_game.tscn` como la escena principal.
    *   **Nota:** `main_game.tscn` y las escenas de los defensores (`warrior.tscn`, etc.) son actualmente placeholders y necesitan ser construidas/editadas en el editor de Godot para añadir nodos visuales (Sprites, TileSet para el TileMap, etc.) y conectar nodos `onready var` correctamente.
    *   Para probar diferentes niveles, la variable `level_config_path` en `MainGame.gd` (o en la escena `MainGame.tscn` en el editor) debe ser cambiada para apuntar al archivo `.tres` del nivel deseado (ej: `res://src/levels/level_2.tres`).
2.  **Ejecutar el Juego desde el Editor:**
    *   Dentro del editor de Godot, presiona el botón "Ejecutar Proyecto" (F5).
3.  **Exportar (Web, Android, iOS):**
    *   Sigue la documentación oficial de Godot para configurar plantillas de exportación y SDKs.
    *   `Proyecto -> Exportar...`

## Próximos Pasos del Desarrollo (Conceptual en Editor Godot)

*   **Construir Escenas en Godot:**
    *   Crear/completar `MainGame.tscn` con los nodos `TileMap` (y su `TileSet`), contenedores, e instancia de `GameUI`.
    *   Crear/completar las escenas de los defensores y atacantes con `Sprite`, `CollisionShape2D`, etc.
*   **Implementar Interacción de Colocación Visual:**
    *   UI para seleccionar torres y activar mejoras.
    *   Conectar clics del ratón en el `TileMap` para la selección de celdas.
    *   Feedback visual para el modo de colocación.
*   **Desarrollar Assets Visuales y de Audio.**
*   **Refinar IA y Balance.**
*   **Añadir Múltiples Niveles y Mecánicas de Progresión.**
