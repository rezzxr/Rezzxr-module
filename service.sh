#!/system/bin/sh

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 5
done
sleep 5

echo "0 0 0 0" > /proc/sys/kernel/printk 2>/dev/null

safe_write() {
    if [ -f "$2" ]; then
        chmod 644 "$2" 2>/dev/null
        echo "$1" > "$2" 2>/dev/null
    fi
}

safe_write "60" "/proc/sys/vm/swappiness"
safe_write "50" "/proc/sys/vm/vfs_cache_pressure"
safe_write "10" "/proc/sys/vm/dirty_background_ratio"
safe_write "20" "/proc/sys/vm/dirty_ratio"
safe_write "500" "/proc/sys/vm/dirty_writeback_centisecs"
safe_write "3000" "/proc/sys/vm/dirty_expire_centisecs"
safe_write "0" "/proc/sys/vm/zone_reclaim_mode"
safe_write "1" "/proc/sys/vm/page-cluster"

for storage in /sys/block/sd* /sys/block/mmcblk*; do
    [ -d "$storage" ] && safe_write "512" "$storage/queue/read_ahead_kb"
done

safe_write "1" "/sys/kernel/fpsgo/common/fpsgo_enable"
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
    [ -f "$policy/sugov_ext/up_rate_limit_us" ] && echo "0" > "$policy/sugov_ext/up_rate_limit_us" 2>/dev/null
    [ -f "$policy/sugov_ext/down_rate_limit_us" ] && echo "40000" > "$policy/sugov_ext/down_rate_limit_us" 2>/dev/null
done

resetprop -n debug.sf.disable_client_composition_cache 1
resetprop -n ro.surface_flinger.uclamp.min "$UCLAMP_MAX"
resetprop -n vendor.display.fps 120
resetprop -n ro.surface_flinger.set_idle_timer_ms 10000
resetprop -n ro.surface_flinger.set_touch_timer_ms 3000
resetprop -n view.scroll_friction 0.015
resetprop -n ro.max.fling_velocity 7000
resetprop -n ro.min.fling_velocity 200
resetprop -n debug.graphics.game_framerate_log 0
resetprop -n ro.kernel.android.checkjni 0
resetprop -n debug.hwui.renderer skiavk

for i in lowbound_uclamp_min min_60 min_90 min_120 upbound_uclamp_min; do
    resetprop -n vendor.debug.sf.cpupolicy.$i 1024
done

disable_pkg() {
    if pm list packages | grep -q "$1"; then
        pm disable-user --user 0 "$1" >/dev/null 2>&1
    fi
}
disable_pkg com.google.android.apps.wellbeing
disable_pkg com.google.android.apps.tachyon
disable_pkg com.google.android.gms.location.history
disable_pkg com.miui.analytics
disable_pkg com.miui.msa.global
disable_pkg com.oplus.analytics
disable_pkg com.facebook.system
disable_pkg com.facebook.appmanager
disable_pkg com.transsion.ga
disable_pkg com.transsion.logtools

(
    boost_max() {
        for p in /sys/devices/system/cpu/cpufreq/policy*; do
            if [ -d "$p" ]; then
                cat "$p/scaling_max_freq" > "$p/scaling_min_freq" 2>/dev/null
            fi
        done
        for gpu in /sys/class/devfreq/*mali* /sys/class/devfreq/gpufreq; do
            [ -f "$gpu/max_freq" ] && cat "$gpu/max_freq" > "$gpu/min_freq" 2>/dev/null
        done
    }

    boost_down() {
        for p in /sys/devices/system/cpu/cpufreq/policy*; do
            if [ -d "$p" ]; then
                cat "$p/cpuinfo_min_freq" > "$p/scaling_min_freq" 2>/dev/null
            fi
        done
        for gpu in /sys/class/devfreq/*mali* /sys/class/devfreq/gpufreq; do
            if [ -f "$gpu/gpuinfo_min_freq" ]; then
                cat "$gpu/gpuinfo_min_freq" > "$gpu/min_freq" 2>/dev/null
            elif [ -f "$gpu/min_freq" ]; then
                echo "0" > "$gpu/min_freq" 2>/dev/null
            fi
        done
    }

    boost_max
    sleep 3
    boost_down
) &

exit 0
