#!/system/bin/sh
while [ "$(getprop sys.boot_completed)" != "1" ]; do 
    sleep 2 
done

MODDIR="$(dirname "$(readlink -f "$0")")"
echo "FPSGO/UCLAMP Optimization applied successfully at $(date)" > "$MODDIR/rezzxr_boost.log"

if [ -f "/sys/kernel/fpsgo/common/fpsgo_enable" ]; then
    chmod 644 /sys/kernel/fpsgo/common/fpsgo_enable
    echo "0" > /sys/kernel/fpsgo/common/fpsgo_enable
    chmod 444 /sys/kernel/fpsgo/common/fpsgo_enable
fi

if [ -f "/sys/kernel/fpsgo/fstb/set_cam_active_fpsgo_off" ]; then
    echo "1" > /sys/kernel/fpsgo/fstb/set_cam_active_fpsgo_off
fi

if [ -f "/sys/kernel/fpsgo/fstb/fpsgo_status" ]; then
    chmod 644 /sys/kernel/fpsgo/fstb/fpsgo_status
    echo "0" > /sys/kernel/fpsgo/fstb/fpsgo_status
    chmod 444 /sys/kernel/fpsgo/fstb/fpsgo_status
fi

for fbt_limit in /sys/kernel/fpsgo/fbt/limit_*; do
    if [ -f "$fbt_limit" ]; then
        chmod 644 "$fbt_limit"
        echo "9999000" > "$fbt_limit"
        chmod 444 "$fbt_limit"
    fi
done

if [ -f "/proc/perfmgr/syslimiter/syslimiter_force_disable" ]; then
    echo "1" > /proc/perfmgr/syslimiter/syslimiter_force_disable
fi

if [ -f "/proc/ppm/enabled" ]; then
    chmod 644 /proc/ppm/enabled
    echo "1" > /proc/ppm/enabled
    chmod 444 /proc/ppm/enabled
fi

if [ -f "/proc/ppm/policy_status" ]; then
    chmod 644 /proc/ppm/policy_status
    for i in 0 1 2 3 4 5 6 7 8 9 10; do
        echo "$i 0" > /proc/ppm/policy_status
    done
    chmod 444 /proc/ppm/policy_status
fi

if [ -f "/dev/cpuctl/cpu.uclamp.sched_boost_no_override" ]; then
    chmod 644 /dev/cpuctl/cpu.uclamp.sched_boost_no_override
    echo "0" > /dev/cpuctl/cpu.uclamp.sched_boost_no_override
    chmod 444 /dev/cpuctl/cpu.uclamp.sched_boost_no_override
fi

for group in top-app foreground; do
    if [ -f "/dev/cpuctl/$group/cpu.uclamp.sched_boost_no_override" ]; then
        chmod 644 "/dev/cpuctl/$group/cpu.uclamp.sched_boost_no_override"
        echo "0" > "/dev/cpuctl/$group/cpu.uclamp.sched_boost_no_override"
        chmod 444 "/dev/cpuctl/$group/cpu.uclamp.sched_boost_no_override"
    fi

    if [ -f "/dev/cpuctl/$group/cpu.uclamp.min" ]; then
        chmod 666 "/dev/cpuctl/$group/cpu.uclamp.min"
        echo "1024" > "/dev/cpuctl/$group/cpu.uclamp.min"
        chmod 444 "/dev/cpuctl/$group/cpu.uclamp.min"
    fi
done

if [ -f "/dev/cpuctl/system-background/cpu.uclamp.sched_boost_no_override" ]; then
    chmod 644 "/dev/cpuctl/system-background/cpu.uclamp.sched_boost_no_override"
    echo "0" > "/dev/cpuctl/system-background/cpu.uclamp.sched_boost_no_override"
    chmod 444 "/dev/cpuctl/system-background/cpu.uclamp.sched_boost_no_override"
fi

if [ -f "/dev/cpuctl/system-background/cpu.uclamp.min" ]; then
    chmod 666 "/dev/cpuctl/system-background/cpu.uclamp.min"
    echo "165" > "/dev/cpuctl/system-background/cpu.uclamp.min"
    chmod 444 "/dev/cpuctl/system-background/cpu.uclamp.min"
fi

resetprop -n vendor.debug.sf.cpupolicy.lowbound_uclamp_min 1024
resetprop -n vendor.debug.sf.cpupolicy.min_120 1024
resetprop -n vendor.debug.sf.cpupolicy.upbound_uclamp_min 1024
resetprop -n vendor.prop.pnp.fpsgo.boost enable

resetprop -n ro.surface_flinger.max_frame_buffer_acquired_buffers 3
resetprop -n ro.vendor.display.default_fps 120
resetprop -n persistence.sys.sf.high_fps 1
resetprop -n view.scroll_friction 0.008

(
while true; do
    sleep 5
    state_disp=$(dumpsys display | grep -i "mScreenState" | head -n 1 | grep -oE "ON|OFF")
    state_pwr=$(dumpsys power | grep -i "mWakefulness" | head -n 1 | grep -oE "Asleep|Awake")
    
    if [ "$state_disp" = "OFF" ] || [ "$state_pwr" = "Asleep" ]; then
        for g in top-app foreground; do
            if [ -f "/dev/cpuctl/$g/cpu.uclamp.min" ]; then
                chmod 666 "/dev/cpuctl/$g/cpu.uclamp.min"
                echo "0" > "/dev/cpuctl/$g/cpu.uclamp.min"
                chmod 444 "/dev/cpuctl/$g/cpu.uclamp.min"
            fi
        done
    elif [ "$state_disp" = "ON" ] || [ "$state_pwr" = "Awake" ]; then
        for g in top-app foreground; do
            if [ -f "/dev/cpuctl/$g/cpu.uclamp.min" ]; then
                chmod 666 "/dev/cpuctl/$g/cpu.uclamp.min"
                echo "1024" > "/dev/cpuctl/$g/cpu.uclamp.min"
                chmod 444 "/dev/cpuctl/$g/cpu.uclamp.min"
            fi
        done
    fi
done
) >/dev/null 2>&1 &
