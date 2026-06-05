# ⚡ Rezzxr-module (v1.1 - Master Edition)

An ultimate lightweight hybrid module for **KernelSU-Next / Magisk**, engineered specifically to eliminate aggressive system limits and improve UI smoothness on **MediaTek Helio G99** devices. Fully optimized for **Transsion (Tecno / Infinix)** ecosystem and tested on **Tecno Pova 6 Neo (Li6)** running with WildKernel + SusFS.

## 🛠️ Main Engine Features:
* **FPSGO Execution:** Hard throttles the core MediaTek limitation framework (`fpsgo_enable=0`). CPU task management is handed over to pure, unrestricted Linux scheduling algorithms.
* **SurfaceFlinger Triple Buffering:** Forces Android graphics rendering engine to use 3 acquired buffers, completely wiping out shutter lag and micro-stutters during notification panel pulls and app switching.
* **Smart Sleep Daemon:** An asynchronous background loop that checks screen activity every 5 seconds. Instantly drops uclamp values to zero when the screen is OFF (`Asleep`), saving 100% of your battery at night, and snaps back to full force on unlock.
* **Frictionless Scrolling:** Tweaks system scroll friction variables to deliver an incredibly smooth, fluid, high-refresh-rate scrolling experience.
* **SusFS & KernelSU-Next Ready:** The optimization boot log (`rezzxr_boost.log`) is isolated inside the secure module directory, keeping your system completely invisible to strict Integrity / Safetynet checks and mobile anti-cheats.

## 🐧 Powered by Velikiy TUX & Pure 100% Shell

