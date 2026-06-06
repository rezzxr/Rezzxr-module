"#!/system/bin/sh

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done
sleep 3

MODDIR="$(dirname "$(readlink -f "$0")")"
LOG="$MODDIR/helio_smooth.log"
echo "=== Helio G99 Smooth UI $(date) ===" > "$LOG"

if [ -f "/proc/ppm/policy_status" ]; then
    for i in 0 1 2 3 4 5 6 7 8 9 10; do
        echo "$i 0" > /proc/ppm/policy_status 2>/dev/null
    done
fi
[ -f "/proc/ppm/enabled" ] && echo "1" > /proc/ppm/enabled 2>/dev/null
[ -f "/proc/perfmgr/syslimiter/syslimiter_force_disable" ] && echo "1" > /proc/perfmgr/syslimiter/syslimiter_force_disable 2>/dev/null

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

for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -f "$policy/scaling_governor" ] && echo "schedutil" > "$policy/scaling_governor" 2>/dev/null
    [ -f "$policy/sugov_ext/up_rate_limit_us" ] && echo "0" > "$policy/sugov_ext/up_rate_limit_us" 2>/dev/null
    [ -f "$policy/sugov_ext/down_rate_limit_us" ] && echo "40000" > "$policy/sugov_ext/down_rate_limit_us" 2>/dev/null
done

echo "500000" > /proc/sys/kernel/sched_min_granularity_ns 2>/dev/null
echo "1000000" > /proc/sys/kernel/sched_wakeup_granularity_ns 2>/dev/null
echo "2000000" > /proc/sys/kernel/sched_migration_cost_ns 2>/dev/null

resetprop -n debug.sf.disable_client_composition_cache 1
resetprop -n debug.sf.latch_unsignaled 1
resetprop -n debug.sf.early_phase_offset_ns 1000000
resetprop -n debug.sf.phase_offset_ns 3000000
resetprop -n debug.sf.vsync_phase_offset_ns 0
resetprop -n vendor.display.fps 120
resetprop -n ro.surface_flinger.set_idle_timer_ms 80
resetprop -n ro.surface_flinger.set_touch_timer_ms 200
resetprop -n view.scroll_friction 0.008
resetprop -n vendor.debug.sf.cpupolicy.lowbound_uclamp_min "$UCLAMP_MAX"
resetprop -n vendor.debug.sf.cpupolicy.min_120 "$UCLAMP_MAX"
resetprop -n vendor.debug.sf.cpupolicy.upbound_uclamp_min "$UCLAMP_MAX"

for cpu in /sys/devices/system/cpu/cpu*/cpuidle/state6 /sys/devices/system/cpu/cpu*/cpuidle/state7; do
    [ -f "$cpu/disable" ] && echo "1" > "$cpu/disable" 2>/dev/null
done

[ -f "/sys/kernel/ged/hal/gpu_governor" ] && echo "performance" > /sys/kernel/ged/hal/gpu_governor 2>/dev/null
[ -f "/sys/class/devfreq/13000000.mali/governor" ] && echo "performance" > /sys/class/devfreq/13000000.mali/governor 2>/dev/null

if [ -f "/sys/kernel/ged/hal/gpu_min_freq" ]; then
    CURRENT_MIN=$(cat /sys/kernel/ged/hal/gpu_min_freq 2>/dev/null)
    if [ "$CURRENT_MIN" -lt "300000" ] 2>/dev/null; then
        echo "400000" > /sys/kernel/ged/hal/gpu_min_freq 2>/dev/null
    fi
fi
[ -f "/sys/kernel/ged/hal/gpu_dvfs_timer" ] && echo "200" > /sys/kernel/ged/hal/gpu_dvfs_timer 2>/dev/null

for cpu in 4 5 6 7; do
    [ -f "/sys/devices/system/cpu/cpu$cpu/online" ] && echo "1" > "/sys/devices/system/cpu/cpu$cpu/online" 2>/dev/null
done
[ -f "/sys/devices/system/cpu/cpu4/core_ctl/enable" ] && echo "0" > /sys/devices/system/cpu/cpu4/core_ctl/enable 2>/dev/null

echo "Smooth UI applied" >> "$LOG"

(
    while true; do
        if [ -f "/proc/ppm/policy_status" ]; then
            for i in 0 1 2 3 4 5 6 7 8 9 10; do
                echo "$i 0" > /proc/ppm/policy_status 2>/dev/null
            done
        fi
        if [ -f "/proc/sys/kernel/sched_min_granularity_ns" ]; then
            echo "500000" > /proc/sys/kernel/sched_min_granularity_ns 2>/dev/null
            echo "1000000" > /proc/sys/kernel/sched_wakeup_granularity_ns 2>/dev/null
            echo "2000000" > /proc/sys/kernel/sched_migration_cost_ns 2>/dev/null
        fi
        for cpu in 4 5 6 7; do
            [ -f "/sys/devices/system/cpu/cpu$cpu/online" ] && echo "1" > "/sys/devices/system/cpu/cpu$cpu/online" 2>/dev/null
        done
        sleep 5
    done
) >/dev/null 2>&1 &
