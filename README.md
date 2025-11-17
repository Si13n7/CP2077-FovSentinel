# FOV Sentinel

See your real in-game FOV (field of view) and lock it when the game tries to change it. Keep your view consistent, stop unwanted zoom shifts, and play exactly the way you set it.

---

## Features

- Frontend only: displays and controls FOV for the player.
- Powered by [FOV Control](https://github.com/Si13n7/CP2077-FovControl): uses its engine-level conversion and lock/unlock functions.
- No automation: it does not change cameras or anything else on its own.
- Works game-wide; not limited to third-person or a specific camera.

## Padlock HUD

**Padlock closed (locked)**
- **Cyan** number = locked FOV (held by the mod).
- **Yellow** number (if shown) = the FOV the game tried to apply (blocked).

**Padlock open (unlocked)**
- **Cyan** number = current FOV (updates with the game).

## Usage

- View the live engine FOV.
- Lock the FOV to stop unwanted changes.
- Unlock anytime to let the game decide the FOV again.

### CET Bindings

1. Open the CET overlay.
2. Open the **Bindings** tab.
3. Find this mod’s actions and bind keyboard or controller buttons.
4. Close CET overlay and test in-game. The padlock HUD shows the current state.

Notes: keyboard and controller bindings are supported. If you run into conflicts, use a modifier such as Ctrl or Alt. In some contexts a short state change may be needed before a new FOV appears.

## Background

The game changes FOV dynamically, and it does it a lot. With this mod you can see those shifts live, which makes the scope of the problem obvious. How disruptive it feels depends on your preferred FOV in the Graphics settings. If you play at 80, you might barely notice, because the game often snaps back to 80 anyway. If you prefer 90 or higher, sudden drops to 80 can be jarring and break immersion. It feels like an extreme zoom you never asked for.

## Requirements

- [FOV Control](https://github.com/Si13n7/CP2077-FovControl) with all dependencies.
- [Cyber Engine Tweaks](https://github.com/maximegmd/CyberEngineTweaks).
- [Codeware](https://github.com/psiberx/cp2077-codeware) is optional. It displays the precise FOV used by the third-person camera. FOV locking works without it.

## Installation

1. Install all requirements listed above.
2. Extract the `FovSentinel` folder into your CET mods folder:

```
<GameDir>/bin/x64/plugins/cyber_engine_tweaks/mods/
```

3. Launch the game.

## Troubleshooting

When reporting issues, please provide:

- Game version and mod version.
- The following log files:
  ```
  <GameDir>\red4ext\logs\FovControl.log
  <GameDir>\bin\x64\plugins\cyber_engine_tweaks\mods\FovSentinel\FovSentinel.log
  ```

## Notes

- If another tool also forces FOV, the one that locks first will take precedence. Disable or unlock the other tool if you need to switch.
- Codeware is optional. It displays the precise FOV used by the third-person camera. FOV locking remains fully functional without it.

## Tagline

See your real FOV, and lock it when you need to. Minimal, precise, powered by FOV Control.
