⚡ Rezzxr-module (v1.3 - Optimized & Safe Edition)
An ultimate lightweight multi-profile systemless module for KernelSU-Next / Magisk / APatch, engineered specifically to control hardware behaviors on MediaTek Helio G99 devices. Fully optimized for Transsion (Tecno / Infinix) ecosystem and tested on Tecno Pova 6 Neo (Li6) running GSI Android 16 with WildKernel + SusFS.

The repository offers two polar-opposite profiles depending on your target workflow.

🚀 Profile 1: Performance & Smooth UI Mode (rezzxr_v1.3.zip)
Target: Intense gaming and buttery-smooth user interface.

* **FPSGO Execution:** Hard throttles the core MediaTek limitation framework (`fpsgo_enable=0`) and locks limits to `9999000` [INDEX]. CPU task management is handed over to pure, unrestricted Linux scheduling algorithms.
* **Smart Touch Tracker Daemon:** An asynchronous background loop that checks screen activity via `chipone-tddi` interrupts using fast `awk` filtering (scanning CPU0-7 columns). Instantly forces CPU `policy0/6` minimum frequencies to 2.0/2.2GHz and GPU Mali-G57 to 950MHz upon touch, maintaining the boost for 3 seconds [INDEX].
* **I/O Overnight Protection:** Incorporates `IS_BOOSTED` state validation to eliminate repetitive write operations to sysfs kernel nodes. Frequency commands are sent exactly once per state transition.
* **Idle Energy Saving:** When screen inactivity exceeds 12 seconds (`IDLE_COUNT >= 4`), minimum CPU frequencies drop back to 500/725MHz and GPU Mali to 390MHz to preserve battery lifespan.
* **Origin OS Scroll Physics:** Alters configurations (`view.scroll_friction=0.012-0.015` and `ro.max.fling_velocity=7000`) to mirror premium Vivo/iOS kinetic scrolling behavior, adding a pleasant physical weight and inertial deceleration to lists [INDEX].
* **Safe SurfaceFlinger Lifecycle:** Uses native `setprop ctl.restart surfaceflinger` instead of aggressive `killall -9` process termination, ensuring 100% stable deployment on Android 14, 15, and 16 GSI without triggering gray screen locks or security Apex panics [INDEX].

🔋 Profile 2: Battery ECO Mode (rezzxr_power.zip)
Target: Ultimate battery endurance and ice-cold hardware.

* **FPSGO Enforcement:** Restores the core MediaTek limitation framework (`fpsgo_enable=1`) and applies strict performance throttling boundaries to drop core temperatures.
* **PPM Power Save:** Locks MediaTek PPM policies to power-saving mode, forcing the scheduler to utilize power-efficient little cores and restricting sudden CPU frequency spikes.
* **60Hz Refresh Rate Lock:** Forces the display refresh rate to a stable 60Hz to reduce active graphic engine power consumption.
* **Aggressive Friction Scrolling:** Increases scroll friction variables to `0.050` to stop scrolling immediately, heavily reducing active GPU drawing overhead.

🛡️ Hidden Core Features (Both Profiles)
* **SusFS Ready:** The boot log (`helio_smooth.log`) is isolated inside the secure module directory, preventing data leaks and keeping the system fully invisible to strict Integrity / SafetyNet checks [INDEX].
* **Android 14, 15 & 16 Compatibility:** Uses a unified script layout to ensure stable deployment across modern custom GSI ROMs without cross-version core execution errors [INDEX].

🐧 Powered by Velikiy TUX & Pure 100% Shell

