#! /vendor/bin/sh
# Perfd-opt https://github.com/yc9559/perfd-opt/
# Author: Matt Yang
# Platform: sm6150
# Version: v1 (20190727)

# Runonce after boot, to speed up the transition of power modes in powercfg

# $1:value $2:file path
lock_val() 
{
    if [ -f ${2} ]; then
        chmod 0666 ${2}
        echo ${1} > ${2}
        chmod 0444 ${2}
    fi
}

# $1:task_name $2:cgroup_name $3:"cpuset"/"stune"
change_task_cgroup()
{
    temp_pids=`ps -Ao pid,cmd | grep "${1}" | awk '{print $1}'`
    for temp_pid in ${temp_pids}
    do
        for temp_tid in `ls /proc/${temp_pid}/task/`
        do
            echo ${temp_tid} > /dev/${3}/${2}/tasks
        done
    done
}

# suppress stderr
(

# 580M for empty apps
lock_val "18432,23040,27648,51256,122880,150296" /sys/module/lowmemorykiller/parameters/minfree

# treat crtc_commit as display
change_task_cgroup "crtc_commit" "display" "cpuset"

# avoid display preemption on big
lock_val "0-5" /dev/cpuset/display/cpus

# fix laggy bilibili feed scrolling
change_task_cgroup "servicemanager" "top-app" "cpuset"
change_task_cgroup "servicemanager" "foreground" "stune"
change_task_cgroup "android.phone" "top-app" "cpuset"
change_task_cgroup "android.phone" "foreground" "stune"

# fix laggy home gesture
change_task_cgroup "system_server" "top-app" "cpuset"
change_task_cgroup "system_server" "foreground" "stune"

# reduce render thread waiting time
change_task_cgroup "surfaceflinger" "top-app" "cpuset"
change_task_cgroup "surfaceflinger" "foreground" "stune"

# unify schedtune misc
lock_val "0" /dev/stune/background/schedtune.sched_boost_enabled
lock_val "1" /dev/stune/background/schedtune.sched_boost_no_override
lock_val "0" /dev/stune/background/schedtune.boost
lock_val "0" /dev/stune/background/schedtune.prefer_idle
lock_val "0" /dev/stune/foreground/schedtune.sched_boost_enabled
lock_val "1" /dev/stune/foreground/schedtune.sched_boost_no_override
lock_val "0" /dev/stune/foreground/schedtune.boost
lock_val "0" /dev/stune/foreground/schedtune.prefer_idle
lock_val "0" /dev/stune/top-app/schedtune.sched_boost_no_override

# CFQ io scheduler takes cgroup into consideration
lock_val "cfq" /sys/block/sda/queue/scheduler
# Flash doesn't have back seek problem, so penalty is as low as possible
lock_val "1" /sys/block/sda/queue/iosched/back_seek_penalty
# slice_idle = 0 means CFQ IOP mode, https://lore.kernel.org/patchwork/patch/944972/
lock_val "0" /sys/block/sda/queue/iosched/slice_idle
# UFS 2.0+ hardware queue depth is 32
lock_val "16" /sys/block/sda/queue/iosched/quantum
# lower read_ahead_kb to reduce random access overhead
lock_val "128" /sys/block/sda/queue/read_ahead_kb

# adreno default settings
lock_val "0" /sys/class/kgsl/kgsl-3d0/force_no_nap
lock_val "1" /sys/class/kgsl/kgsl-3d0/bus_split
lock_val "0" /sys/class/kgsl/kgsl-3d0/force_bus_on
lock_val "0" /sys/class/kgsl/kgsl-3d0/force_clk_on
lock_val "0" /sys/class/kgsl/kgsl-3d0/force_rail_on

# zram doesn't need much read ahead(random read)
lock_val "4" /sys/block/zram0/queue/read_ahead_kb

# suppress stderr
) 2> /dev/null
