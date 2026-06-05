# ⚡ Rezzxr-module (v1.1 - Master Edition)

An ultimate lightweight multi-profile systemless module for **KernelSU-Next / Magisk / APatch**, engineered specifically to control hardware behaviors on **MediaTek Helio G99** devices. Fully optimized for **Transsion (Tecno / Infinix)** ecosystem and tested on **Tecno Pova 6 Neo (Li6)** running GSI Android 16 with WildKernel + SusFS.

The repository offers two polar-opposite profiles depending on your target workflow.

---

## 🚀 Profile 1: Performance & Smooth UI Mode (`rezzxr.1.zip`)
*Target: Intense gaming and buttery-smooth user interface.*

* **FPSGO Execution:** Hard throttles the core MediaTek limitation framework (`fpsgo_enable=0`). CPU task management is handed over to pure, unrestricted Linux scheduling algorithms.
* **SurfaceFlinger Triple Buffering:** Forces Android graphics rendering engine to use 3 acquired buffers, completely wiping out shutter lag and micro-stutters during notification panel pulls and quick swipes at 120Hz.
* **Smart Sleep Daemon:** An asynchronous background loop that checks screen activity every 5 seconds. Instantly drops uclamp values to zero when the screen is OFF (`Asleep`), saving 100% of your battery at night, and snaps back to 1024 on unlock.
* **Frictionless Scrolling:** Tweaks system scroll friction variables (`view.scroll_friction=0.008`) to deliver an incredibly smooth, fluid, high-refresh-rate scrolling experience.

---

## 🔋 Profile 2: Battery ECO Mode (`rezzxr_power.zip`)
*Target: Ultimate battery endurance and ice-cold hardware.*

* **FPSGO Dictatorship:** Forces the core MediaTek limitation framework back ON (`fpsgo_enable=1`) and sets an aggressive throttling trigger at 45°C to instantly chill the CPU.
* **PPM Power Save:** Locks MediaTek PPM core policies to a strict power-saving mode, forcing the system to utilize energy-efficient little cores and blocking unnecessary CPU clock spikes.
* **60Hz Refresh Rate Lock:** Drops rendering buffers and restricts the display refresh rate to a steady, battery-friendly 60Hz.
* **Aggressive Friction Scrolling:** Increases scroll friction variables (`view.scroll_friction=0.050`) to stop list scrolling immediately, heavily reducing GPU drawing overhead.

---

## 🛡️ Hidden Core Features (Both Profiles)
* **SusFS Ready:** The optimization boot log (`rezzxr_boost.log`) is isolated inside the secure module directory (`/data/adb/modules/...`), keeping your system completely invisible to strict Integrity / Safetynet checks and mobile anti-cheats.
* **Android 15 & 16 Compatibility:** Uses dual-path uclamp tracking (including `/dev/cpuctl/apps/`) to ensure 100% stable deployment across any modern custom GSI ROM.

## 🐧 Powered by Velikiy TUX & Pure 100% Shell
