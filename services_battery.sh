#!/system/bin/sh
while [ "$(getprop sys.boot_completed)" != "1" ]; do 
    sleep 2 
done

MODDIR="$(dirname "$(readlink -f "$0")")"
echo "ENERGY SAVING PROFILE APPLIED AT $(date)" > "$MODDIR/rezzxr_boost.log"

if [ -f "/sys/kernel/fpsgo/common/fpsgo_enable" ]; then
    chmod 644 /sys/kernel/fpsgo/common/fpsgo_enable
    echo "1" > /sys/kernel/fpsgo/common/fpsgo_enable
    chmod 444 /sys/kernel/fpsgo/common/fpsgo_enable
fi

if [ -f "/sys/kernel/fpsgo/fstb/set_cam_active_fpsgo_off" ]; then
    echo "0" > /sys/kernel/fpsgo/fstb/set_cam_active_fpsgo_off
fi

if [ -f "/sys/kernel/fpsgo/fstb/fpsgo_status" ]; then
    chmod 644 /sys/kernel/fpsgo/fstb/fpsgo_status
    echo "1" > /sys/kernel/fpsgo/fstb/fpsgo_status
    chmod 444 /sys/kernel/fpsgo/fstb/fpsgo_status
fi

# Выставляем жесткий лимит фреймрейта в ядре на экономные 45 кадров
for fbt_limit in /sys/kernel/fpsgo/fbt/limit_*; do
    if [ -f "$fbt_limit" ]; then
        chmod 644 "$fbt_limit"
        echo "45000" > "$fbt_limit"
        chmod 444 "$fbt_limit"
    fi
done

# Врубаем термал-панику FPSGO: пусть душит частоты уже при 45 градусах (Ультра Эконом)
if [ -f "/sys/kernel/fpsgo/fbt/thrm_enable" ]; then
    chmod 644 /sys/kernel/fpsgo/fbt/thrm_enable
    echo "1" > /sys/kernel/fpsgo/fbt/thrm_enable
    chmod 444 /sys/kernel/fpsgo/fbt/thrm_enable
fi
if [ -f "/sys/kernel/fpsgo/fbt/thrm_temp_th" ]; then
    chmod 644 /sys/kernel/fpsgo/fbt/thrm_temp_th
    echo "45" > /sys/kernel/fpsgo/fbt/thrm_temp_th
    chmod 444 /sys/kernel/fpsgo/fbt/thrm_temp_th
fi

if [ -f "/proc/perfmgr/syslimiter/syslimiter_force_disable" ]; then
    echo "0" > /proc/perfmgr/syslimiter/syslimiter_force_disable
fi

if [ -f "/proc/ppm/enabled" ]; then
    chmod 644 /proc/ppm/enabled
    echo "1" > /proc/ppm/enabled
    chmod 444 /proc/ppm/enabled
fi

# Переводим системный PPM монитор процессора в режим жесткого сбережения (политика 1)
if [ -f "/proc/ppm/policy_status" ]; then
    chmod 644 /proc/ppm/policy_status
    for i in 0 1 2 3 4 5 6 7 8 9 10; do
        echo "$i 1" > /proc/ppm/policy_status
    done
    chmod 444 /proc/ppm/policy_status
fi

resetprop -n vendor.debug.sf.cpupolicy.lowbound_uclamp_min 0
resetprop -n vendor.debug.sf.cpupolicy.min_120 0
resetprop -n vendor.debug.sf.cpupolicy.upbound_uclamp_min 0
resetprop -n vendor.prop.pnp.fpsgo.boost disable

# Режем ресурсы графического рендеринга и переводим экран в экономные 60 Гц
resetprop -n ro.surface_flinger.max_frame_buffer_acquired_buffers 1
resetprop -n ro.vendor.display.default_fps 60
resetprop -n persistence.sys.sf.high_fps 0
resetprop -n view.scroll_friction 0.050
