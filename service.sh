#!/system/bin/sh

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done
sleep 3

echo "0 0 0 0" > /proc/sys/kernel/printk 2>/dev/null

MODDIR="$(dirname "$(readlink -f "$0")")"
LOG="$MODDIR/helio_smooth.log"
echo "=== Helio G99 Animation Overlord v1.4 (Origin OS) $(date) ===" > "$LOG"

if [ -f "/sys/kernel/fpsgo/common/fpsgo_enable" ]; then
    chmod 644 /sys/kernel/fpsgo/common/fpsgo_enable 2>/dev/null
    echo "0" > /sys/kernel/fpsgo/common/fpsgo_enable 2>/dev/null
    chmod 444 /sys/kernel/fpsgo/common/fpsgo_enable 2>/dev/null
fi
if [ -f "/sys/kernel/fpsgo/fstb/fpsgo_status" ]; then
    chmod 644 /sys/kernel/fpsgo/fstb/fpsgo_status 2>/dev/null
    echo "0" > /sys/kernel/fpsgo/fstb/fpsgo_status 2>/dev/null
    chmod 444 /sys/kernel/fpsgo/fstb/fpsgo_status 2>/dev/null
fi
[ -f "/sys/kernel/fpsgo/fstb/set_cam_active_fpsgo_off" ] && echo "1" > /sys/kernel/fpsgo/fstb/set_cam_active_fpsgo_off 2>/dev/null

for limit in /sys/kernel/fpsgo/fbt/limit_*; do
    [ -f "$limit" ] && echo "9999000" > "$limit" 2>/dev/null
done

sleep 1

UCLAMP_MAX=100
if [ -f "/dev/cpuctl/top-app/cpu.uclamp.max" ]; then
    UCLAMP_MAX=$(cat /dev/cpuctl/top-app/cpu.uclamp.max 2>/dev/null)
fi

for group in top-app foreground foreground_window systemui ax_foreground; do
    if [ -d "/dev/cpuctl/$group" ]; then
        if [ -f "/dev/cpuctl/$group/cpu.uclamp.min" ]; then
            chmod 666 "/dev/cpuctl/$group/cpu.uclamp.min" 2>/dev/null
            echo "$UCLAMP_MAX" > "/dev/cpuctl/$group/cpu.uclamp.min" 2>/dev/null
            chmod 444 "/dev/cpuctl/$group/cpu.uclamp.min" 2>/dev/null
        fi
        [ -f "/dev/cpuctl/$group/cpu.uclamp.sched_boost_no_override" ] && echo "0" > "/dev/cpuctl/$group/cpu.uclamp.sched_boost_no_override" 2>/dev/null
    fi
done

if [ -f "/dev/cpuctl/system/cpu.uclamp.min" ]; then
    chmod 666 "/dev/cpuctl/system/cpu.uclamp.min" 2>/dev/null
    echo "70" > "/dev/cpuctl/system/cpu.uclamp.min" 2>/dev/null
    chmod 444 "/dev/cpuctl/system/cpu.uclamp.min" 2>/dev/null
fi

sleep 1

for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -f "$policy/sugov_ext/up_rate_limit_us" ] && echo "0" > "$policy/sugov_ext/up_rate_limit_us" 2>/dev/null
    [ -f "$policy/sugov_ext/down_rate_limit_us" ] && echo "40000" > "$policy/sugov_ext/down_rate_limit_us" 2>/dev/null
done

if [ -d "/sys/devices/system/cpu/cpufreq/policy0" ]; then
    echo "2000000" > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq 2>/dev/null
fi
if [ -d "/sys/devices/system/cpu/cpufreq/policy6" ]; then
    echo "2200000" > /sys/devices/system/cpu/cpufreq/policy6/scaling_min_freq 2>/dev/null
fi

echo "500000" > /proc/sys/kernel/sched_min_granularity_ns 2>/dev/null
echo "1000000" > /proc/sys/kernel/sched_wakeup_granularity_ns 2>/dev/null
echo "2000000" > /proc/sys/kernel/sched_migration_cost_ns 2>/dev/null

sleep 1

# === БЕЗОПАСНАЯ ГРАФИКА ORIGIN OS PHYSICS ===
resetprop -n debug.sf.disable_client_composition_cache 1
resetprop -n ro.surface_flinger.uclamp.min "$UCLAMP_MAX"
resetprop -n vendor.display.fps 120
resetprop -n ro.surface_flinger.set_idle_timer_ms 10000
resetprop -n ro.surface_flinger.set_touch_timer_ms 3000

# Настройка вязкого скролла Vivo (Трение + Ограничение безумной скорости "выстрела")
resetprop -n view.scroll_friction 0.015
resetprop -n ro.max.fling_velocity 7000
resetprop -n ro.min.fling_velocity 200

# Фрейм-пейсинг и инерция для рендеринга (Убирает микро-дерганья при затухании анимаций)
resetprop -n debug.graphics.game_framerate_log 0
resetprop -n ro.kernel.android.checkjni 0
resetprop -n debug.hwui.renderer skiavk

# Агрессивные веса планировщика для SurfaceFlinger
resetprop -n vendor.debug.sf.cpupolicy.lowbound_uclamp_min 1024
resetprop -n vendor.debug.sf.cpupolicy.min_60 1024
resetprop -n vendor.debug.sf.cpupolicy.min_90 1024
resetprop -n vendor.debug.sf.cpupolicy.min_120 1024
resetprop -n vendor.debug.sf.cpupolicy.upbound_uclamp_min 1024

sleep 1

[ -f "/sys/class/devfreq/13000000.mali/min_freq" ] && echo "950000000" > /sys/class/devfreq/13000000.mali/min_freq 2>/dev/null
[ -f "/sys/kernel/ged/hal/gpu_dvfs_timer" ] && echo "200" > /sys/kernel/ged/hal/gpu_dvfs_timer 2>/dev/null

echo "Animation Overlord applied" >> "$LOG"

(
    LAST_IRQ=0
    IDLE_COUNT=0
    IS_BOOSTED=1

    while true; do
        CURRENT_IRQ=$(awk '/chipone-tddi/ {sum=0; for(i=2; i<=9; i++) sum+=$i; print sum}' /proc/interrupts 2>/dev/null)

        if [ "$CURRENT_IRQ" != "$LAST_IRQ" ] && [ ! -z "$CURRENT_IRQ" ]; then
            LAST_IRQ=$CURRENT_IRQ
            IDLE_COUNT=0
            
            if [ "$IS_BOOSTED" -eq 0 ]; then
                [ -d "/sys/devices/system/cpu/cpufreq/policy0" ] && echo "2000000" > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq 2>/dev/null
                [ -d "/sys/devices/system/cpu/cpufreq/policy6" ] && echo "2200000" > /sys/devices/system/cpu/cpufreq/policy6/scaling_min_freq 2>/dev/null
                [ -f "/sys/class/devfreq/13000000.mali/min_freq" ] && echo "950000000" > /sys/class/devfreq/13000000.mali/min_freq 2>/dev/null
                IS_BOOSTED=1
            fi
            
            sleep 3
        else
            IDLE_COUNT=$((IDLE_COUNT + 1))
            
            if [ "$IDLE_COUNT" -ge 4 ]; then
                if [ "$IS_BOOSTED" -eq 1 ]; then
                    [ -d "/sys/devices/system/cpu/cpufreq/policy0" ] && echo "500000" > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq 2>/dev/null
                    [ -d "/sys/devices/system/cpu/cpufreq/policy6" ] && echo "725000" > /sys/devices/system/cpu/cpufreq/policy6/scaling_min_freq 2>/dev/null
                    [ -f "/sys/class/devfreq/13000000.mali/min_freq" ] && echo "390000000" > /sys/class/devfreq/13000000.mali/min_freq 2>/dev/null
                    IS_BOOSTED=0
                fi
                sleep 2
                IDLE_COUNT=4
            else
                sleep 3
            fi
        fi
    done
) >/dev/null 2>&1 &

sleep 2
setprop ctl.restart surfaceflinger 2>/dev/null
