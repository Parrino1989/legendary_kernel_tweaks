#!/system/bin/sh
# =======================================================#
# Codename: LKT
# Author: korom42 @ XDA
# Device: Multi-device
# Version : 1.9.1
# Last Update: 18.AUG.2019
# =======================================================#
# THE BEST BATTERY MOD YOU CAN EVER USE
# =======================================================#
# Credits : Project WIPE contributors 
# @yc9559 @Fdss45 @yy688go (好像不见了) @Jouiz @lpc3123191239
# @小方叔叔 @星辰紫光 @ℳ๓叶落情殇 @屁屁痒 @发热不卡算我输# @予北
# @選擇遺忘 @想飞的小伙 @白而出清 @AshLight @微风阵阵 @半阳半
# @AhZHI @悲欢余生有人听 @YaomiHwang @花生味 @胡同口卖菜的
# @gce8980 @vesakam @q1006237211 @Runds @lmentor
# @萝莉控の胜利 @iMeaCore @Dfift半島鐵盒 @wenjiahong @星空未来
# @水瓶 @瓜瓜皮 @默认用户名8 @影灬无神 @橘猫520 @此用户名已存在
# @ピロちゃん @Jaceﮥ @黑白颠倒的年华0 @九日不能贱 @fineable
# @哑剧 @zokkkk @永恒的丶齿轮 @L风云 @Immature_H @揪你鸡儿
# @xujiyuan723 @Ace蒙奇 @ちぃ @木子茶i同学 @HEX_Stan
# @_暗香浮动月黄昏 @子喜 @ft1858336 @xxxxuanran @Scorpiring
# @猫见 @僞裝灬 @请叫我芦柑 @吃瓜子的小白 @HELISIGN @鹰雏
# @贫家boy有何贵干 @Yoooooo
# =======================================================#
# Give proper credits when using this in your work
# =======================================================#

write() {
    echo -n $2 > $1
}
mutate() 
{
    if [ -f ${2} ]; then
        chmod 0666 ${2}
        echo ${1} > ${2}
    fi
}
copy() {
    if [ "$4" == "" ];then
	if [ -e "$1" ]; then
    cat $1 > $2
	fi
	else
	src1=$(cat $1 | tr -d '\n')
	src2=$(cat $2 | tr -d '\n')
	if [ -e "$1" ] && [ -e "$2" ]; then
	write "$3" "${src1} $4 ${src2}"
	fi
	fi
}
round() {
  printf "%.$2f" "$1"
}
min()
{
    local m="$1"
    for n in "$@"
    do
        [ "$n" -lt "$m" ] && m="$n"
    done
    echo "$m"
}
max()
{
    local m="$1"
    for n in "$@"
    do
        [ "$n" -gt "$m" ] && m="$n"
    done
    echo "$m"
}
lock_value() {
	if [ -f ${2} ]; then
		chmod 0666 ${2}
		echo ${1} > ${2}
		chmod 0444 ${2}
	fi
}

is_int() { return $(test "$@" -eq "$@" > /dev/null 2>&1); }
    cores=$(awk '{ if ($0~/^physical id/) { p=$NF }; if ($0~/^core id/) { cores[p$NF]=p$NF }; if ($0~/processor/) { cpu++ } } END { for (key in cores) { n++ } } END { if (n) {print n} else {print cpu} }' /proc/cpuinfo)
    coresmax=$(cat /sys/devices/system/cpu/kernel_max) 2>/dev/null

	if [ -z ${cores} ];then
	cores=$(( ${coresmax} + 1 ))
	fi	
	
    if [ -e "/sys/devices/system/cpu/cpufreq/policy2" ];then
    bcores="2"
    elif [ -e "/sys/devices/system/cpu/cpufreq/policy6" ];then
    bcores="6"
    else
    bcores="4"
    fi
set_boost() {
	#Tune Input Boost
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_ms" ]; then
	lock_value $1 /sys/module/cpu_boost/parameters/input_boost_ms
	fi
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_ms_s2" ]; then
	lock_value 0 /sys/module/cpu_boost/parameters/input_boost_ms_s2
	fi
	if [ -e /sys/module/cpu_boost/parameters/input_boost_enabled ]; then
	lock_value 1 /sys/module/cpu_boost/parameters/input_boost_enabled
	fi
	if [ -e /sys/module/cpu_boost/parameters/sched_boost_on_input ]; then
	lock_value "N" /sys/module/cpu_boost/parameters/sched_boost_on_input
	fi
	if [ -e "/sys/kernel/cpu_input_boost/enabled" ]; then
	lock_value 1 /sys/kernel/cpu_input_boost/enabled
	lock_value $1 /sys/kernel/cpu_input_boost/ib_duration_ms
	fi
	#Disable Touch Boost
	if [ -e "/sys/module/msm_performance/parameters/touchboost" ]; then
	lock_value 0 /sys/module/msm_performance/parameters/touchboost
	fi
	if [ -e /sys/power/pnpmgr/touch_boost ]; then
	lock_value 0 /sys/power/pnpmgr/touch_boost
	fi
	#Disable CPU Boost
	if [ -e "/sys/module/cpu_boost/parameters/boost_ms" ]; then
	lock_value 0 /sys/module/cpu_boost/parameters/boost_ms
	fi

}
set_boost_freq() {
    cpu_l=$(echo $1 | awk '{split($0,a); print a[1]}') 2>/dev/null
    cpu_b=$(echo $1 | awk '{split($0,a); print a[2]}') 2>/dev/null
    cpu_l_f=$(echo $cpu_l | awk -F: '{ print($NF) }') 2>/dev/null
	cpu_b_f=$(echo $cpu_b | awk -F: '{ print($NF) }') 2>/dev/null
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq" ]; then
	freq="0:$cpu_l_f"
	i=1
	while [ $i -lt $bcores ]
	do
	freq="$i:$cpu_l_f $freq"
	i=$(( $i + 1 ))
	done
	i=$bcores
	while [ $i -lt $cores ]
	do
	freq="$i:$cpu_b_f $freq"
	i=$(( $i + 1 ))
	done	
	freq=$(echo $freq | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
	lock_value "$freq" /sys/module/cpu_boost/parameters/input_boost_freq
	if [ -e "/sys/kernel/cpu_input_boost/ib_freqs" ]; then
	lock_value "0" /sys/kernel/cpu_input_boost/ib_freqs
	fi
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq_s2" ]; then
	freq="0:0"
	i=1
	while [ $i -lt $cores ]
	do
	freq="$i:0 $freq"
	i=$(( $i + 1 ))
	done
	freq=$(echo $freq | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
	lock_value "$freq" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	fi
	else
	if [ -e "/sys/kernel/cpu_input_boost/ib_freqs" ]; then
	freq="$cpu_l_f $cpu_b_f"
	lock_value "$freq" /sys/kernel/cpu_input_boost/ib_freqs
	fi
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq_s2" ]; then
	freq="0:$cpu_l_f"
	i=1
	while [ $i -lt $cores ]
	do
	freq="$i:$cpu_b_f $freq"
	i=$(( $i + 1 ))
	done
	freq=$(echo $freq | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
	lock_value "$freq" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	fi
	fi
	if [ -e "/sys/module/cpu_boost/parameters/sync_threshold" ]; then
	lock_value 0 /sys/module/cpu_boost/parameters/sync_threshold
	lock_value 0 /sys/devices/system/cpu/cpufreq/interactive/sync_freq
	lock_value 0 /sys/devices/system/cpu*/cpufreq/interactive/sync_freq
	fi
}
backup_boost() {
copy "/sys/module/cpu_boost/parameters/input_boost_freq" "/sys/module/cpu_boost/parameters/input_boost_ms" "/data/adb/boost1.txt" "#"
copy "/sys/kernel/cpu_input_boost/ib_freqs" "/sys/kernel/cpu_input_boost/ib_duration_m" "/data/adb/boost2.txt" "#"
copy "/sys/module/cpu_boost/parameters/input_boost_freq_s2" "/sys/module/cpu_boost/parameters/input_boost_ms_s2" "/data/adb/boost3.txt" "#"
copy "/sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load" "/data/adb/go_hispeed.txt"
copy "/sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load" "/data/adb/go_hispeed_l.txt"
copy "/sys/devices/system/cpu/cpu$bcores/cpufreq/interactive/go_hispeed_load" "/data/adb/go_hispeed_b.txt"
}
restore_boost() {
	if [ -e "/data/adb/boost1.txt" ]; then
	FREQ_FILE="/data/adb/boost1.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	lock_value "$FREQ" /sys/module/cpu_boost/parameters/input_boost_freq
	lock_value $BOOSTMS /sys/module/cpu_boost/parameters/input_boost_ms
	fi
	if [ -e "/data/adb/boost2.txt" ]; then
	FREQ_FILE="/data/adb/boost2.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	lock_value "$FREQ" /sys/kernel/cpu_input_boost/ib_freqs
	lock_value $BOOSTMS /sys/kernel/cpu_input_boost/ib_duration_ms
	fi
	if [ -e "/data/adb/boost3.txt" ]; then
	FREQ_FILE="/data/adb/boost3.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	lock_value "$FREQ" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	lock_value $BOOSTMS /sys/module/cpu_boost/parameters/input_boost_ms_s2
	fi
	if [ -e "/data/adb/go_hispeed" ]; then
	$GO_HIS=$(cat /data/adb/go_hispeed.txt)
	lock_value $GO_HIS /sys/devices/system/cpu/cpufreq/interactive/go_hispeed
	fi
	if [ -e "/data/adb/go_hispeed_l" ]; then
	$GO_HIS=$(cat /data/adb/go_hispeed_l.txt)
	lock_value $GO_HIS /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed
	fi
	if [ -e "/data/adb/go_hispeed_b" ]; then
	$GO_HIS=$(cat /data/adb/go_hispeed_b.txt)
	lock_value $GO_HIS /sys/devices/system/cpu/cpu$bcores/cpufreq/interactive/go_hispeed
	fi
}
backup_eas() {
copy "/dev/stune/top-app/schedtune.boost" "/data/adb/top-app.txt"
copy "/dev/stune/foreground/schedtune.boost" "/data/adb/foreground.txt"
copy "/dev/stune/background/schedtune.boost" "/data/adb/background.txt"
copy "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "/data/adb/dynamic_stune_boost.txt"
}
backup_gpu() {
if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
GPU_DIR="/sys/class/kgsl/kgsl-3d0"
else
GPU_DIR="/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
fi

for i in ${GPU_DIR}/*
do
chmod 0666 $i
done

copy "$GPU_DIR/deep_nap_timer" "/data/adb/deep_nap_timer.txt"
copy "$GPU_DIR/idle_timer" "/data/adb/idle_timer.txt"
}

# stop before updating cfg
stop_qti_perfd()
{
    #stop perfd
    stop perf-hal-1-0
}

# start after updating cfg
start_qti_perfd()
{
    #start perfd
    start perf-hal-1-0
	
}

# $1:mode(such as balance)
update_qti_perfd()
{
    rm -rf /data/vendor/perfd/*
    cp -af ${MODDIR}/system/vendor/etc/perf/perfd_profiles/$1 ${MODDIR}/system/vendor/etc/perf/
}
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
HAS_BAK=0
LOG="/data/LKT.prop"
RETRY_INTERVAL=10 #in seconds
MAX_RETRY=30
retry=${MAX_RETRY}
#wait for boot completed
while (("$retry" > "0")) && [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep ${RETRY_INTERVAL}
  ((retry--))
done
if [ -e $LOG ]; then
  rm $LOG;
fi;
PARAM_BAK_FILE="/data/adb/.lkt_param_bak"
if [ "$1" == "" ];then
if [ -e "/data/adb/boost1.txt" ]; then
rm "/data/adb/boost1.txt"
fi;
if [ -e "/data/adb/boost2.txt" ]; then
rm "/data/adb/boost2.txt"
fi;
if [ -e "/data/adb/boost3.txt" ]; then
rm "/data/adb/boost3.txt"
fi;
if [ -e "/data/adb/background.txt" ]; then
rm "/data/adb/background.txt"
fi;
if [ -e "/data/adb/foreground.txt" ]; then
rm "/data/adb/foreground.txt"
fi;
if [ -e "/data/adb/top-app.txt" ]; then
rm "/data/adb/top-app.txt"
fi;
if [ -e "/data/adb/dynamic_stune_boost.txt" ]; then
rm "/data/adb/dynamic_stune_boost.txt"
fi;
if [ -e "/data/adb/go_hispeed.txt" ]; then
rm "/data/adb/go_hispeed.txt"
fi;
if [ -e "/data/adb/go_hispeed_l.txt" ]; then
rm "/data/adb/go_hispeed_l.txt"
fi;
if [ -e "/data/adb/go_hispeed_b.txt" ]; then
rm "/data/adb/go_hispeed_b.txt"
fi;
if [ -e "/data/adb/idle_timer.txt" ]; then
rm "/data/adb/idle_timer.txt"
fi;
if [ -e "/data/adb/deep_nap_timer.txt" ]; then
rm "/data/adb/deep_nap_timer.txt"
fi;
backup_boost
backup_eas
backup_gpu
fi;

    if [ "$2" == "" ];then
    PROFILE="<PROFILE_MODE>"
    if [ -e "/data/adb/.lkt_cur_level" ]; then
	PROFILE=$(cat /data/adb/.lkt_cur_level | tr -d '\n')
	else
	echo $PROFILE > "/data/adb/.lkt_cur_level"
	fi
	else
    PROFILE=$1
	rm "/data/adb/.lkt_cur_level"
	if [ ! -f "/data/adb/.lkt_cur_level" ]; then
	echo $1 > "/data/adb/.lkt_cur_level"
    fi
	fi
    if [ -z $2 ];then
    bootdelay=90
    else
    bootdelay=$2
    fi
    sleep ${bootdelay}
    export TZ=$(getprop persist.sys.timezone);
    #MOD Variable
    V="<VER>"
    dt=$(date '+%d/%m/%Y %H:%M:%S');
    sbusybox=`busybox | awk 'NR==1{print $2}'` 2>/dev/null
    # RAM variables
    TOTAL_RAM=$(awk '/^MemTotal:/{print $2}' /proc/meminfo) 2>/dev/null
    if [ $TOTAL_RAM -ge 1000000 ] && [ $TOTAL_RAM -lt 1500000 ]; then
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{print x/1000000}')
    memg=$(round ${memg} 1)
	else
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{printf("%.f\n", (x/1000000)+0.5)}')
    memg=$(round ${memg} 0)
    fi
    if [ ${memg} -gt 32 ];then
    memg=$(awk -v x=$memg 'BEGIN{printf("%.f\n", (x/1000)+0.5)}')
    fi
    # CPU variables
    arch_type=`uname -m` 2>/dev/null
    # Device infos
    BATT_LEV=`cat /sys/class/power_supply/battery/capacity | tr -d '\n'` 2>/dev/null
    BATT_TECH=`cat /sys/class/power_supply/battery/technology | tr -d '\n'` 2>/dev/null
    BATT_HLTH=`cat /sys/class/power_supply/battery/health | tr -d '\n'` 2>/dev/null
    BATT_TEMP=`cat /sys/class/power_supply/battery/temp | tr -d '\n'` 2>/dev/null
    BATT_VOLT=`cat /sys/class/power_supply/battery/batt_vol | tr -d '\n'` 2>/dev/null
    if [ "$BATT_LEV" == "" ];then
    BATT_LEV=`dumpsys battery | grep level | awk '{print $2}'` 2>/dev/null
    elif [ "$BATT_LEV" == "" ];then
    BATT_LEV=$(awk -F ': |;' '$1=="Percentage(%)" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    fi
    if [ "$BATT_TECH" == "" ];then
    BATT_TECH=`dumpsys battery | grep technology | awk '{print $2}'` 2>/dev/null
    fi
    if [ "$BATT_VOLT" == "" ];then
    BATT_VOLT=`dumpsys battery | awk '/^ +voltage:/ && $NF!=0{print $NF}'` 2>/dev/null
    elif [ "$BATT_VOLT" == "" ];then
    BATT_VOLT=$(awk -F ': |;' '$1=="VBAT(mV)" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    fi
    if [ "$BATT_TEMP" == "" ];then
    BATT_TEMP=`dumpsys battery | grep temperature | awk '{print $2}'` 2>/dev/null
    elif [ "$BATT_TEMP" == "" ];then
    BATT_TEMP=$(awk -F ': |;' '$1=="BATT_TEMP" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    fi
    if [ "$BATT_HLTH" == "" ];then
    BATT_HLTH=`dumpsys battery | grep health | awk '{print $2}'` 2>/dev/null
    if [ $BATT_HLTH -eq "2" ];then
    BATT_HLTH="Very Good"
    elif [ $BATT_HLTH -eq "3" ];then
    BATT_HLTH="Good"
    elif [ $BATT_HLTH -eq "4" ];then
    BATT_HLTH="Poor"
    elif [ $BATT_HLTH -eq "5" ];then
    BATT_HLTH="Sh*t"
    else
    BATT_HLTH="Unknown"
    fi
    elif [ "$BATT_HLTH" == "" ];then
    BATT_HLTH=$(awk -F ': |;' '$1=="HEALTH" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    if [ $BATT_HLTH -eq "1" ];then
    BATT_HLTH="Very Good"
    else
    BATT_HLTH="Unknown"
    fi
    fi
    BATT_TEMP=$(awk -v x=$BATT_TEMP 'BEGIN{print x/10}')
    BATT_VOLT=$(awk -v x=$BATT_VOLT 'BEGIN{print x/1000}')
    BATT_VOLT=$(round ${BATT_VOLT} 1) 
    VENDOR=`getprop ro.product.brand | tr '[:lower:]' '[:upper:]'`
    KERNEL="$(uname -r)"
    OS=`getprop ro.build.version.release`
    APP=`getprop ro.product.model`
    SOC=$(awk '/^Hardware/{print tolower($NF)}' /proc/cpuinfo | tr -d '\n') 2>/dev/null
    SOC0=`cat /sys/devices/soc0/machine  | tr -d '\n' | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC1=`cat /sys/devices/soc0/soc_id  | tr -d '\n' | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC2=`getprop ro.product.board | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC3=`getprop ro.product.platform | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC4=`getprop ro.board.platform | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC5=`getprop ro.chipname | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC6=`getprop ro.hardware | tr '[:upper:]' '[:lower:]'` 2>/dev/null
	soc_id=$(cat /sys/devices/soc0/id) 2>/dev/null
	soc_revision=$(cat /sys/devices/soc0/revision) 2>/dev/null
	adreno=0
	if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/class/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/platform/*.gpu/devfreq/*.gpu" ]; then
	GPU_DIR="/sys/devices/platform/*.gpu/devfreq/*.gpu"	
	adreno=0
	elif [ -d "/sys/devices/platform/gpusysfs" ]; then
	GPU_DIR="/sys/devices/platform/gpusysfs"
	adreno=0
	elif [ -d "/sys/devices/*.mali" ]; then
	GPU_DIR="/sys/devices/*.mali"
	adreno=0
	elif [ -d "/sys/devices/*.gpu" ]; then
	GPU_DIR="/sys/devices/*.gpu"
	adreno=0
	elif [ -d "/sys/devices/platform/mali.0" ]; then
	GPU_DIR="/sys/devices/platform/mali.0"
	adreno=0
	elif [ -d "/sys/devices/platform/mali-*.0" ]; then
	GPU_DIR="/sys/devices/platform/mali-*.0"
	adreno=0
	elif [ -d "/sys/module/mali/parameters" ]; then
	GPU_DIR="/sys/module/mali/parameters"
	adreno=0
	elif [ -d "/sys/class/misc/mali0" ]; then
	GPU_DIR="/sys/class/misc/mali0"
	adreno=0
	elif [ -d "/sys/kernel/gpu" ]; then
	GPU_DIR="/sys/kernel/gpu"
	adreno=0
	fi
	if [ -e "$GPU_DIR/devfreq/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/devfreq/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/devfreq/*.mali/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/devfreq/*.mali/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/device/devfreq/*.gpu/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/device/devfreq/*.gpu/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/device/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/device/available_frequencies) 2>/dev/null
	fi

	if [ -e "$GPU_DIR/devfreq/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/devfreq/available_governors) 2>/dev/null
	elif [ -d "$GPU_DIR/devfreq/*.mali/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/devfreq/*.mali/available_governors) 2>/dev/null
	elif [ -d "$GPU_DIR/device/devfreq/*.gpu/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/device/devfreq/*.gpu/available_governors) 2>/dev/null
	elif [ -d "$GPU_DIR/device/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/device/available_governors) 2>/dev/null
	fi

	if [ -e "$GPU_DIR/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/gpu_model) 2>/dev/null
	elif [ -d "$GPU_DIR/*.mali/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/*.mali/gpu_model) 2>/dev/null
	elif [ -d "$GPU_DIR/device/*.gpu/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/device/*.gpu/gpu_model) 2>/dev/null
	elif [ -d "$GPU_DIR/device/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/device/gpu_model) 2>/dev/null
	fi
    fstorage=$(cat proc/scsi/scsi | grep -m1 Vendor | awk '{print $4}') 2>/dev/null
	
 	case "${fstorage}" in
 	"KLUCG2K1EA-B0C1") UFS=210;;
 	"KLUCG4J1ED-B0C1") UFS=210;;
 	"KLUDG8V1EE-B0C1") UFS=210;;
 	"KLUEG8U1EM-B0C1") UFS=210;;
 	"KLUDG4U1EA-B0C1") UFS=210;;
 	"THGAF4G8N2LBAIR") UFS=210;;
 	"THGAF8T0T43BAIR") UFS=210;;
 	"H28U62301AMR") UFS=210;;
 	"H28S6D302BMR") UFS=210;;
 	"H28U74301AMR") UFS=210;;
 	"H28S7Q302BMR") UFS=210;;
 	"H28U88301AMR") UFS=210;;
 	"H28S8Q302CMR") UFS=210;;
 	"H28S9O302BMR") UFS=210;;
 	"THGBF7G8K4LBATR") UFS=200;;
 	"THGBF7G9L4LBATR") UFS=200;;
 	"THGBF7T0L8LBATA") UFS=200;;
 	"KLUBG4G1CE-B0B1") UFS=200;;
 	"KLUCG4J1CB-B0B1") UFS=200;;
 	"KLUDG8J1CB-B0B1") UFS=200;;
	*) UFS=100;;
	esac
    CPU_FILE="/data/soc.txt"
    error=0
    support=0
    snapdragon=0
    chip=0
	EAS=0
	HMP=0
	shared=1
	MSG=0
    LOGDATA() {
        echo $1 |  tee -a $LOG;
    }
    if [ -e /sys/devices/system/cpu/cpu0/cpufreq ]; then
    GOV_PATH_L=/sys/devices/system/cpu/cpu0/cpufreq
    fi
    if [ -e "/sys/devices/system/cpu/cpu${bcores}/cpufreq" ]; then
    GOV_PATH_B="/sys/devices/system/cpu/cpu${bcores}/cpufreq"
    fi
	available_governors=$(cat ${GOV_PATH_L}/scaling_available_governors)
    is_big_little=true
    if [ -z ${SOC} ];then
	error=1
    SOC=${SOC0}
	else
    #LOGDATA "#  [WARNING] SOC DETECTION FAILED. TRYING ALTERNATIVES"
	case ${SOC} in msm* | sm* | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC0}
    fi
    ;;
	*)
	error=2
    SOC=${SOC0}
    ;;
	esac
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC1}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(0) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC1}
    fi
    ;;
	*)
	error=2
	SOC=${SOC1}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC2}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(1) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC2}
    fi
    ;;
	*)
	error=2
	SOC=${SOC2}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC3}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(2) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC3}
    fi
    ;;
	*)
	error=2
 	SOC=${SOC3}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC4}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(3) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC4}
    fi
     ;;
	*)
	error=2
    SOC=${SOC4}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC5}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(3) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC5}
    fi
     ;;
	*)
	error=2
    SOC=${SOC5}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
    LOGDATA "#  [WARNING] SOC DETECTION FAILED. USING MANUAL METHOD"
    if [ -e $CPU_FILE ]; then
    if grep -q 'CPU=' $CPU_FILE
    then
    SOC7=$(awk -F= '{ print tolower($2) }' $CPU_FILE) 2>/dev/null
    else
    SOC7=$(cat $CPU_FILE | tr '[:upper:]' '[:lower:]') 2>/dev/null
    fi	
    SOC=${SOC7}
    if [ -z ${SOC} ];then
    error=3
    LOGDATA "#  [ERROR] MANUAL SOC DETECTION FAILED"
    LOGDATA "#  [INFO] $CPU_FILE IS EMPTY"
    LOGDATA "#  [INFO] PLEASE EDIT $CPU_FILE FILE WITH YOUR SOC MODEL NUMBER THEN REBOOT"
    exit 0
    fi
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
	;;
	*)
    LOGDATA "#  [ERROR] MANUAL SOC DETECTION FAILED"
    LOGDATA "#  [INFO] $CPU_FILE DOES NOT CONTAIN A VALID CPU MODEL NUMBER"
    LOGDATA "#  [INFO] PLEASE EDIT $CPU_FILE FILE WITH YOUR CORRECT SOC MODEL NUMBER THEN REBOOT"
    exit 0
	;;
	esac
    else
    LOGDATA "#  [ERROR] SOC DETECTION FAILED"
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "# 1) USING A ROOT FILE EXPLORER"
    LOGDATA "#  "
    LOGDATA "# 2) GO TO $CPU_FILE AND EDIT IT WITH YOUR CPU MODEL"
    LOGDATA "#  "
    LOGDATA "#    EXAMPLE (HUAWEI KIRIN 970)       CPU=KIRIN970"
    LOGDATA "#    EXAMPLE (SNAPDRAGON 845)         CPU=SDM845"
    LOGDATA "#    EXAMPLE (SNAPDRAGON 820 OR 821)  CPU=MSM8996"
    LOGDATA "#    EXAMPLE (GALAXY S7 EXYNOS8890)   CPU=EXYNOS8890"
    LOGDATA "#    EXAMPLE (GALAXY S8 EXYNOS8890)   CPU=EXYNOS8895"
    LOGDATA "#  "
    LOGDATA '#    PRECEEDING THE CPU MODEL NUMBER WITH "CPU=" IS NOT REQUIRED '
    LOGDATA "#    YOU CAN ALSO WRITE ONLY YOUR CPU MODEL IN SOC.TXT FILE "
    LOGDATA "#  "
    LOGDATA "# 3) SAVE CHANGES & REBOOT"
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "#  "
    LOGDATA "# TIP: USE CPU-Z APP OR FIND YOUR CORRECT CPU MODEL NUMBER ON THIS PAGE"
    LOGDATA "#  "
    LOGDATA "# https://en.wikipedia.org/wiki/List_of_Qualcomm_Snapdragon_systems-on-chip"
    write $CPU_FILE "CPU="
    exit 0
    fi	
    fi
    SOC="${SOC//[[:space:]]/}"
    SOC=`echo $SOC | tr -d -c '[:alnum:]'`
	freqs_list0=$(cat $GOV_PATH_L/scaling_available_frequencies) 2>/dev/null
    freqs_list4=$(cat $GOV_PATH_B/scaling_available_frequencies) 2>/dev/null
	maxfreq_l="$(max $freqs_list0)"
	maxfreq_b="$(max $freqs_list4)"
	minfreq_l="$(min $freqs_list0)"
	minfreq_b="$(min $freqs_list4)"
	
	if [ ! -e ${GOV_PATH_L}/scaling_available_frequencies ]; then
	maxfreq_l=$(cat "$GOV_PATH_L/cpuinfo_max_freq") 2>/dev/null	
    maxfreq_b=$(cat "$GOV_PATH_B/cpuinfo_max_freq") 2>/dev/null
	minfreq_l=$(cat "$GOV_PATH_L/cpuinfo_min_freq") 2>/dev/null	
    minfreq_b=$(cat "$GOV_PATH_B/cpuinfo_min_freq") 2>/dev/null
    fi
	
	if [ ! -e "${GOV_PATH_L}/scaling_available_frequencies" ] && [ ! -e "${GOV_PATH_L}/cpuinfo_max_freq" ]; then
	maxfreq_l=$(cat "/sys/devices/system/cpu/cpufreq/cpuinfo_max_freq") 2>/dev/null	
    maxfreq_b=${maxfreq_l}
	minfreq_l=$(cat "/sys/devices/system/cpu/cpufreq/cpuinfo_max_freq") 2>/dev/null	
    minfreq_b=${minfreq_l}
    fi

	GPU_MIN="$(min $GPU_FREQS)"
	GPU_MAX="$(max $GPU_FREQS)"
	
	if [ ! -e ${GPU_FREQS} ]; then
	GPU_MIN=$(cat "$GPU_DIR/devfreq/min_freq") 2>/dev/null	
	GPU_MAX=$(cat "$GPU_DIR/devfreq/max_freq") 2>/dev/null	
	fi

	if [ ! -e ${GPU_DIR}/devfreq/max_freq ] && [ ! -e ${GPU_DIR}/devfreq/max_freq ]; then
	GPU_MIN=$(cat "$GPU_DIR/gpuclk") 2>/dev/null	
	GPU_MAX=$(cat "$GPU_DIR/max_gpuclk") 2>/dev/null	
    fi

    before_modify()
{
for i in ${GOV_PATH_L}/interactive/*
do
chmod 0666 $i
done
for i in ${GOV_PATH_B}/interactive/*
do
chmod 0666 $i
done
if [ -d "/sys/devices/system/cpu/cpufreq/interactive" ]; then
for i in /sys/devices/system/cpu/cpufreq/interactive/*
do
chmod 0666 $i
done
fi
}
    after_modify()
{
for i in ${GOV_PATH_L}/interactive/*
do
chmod 0444 $i
done
for i in ${GOV_PATH_B}/interactive/*
do
chmod 0444 $i
done
if [ -d "/sys/devices/system/cpu/cpufreq/interactive" ]; then
for i in /sys/devices/system/cpu/cpufreq/interactive/*
do
chmod 0444 $i
done
fi
}
    before_modify_eas()
{
for i in ${GOV_PATH_L}/$1/*
do
chown 0.0 $i
chmod 0666 $i
done
for i in ${GOV_PATH_B}/$1/*
do
chown 0.0 $i
chmod 0666 $i
done	
}
    after_modify_eas()
{
for i in ${GOV_PATH_L}/$1/*
do
chmod 0444 $i
done
for i in ${GOV_PATH_B}/$1/*
do
chmod 0444 $i
done	
}
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu${bcores}/cpufreq/interactive"
C0_CPUFREQ_DIR="/sys/devices/system/cpu/cpu0/cpufreq"
C1_CPUFREQ_DIR="/sys/devices/system/cpu/cpu${bcores}/cpufreq"
if ! ${is_big_little} ; then
	C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpufreq/interactive"
	C1_GOVERNOR_DIR=""
	C0_CPUFREQ_DIR="/sys/devices/system/cpu/cpu0/cpufreq"
	C1_CPUFREQ_DIR=""
fi

update_clock_speed() {
 if [ $2 = "little" ];then
	i=0
	t_cores=${bcores}
  	lock_value "${i}:${1}" "/sys/module/msm_performance/parameters/cpu_${3}_freq"
	chmod 0644 "/sys/module/msm_performance/parameters/cpu_${3}_freq"
	while [ ${i} -lt $t_cores ]
	do
	CPUFREQ_DIR="/sys/devices/system/cpu/cpu${i}/cpufreq"
	lock_value "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
	chmod 0644 "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
	i=$(( ${i} + 1 ))
	done		
fi
if [ $2 = "big" ];then
	i=${bcores}
	t_cores=${cores}
  	lock_value "${i}:${1}" "/sys/module/msm_performance/parameters/cpu_${3}_freq"
	chmod 0644 "/sys/module/msm_performance/parameters/cpu_${3}_freq"
	while [ ${i} -lt $t_cores ]
	do
	CPUFREQ_DIR="/sys/devices/system/cpu/cpu${i}/cpufreq"
	lock_value "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
	chmod 0644 "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
	i=$(( ${i} + 1 ))
	done			
fi
if [ $2 = "prime" ];then
if [ -f  "/proc/cpufreq/cpufreq_limited_${3}_freq_by_user"  ]; then
	CPUFREQ_DIR="/sys/devices/system/cpu/cpu7/cpufreq"
	lock_value "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
    mutate "${1}" "/sys/devices/system/cpu/cpufreq/policy7/scaling_${3}_freq"
	chmod 0644 "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
fi
fi
}
set_io() {

	if [ -f $2/queue/scheduler ]; then
		if [ `grep -c $1 $2/queue/scheduler` = 1 ]; then
			write $2/queue/scheduler $1
			if [[ "$1" == "cfq" ]];then
			# lower read_ahead_kb to reduce random access overhead
			write $2/queue/read_ahead_kb 128
			for i in /sys/block/*/queue/iosched; do
			  write $i/low_latency 0;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/group_idle 8;
			done;
			if [ $UFS -ge 200 ]; then
		    	# UFS 2.0+ hardware queue depth is 32
		    	for i in /sys/block/*/queue/iosched; do
		    	    write $i/quantum 16;
		    	done;
			fi
			# slice_idle = 0 means CFQ IOP mode, https://lore.kernel.org/patchwork/patch/944972/
			for i in /sys/block/*/queue/iosched; do
			  write $i/slice_idle 0;
			done;
			# Flash doesn't have back seek problem, so penalty is as low as possible
			for i in /sys/block/*/queue/iosched; do
			  write $i/back_seek_penalty 1;
			done;
				elif [[ "$1" == "maple" ]];then
			for i in /sys/block/*/queue/iosched; do
			  write $i/async_read_expire 666;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/async_write_expire 1666;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/fifo_batch 16;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/sleep_latency_multiple 5;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/sync_read_expire 333;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/sync_write_expire 1166;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/writes_starved 3;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/read_ahead_kb 128;
			done;
			else
			write $2/queue/read_ahead_kb 128
			fi
  		fi
	fi
	
}
    # Manually add infos that are not found/ inaccurate for some devices
	case ${SOC} in sm8150* | msmnile* ) #sd855
    support=1
	maxfreq_l=1880000
	maxfreq_b=2880000
	#update_clock_speed 280000 little min
	#update_clock_speed 680000 big min
	esac
	case ${SOC} in sdm845* | sda845* ) #sd845
    support=1
	maxfreq_l=1780000
	maxfreq_b=2880000
	update_clock_speed 280000 little min
	update_clock_speed 780000 big min
	esac
	case ${SOC} in msm8998* | apq8098*) #sd835
    support=1
	esac
    case ${SOC} in msm8996* | apq8096*) #sd820
    support=1
	esac

	case ${SOC} in sm6150*) #sd675/730
    support=1
	esac
	case ${SOC} in sdm710*) #sd710
    support=1
	esac
	case ${SOC} in msm8994*) #sd810
    support=0
	maxfreq_l=1555200
	maxfreq_b=1958400
	cores=8
	bcores=4
	esac
	case ${SOC} in msm8992*) #sd808
    support=0
	maxfreq_l=1440000
	maxfreq_b=1824000
	cores=6
	bcores=4
	esac
	case ${SOC} in apq8074* | apq8084* | msm8074* | msm8084* | msm8274* | msm8674*| msm8974*)  #sd800-801-805
	is_big_little=false
    support=0
	esac
	case ${SOC} in sdm660* | sda660*) #sd660
    support=1
	esac
	case ${SOC} in msm8956* | msm8976*)  #sd650/652/653
    support=1
	esac
	case ${SOC} in sdm636* | sda636*) #sd636
    support=1
	esac
	case ${SOC} in msm8953* | sdm630* | sda630* )  #sd625/626/630
    support=1
	esac
	case ${SOC} in universal9810* | exynos9810*) #exynos9810
    support=0
	maxfreq_l=1794000
	maxfreq_b=2704000
  	cores=8
	bcores=4
	MSG=1
	esac
	case ${SOC} in universal8895* | exynos8895*)  #EXYNOS8895 (S8)
    support=1
	maxfreq_l=1690000
	maxfreq_b=2314000
	cores=8
	bcores=4
	esac
	case ${SOC} in universal8890* | exynos8890*)  #EXYNOS8890 (S7)
    support=1
	maxfreq_l=1586000
	maxfreq_b=2600000
	cores=8
	bcores=4
	esac
	case ${SOC} in universal7420* | exynos7420*) #EXYNOS7420 (S6)
    support=1
	esac
	case ${SOC} in kirin970* | hi3670*)  # Huawei Kirin 970
    support=0
	esac
	case ${SOC} in kirin960* | hi3660*)  # Huawei Kirin 960
    support=0
	esac
	case ${SOC} in kirin950* | hi3650* | kirin955* | hi3655*) # Huawei Kirin 950
    support=0
	esac
	case ${SOC} in mt6797*) #Helio X25 / X20	 
    support=0
	maxfreq_l=2100000
	maxfreq_b=2100000
	esac
	case ${SOC} in mt6795*) #Helio X10
    support=0
	maxfreq_l=1950000
	maxfreq_b=1950000
	esac
	case ${SOC} in moorefield*) # Intel Atom
    support=0
	esac
	case ${SOC} in msm8939* | msm8952*)  #sd615/616/617 by@ 橘猫520
	 if [ "$SOC" = "msm8952" ]; then
	 maxfreq_l=1516800
	 maxfreq_b=1209600
	 fi
    support=0
	cores=8
	bcores=4
	MSG=1
    esac
    case ${SOC} in kirin650* | kirin655* | kirin658* | kirin659* | hi625*)  #KIRIN650 by @橘猫520
    support=0
	MSG=1
    esac
    case ${SOC} in apq8026* | apq8028* | apq8030* | msm8226* | msm8228* | msm8230* | msm8626* | msm8628* | msm8630* | msm8926* | msm8928* | msm8930*)  #sd400 series by @cjybyjk
	is_big_little=false
    support=0
	cores=4
	bcores=2
	MSG=1
    esac
	case ${SOC} in apq8016* | msm8916* | msm8216* | msm8917* | msm8217*)  #sd410/sd425 series by @cjybyjk
	is_big_little=false
    support=0
	cores=4
	bcores=2
	MSG=2
    esac
	case ${SOC} in msm8937*)  #sd430 series by @cjybyjk
	maxfreq_l=1401000
	maxfreq_b=1094400
    support=0
	cores=8
	bcores=4
	MSG=1
    esac
	case ${SOC} in msm8940*)  #sd435 series by @cjybyjk
	is_big_little=false
    support=0
	cores=8
	bcores=4
	MSG=1
    esac
	case ${SOC} in sdm450*)  #sd450 series by @cjybyjk
    support=0
	cores=8
	bcores=4
	MSG=1
    esac
	case ${SOC} in mt6755*)  #P10 
    support=0
	MSG=1
    esac
	
	if [[ "$available_governors" == *"schedutil"* ]]; then
	EAS=1
	fi
	if [[ "$available_governors" == *"sched"* ]]; then
	EAS=1
	fi
	if [[ "$available_governors" == *"blu_schedutil"* ]]; then
	EAS=1
	fi
	if [[ "$available_governors" == *"pwrutil"* ]]; then
	EAS=1
	fi
	if [[ "$available_governors" == *"pwrutilx"* ]]; then
	EAS=1
	fi
	if [[ "$available_governors" == *"darkutil"* ]]; then
	EAS=1
	fi
	if [[ "$available_governors" == *"helix"* ]]; then
	EAS=1
	fi
	if [[ "$available_governors" == *"schedalucard"* ]]; then
	EAS=1
	fi
	if [[ "$available_governors" == *"electroutil"* ]]; then
	EAS=1
	fi
	if [ -d "/sys/devices/system/cpu/cpu0/cpufreq/schedutil" ] || [ -d "/sys/devices/system/cpu/cpu0/cpufreq/sched" ]; then
	EAS=1
	fi
	if [ -d "/sys/devices/system/cpu/cpufreq/schedutil" ] || [ -d "/sys/devices/system/cpu/cpufreq/sched" ]; then
	EAS=1
	fi
	
	# If EAS then all profiles all supported
	if [ ${EAS} -eq 1 ];then
	support=1
	MSG=0
	fi
	
	if [ ${PROFILE} -eq 0 ];then
	PROFILE_B="Battery"
	PROFILE_P="powersave"
	elif [ ${PROFILE} -eq 1 ];then
	PROFILE_B="Balanced"
	PROFILE_P="balance"
	elif [ ${PROFILE} -eq 2 ];then
	PROFILE_B="Performance"
	PROFILE_P="performance"
	elif [ ${PROFILE} -eq 3 ];then
	PROFILE_B="Turbo"
	PROFILE_P="fast"
	fi
case ${MSG} in
		"1")
    if [ ${PROFILE} -ne 1 ]; then
	PROFILE=1
	else
	MSG=0
	fi
		;;
		"2")
    if [ ${PROFILE} -eq 0 ] || [ ${PROFILE} -eq 3 ]; then
	PROFILE=1
	else
	MSG=0
	fi
		;;
esac
	if [ ${PROFILE} -eq 0 ];then
	PROFILE_M="Battery"
	elif [ ${PROFILE} -eq 1 ];then
	PROFILE_M="Balanced"
	elif [ ${PROFILE} -eq 2 ];then
	PROFILE_M="Performance"
	elif [ ${PROFILE} -eq 3 ];then
	PROFILE_M="Turbo"
	fi
    maxfreq=$(awk -v x=$maxfreq_b 'BEGIN{print x/1000000}')
    maxfreq=$(round ${maxfreq} 2)
    GPU_MAX_MHz=$(awk -v x=$GPU_MAX 'BEGIN{print x/1000000}')
    GPU_MAX_MHz=$(round ${GPU_MAX_MHz} 0)
	LOGDATA "###### LKT™ $V" 
	LOGDATA "###### PROFILE : ${PROFILE_M}"
    LOGDATA "#  START : $(date +"%d-%m-%Y %r")" 
    LOGDATA "#  =================================" 
    LOGDATA "#  VENDOR : $VENDOR" 
    LOGDATA "#  DEVICE : $APP" 
if [ ${GPU_MAX} -eq 0 ] || [ -z ${GPU_MODEL} ] ;then
    LOGDATA "#  CPU : $SOC @ $maxfreq GHz ($cores x cores)"
else
    LOGDATA "#  CPU : $SOC @ $maxfreq GHz ($cores x cores)"
    LOGDATA "#  GPU : $GPU_MODEL @ $GPU_MAX_MHz MHz"
fi
    LOGDATA "#  RAM : $memg GB"
	
Flash Storage Chip
    LOGDATA "#  =================================" 
    LOGDATA "#  ANDROID : $OS" 
    LOGDATA "#  KERNEL : $KERNEL" 
    LOGDATA "#  BUSYBOX  : $sbusybox" 
    LOGDATA "# ================================="
    if [ -z ${sbusybox} ]; then
	LOGDATA "#  [WARNING] BUSYBOX NOT FOUND"
	fi
case ${MSG} in
		"1")
	LOGDATA "#  [INFO] ${PROFILE_B} PROFILE ISN'T AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
		;;
		"2")
	LOGDATA "#  [INFO] ONLY BALANCED & PERFORMANCE PROFILES ARE AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
		;;
esac
    if [ "$SOC" != "${SOC/sm/}" ] || [ "$SOC" != "${SOC/sda/}" ] || [ "$SOC" != "${SOC/sdm/}" ] || [ "$SOC" != "${SOC/apq/}" ];     then
    snapdragon=1
    else
    snapdragon=0
    fi

disable_lmk() {
if [ -e "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" ]; then
 lock_value 0 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
 lock_value 0 /sys/module/process_reclaim/parameters/enable_process_reclaim
 setprop lmk.autocalc false
 else
LOGDATA "#  [WARNING] ADAPTIVE LMK IS NOT SUPPORTED BY YOUR KERNEL" 
fi;
}
ramtuning() { 

# =========
# Low Memory Killer
# =========

if [ ${memg} -gt 4 ]; then
LMK1=18432
LMK2=23040
LMK3=27648
LMK4=51256
LMK5=122880
LMK6=150296
    elif [ ${memg} -gt 2 ]; then
LMK1=18432
LMK2=23040
LMK3=27648
LMK4=51200
LMK5=150296 #110296
LMK6=200640 #147456
    elif [ ${memg} -gt 1 ]; then
LMK1=14746
LMK2=18432
LMK3=22118
LMK4=25805
LMK5=40000
LMK6=55000
fi

if [ ${PROFILE} -eq 0 ];then
c=("${LIGHT[@]}")
elif [ ${PROFILE} -eq 1 ];then
c=("${LIGHT[@]}")
elif [ ${PROFILE} -eq 2 ];then
c=("${AGGRESSIVE[@]}")
elif [ ${PROFILE} -eq 3 ];then
c=("${LIGHT[@]}")
fi

if [ -e "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" ]; then
lock_value 1 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
fi
if [ -e "/sys/module/lowmemorykiller/parameters/minfree" ]; then
lock_value "$LMK1,$LMK2,$LMK3,$LMK4,$LMK5,$LMK6" /sys/module/lowmemorykiller/parameters/minfree
fi
if [ -e "/sys/module/lowmemorykiller/parameters/oom_reaper" ]; then
lock_value 1 /sys/module/lowmemorykiller/parameters/oom_reaper
fi
# =========
# Vitual Memory
# =========
LOGDATA "#  [INFO] CONFIGURING ANDROID VM"
for i in /proc/sys/vm/*;
do
chmod 0666 $i
done
for i in /proc/sys/fs/*;
do
chmod 0666 $i
done

if [ ${memg} -ge 3 ];then
#write /proc/sys/vm/swappiness 60
write /proc/sys/vm/dirty_ratio 5
write /proc/sys/vm/dirty_background_ratio 1
else
#write /proc/sys/vm/swappiness 100
write /proc/sys/vm/dirty_ratio 20
write /proc/sys/vm/dirty_background_ratio 5
fi

if [ ${PROFILE} -eq 0 ];then
write /proc/sys/vm/drop_caches 1
write /proc/sys/vm/vfs_cache_pressure 30
write /proc/sys/vm/laptop_mode 0
write /proc/sys/vm/dirty_writeback_centisecs 5000
write /proc/sys/vm/dirty_expire_centisecs 200
write /proc/sys/fs/leases-enable 1
write /proc/sys/fs/dir-notify-enable 0
write /proc/sys/fs/lease-break-time 45
write /proc/sys/vm/compact_memory 1
write /proc/sys/vm/compact_unevictable_allowed 1
write /proc/sys/vm/page-cluster 0
write /proc/sys/vm/panic_on_oom 0
#sysctl -e -w kernel.random.read_wakeup_threshold 64
#sysctl -e -w kernel.random.write_wakeup_threshold 96
elif [ ${PROFILE} -eq 1 ] || [ ${PROFILE} -eq 2 ];then
write /proc/sys/vm/drop_caches 1
write /proc/sys/vm/vfs_cache_pressure 76
write /proc/sys/vm/laptop_mode 0
write /proc/sys/vm/dirty_writeback_centisecs 5000
write /proc/sys/vm/dirty_expire_centisecs 200
write /proc/sys/fs/leases-enable 1
write /proc/sys/fs/dir-notify-enable 0
write /proc/sys/fs/lease-break-time 20
write /proc/sys/vm/compact_memory 1
write /proc/sys/vm/compact_unevictable_allowed 1
write /proc/sys/vm/page-cluster 0
write /proc/sys/vm/panic_on_oom 0
#sysctl -e -w kernel.random.read_wakeup_threshold 64
#sysctl -e -w kernel.random.write_wakeup_threshold 128
else
write /proc/sys/vm/drop_caches 3
write /proc/sys/vm/vfs_cache_pressure 100
write /proc/sys/vm/laptop_mode 0
write /proc/sys/vm/dirty_writeback_centisecs 500
write /proc/sys/vm/dirty_expire_centisecs 200
write /proc/sys/fs/leases-enable 1
write /proc/sys/fs/dir-notify-enable 0
write /proc/sys/fs/lease-break-time 10
write /proc/sys/vm/compact_memory 1
write /proc/sys/vm/compact_unevictable_allowed 1
write /proc/sys/vm/page-cluster 0
write /proc/sys/vm/panic_on_oom 0
#sysctl -e -w kernel.random.read_wakeup_threshold 64
#sysctl -e -w kernel.random.write_wakeup_threshold 128
fi

for i in /proc/sys/vm/*;
do
chmod 0444 $i
done

for i in /proc/sys/fs/*;
do
chmod 0444 $i
done

sync;

}
cputuning() {
    if [ ${snapdragon} -eq 1 ];then
    # disable thermal bcl hotplug to switch governor
    write /sys/module/msm_thermal/core_control/enabled "0"
    write /sys/module/msm_thermal/parameters/enabled "N"
    else
    # Linaro HMP, between 0 and 1024, maybe compare to the capacity of current cluster
    # PELT and period average smoothing sampling, so the parameter style differ from WALT by Qualcomm a lot.
    # https://lists.linaro.org/pipermail/linaro-dev/2012-November/014485.html
    # https://www.anandtech.com/show/9330/exynos-7420-deep-dive/6
    # lock_value 60 /sys/kernel/hmp/load_avg_period_ms
    lock_value 256 /sys/kernel/hmp/down_threshold
    lock_value 640 /sys/kernel/hmp/up_threshold
    lock_value 0 /sys/kernel/hmp/boost
	# Exynos hotplug
	lock_value 0 /sys/power/cpuhotplug/enabled
	lock_value 0 /sys/devices/system/cpu/cpuhotplug/enabled
	lock_value 1 /sys/devices/system/cpu/cpu4/online
	lock_value 1 /sys/devices/system/cpu/cpu5/online
	lock_value 1 /sys/devices/system/cpu/cpu6/online
	lock_value 1 /sys/devices/system/cpu/cpu7/online
    fi

    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        bcl_hotplug_mask=`cat $hotplug_mask`
        write $hotplug_mask 0
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
        write $hotplug_soc_mask 0
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done

	if [ -e /data/system/perfd/default_values ]; then
	rm /data/system/perfd/default_values
	fi
	sleep "0.001"
	# Bring all cores online
	num=0
	while [ $num -le $coresmax ]
	do
	write "/sys/devices/system/cpu/cpu${num}/online" 1
	num=$(( $num + 1 ))
	done
	write "/sys/devices/system/cpu/online" "0-$coresmax"
	string1="${GOV_PATH_L}/scaling_available_governors";
	string2="${GOV_PATH_B}/scaling_available_governors";
	if [ ${PROFILE} -eq 0 ];then
	if [ -e "/sys/module/lazyplug" ]; then
	write "/sys/module/lazyplug/parameters/cpu_nr_run_theshold" '1250'
	write "/sys/module/lazyplug/parameters/cpu_nr_hysteresis" '5'
	write "/sys/module/lazyplug/parameters/nr_run_profile_sel" '0'
	fi
	fi
	# Enable power efficient work_queue mode
	if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
	lock_value "Y" "/sys/module/workqueue/parameters/power_efficient"
	LOGDATA "#  [INFO] ENABLING POWER EFFICIENT WORKQUEUE MODE " 
	fi

if [ ${EAS} -eq 1 ];then
	EAS=1

	LOGDATA "#  [INFO] EAS KERNEL SUPPORT DETECTED"

	if [[ "$available_governors" == *"sched"* ]]; then
	EASGOV="sched"
	fi
	if [[ "$available_governors" == *"schedutil"* ]]; then
	EASGOV="schedutil"
	fi
	if [[ "$available_governors" == *"electroutil"* ]]; then
	EASGOV="electroutil"
	fi
	if [[ "$available_governors" == *"darkutil"* ]]; then
	EASGOV="darkutil"
	fi
	if [[ "$available_governors" == *"schedalucard"* ]]; then
	EASGOV="schedalucard"
	fi
	if [[ "$available_governors" == *"pwrutil"* ]]; then
	EASGOV="pwrutil"
	fi
	if [[ "$available_governors" == *"pwrutilx"* ]]; then
	EASGOV="pwrutilx"
	fi
	if [[ "$available_governors" == *"helix"* ]]; then
	EASGOV="helix"
	fi
	if [[ "$available_governors" == *"blu_schedutil"* ]]; then
	EASGOV="blu_schedutil"
    fi
	
	i=0
	while [ $i -lt $cores ]
	do
	dir="/sys/devices/system/cpu/cpu$i/cpufreq"
	lock_value ${EASGOV} ${dir}/scaling_governor
	i=$(( $i + 1 ))
	done
	
	govn=${EASGOV}
	stop_qti_perfd
	
	before_modify_eas ${govn}
	LOGDATA "#  [INFO] APPLYING ${govn} GOVERNOR PARAMETERS"
		
# treat crtc_commit as display
change_task_cgroup "crtc_commit" "display" "cpuset"

# avoid display preemption on big
lock_value "0-3" /dev/cpuset/display/cpus

# fix laggy bilibili feed scrolling
LOGDATA "#  [INFO] Fixing Scrolling Lag"
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
	LOGDATA "#  [INFO] ADJUSTING SCHEDTUNE PARAMETERS" 
	write "/dev/stune/schedtune.boost" 0
	write "/dev/stune/schedtune.prefer_idle" 1
	write "/dev/stune/cgroup.clone_children" 0
	write "/dev/stune/cgroup.sane_behavior" 0
	write "/dev/stune/notify_on_release" 0
	write "/dev/stune/top-app/schedtune.sched_boost" 0
	write "/dev/stune/top-app/notify_on_release" 0
	write "/dev/stune/top-app/cgroup.clone_children" 0
   	write "/dev/stune/foreground/schedtune.sched_boost" 0
	write "/dev/stune/foreground/notify_on_release" 0
	write "/dev/stune/foreground/cgroup.clone_children" 0
	write "/dev/stune/background/schedtune.sched_boost" 0
	write "/dev/stune/background/notify_on_release" 0
	write "/dev/stune/background/cgroup.clone_children" 0
	write "/proc/sys/kernel/sched_use_walt_task_util" 1
	write "/proc/sys/kernel/sched_use_walt_cpu_util" 1
	write "/proc/sys/kernel/sched_walt_cpu_high_irqload" 10000000
	write "/proc/sys/kernel/sched_rt_runtime_us" 950000	
	write "/proc/sys/kernel/sched_latency_ns" 100000
	LOGDATA "#  [INFO] TUNING CONTROL GROUPS (CGroups)" 
	write "/dev/cpuset/cgroup.clone_children" 0
	write "/dev/cpuset/cgroup.sane_behavior" 0
	write "/dev/cpuset/notify_on_release" 0
	write "/dev/cpuctl/cgroup.clone_children" 0
	write "/dev/cpuctl/cgroup.sane_behavior" 0
	write "/dev/cpuctl/notify_on_release" 0
	write "/dev/cpuctl/cpu.rt_period_us" 1000000
	write "/dev/cpuctl/cpu.rt_runtime_us" 950000
	write "/dev/cpuctl/bg_non_interactive/cpu.rt_runtime_us" 10000
	mutate 1 "/dev/stune/top-app/schedtune.prefer_idle"
	mutate 1 "/dev/stune/foreground/schedtune.prefer_idle"
    mutate 0 "/dev/stune/background/schedtune.prefer_idle"
    mutate 0 "/dev/stune/rt/schedtune.prefer_idle"
	dynstune=$(cat /data/adb/dynamic_stune_boost.txt | tr -d '\n')	
	if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]];then
	if [ ${PROFILE} -eq 0 ];then
	dynstune=$(awk -v x=$dynstune 'BEGIN{print x/1.8}')
	dynstune=$(round ${dynstune} 0)
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost ${dynstune}
	elif [ ${PROFILE} -eq 1 ]; then
	dynstune=$(awk -v x=$dynstune 'BEGIN{print x*0.8}')
	dynstune=$(round ${dynstune} 0)
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost ${dynstune}
	elif [ ${PROFILE} -eq 2 ]; then
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost ${dynstune}
	elif [ ${PROFILE} -eq 3 ]; then
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost ${dynstune}
	fi
	fi

	sleep 2
	case ${SOC} in sm8150* | msmnile* ) #sd855
    # prevent foreground using big cluster, may be override
    mutate "0-3" /dev/cpuset/foreground/cpus

    # task_util(p) = p->ravg.demand_scaled <= sysctl_sched_min_task_util_for_boost
    mutate "12" /proc/sys/kernel/sched_min_task_util_for_boost
    mutate "96" /proc/sys/kernel/sched_min_task_util_for_colocation
    # normal colocation util report
    mutate "1000000" /proc/sys/kernel/sched_little_cluster_coloc_fmin_khz

    # turn off hotplug to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu0/core_ctl/enable
    # tend to online more cores to balance parallel tasks
    mutate "15" /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
    mutate "5" /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
    mutate "100" /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
    mutate "3" /sys/devices/system/cpu/cpu4/core_ctl/task_thres
    # task usually doesn't run on cpu7
    mutate "15" /sys/devices/system/cpu/cpu7/core_ctl/busy_up_thres
    mutate "10" /sys/devices/system/cpu/cpu7/core_ctl/busy_down_thres
    mutate "100" /sys/devices/system/cpu/cpu7/core_ctl/offline_delay_ms

    # unify scaling_min_freq, may be override
    mutate "576000" /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    mutate "710400" /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    mutate "825600" /sys/devices/system/cpu/cpufreq/policy7/scaling_min_freq

    # unify scaling_max_freq, may be override
    mutate "1785600" /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
    mutate "2419100" /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    mutate "2841600" /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq

    # unify group_migrate, may be override
	mutate "110" /proc/sys/kernel/sched_group_upmigrate
	mutate "100" /proc/sys/kernel/sched_group_downmigrate
	
	if [ ${PROFILE} -eq 0 ];then
	update_clock_speed 1612800 big max
	update_clock_speed 2016000 prime max
    # may be override
    mutate "300000" /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    mutate "710400" /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    mutate "825600" /sys/devices/system/cpu/cpufreq/policy7/scaling_min_freq

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90 60" /proc/sys/kernel/sched_downmigrate
    mutate "90 85" /proc/sys/kernel/sched_upmigrate
    mutate "90 60" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1113600 4:825600 7:0"
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "0" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
    # task usually doesn't run on cpu7
    lock_value "1" /sys/devices/system/cpu/cpu7/core_ctl/enable
    mutate "0" /sys/devices/system/cpu/cpu7/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 1 ]; then
	update_clock_speed 1804800 big max
	update_clock_speed 2419100 prime max
    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90 60" /proc/sys/kernel/sched_downmigrate
    mutate "90 85" /proc/sys/kernel/sched_upmigrate
    mutate "90 60" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1113600 4:825600 7:0" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "2" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
    # task usually doesn't run on cpu7
    lock_value "1" /sys/devices/system/cpu/cpu7/core_ctl/enable
    mutate "0" /sys/devices/system/cpu/cpu7/core_ctl/min_cpus
	
	elif [ ${PROFILE} -eq 2 ]; then
	update_clock_speed 2419100 big max
	update_clock_speed 2745600 prime max
    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90 60" /proc/sys/kernel/sched_downmigrate
    mutate "90 85" /proc/sys/kernel/sched_upmigrate
    mutate "90 60" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "10" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1209600 4:1612800 7:0" 
    set_boost 2000
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "3" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
    # task usually doesn't run on cpu7
    lock_value "1" /sys/devices/system/cpu/cpu7/core_ctl/enable
    mutate "0" /sys/devices/system/cpu/cpu7/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 3 ]; then # Turbo
	update_clock_speed 1804800 big max
	update_clock_speed 2649600 prime max
    # may be override
    mutate "576000" /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    mutate "1401600" /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    mutate "1401600" /sys/devices/system/cpu/cpufreq/policy7/scaling_min_freq

    # easier to boost
    mutate "16" /proc/sys/kernel/sched_min_task_util_for_boost
    mutate "16" /proc/sys/kernel/sched_min_task_util_for_colocation
    mutate "40 40" /proc/sys/kernel/sched_downmigrate
    mutate "40 60" /proc/sys/kernel/sched_upmigrate
    mutate "40 40" /proc/sys/kernel/sched_downmigrate

    # avoid being the bottleneck
    # mutate "1440000000" /sys/class/devfreq/soc:qcom,cpu0-cpu-l3-lat/min_freq
    # mutate "1440000000" /sys/class/devfreq/soc:qcom,cpu4-cpu-l3-lat/min_freq
    # mutate "1440000000" /sys/class/devfreq/soc:qcom,cpu7-cpu-l3-lat/min_freq

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "20" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:0 4:1804800 7:1612800" 
    set_boost 2000
    lock_value "1" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "3" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu7/core_ctl/enable
    mutate "1" /sys/devices/system/cpu/cpu7/core_ctl/min_cpus
	fi
	update_qti_perfd ${PROFILE_P}
	;;

	sdm845* )
    # prevent foreground using big cluster, may be override
    mutate "0-3" /dev/cpuset/foreground/cpus

    # turn off hotplug to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu0/core_ctl/enable
    # tend to online more cores to balance parallel tasks
    mutate "15" /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
    mutate "5" /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
    mutate "100" /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms

    # unify scaling_min_freq, may be override
    mutate "576000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "825600" /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

    # unify scaling_max_freq, may be override
    mutate "1766400" /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    mutate "2803200" /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq

    # unify group_migrate, may be override
	mutate "110" /proc/sys/kernel/sched_group_upmigrate
	mutate "100" /proc/sys/kernel/sched_group_downmigrate
	if [ ${PROFILE} -eq 0 ]; then
	update_clock_speed 1843200 big max

    # may be override
    mutate "300000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "300000" /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1209600 4:1036800" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "0" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 1 ]; then
	update_clock_speed 2323200 big max

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1209600 4:1036800" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "2" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 2 ]; then
	update_clock_speed 2803200 big max

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "10" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1228800 4:1612800" 
    set_boost 2000
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "4" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 3 ]; then # Turbo
	update_clock_speed 2323200 big max

    # may be override
    mutate "576000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "1612800" /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

    # easier to boost
    mutate "40" /proc/sys/kernel/sched_downmigrate
    mutate "60" /proc/sys/kernel/sched_upmigrate
    mutate "40" /proc/sys/kernel/sched_downmigrate

    # avoid being the bottleneck
    # mutate "1401600000" /sys/class/devfreq/soc:qcom,l3-cpu0/min_freq
    # mutate "1401600000" /sys/class/devfreq/soc:qcom,l3-cpu4/min_freq

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "20" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:0 4:1612800" 
    set_boost 2000
    lock_value "1" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "4" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	fi
		update_qti_perfd ${PROFILE_P}

	;;

	sm6150* )
lock_value "0-5" /dev/cpuset/display/cpus
    # prevent foreground using big cluster, may be override
    mutate "0-5" /dev/cpuset/foreground/cpus

    # tend to online more cores to balance parallel tasks
    mutate "15" /sys/devices/system/cpu/cpu6/core_ctl/busy_up_thres
    mutate "5" /sys/devices/system/cpu/cpu6/core_ctl/busy_down_thres
    mutate "100" /sys/devices/system/cpu/cpu6/core_ctl/offline_delay_ms

    # unify scaling_min_freq, may be override
    mutate "576000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "652800" /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

    # unify scaling_max_freq, may be override
    mutate "1804800" /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    mutate "2208000" /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq

    # unify group_migrate, may be override
	mutate "110" /proc/sys/kernel/sched_group_upmigrate
	mutate "100" /proc/sys/kernel/sched_group_downmigrate
	if [ ${PROFILE} -eq 0 ]; then
    mutate 1555200 /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq

    # may be override
    mutate "300000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "300000" /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1200000 6:1000000" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu6/core_ctl/enable
    mutate "0" /sys/devices/system/cpu/cpu6/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 1 ]; then
    mutate 1880000 /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq
    # may be override
    mutate "300000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "300000" /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1200000 6:1000000" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu6/core_ctl/enable
    mutate "1" /sys/devices/system/cpu/cpu6/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 2 ]; then
    mutate ${maxfreq_b} /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "10" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1200000 6:1500000" 
    set_boost 2000
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu0/core_ctl/enable
    lock_value "0" /sys/devices/system/cpu/cpu6/core_ctl/enable
    mutate "2" /sys/devices/system/cpu/cpu6/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 3 ]; then # Turbo
    mutate ${maxfreq_b} /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq
	
    # may be override
    mutate "576000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "1500000" /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

    # easier to boost
    mutate "40" /proc/sys/kernel/sched_downmigrate
    mutate "60" /proc/sys/kernel/sched_upmigrate
    mutate "40" /proc/sys/kernel/sched_downmigrate

    # avoid being the bottleneck
    # mutate "1344000000" /sys/class/devfreq/soc:qcom,cpu0-cpu-l3-lat/min_freq
    # mutate "1344000000" /sys/class/devfreq/soc:qcom,cpu6-cpu-l3-lat/min_freq

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "20" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:0 6:1500000" 
    set_boost 2000
    lock_value "1" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu0/core_ctl/enable
    lock_value "0" /sys/devices/system/cpu/cpu6/core_ctl/enable
    mutate "2" /sys/devices/system/cpu/cpu6/core_ctl/min_cpus
	fi
	update_qti_perfd ${PROFILE_P}
	;;

	sdm710* )
lock_value "0-5" /dev/cpuset/display/cpus
    # prevent foreground using big cluster, may be override
    mutate "0-5" /dev/cpuset/foreground/cpus

    # tend to online more cores to balance parallel tasks
    mutate "15" /sys/devices/system/cpu/cpu6/core_ctl/busy_up_thres
    mutate "5" /sys/devices/system/cpu/cpu6/core_ctl/busy_down_thres
    mutate "100" /sys/devices/system/cpu/cpu6/core_ctl/offline_delay_ms

    # unify scaling_min_freq, may be override
    mutate "576000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "652800" /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

    # unify scaling_max_freq, may be override
    mutate "1708800" /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    mutate "2208000" /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq

    # unify group_migrate, may be override
	mutate "110" /proc/sys/kernel/sched_group_upmigrate
	mutate "100" /proc/sys/kernel/sched_group_downmigrate
	if [ ${PROFILE} -eq 0 ]; then
    mutate 1747200 /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq

    # may be override
    mutate "300000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "300000" /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1209660 6:1132800" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu6/core_ctl/enable
    mutate "0" /sys/devices/system/cpu/cpu6/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 1 ]; then
    mutate 2016000 /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq

    # may be override
    mutate "300000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "300000" /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1209660 6:1132800" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu6/core_ctl/enable
    mutate "1" /sys/devices/system/cpu/cpu6/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 2 ]; then
    mutate 2208000 /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "10" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1209600 6:1843200" 
    set_boost 2000
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu0/core_ctl/enable
    lock_value "0" /sys/devices/system/cpu/cpu6/core_ctl/enable
    mutate "2" /sys/devices/system/cpu/cpu6/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 3 ]; then # Turbo
    mutate 2208000 /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq

    # may be override
    mutate "576000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "1843200" /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

    # easier to boost
    mutate "40" /proc/sys/kernel/sched_downmigrate
    mutate "60" /proc/sys/kernel/sched_upmigrate
    mutate "40" /proc/sys/kernel/sched_downmigrate

    # avoid being the bottleneck
    # mutate "1344000000" /sys/class/devfreq/soc:qcom,cpu0-cpu-l3-lat/min_freq
    # mutate "1344000000" /sys/class/devfreq/soc:qcom,cpu6-cpu-l3-lat/min_freq

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "20" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:0 6:1843200" 
    set_boost 2000
    lock_value "1" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu0/core_ctl/enable
    lock_value "0" /sys/devices/system/cpu/cpu6/core_ctl/enable
    mutate "2" /sys/devices/system/cpu/cpu6/core_ctl/min_cpus
	fi
	update_qti_perfd ${PROFILE_P}
	;;
	msm8998* )


    # prevent foreground using big cluster, may be override
    mutate "0-3" /dev/cpuset/foreground/cpus

    # turn off hotplug to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu0/core_ctl/enable
    # tend to online more cores to balance parallel tasks
    mutate "15" /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
    mutate "5" /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
    mutate "100" /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms

    # unify scaling_min_freq, may be override
    mutate "300000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "300000" /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

    # unify scaling_max_freq, may be override
    mutate "1900800" /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    mutate "2457600" /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq

    # unify group_migrate, may be override
	mutate "110" /proc/sys/kernel/sched_group_upmigrate
	mutate "100" /proc/sys/kernel/sched_group_downmigrate
	if [ ${PROFILE} -eq 0 ]; then
	update_clock_speed 1651200 big max
    # may be override
    mutate "300000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "300000" /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1056000 4:1132800" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "0" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 1 ]; then
	update_clock_speed 2035200 big max
    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1056000 4:1132800" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "2" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 2 ]; then
	update_clock_speed 2457600 big max

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "10" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:1132800 4:1747200" 
    set_boost 2000
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "4" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 3 ]; then # Turbo
	update_clock_speed 2035200 big max

    # may be override
    mutate "672000" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "1747200" /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

    # easier to boost
    mutate "40" /proc/sys/kernel/sched_downmigrate
    mutate "60" /proc/sys/kernel/sched_upmigrate
    mutate "40" /proc/sys/kernel/sched_downmigrate

    # avoid being the bottleneck
    # mutate "1401600000" /sys/class/devfreq/soc:qcom,l3-cpu0/min_freq
    # mutate "1401600000" /sys/class/devfreq/soc:qcom,l3-cpu4/min_freq

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "20" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:0 4:1612800" 
    set_boost 2000
    lock_value "1" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "4" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	fi
		update_qti_perfd ${PROFILE_P}

	;;
	msm8996* | apq8096* )
    # prevent foreground using big cluster, may be override
    mutate "0-1" /dev/cpuset/foreground/cpus

    # turn off hotplug to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu0/core_ctl/enable
    # tend to online more cores to balance parallel tasks
    mutate "15" /sys/devices/system/cpu/cpu2/core_ctl/busy_up_thres
    mutate "5" /sys/devices/system/cpu/cpu2/core_ctl/busy_down_thres
    mutate "100" /sys/devices/system/cpu/cpu2/core_ctl/offline_delay_ms

    # unify scaling_min_freq, may be override
    mutate ${minfreq_l} /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate ${minfreq_b} /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq

    # unify scaling_max_freq, may be override
    mutate ${maxfreq_l} /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    mutate ${maxfreq_b} /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq

    # unify group_migrate, may be override
	mutate "110" /proc/sys/kernel/sched_group_upmigrate
	mutate "100" /proc/sys/kernel/sched_group_downmigrate
	if [ ${PROFILE} -eq 0 ]; then
	update_clock_speed 1440000 big max

    # may be override
    mutate "307200" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "307200" /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:844800 4:1132800" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu2/core_ctl/enable
    mutate "0" /sys/devices/system/cpu/cpu2/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 1 ]; then
	update_clock_speed 1824000 big max

	
    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:844800 4:1132800" 
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu2/core_ctl/enable
    mutate "2" /sys/devices/system/cpu/cpu2/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 2 ]; then
	update_clock_speed ${maxfreq_b} big max

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "10" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:960000 4:1440000" 
    set_boost 2000
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu2/core_ctl/enable
    mutate "4" /sys/devices/system/cpu/cpu2/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 3 ]; then # Turbo
	update_clock_speed 1824000 big max

    # may be override
    mutate "614400" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    mutate "1747200" /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq

    # easier to boost
    mutate "40" /proc/sys/kernel/sched_downmigrate
    mutate "60" /proc/sys/kernel/sched_upmigrate
    mutate "40" /proc/sys/kernel/sched_downmigrate

    # avoid being the bottleneck
    # mutate "1401600000" /sys/class/devfreq/soc:qcom,l3-cpu0/min_freq
    # mutate "1401600000" /sys/class/devfreq/soc:qcom,l3-cpu2/min_freq

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "20" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

    set_boost_freq "0:0 4:1530000" 
    set_boost 2000
    lock_value "1" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu2/core_ctl/enable
    mutate "4" /sys/devices/system/cpu/cpu2/core_ctl/min_cpus
	fi
		update_qti_perfd ${PROFILE_P}

	;;
	*)
	
	FREQ_FILE="/data/adb/boost1.txt"
	IBOOST_FREQ_L=$(awk -F ' 1' '{ print($1) }' $FREQ_FILE)
	IBOOST_FREQ_L=$(echo $IBOOST_FREQ_L |awk -F '0:' '{ print($2) }')
	IBOOST_FREQ_B=$(awk -F ' 5' '{ print($1) }' $FREQ_FILE)
	IBOOST_FREQ_B=$(echo $IBOOST_FREQ_B |awk -F '4:' '{ print($2) }')
	if [ ${IBOOST_FREQ_B} -eq 0 ]; then
	IBOOST_FREQ_B=${IBOOST_FREQ_L}
	fi
	
	if [ ${PROFILE} -eq 0 ]; then
	IBOOST_FREQ_L=$(awk -v x=$maxfreq_l 'BEGIN{print x*0.93}')
    IBOOST_FREQ_L=$(round ${IBOOST_FREQ_L} 0)
	IBOOST_FREQ_B=$(awk -v x=$IBOOST_FREQ_L 'BEGIN{print x*1.07}')
    IBOOST_FREQ_B=$(round ${IBOOST_FREQ_B} 0)
	diff=$(awk -v x=$maxfreq_b -v y=2800000 'BEGIN{print (x/y)*1000000}')
    diff=$(round ${diff} 0)
	maxfreq_b=$((${maxfreq_b}-${diff}))
	elif [ ${PROFILE} -eq 1 ]; then
	IBOOST_FREQ_L=$(awk -v x=$maxfreq_l 'BEGIN{print x*0.93}')
    IBOOST_FREQ_L=$(round ${IBOOST_FREQ_L} 0)
	IBOOST_FREQ_B=$(awk -v x=$IBOOST_FREQ_L 'BEGIN{print x*1.07}')
    IBOOST_FREQ_B=$(round ${IBOOST_FREQ_B} 0)
	diff=$(awk -v x=$maxfreq_b -v y=2800000 'BEGIN{print (x/y)*500000}')
    diff=$(round ${diff} 0)	
	maxfreq_b=$((${maxfreq_b}-${diff}))
	elif [ ${PROFILE} -eq 2 ]; then
	IBOOST_FREQ_B=$(awk -v x=$IBOOST_FREQ_B 'BEGIN{print x*1.54}')
    IBOOST_FREQ_B=$(round ${IBOOST_FREQ_B} 0)
	elif [ ${PROFILE} -eq 3 ]; then
	IBOOST_FREQ_L=0
	IBOOST_FREQ_B=$(awk -v x=$IBOOST_FREQ_B 'BEGIN{print x*1.42}')
    IBOOST_FREQ_B=$(round ${IBOOST_FREQ_B} 0)
	fi
	
	# prevent foreground using big cluster, may be override
    mutate "0-3" /dev/cpuset/foreground/cpus

    # turn off hotplug to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu0/core_ctl/enable
    # tend to online more cores to balance parallel tasks
    mutate "15" /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
    mutate "5" /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
    mutate "100" /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms

    # unify scaling_min_freq, may be override
    update_clock_speed ${minfreq_l} little min
	update_clock_speed ${minfreq_b} big min

    # unify scaling_max_freq, may be override
    update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max

	
    # unify group_migrate, may be override
	mutate "110" /proc/sys/kernel/sched_group_upmigrate
	mutate "100" /proc/sys/kernel/sched_group_downmigrate
	if [ ${PROFILE} -eq 0 ]; then

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

	set_boost_freq "0:${IBOOST_FREQ_L} ${bcores}:0"
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "0" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 1 ]; then

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/top-app/schedtune.prefer_idle

	set_boost_freq "0:${IBOOST_FREQ_L} ${bcores}:0"
    set_boost 400
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # limit the usage of big cluster
    lock_value "1" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "2" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 2 ]; then

    # 1708 * 0.95 / 1785 = 90.9
    # higher sched_downmigrate to use little cluster more
    mutate "90" /proc/sys/kernel/sched_downmigrate
    mutate "90" /proc/sys/kernel/sched_upmigrate
    mutate "90" /proc/sys/kernel/sched_downmigrate

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "10" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

	set_boost_freq "0:${IBOOST_FREQ_L} ${bcores}:${IBOOST_FREQ_B}"
    set_boost 2000
    lock_value "2" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "4" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	elif [ ${PROFILE} -eq 3 ]; then # Turbo
	
    update_clock_speed 580000 little min
	update_clock_speed ${IBOOST_FREQ_B} big min
	
    # easier to boost
    mutate "40" /proc/sys/kernel/sched_downmigrate
    mutate "60" /proc/sys/kernel/sched_upmigrate
    mutate "40" /proc/sys/kernel/sched_downmigrate

    # avoid being the bottleneck
    # mutate "1401600000" /sys/class/devfreq/soc:qcom,l3-cpu0/min_freq
    # mutate "1401600000" /sys/class/devfreq/soc:qcom,l3-cpu4/min_freq

    # do not use lock_val(), libqti-perfd-client.so will fail to override it
    mutate "1" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "20" /dev/stune/top-app/schedtune.boost
    mutate "1" /dev/stune/top-app/schedtune.prefer_idle

	set_boost_freq "0:${IBOOST_FREQ_L} ${bcores}:${IBOOST_FREQ_B}"
    set_boost 2000
    lock_value "1" /sys/module/cpu_boost/parameters/sched_boost_on_input

    # turn off core_ctl to reduce latency
    lock_value "0" /sys/devices/system/cpu/cpu4/core_ctl/enable
    mutate "4" /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	fi

	;;
	esac

	after_modify_eas ${govn}
	start_qti_perfd
fi
## INTERACTIVE
if [ ${EAS} -eq 0 ];then
    HMP=1
    i=0
	while [ $i -lt $cores ]
	do
	dir="/sys/devices/system/cpu/cpu$i/cpufreq"
	lock_value "interactive" ${dir}/scaling_governor
	i=$(( $i + 1 ))
	done
	lock_value "interactive" "/sys/devices/system/cpu/cpufreq/scaling_governor"
	LOGDATA "#  [INFO] HMP KERNEL SUPPORT DETECTED" 
	LOGDATA "#  [INFO] APPLYING INTERACTIVE GOVERNOR PARAMETERS"
	before_modify
	
	sleep 2
case ${SOC} in msm8998* | apq8098*) #sd835

# const variables
PARAM_NUM=59

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu4/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu4"

sysfs_obj1="/sys/module/msm_thermal/core_control/enabled"
sysfs_obj2="/sys/module/msm_thermal/parameters/enabled"
sysfs_obj3="/sys/module/msm_performance/parameters/cpu_min_freq"
sysfs_obj4="/sys/module/msm_performance/parameters/cpu_max_freq"
sysfs_obj5="${C0_DIR}/online"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj7="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj8="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj9="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj10="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj11="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj12="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj13="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj14="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj15="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj16="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj17="${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj18="${C0_GOVERNOR_DIR}/boost"
sysfs_obj19="${C0_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj20="${C0_GOVERNOR_DIR}/align_windows"
sysfs_obj21="${C0_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj22="${C0_GOVERNOR_DIR}/enable_prediction"
sysfs_obj23="${C0_GOVERNOR_DIR}/use_sched_load"
sysfs_obj24="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj25="${C1_DIR}/online"
sysfs_obj26="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj27="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj28="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj29="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj30="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj31="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj32="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj33="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj34="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj35="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj36="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj37="${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj38="${C1_GOVERNOR_DIR}/boost"
sysfs_obj39="${C1_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj40="${C1_GOVERNOR_DIR}/align_windows"
sysfs_obj41="${C1_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj42="${C1_GOVERNOR_DIR}/enable_prediction"
sysfs_obj43="${C1_GOVERNOR_DIR}/use_sched_load"
sysfs_obj44="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj45="${SCHED_DIR}/sched_downmigrate"
sysfs_obj46="${SCHED_DIR}/sched_upmigrate"
sysfs_obj47="${SCHED_DIR}/sched_downmigrate"
sysfs_obj48="${SCHED_DIR}/sched_freq_aggregate"
sysfs_obj49="${SCHED_DIR}/sched_ravg_hist_size"
sysfs_obj50="${SCHED_DIR}/sched_window_stats_policy"
sysfs_obj51="${SCHED_DIR}/sched_spill_load"
sysfs_obj52="${SCHED_DIR}/sched_restrict_cluster_spill"
sysfs_obj53="${SCHED_DIR}/sched_boost"
sysfs_obj54="${SCHED_DIR}/sched_prefer_sync_wakee_to_waker"
sysfs_obj55="${SCHED_DIR}/sched_freq_inc_notify"
sysfs_obj56="${SCHED_DIR}/sched_freq_dec_notify"
sysfs_obj57="/sys/module/msm_performance/parameters/touchboost"
sysfs_obj58="/sys/module/cpu_boost/parameters/input_boost_ms"
sysfs_obj59="/sys/module/cpu_boost/parameters/input_boost_freq"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 2.7%
# battery life: 90.5%
level0_val1="0"
level0_val2="N"
level0_val3="0:299000 1:0 2:0 3:0 4:299000"
level0_val4="0:1901000 1:0 2:0 3:0 4:2458000"
level0_val5="1"
level0_val6="interactive"
level0_val7="299000"
level0_val8="1901000"
level0_val9="748000"
level0_val10="87"
level0_val11="18000"
level0_val12="78000"
level0_val13="178000 825000:138000 883000:78000 960000:98000 1036000:138000 1094000:58000 1171000:158000 1248000:98000 1478000:58000 1555000:78000 1670000:98000 1747000:158000"
level0_val14="72 364000:52 518000:64 595000:56 672000:28 748000:72 825000:90 883000:64 960000:24 1036000:64 1094000:36 1171000:60 1248000:56 1324000:48 1401000:52 1670000:40 1747000:52 1824000:60 1900000:86"
level0_val15="20000"
level0_val16="-1"
level0_val17="0"
level0_val18="0"
level0_val19="0"
level0_val20="0"
level0_val21="1"
level0_val22="0"
level0_val23="1"
level0_val24="0"
level0_val25="1"
level0_val26="interactive"
level0_val27="299000"
level0_val28="2458000"
level0_val29="1958000"
level0_val30="60"
level0_val31="18000"
level0_val32="98000"
level0_val33="198000 2035000:158000 2112000:198000 2265000:118000 2342000:198000 2361000:118000"
level0_val34="80 345000:44 422000:36 576000:68 652000:28 729000:56 806000:60 979000:24 1056000:52 1132000:56 1344000:40 1420000:92 1497000:52 1728000:64 1804000:72 1958000:99"
level0_val35="20000"
level0_val36="-1"
level0_val37="0"
level0_val38="0"
level0_val39="0"
level0_val40="0"
level0_val41="1"
level0_val42="0"
level0_val43="1"
level0_val44="0"
level0_val45="44"
level0_val46="44"
level0_val47="44"
level0_val48="0"
level0_val49="4"
level0_val50="2"
level0_val51="90"
level0_val52="1"
level0_val53="0"
level0_val54="1"
level0_val55="200000"
level0_val56="400000"
level0_val57="0"
level0_val58="2300"
level0_val59="0:1670000 1:0 2:0 3:0 4:345000"

# LEVEL 1
# lag percent: 15.0%
# battery life: 100.9%
level1_val1="0"
level1_val2="N"
level1_val3="0:299000 1:0 2:0 3:0 4:299000"
level1_val4="0:1901000 1:0 2:0 3:0 4:2458000"
level1_val5="1"
level1_val6="interactive"
level1_val7="299000"
level1_val8="1901000"
level1_val9="672000"
level1_val10="88"
level1_val11="38000"
level1_val12="158000"
level1_val13="18000 748000:118000 825000:98000 883000:118000 960000:178000 1036000:118000 1094000:78000 1171000:138000 1248000:38000 1324000:98000 1401000:58000 1478000:138000 1670000:118000 1747000:158000 1824000:138000"
level1_val14="64 364000:72 518000:13 595000:56 672000:52 748000:56 825000:20 883000:92 960000:94 1036000:95 1094000:44 1171000:3 1248000:64 1324000:80 1401000:76 1478000:64 1555000:60 1670000:76 1747000:64 1824000:68 1900000:76"
level1_val15="20000"
level1_val16="-1"
level1_val17="0"
level1_val18="0"
level1_val19="0"
level1_val20="0"
level1_val21="1"
level1_val22="0"
level1_val23="1"
level1_val24="0"
level1_val25="1"
level1_val26="interactive"
level1_val27="299000"
level1_val28="2458000"
level1_val29="1958000"
level1_val30="80"
level1_val31="18000"
level1_val32="138000"
level1_val33="198000 2112000:178000 2265000:138000 2342000:158000 2361000:78000"
level1_val34="24 345000:28 422000:20 499000:11 576000:56 652000:52 729000:90 806000:64 902000:44 979000:60 1056000:28 1132000:24 1267000:56 1344000:76 1420000:90 1497000:91 1574000:96 1651000:64 1728000:85 1804000:64 1881000:68 1958000:99"
level1_val35="20000"
level1_val36="-1"
level1_val37="0"
level1_val38="0"
level1_val39="0"
level1_val40="0"
level1_val41="1"
level1_val42="0"
level1_val43="1"
level1_val44="0"
level1_val45="93"
level1_val46="93"
level1_val47="93"
level1_val48="0"
level1_val49="3"
level1_val50="2"
level1_val51="90"
level1_val52="1"
level1_val53="0"
level1_val54="1"
level1_val55="200000"
level1_val56="400000"
level1_val57="0"
level1_val58="1600"
level1_val59="0:1824000 1:0 2:0 3:0 4:345000"

# LEVEL 2
# lag percent: 30.0%
# battery life: 106.5%
level2_val1="0"
level2_val2="N"
level2_val3="0:299000 1:0 2:0 3:0 4:299000"
level2_val4="0:1901000 1:0 2:0 3:0 4:2458000"
level2_val5="1"
level2_val6="interactive"
level2_val7="299000"
level2_val8="1901000"
level2_val9="960000"
level2_val10="91"
level2_val11="18000"
level2_val12="78000"
level2_val13="198000 1094000:58000 1171000:178000 1248000:98000 1324000:158000 1401000:18000 1478000:158000 1555000:58000 1670000:198000 1824000:178000"
level2_val14="72 441000:48 518000:56 595000:44 672000:52 748000:85 825000:64 883000:97 960000:68 1036000:9 1094000:2 1171000:76 1248000:60 1324000:87 1401000:13 1478000:60 1555000:52 1670000:68 1747000:12 1824000:92 1900000:94"
level2_val15="20000"
level2_val16="-1"
level2_val17="0"
level2_val18="0"
level2_val19="0"
level2_val20="0"
level2_val21="1"
level2_val22="0"
level2_val23="1"
level2_val24="0"
level2_val25="1"
level2_val26="interactive"
level2_val27="299000"
level2_val28="2458000"
level2_val29="1958000"
level2_val30="80"
level2_val31="18000"
level2_val32="138000"
level2_val33="198000 2265000:78000 2342000:198000 2361000:78000"
level2_val34="64 345000:72 422000:91 499000:56 576000:44 652000:16 729000:7 806000:20 902000:76 979000:24 1056000:89 1132000:36 1190000:76 1267000:56 1344000:98 1420000:96 1497000:97 1651000:84 1728000:80 1958000:99"
level2_val35="20000"
level2_val36="-1"
level2_val37="0"
level2_val38="0"
level2_val39="0"
level2_val40="0"
level2_val41="1"
level2_val42="0"
level2_val43="1"
level2_val44="0"
level2_val45="93"
level2_val46="93"
level2_val47="93"
level2_val48="0"
level2_val49="3"
level2_val50="2"
level2_val51="90"
level2_val52="1"
level2_val53="0"
level2_val54="1"
level2_val55="200000"
level2_val56="400000"
level2_val57="0"
level2_val58="1500"
level2_val59="0:1401000 1:0 2:0 3:0 4:345000"

# LEVEL 3
# lag percent: 49.8%
# battery life: 112.1%
level3_val1="0"
level3_val2="N"
level3_val3="0:299000 1:0 2:0 3:0 4:299000"
level3_val4="0:1901000 1:0 2:0 3:0 4:2458000"
level3_val5="1"
level3_val6="interactive"
level3_val7="299000"
level3_val8="1901000"
level3_val9="960000"
level3_val10="90"
level3_val11="18000"
level3_val12="38000"
level3_val13="198000 1036000:138000 1094000:118000 1324000:178000 1401000:18000 1478000:158000 1555000:58000 1670000:198000 1747000:118000 1824000:138000"
level3_val14="88 364000:48 441000:64 518000:52 595000:40 672000:56 748000:60 825000:72 883000:80 960000:68 1036000:76 1094000:60 1171000:68 1248000:60 1324000:86 1401000:3 1478000:60 1555000:44 1670000:64 1824000:96"
level3_val15="20000"
level3_val16="-1"
level3_val17="0"
level3_val18="0"
level3_val19="0"
level3_val20="0"
level3_val21="1"
level3_val22="0"
level3_val23="1"
level3_val24="0"
level3_val25="1"
level3_val26="interactive"
level3_val27="299000"
level3_val28="2458000"
level3_val29="1958000"
level3_val30="85"
level3_val31="18000"
level3_val32="58000"
level3_val33="198000 2265000:58000 2361000:138000"
level3_val34="44 345000:48 422000:60 499000:16 576000:48 652000:44 729000:20 806000:60 902000:64 979000:56 1056000:91 1132000:28 1190000:84 1267000:60 1344000:99 1497000:96 1574000:98 1651000:90 1728000:80 1958000:99"
level3_val35="20000"
level3_val36="-1"
level3_val37="0"
level3_val38="0"
level3_val39="0"
level3_val40="0"
level3_val41="1"
level3_val42="0"
level3_val43="1"
level3_val44="0"
level3_val45="95"
level3_val46="95"
level3_val47="95"
level3_val48="0"
level3_val49="3"
level3_val50="2"
level3_val51="90"
level3_val52="1"
level3_val53="0"
level3_val54="1"
level3_val55="200000"
level3_val56="400000"
level3_val57="0"
level3_val58="1500"
level3_val59="0:1401000 1:0 2:0 3:0 4:300000"

# LEVEL 4
# lag percent: 74.7%
# battery life: 118.1%
level4_val1="0"
level4_val2="N"
level4_val3="0:299000 1:0 2:0 3:0 4:299000"
level4_val4="0:1901000 1:0 2:0 3:0 4:2458000"
level4_val5="1"
level4_val6="interactive"
level4_val7="299000"
level4_val8="1901000"
level4_val9="825000"
level4_val10="80"
level4_val11="58000"
level4_val12="178000"
level4_val13="138000 960000:158000 1036000:118000 1094000:138000 1324000:18000 1401000:198000 1478000:98000 1555000:78000 1670000:118000 1747000:78000 1824000:58000"
level4_val14="72 364000:60 441000:90 518000:56 595000:64 748000:72 825000:80 883000:94 960000:68 1036000:88 1094000:80 1171000:60 1248000:36 1324000:28 1401000:87 1478000:64 1555000:32 1670000:64 1747000:52 1824000:80 1900000:95"
level4_val15="20000"
level4_val16="-1"
level4_val17="0"
level4_val18="0"
level4_val19="0"
level4_val20="0"
level4_val21="1"
level4_val22="0"
level4_val23="1"
level4_val24="0"
level4_val25="1"
level4_val26="interactive"
level4_val27="299000"
level4_val28="2458000"
level4_val29="1958000"
level4_val30="85"
level4_val31="18000"
level4_val32="58000"
level4_val33="198000 2265000:78000 2342000:98000 2361000:58000"
level4_val34="52 422000:64 499000:88 576000:4 652000:72 729000:16 806000:36 902000:72 979000:60 1056000:52 1132000:64 1190000:72 1267000:52 1420000:96 1497000:60 1574000:88 1651000:56 1728000:80 1881000:72 1958000:99"
level4_val35="20000"
level4_val36="-1"
level4_val37="0"
level4_val38="0"
level4_val39="0"
level4_val40="0"
level4_val41="1"
level4_val42="0"
level4_val43="1"
level4_val44="0"
level4_val45="84"
level4_val46="84"
level4_val47="84"
level4_val48="0"
level4_val49="3"
level4_val50="3"
level4_val51="90"
level4_val52="1"
level4_val53="0"
level4_val54="1"
level4_val55="200000"
level4_val56="400000"
level4_val57="0"
level4_val58="1400"
level4_val59="0:1324000 1:0 2:0 3:0 4:345000"

# LEVEL 5
# lag percent: 98.8%
# battery life: 124.2%
level5_val1="0"
level5_val2="N"
level5_val3="0:299000 1:0 2:0 3:0 4:299000"
level5_val4="0:1901000 1:0 2:0 3:0 4:2458000"
level5_val5="1"
level5_val6="interactive"
level5_val7="299000"
level5_val8="1901000"
level5_val9="364000"
level5_val10="98"
level5_val11="88000"
level5_val12="88000"
level5_val13="88000 441000:178000 595000:88000 825000:178000 960000:88000 1401000:178000 1478000:88000"
level5_val14="93 364000:90 441000:76 518000:86 595000:56 672000:4 748000:72 825000:80 960000:92 1036000:56 1094000:85 1171000:11 1248000:92 1324000:16 1401000:80 1478000:64 1555000:9 1670000:32 1747000:60 1824000:97 1900000:91"
level5_val15="90000"
level5_val16="-1"
level5_val17="0"
level5_val18="0"
level5_val19="0"
level5_val20="0"
level5_val21="1"
level5_val22="0"
level5_val23="1"
level5_val24="0"
level5_val25="1"
level5_val26="interactive"
level5_val27="299000"
level5_val28="2458000"
level5_val29="1958000"
level5_val30="72"
level5_val31="88000"
level5_val32="88000"
level5_val33="178000 2035000:88000"
level5_val34="16 345000:64 499000:20 576000:28 652000:60 729000:72 806000:84 902000:28 979000:76 1056000:93 1132000:68 1190000:76 1267000:98 1344000:91 1420000:56 1497000:64 1574000:89 1728000:92 1804000:76 1958000:99"
level5_val35="90000"
level5_val36="-1"
level5_val37="0"
level5_val38="0"
level5_val39="0"
level5_val40="0"
level5_val41="1"
level5_val42="0"
level5_val43="1"
level5_val44="0"
level5_val45="84"
level5_val46="84"
level5_val47="84"
level5_val48="0"
level5_val49="5"
level5_val50="3"
level5_val51="90"
level5_val52="1"
level5_val53="0"
level5_val54="1"
level5_val55="200000"
level5_val56="400000"
level5_val57="0"
level5_val58="1700"
level5_val59="0:1401000 1:0 2:0 3:0 4:300000"

# LEVEL 6
# lag percent: 119.4%
# battery life: 130.4%
level6_val1="0"
level6_val2="N"
level6_val3="0:299000 1:0 2:0 3:0 4:299000"
level6_val4="0:1901000 1:0 2:0 3:0 4:2458000"
level6_val5="1"
level6_val6="interactive"
level6_val7="299000"
level6_val8="1901000"
level6_val9="883000"
level6_val10="86"
level6_val11="98000"
level6_val12="98000"
level6_val13="98000 960000:198000 1094000:98000 1401000:198000 1478000:98000 1555000:198000 1747000:98000"
level6_val14="72 364000:9 441000:64 595000:48 672000:32 748000:13 825000:68 883000:80 1036000:20 1094000:80 1248000:60 1324000:10 1401000:89 1478000:40 1555000:64 1670000:99 1747000:16 1824000:68 1900000:64"
level6_val15="100000"
level6_val16="-1"
level6_val17="0"
level6_val18="0"
level6_val19="0"
level6_val20="0"
level6_val21="1"
level6_val22="0"
level6_val23="1"
level6_val24="0"
level6_val25="1"
level6_val26="interactive"
level6_val27="299000"
level6_val28="2458000"
level6_val29="1958000"
level6_val30="90"
level6_val31="98000"
level6_val32="98000"
level6_val33="198000 2112000:98000"
level6_val34="32 345000:87 422000:60 499000:14 576000:20 652000:28 729000:6 806000:80 902000:60 979000:56 1056000:40 1132000:48 1190000:98 1267000:48 1344000:52 1420000:80 1497000:56 1574000:72 1651000:32 1728000:91 1804000:76 1881000:80 1958000:99"
level6_val35="100000"
level6_val36="-1"
level6_val37="0"
level6_val38="0"
level6_val39="0"
level6_val40="0"
level6_val41="1"
level6_val42="0"
level6_val43="1"
level6_val44="0"
level6_val45="94"
level6_val46="94"
level6_val47="94"
level6_val48="0"
level6_val49="5"
level6_val50="3"
level6_val51="90"
level6_val52="1"
level6_val53="0"
level6_val54="1"
level6_val55="200000"
level6_val56="400000"
level6_val57="0"
level6_val58="2500"
level6_val59="0:1324000 1:0 2:0 3:0 4:345000"

	
esac
case ${SOC} in msm8996* | apq8096*) #sd820

soc_revision=$(cat /sys/devices/soc0/revision)
if [[ ${soc_revision} == "1.1" ]] || [[ "$SOC0" == "msm996pro" ]];then

if [ ${maxfreq_l} -gt 1500000 ]; then
# const variables
PARAM_NUM=59

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu2/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu2"

sysfs_obj1="/sys/module/msm_thermal/core_control/enabled"
sysfs_obj2="/sys/module/msm_thermal/parameters/enabled"
sysfs_obj3="/sys/module/msm_performance/parameters/cpu_min_freq"
sysfs_obj4="/sys/module/msm_performance/parameters/cpu_max_freq"
sysfs_obj5="${C0_DIR}/online"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj7="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj8="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj9="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj10="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj11="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj12="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj13="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj14="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj15="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj16="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj17="${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj18="${C0_GOVERNOR_DIR}/boost"
sysfs_obj19="${C0_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj20="${C0_GOVERNOR_DIR}/align_windows"
sysfs_obj21="${C0_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj22="${C0_GOVERNOR_DIR}/enable_prediction"
sysfs_obj23="${C0_GOVERNOR_DIR}/use_sched_load"
sysfs_obj24="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj25="${C1_DIR}/online"
sysfs_obj26="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj27="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj28="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj29="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj30="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj31="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj32="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj33="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj34="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj35="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj36="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj37="${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj38="${C1_GOVERNOR_DIR}/boost"
sysfs_obj39="${C1_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj40="${C1_GOVERNOR_DIR}/align_windows"
sysfs_obj41="${C1_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj42="${C1_GOVERNOR_DIR}/enable_prediction"
sysfs_obj43="${C1_GOVERNOR_DIR}/use_sched_load"
sysfs_obj44="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj45="${SCHED_DIR}/sched_downmigrate"
sysfs_obj46="${SCHED_DIR}/sched_upmigrate"
sysfs_obj47="${SCHED_DIR}/sched_downmigrate"
sysfs_obj48="${SCHED_DIR}/sched_freq_aggregate"
sysfs_obj49="${SCHED_DIR}/sched_ravg_hist_size"
sysfs_obj50="${SCHED_DIR}/sched_window_stats_policy"
sysfs_obj51="${SCHED_DIR}/sched_spill_load"
sysfs_obj52="${SCHED_DIR}/sched_restrict_cluster_spill"
sysfs_obj53="${SCHED_DIR}/sched_boost"
sysfs_obj54="${SCHED_DIR}/sched_prefer_sync_wakee_to_waker"
sysfs_obj55="${SCHED_DIR}/sched_freq_inc_notify"
sysfs_obj56="${SCHED_DIR}/sched_freq_dec_notify"
sysfs_obj57="/sys/module/msm_performance/parameters/touchboost"
sysfs_obj58="/sys/module/cpu_boost/parameters/input_boost_ms"
sysfs_obj59="/sys/module/cpu_boost/parameters/input_boost_freq"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 4.6%
# battery life: 91.6%
level0_val1="0"
level0_val2="N"
level0_val3="0:306000 1:0 2:306000"
level0_val4="0:1594000 1:0 2:1997000"
level0_val5="1"
level0_val6="interactive"
level0_val7="306000"
level0_val8="1594000"
level0_val9="403000"
level0_val10="94"
level0_val11="18000"
level0_val12="118000"
level0_val13="178000 480000:18000 556000:158000 652000:78000 729000:158000 806000:58000 844000:98000 883000:118000 960000:138000 1113000:78000 1228000:138000 1324000:98000 1555000:58000"
level0_val14="87 403000:68 480000:32 556000:36 652000:95 729000:76 806000:32 960000:60 1036000:56 1113000:68 1228000:40 1248000:48 1401000:44 1593000:40"
level0_val15="20000"
level0_val16="-1"
level0_val17="0"
level0_val18="0"
level0_val19="0"
level0_val20="0"
level0_val21="1"
level0_val22="0"
level0_val23="1"
level0_val24="0"
level0_val25="1"
level0_val26="interactive"
level0_val27="306000"
level0_val28="1997000"
level0_val29="1708000"
level0_val30="68"
level0_val31="18000"
level0_val32="18000"
level0_val33="198000"
level0_val34="32 403000:10 480000:44 556000:48 729000:56 806000:72 844000:68 883000:12 960000:86 1036000:91 1113000:95 1228000:68 1248000:60 1324000:76 1555000:52 1593000:8 1632000:48 1708000:99 1996000:97"
level0_val35="20000"
level0_val36="-1"
level0_val37="0"
level0_val38="0"
level0_val39="0"
level0_val40="0"
level0_val41="1"
level0_val42="0"
level0_val43="1"
level0_val44="0"
level0_val45="28"
level0_val46="28"
level0_val47="28"
level0_val48="0"
level0_val49="3"
level0_val50="2"
level0_val51="90"
level0_val52="1"
level0_val53="0"
level0_val54="1"
level0_val55="200000"
level0_val56="400000"
level0_val57="0"
level0_val58="2400"
level0_val59="0:480000 1:0 2:480000"

# LEVEL 1
# lag percent: 15.0%
# battery life: 101.3%
level1_val1="0"
level1_val2="N"
level1_val3="0:306000 1:0 2:306000"
level1_val4="0:1594000 1:0 2:1997000"
level1_val5="1"
level1_val6="interactive"
level1_val7="306000"
level1_val8="1594000"
level1_val9="480000"
level1_val10="60"
level1_val11="18000"
level1_val12="98000"
level1_val13="38000 729000:198000 806000:138000 1036000:158000 1113000:38000 1228000:78000 1248000:118000 1324000:158000 1401000:78000 1555000:38000"
level1_val14="80 480000:48 556000:44 729000:60 806000:80 844000:56 883000:87 960000:68 1036000:60 1113000:28 1248000:36 1324000:40 1401000:44 1555000:32 1593000:44"
level1_val15="20000"
level1_val16="-1"
level1_val17="0"
level1_val18="0"
level1_val19="0"
level1_val20="0"
level1_val21="1"
level1_val22="0"
level1_val23="1"
level1_val24="0"
level1_val25="1"
level1_val26="interactive"
level1_val27="306000"
level1_val28="1997000"
level1_val29="1708000"
level1_val30="98"
level1_val31="18000"
level1_val32="38000"
level1_val33="198000"
level1_val34="64 403000:36 556000:80 652000:76 729000:72 960000:80 1036000:72 1113000:68 1228000:95 1248000:92 1324000:80 1555000:20 1593000:40 1632000:10 1708000:99"
level1_val35="20000"
level1_val36="-1"
level1_val37="0"
level1_val38="0"
level1_val39="0"
level1_val40="0"
level1_val41="1"
level1_val42="0"
level1_val43="1"
level1_val44="0"
level1_val45="6"
level1_val46="40"
level1_val47="6"
level1_val48="0"
level1_val49="3"
level1_val50="2"
level1_val51="90"
level1_val52="1"
level1_val53="0"
level1_val54="1"
level1_val55="200000"
level1_val56="400000"
level1_val57="0"
level1_val58="0"
level1_val59="0:652000 1:0 2:1228000"

# LEVEL 2
# lag percent: 30.0%
# battery life: 106.7%
level2_val1="0"
level2_val2="N"
level2_val3="0:306000 1:0 2:306000"
level2_val4="0:1594000 1:0 2:1997000"
level2_val5="1"
level2_val6="interactive"
level2_val7="306000"
level2_val8="1594000"
level2_val9="652000"
level2_val10="60"
level2_val11="18000"
level2_val12="198000"
level2_val13="138000 729000:78000 806000:138000 844000:118000 883000:138000 960000:98000 1036000:158000 1113000:98000 1228000:138000 1555000:158000"
level2_val14="88 403000:68 480000:64 556000:96 652000:60 729000:72 844000:8 883000:72 1228000:44 1248000:36 1324000:15 1401000:48 1555000:52 1593000:80"
level2_val15="20000"
level2_val16="-1"
level2_val17="0"
level2_val18="0"
level2_val19="0"
level2_val20="0"
level2_val21="1"
level2_val22="0"
level2_val23="1"
level2_val24="0"
level2_val25="1"
level2_val26="interactive"
level2_val27="306000"
level2_val28="1997000"
level2_val29="1708000"
level2_val30="99"
level2_val31="18000"
level2_val32="38000"
level2_val33="198000"
level2_val34="32 403000:40 556000:76 729000:72 806000:84 844000:80 1113000:94 1228000:92 1248000:40 1324000:99 1401000:56 1555000:84 1593000:32 1632000:40 1708000:99"
level2_val35="20000"
level2_val36="-1"
level2_val37="0"
level2_val38="0"
level2_val39="0"
level2_val40="0"
level2_val41="1"
level2_val42="0"
level2_val43="1"
level2_val44="0"
level2_val45="5"
level2_val46="44"
level2_val47="5"
level2_val48="0"
level2_val49="3"
level2_val50="2"
level2_val51="90"
level2_val52="1"
level2_val53="0"
level2_val54="1"
level2_val55="200000"
level2_val56="400000"
level2_val57="0"
level2_val58="0"
level2_val59="0:1113000 1:0 2:1824000"

# LEVEL 3
# lag percent: 50.0%
# battery life: 112.0%
level3_val1="0"
level3_val2="N"
level3_val3="0:306000 1:0 2:306000"
level3_val4="0:1594000 1:0 2:1997000"
level3_val5="1"
level3_val6="interactive"
level3_val7="306000"
level3_val8="1594000"
level3_val9="652000"
level3_val10="60"
level3_val11="18000"
level3_val12="118000"
level3_val13="178000 729000:118000 844000:98000 883000:138000 960000:118000 1036000:138000 1113000:58000 1228000:118000 1324000:138000 1401000:78000 1555000:118000"
level3_val14="84 403000:72 556000:76 652000:60 729000:76 844000:36 883000:80 960000:76 1036000:80 1113000:85 1228000:87 1248000:24 1324000:72 1401000:60 1555000:64"
level3_val15="20000"
level3_val16="-1"
level3_val17="0"
level3_val18="0"
level3_val19="0"
level3_val20="0"
level3_val21="1"
level3_val22="0"
level3_val23="1"
level3_val24="0"
level3_val25="1"
level3_val26="interactive"
level3_val27="306000"
level3_val28="1997000"
level3_val29="1708000"
level3_val30="99"
level3_val31="18000"
level3_val32="38000"
level3_val33="198000"
level3_val34="36 403000:24 480000:98 556000:36 652000:76 729000:80 1113000:94 1228000:92 1248000:48 1324000:98 1401000:76 1555000:64 1593000:80 1632000:44 1708000:99"
level3_val35="20000"
level3_val36="-1"
level3_val37="0"
level3_val38="0"
level3_val39="0"
level3_val40="0"
level3_val41="1"
level3_val42="0"
level3_val43="1"
level3_val44="0"
level3_val45="24"
level3_val46="44"
level3_val47="24"
level3_val48="0"
level3_val49="3"
level3_val50="2"
level3_val51="90"
level3_val52="1"
level3_val53="0"
level3_val54="1"
level3_val55="200000"
level3_val56="400000"
level3_val57="0"
level3_val58="0"
level3_val59="0:806000 1:0 2:1824000"

# LEVEL 4
# lag percent: 74.9%
# battery life: 120.6%
level4_val1="0"
level4_val2="N"
level4_val3="0:306000 1:0 2:306000"
level4_val4="0:1594000 1:0 2:1997000"
level4_val5="1"
level4_val6="interactive"
level4_val7="306000"
level4_val8="1594000"
level4_val9="1036000"
level4_val10="92"
level4_val11="78000"
level4_val12="138000"
level4_val13="118000 1113000:38000 1228000:118000 1324000:98000 1401000:58000 1555000:158000"
level4_val14="84 403000:28 480000:13 556000:68 652000:24 729000:68 806000:24 844000:64 883000:44 960000:16 1036000:24 1113000:80 1228000:64 1248000:44 1324000:13 1401000:28 1555000:60 1593000:52"
level4_val15="20000"
level4_val16="-1"
level4_val17="0"
level4_val18="0"
level4_val19="0"
level4_val20="0"
level4_val21="1"
level4_val22="0"
level4_val23="1"
level4_val24="0"
level4_val25="1"
level4_val26="interactive"
level4_val27="306000"
level4_val28="1997000"
level4_val29="729000"
level4_val30="76"
level4_val31="18000"
level4_val32="58000"
level4_val33="158000 844000:118000 883000:158000 960000:178000 1036000:78000 1228000:18000 1248000:118000 1324000:18000 1555000:138000 1593000:178000 1708000:198000"
level4_val34="28 403000:16 480000:24 556000:80 652000:72 729000:84 806000:56 844000:44 883000:64 960000:76 1036000:72 1113000:1 1228000:85 1248000:76 1401000:84 1555000:40 1593000:6 1632000:13 1708000:99"
level4_val35="20000"
level4_val36="-1"
level4_val37="0"
level4_val38="0"
level4_val39="0"
level4_val40="0"
level4_val41="1"
level4_val42="0"
level4_val43="1"
level4_val44="0"
level4_val45="12"
level4_val46="12"
level4_val47="12"
level4_val48="0"
level4_val49="3"
level4_val50="3"
level4_val51="90"
level4_val52="1"
level4_val53="0"
level4_val54="1"
level4_val55="200000"
level4_val56="400000"
level4_val57="0"
level4_val58="100"
level4_val59="0:307000 1:0 2:806000"

# LEVEL 5
# lag percent: 99.0%
# battery life: 127.7%
level5_val1="0"
level5_val2="N"
level5_val3="0:306000 1:0 2:306000"
level5_val4="0:1594000 1:0 2:1997000"
level5_val5="1"
level5_val6="interactive"
level5_val7="306000"
level5_val8="1594000"
level5_val9="960000"
level5_val10="80"
level5_val11="38000"
level5_val12="98000"
level5_val13="178000 1036000:138000 1113000:38000 1228000:138000 1324000:18000 1401000:98000 1555000:58000"
level5_val14="76 403000:80 480000:28 556000:76 652000:52 729000:76 806000:56 844000:72 883000:64 960000:52 1036000:48 1113000:56 1228000:68 1248000:64 1324000:32 1555000:64"
level5_val15="20000"
level5_val16="-1"
level5_val17="0"
level5_val18="0"
level5_val19="0"
level5_val20="0"
level5_val21="1"
level5_val22="0"
level5_val23="1"
level5_val24="0"
level5_val25="1"
level5_val26="interactive"
level5_val27="306000"
level5_val28="1997000"
level5_val29="729000"
level5_val30="72"
level5_val31="18000"
level5_val32="58000"
level5_val33="158000 844000:58000 883000:138000 960000:158000 1036000:58000 1113000:78000 1228000:18000 1248000:158000 1324000:18000 1401000:38000 1555000:158000 1593000:138000 1632000:98000 1708000:198000"
level5_val34="40 403000:6 480000:20 556000:76 652000:72 729000:84 806000:60 844000:44 883000:64 960000:76 1036000:72 1113000:32 1228000:86 1248000:76 1401000:85 1555000:10 1593000:28 1632000:13 1708000:99"
level5_val35="20000"
level5_val36="-1"
level5_val37="0"
level5_val38="0"
level5_val39="0"
level5_val40="0"
level5_val41="1"
level5_val42="0"
level5_val43="1"
level5_val44="0"
level5_val45="10"
level5_val46="10"
level5_val47="10"
level5_val48="0"
level5_val49="3"
level5_val50="3"
level5_val51="90"
level5_val52="1"
level5_val53="0"
level5_val54="1"
level5_val55="200000"
level5_val56="400000"
level5_val57="0"
level5_val58="0"
level5_val59="0:403000 1:0 2:729000"

# LEVEL 6
# lag percent: 119.9%
# battery life: 133.9%
level6_val1="0"
level6_val2="N"
level6_val3="0:306000 1:0 2:306000"
level6_val4="0:1594000 1:0 2:1997000"
level6_val5="1"
level6_val6="interactive"
level6_val7="306000"
level6_val8="1594000"
level6_val9="960000"
level6_val10="95"
level6_val11="58000"
level6_val12="18000"
level6_val13="178000 1036000:138000 1113000:78000 1228000:138000 1248000:158000 1324000:178000 1401000:118000 1555000:138000"
level6_val14="80 403000:40 480000:24 556000:48 652000:76 729000:52 806000:98 844000:16 883000:56 960000:20 1036000:14 1113000:80 1228000:72 1248000:6 1324000:56 1401000:64 1555000:68 1593000:84"
level6_val15="20000"
level6_val16="-1"
level6_val17="0"
level6_val18="0"
level6_val19="0"
level6_val20="0"
level6_val21="1"
level6_val22="0"
level6_val23="1"
level6_val24="0"
level6_val25="1"
level6_val26="interactive"
level6_val27="306000"
level6_val28="1997000"
level6_val29="729000"
level6_val30="76"
level6_val31="18000"
level6_val32="58000"
level6_val33="178000 806000:198000 844000:98000 883000:158000 960000:198000 1036000:18000 1248000:198000 1401000:18000 1555000:138000 1593000:78000 1632000:178000 1708000:198000"
level6_val34="60 403000:20 480000:24 556000:80 652000:72 729000:84 806000:64 844000:48 883000:64 960000:76 1036000:72 1113000:44 1228000:85 1248000:89 1324000:76 1401000:88 1555000:36 1593000:20 1632000:9 1708000:99"
level6_val35="20000"
level6_val36="-1"
level6_val37="0"
level6_val38="0"
level6_val39="0"
level6_val40="0"
level6_val41="1"
level6_val42="0"
level6_val43="1"
level6_val44="0"
level6_val45="12"
level6_val46="12"
level6_val47="12"
level6_val48="0"
level6_val49="3"
level6_val50="3"
level6_val51="90"
level6_val52="1"
level6_val53="0"
level6_val54="1"
level6_val55="200000"
level6_val56="400000"
level6_val57="0"
level6_val58="0"
level6_val59="0:403000 1:0 2:729000"	
	elif [ ${maxfreq_l} -gt 1600000 ]; then
# const variables
PARAM_NUM=59

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu2/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu2"

sysfs_obj1="/sys/module/msm_thermal/core_control/enabled"
sysfs_obj2="/sys/module/msm_thermal/parameters/enabled"
sysfs_obj3="/sys/module/msm_performance/parameters/cpu_min_freq"
sysfs_obj4="/sys/module/msm_performance/parameters/cpu_max_freq"
sysfs_obj5="${C0_DIR}/online"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj7="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj8="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj9="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj10="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj11="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj12="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj13="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj14="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj15="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj16="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj17="${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj18="${C0_GOVERNOR_DIR}/boost"
sysfs_obj19="${C0_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj20="${C0_GOVERNOR_DIR}/align_windows"
sysfs_obj21="${C0_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj22="${C0_GOVERNOR_DIR}/enable_prediction"
sysfs_obj23="${C0_GOVERNOR_DIR}/use_sched_load"
sysfs_obj24="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj25="${C1_DIR}/online"
sysfs_obj26="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj27="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj28="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj29="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj30="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj31="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj32="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj33="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj34="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj35="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj36="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj37="${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj38="${C1_GOVERNOR_DIR}/boost"
sysfs_obj39="${C1_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj40="${C1_GOVERNOR_DIR}/align_windows"
sysfs_obj41="${C1_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj42="${C1_GOVERNOR_DIR}/enable_prediction"
sysfs_obj43="${C1_GOVERNOR_DIR}/use_sched_load"
sysfs_obj44="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj45="${SCHED_DIR}/sched_downmigrate"
sysfs_obj46="${SCHED_DIR}/sched_upmigrate"
sysfs_obj47="${SCHED_DIR}/sched_downmigrate"
sysfs_obj48="${SCHED_DIR}/sched_freq_aggregate"
sysfs_obj49="${SCHED_DIR}/sched_ravg_hist_size"
sysfs_obj50="${SCHED_DIR}/sched_window_stats_policy"
sysfs_obj51="${SCHED_DIR}/sched_spill_load"
sysfs_obj52="${SCHED_DIR}/sched_restrict_cluster_spill"
sysfs_obj53="${SCHED_DIR}/sched_boost"
sysfs_obj54="${SCHED_DIR}/sched_prefer_sync_wakee_to_waker"
sysfs_obj55="${SCHED_DIR}/sched_freq_inc_notify"
sysfs_obj56="${SCHED_DIR}/sched_freq_dec_notify"
sysfs_obj57="/sys/module/msm_performance/parameters/touchboost"
sysfs_obj58="/sys/module/cpu_boost/parameters/input_boost_ms"
sysfs_obj59="/sys/module/cpu_boost/parameters/input_boost_freq"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 2.5%
# battery life: 94.6%
level0_val1="0"
level0_val2="N"
level0_val3="0:306000 1:0 2:306000"
level0_val4="0:1997000 1:0 2:2151000"
level0_val5="1"
level0_val6="interactive"
level0_val7="306000"
level0_val8="1997000"
level0_val9="384000"
level0_val10="93"
level0_val11="38000"
level0_val12="98000"
level0_val13="78000 460000:18000 537000:158000 614000:118000 691000:78000 768000:118000 1056000:98000 1132000:118000 1209000:98000 1440000:158000 1516000:78000"
level0_val14="92 384000:52 460000:24 614000:64 844000:56 902000:40 979000:24 1056000:64 1132000:68 1209000:40 1286000:36 1363000:68 1440000:20 1516000:64 1593000:48 1996000:44"
level0_val15="20000"
level0_val16="-1"
level0_val17="0"
level0_val18="0"
level0_val19="0"
level0_val20="0"
level0_val21="1"
level0_val22="0"
level0_val23="1"
level0_val24="0"
level0_val25="1"
level0_val26="interactive"
level0_val27="306000"
level0_val28="2151000"
level0_val29="1747000"
level0_val30="40"
level0_val31="18000"
level0_val32="58000"
level0_val33="198000 1900000:98000 1977000:198000 2054000:178000"
level0_val34="20 460000:36 537000:20 614000:52 691000:56 748000:80 902000:20 979000:76 1132000:64 1209000:96 1286000:97 1363000:64 1440000:52 1516000:91 1593000:68 1670000:48 1747000:99 2054000:98"
level0_val35="20000"
level0_val36="-1"
level0_val37="0"
level0_val38="0"
level0_val39="0"
level0_val40="0"
level0_val41="1"
level0_val42="0"
level0_val43="1"
level0_val44="0"
level0_val45="16"
level0_val46="16"
level0_val47="16"
level0_val48="0"
level0_val49="3"
level0_val50="2"
level0_val51="90"
level0_val52="1"
level0_val53="0"
level0_val54="1"
level0_val55="200000"
level0_val56="400000"
level0_val57="0"
level0_val58="2700"
level0_val59="0:460000 1:0 2:614000"

# LEVEL 1
# lag percent: 15.0%
# battery life: 109.1%
level1_val1="0"
level1_val2="N"
level1_val3="0:306000 1:0 2:306000"
level1_val4="0:1997000 1:0 2:2151000"
level1_val5="1"
level1_val6="interactive"
level1_val7="306000"
level1_val8="1997000"
level1_val9="614000"
level1_val10="64"
level1_val11="18000"
level1_val12="38000"
level1_val13="38000 691000:118000 979000:98000 1056000:158000 1132000:78000 1209000:18000 1286000:78000 1363000:138000 1440000:98000 1516000:158000 1593000:138000"
level1_val14="76 384000:48 460000:32 537000:64 691000:6 768000:94 844000:40 902000:4 979000:40 1056000:44 1209000:60 1286000:92 1363000:44 1516000:72 1593000:7 1996000:86"
level1_val15="20000"
level1_val16="-1"
level1_val17="0"
level1_val18="0"
level1_val19="0"
level1_val20="0"
level1_val21="1"
level1_val22="0"
level1_val23="1"
level1_val24="0"
level1_val25="1"
level1_val26="interactive"
level1_val27="306000"
level1_val28="2151000"
level1_val29="1747000"
level1_val30="80"
level1_val31="18000"
level1_val32="38000"
level1_val33="198000 1900000:178000"
level1_val34="20 384000:56 460000:24 537000:10 614000:72 691000:48 748000:80 825000:64 902000:91 979000:80 1209000:99 1286000:96 1363000:80 1440000:44 1516000:4 1593000:64 1670000:48 1747000:99"
level1_val35="20000"
level1_val36="-1"
level1_val37="0"
level1_val38="0"
level1_val39="0"
level1_val40="0"
level1_val41="1"
level1_val42="0"
level1_val43="1"
level1_val44="0"
level1_val45="10"
level1_val46="24"
level1_val47="10"
level1_val48="0"
level1_val49="3"
level1_val50="2"
level1_val51="90"
level1_val52="1"
level1_val53="0"
level1_val54="1"
level1_val55="200000"
level1_val56="400000"
level1_val57="0"
level1_val58="0"
level1_val59="0:1440000 1:0 2:825000"

# LEVEL 2
# lag percent: 29.9%
# battery life: 115.4%
level2_val1="0"
level2_val2="N"
level2_val3="0:306000 1:0 2:306000"
level2_val4="0:1997000 1:0 2:2151000"
level2_val5="1"
level2_val6="interactive"
level2_val7="306000"
level2_val8="1997000"
level2_val9="614000"
level2_val10="60"
level2_val11="18000"
level2_val12="58000"
level2_val13="58000 691000:78000 768000:18000 844000:178000 902000:118000 979000:78000 1056000:38000 1132000:98000 1209000:158000 1363000:198000 1440000:18000 1516000:118000 1593000:98000"
level2_val14="76 384000:68 460000:56 537000:72 614000:52 691000:68 768000:89 844000:80 902000:16 979000:72 1056000:93 1209000:80 1286000:56 1363000:60 1440000:44 1516000:68 1593000:56 1996000:48"
level2_val15="20000"
level2_val16="-1"
level2_val17="0"
level2_val18="0"
level2_val19="0"
level2_val20="0"
level2_val21="1"
level2_val22="0"
level2_val23="1"
level2_val24="0"
level2_val25="1"
level2_val26="interactive"
level2_val27="306000"
level2_val28="2151000"
level2_val29="1747000"
level2_val30="97"
level2_val31="18000"
level2_val32="38000"
level2_val33="198000"
level2_val34="36 384000:40 460000:14 537000:4 614000:24 691000:60 748000:88 825000:80 902000:86 979000:72 1132000:99 1209000:88 1286000:97 1363000:80 1440000:60 1516000:84 1593000:87 1670000:52 1747000:99"
level2_val35="20000"
level2_val36="-1"
level2_val37="0"
level2_val38="0"
level2_val39="0"
level2_val40="0"
level2_val41="1"
level2_val42="0"
level2_val43="1"
level2_val44="0"
level2_val45="4"
level2_val46="32"
level2_val47="4"
level2_val48="0"
level2_val49="3"
level2_val50="2"
level2_val51="90"
level2_val52="1"
level2_val53="0"
level2_val54="1"
level2_val55="200000"
level2_val56="400000"
level2_val57="0"
level2_val58="0"
level2_val59="0:1056000 1:0 2:1132000"

# LEVEL 3
# lag percent: 50.0%
# battery life: 119.5%
level3_val1="0"
level3_val2="N"
level3_val3="0:306000 1:0 2:306000"
level3_val4="0:1997000 1:0 2:2151000"
level3_val5="1"
level3_val6="interactive"
level3_val7="306000"
level3_val8="1997000"
level3_val9="768000"
level3_val10="96"
level3_val11="18000"
level3_val12="138000"
level3_val13="98000 844000:38000 902000:58000 979000:38000 1056000:138000 1209000:18000 1286000:78000 1363000:18000 1440000:158000 1516000:138000 1593000:118000"
level3_val14="72 460000:76 537000:80 614000:48 691000:32 768000:9 844000:12 902000:40 979000:28 1056000:60 1132000:64 1209000:48 1363000:44 1440000:68 1516000:36 1593000:68"
level3_val15="20000"
level3_val16="-1"
level3_val17="0"
level3_val18="0"
level3_val19="0"
level3_val20="0"
level3_val21="1"
level3_val22="0"
level3_val23="1"
level3_val24="0"
level3_val25="1"
level3_val26="interactive"
level3_val27="306000"
level3_val28="2151000"
level3_val29="1747000"
level3_val30="84"
level3_val31="18000"
level3_val32="38000"
level3_val33="198000 1900000:178000 1977000:198000 2054000:138000"
level3_val34="15 384000:24 460000:20 537000:36 614000:44 691000:15 748000:80 902000:87 979000:86 1056000:72 1132000:93 1209000:76 1286000:97 1363000:89 1440000:36 1516000:48 1593000:98 1670000:52 1747000:99"
level3_val35="20000"
level3_val36="-1"
level3_val37="0"
level3_val38="0"
level3_val39="0"
level3_val40="0"
level3_val41="1"
level3_val42="0"
level3_val43="1"
level3_val44="0"
level3_val45="8"
level3_val46="8"
level3_val47="8"
level3_val48="0"
level3_val49="3"
level3_val50="3"
level3_val51="90"
level3_val52="1"
level3_val53="0"
level3_val54="1"
level3_val55="200000"
level3_val56="400000"
level3_val57="0"
level3_val58="0"
level3_val59="0:460000 1:0 2:1056000"

# LEVEL 4
# lag percent: 75.0%
# battery life: 124.0%
level4_val1="0"
level4_val2="N"
level4_val3="0:306000 1:0 2:306000"
level4_val4="0:1997000 1:0 2:2151000"
level4_val5="1"
level4_val6="interactive"
level4_val7="306000"
level4_val8="1997000"
level4_val9="1056000"
level4_val10="87"
level4_val11="18000"
level4_val12="78000"
level4_val13="98000 1132000:178000 1209000:158000 1286000:98000 1363000:78000 1440000:58000 1516000:158000 1593000:58000"
level4_val14="80 384000:64 537000:36 614000:64 691000:20 768000:60 844000:24 902000:20 979000:80 1056000:36 1132000:52 1209000:80 1286000:60 1363000:28 1440000:32 1516000:76 1996000:40"
level4_val15="20000"
level4_val16="-1"
level4_val17="0"
level4_val18="0"
level4_val19="0"
level4_val20="0"
level4_val21="1"
level4_val22="0"
level4_val23="1"
level4_val24="0"
level4_val25="1"
level4_val26="interactive"
level4_val27="306000"
level4_val28="2151000"
level4_val29="1747000"
level4_val30="87"
level4_val31="18000"
level4_val32="18000"
level4_val33="198000 2054000:138000"
level4_val34="40 614000:60 691000:72 748000:80 825000:85 902000:93 979000:80 1209000:99 1286000:98 1363000:52 1516000:48 1593000:36 1670000:44 1747000:99"
level4_val35="20000"
level4_val36="-1"
level4_val37="0"
level4_val38="0"
level4_val39="0"
level4_val40="0"
level4_val41="1"
level4_val42="0"
level4_val43="1"
level4_val44="0"
level4_val45="9"
level4_val46="9"
level4_val47="9"
level4_val48="0"
level4_val49="3"
level4_val50="3"
level4_val51="90"
level4_val52="1"
level4_val53="0"
level4_val54="1"
level4_val55="200000"
level4_val56="400000"
level4_val57="0"
level4_val58="0"
level4_val59="0:1516000 1:0 2:1363000"

# LEVEL 5
# lag percent: 98.9%
# battery life: 128.2%
level5_val1="0"
level5_val2="N"
level5_val3="0:306000 1:0 2:306000"
level5_val4="0:1997000 1:0 2:2151000"
level5_val5="1"
level5_val6="interactive"
level5_val7="306000"
level5_val8="1997000"
level5_val9="1056000"
level5_val10="89"
level5_val11="18000"
level5_val12="38000"
level5_val13="158000 1132000:98000 1209000:118000 1286000:198000 1363000:98000 1516000:138000 1593000:158000"
level5_val14="80 384000:72 460000:36 537000:84 614000:32 691000:44 768000:32 844000:44 902000:56 979000:64 1056000:95 1132000:44 1209000:87 1286000:84 1363000:2 1440000:44 1516000:94 1593000:68"
level5_val15="20000"
level5_val16="-1"
level5_val17="0"
level5_val18="0"
level5_val19="0"
level5_val20="0"
level5_val21="1"
level5_val22="0"
level5_val23="1"
level5_val24="0"
level5_val25="1"
level5_val26="interactive"
level5_val27="306000"
level5_val28="2151000"
level5_val29="1747000"
level5_val30="89"
level5_val31="18000"
level5_val32="38000"
level5_val33="198000 1977000:178000"
level5_val34="44 384000:40 614000:76 691000:68 748000:80 825000:92 902000:94 979000:72 1056000:99 1132000:93 1209000:97 1286000:99 1440000:76 1516000:56 1593000:36 1670000:68 1747000:99"
level5_val35="20000"
level5_val36="-1"
level5_val37="0"
level5_val38="0"
level5_val39="0"
level5_val40="0"
level5_val41="1"
level5_val42="0"
level5_val43="1"
level5_val44="0"
level5_val45="9"
level5_val46="9"
level5_val47="9"
level5_val48="0"
level5_val49="3"
level5_val50="3"
level5_val51="90"
level5_val52="1"
level5_val53="0"
level5_val54="1"
level5_val55="200000"
level5_val56="400000"
level5_val57="0"
level5_val58="0"
level5_val59="0:1363000 1:0 2:1977000"

# LEVEL 6
# lag percent: 119.9%
# battery life: 132.1%
level6_val1="0"
level6_val2="N"
level6_val3="0:306000 1:0 2:306000"
level6_val4="0:1997000 1:0 2:2151000"
level6_val5="1"
level6_val6="interactive"
level6_val7="306000"
level6_val8="1997000"
level6_val9="979000"
level6_val10="80"
level6_val11="48000"
level6_val12="98000"
level6_val13="48000 1056000:98000 1132000:148000 1209000:48000 1286000:148000 1363000:48000"
level6_val14="86 384000:40 537000:56 614000:44 768000:40 844000:24 902000:68 979000:7 1056000:72 1132000:48 1209000:52 1286000:97 1363000:48 1440000:64 1516000:76 1593000:9 1996000:56"
level6_val15="50000"
level6_val16="-1"
level6_val17="0"
level6_val18="0"
level6_val19="0"
level6_val20="0"
level6_val21="1"
level6_val22="0"
level6_val23="1"
level6_val24="0"
level6_val25="1"
level6_val26="interactive"
level6_val27="306000"
level6_val28="2151000"
level6_val29="1747000"
level6_val30="86"
level6_val31="48000"
level6_val32="48000"
level6_val33="198000 2054000:148000"
level6_val34="32 384000:28 537000:6 614000:28 691000:64 748000:85 825000:88 902000:84 979000:92 1056000:72 1132000:95 1209000:97 1286000:98 1440000:97 1516000:60 1593000:52 1747000:99"
level6_val35="50000"
level6_val36="-1"
level6_val37="0"
level6_val38="0"
level6_val39="0"
level6_val40="0"
level6_val41="1"
level6_val42="0"
level6_val43="1"
level6_val44="0"
level6_val45="7"
level6_val46="7"
level6_val47="7"
level6_val48="0"
level6_val49="3"
level6_val50="3"
level6_val51="90"
level6_val52="1"
level6_val53="0"
level6_val54="1"
level6_val55="200000"
level6_val56="400000"
level6_val57="0"
level6_val58="0"
level6_val59="0:1996000 1:0 2:825000"
	
	elif [ ${maxfreq_l} -gt 2000000 ]; then
# const variables
PARAM_NUM=59

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu2/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu2"

sysfs_obj1="/sys/module/msm_thermal/core_control/enabled"
sysfs_obj2="/sys/module/msm_thermal/parameters/enabled"
sysfs_obj3="/sys/module/msm_performance/parameters/cpu_min_freq"
sysfs_obj4="/sys/module/msm_performance/parameters/cpu_max_freq"
sysfs_obj5="${C0_DIR}/online"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj7="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj8="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj9="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj10="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj11="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj12="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj13="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj14="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj15="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj16="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj17="${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj18="${C0_GOVERNOR_DIR}/boost"
sysfs_obj19="${C0_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj20="${C0_GOVERNOR_DIR}/align_windows"
sysfs_obj21="${C0_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj22="${C0_GOVERNOR_DIR}/enable_prediction"
sysfs_obj23="${C0_GOVERNOR_DIR}/use_sched_load"
sysfs_obj24="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj25="${C1_DIR}/online"
sysfs_obj26="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj27="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj28="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj29="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj30="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj31="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj32="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj33="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj34="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj35="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj36="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj37="${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj38="${C1_GOVERNOR_DIR}/boost"
sysfs_obj39="${C1_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj40="${C1_GOVERNOR_DIR}/align_windows"
sysfs_obj41="${C1_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj42="${C1_GOVERNOR_DIR}/enable_prediction"
sysfs_obj43="${C1_GOVERNOR_DIR}/use_sched_load"
sysfs_obj44="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj45="${SCHED_DIR}/sched_downmigrate"
sysfs_obj46="${SCHED_DIR}/sched_upmigrate"
sysfs_obj47="${SCHED_DIR}/sched_downmigrate"
sysfs_obj48="${SCHED_DIR}/sched_freq_aggregate"
sysfs_obj49="${SCHED_DIR}/sched_ravg_hist_size"
sysfs_obj50="${SCHED_DIR}/sched_window_stats_policy"
sysfs_obj51="${SCHED_DIR}/sched_spill_load"
sysfs_obj52="${SCHED_DIR}/sched_restrict_cluster_spill"
sysfs_obj53="${SCHED_DIR}/sched_boost"
sysfs_obj54="${SCHED_DIR}/sched_prefer_sync_wakee_to_waker"
sysfs_obj55="${SCHED_DIR}/sched_freq_inc_notify"
sysfs_obj56="${SCHED_DIR}/sched_freq_dec_notify"
sysfs_obj57="/sys/module/msm_performance/parameters/touchboost"
sysfs_obj58="/sys/module/cpu_boost/parameters/input_boost_ms"
sysfs_obj59="/sys/module/cpu_boost/parameters/input_boost_freq"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 0.7%
# battery life: 101.3%
level0_val1="0"
level0_val2="N"
level0_val3="0:306000 1:0 2:306000"
level0_val4="0:2189000 1:0 2:2343000"
level0_val5="1"
level0_val6="interactive"
level0_val7="306000"
level0_val8="2189000"
level0_val9="844000"
level0_val10="86"
level0_val11="38000"
level0_val12="138000"
level0_val13="138000 979000:98000 1056000:158000 1132000:138000 1209000:158000 1286000:78000 1516000:58000 1593000:138000"
level0_val14="80 384000:20 460000:36 614000:48 691000:44 844000:64 902000:85 979000:11 1056000:72 1132000:80 1209000:68 1286000:76 1363000:36 1516000:32 1593000:16 2188000:20"
level0_val15="20000"
level0_val16="-1"
level0_val17="0"
level0_val18="0"
level0_val19="0"
level0_val20="0"
level0_val21="1"
level0_val22="0"
level0_val23="1"
level0_val24="0"
level0_val25="1"
level0_val26="interactive"
level0_val27="306000"
level0_val28="2343000"
level0_val29="1747000"
level0_val30="20"
level0_val31="18000"
level0_val32="38000"
level0_val33="198000 1824000:178000 1900000:158000 1977000:118000 2054000:198000 2150000:118000 2246000:98000"
level0_val34="36 384000:56 460000:13 537000:28 614000:36 748000:76 825000:72 979000:88 1056000:76 1363000:48 1440000:90 1516000:68 1593000:32 1670000:60 1747000:99 1977000:98"
level0_val35="20000"
level0_val36="-1"
level0_val37="0"
level0_val38="0"
level0_val39="0"
level0_val40="0"
level0_val41="1"
level0_val42="0"
level0_val43="1"
level0_val44="0"
level0_val45="10"
level0_val46="10"
level0_val47="10"
level0_val48="0"
level0_val49="3"
level0_val50="3"
level0_val51="90"
level0_val52="1"
level0_val53="0"
level0_val54="1"
level0_val55="200000"
level0_val56="400000"
level0_val57="0"
level0_val58="2200"
level0_val59="0:384000 1:0 2:537000"

# LEVEL 1
# lag percent: 15.0%
# battery life: 117.8%
level1_val1="0"
level1_val2="N"
level1_val3="0:306000 1:0 2:306000"
level1_val4="0:2189000 1:0 2:2343000"
level1_val5="1"
level1_val6="interactive"
level1_val7="306000"
level1_val8="2189000"
level1_val9="614000"
level1_val10="52"
level1_val11="18000"
level1_val12="118000"
level1_val13="38000 691000:58000 844000:38000 902000:78000 979000:38000 1056000:118000 1209000:178000 1286000:98000 1440000:178000 1516000:138000 1593000:118000"
level1_val14="52 384000:86 460000:16 537000:95 614000:60 691000:32 768000:44 844000:80 902000:28 979000:44 1132000:36 1209000:72 1286000:48 1363000:60 1440000:36 1516000:44 2188000:56"
level1_val15="20000"
level1_val16="-1"
level1_val17="0"
level1_val18="0"
level1_val19="0"
level1_val20="0"
level1_val21="1"
level1_val22="0"
level1_val23="1"
level1_val24="0"
level1_val25="1"
level1_val26="interactive"
level1_val27="306000"
level1_val28="2343000"
level1_val29="1747000"
level1_val30="72"
level1_val31="18000"
level1_val32="18000"
level1_val33="198000 2150000:178000 2246000:78000"
level1_val34="16 384000:20 460000:24 537000:36 614000:28 691000:60 748000:97 825000:76 902000:80 979000:72 1132000:94 1209000:72 1286000:90 1363000:96 1440000:76 1516000:56 1747000:99"
level1_val35="20000"
level1_val36="-1"
level1_val37="0"
level1_val38="0"
level1_val39="0"
level1_val40="0"
level1_val41="1"
level1_val42="0"
level1_val43="1"
level1_val44="0"
level1_val45="3"
level1_val46="20"
level1_val47="3"
level1_val48="0"
level1_val49="3"
level1_val50="2"
level1_val51="90"
level1_val52="1"
level1_val53="0"
level1_val54="1"
level1_val55="200000"
level1_val56="400000"
level1_val57="0"
level1_val58="0"
level1_val59="0:2188000 1:0 2:748000"

# LEVEL 2
# lag percent: 30.0%
# battery life: 123.2%
level2_val1="0"
level2_val2="N"
level2_val3="0:306000 1:0 2:306000"
level2_val4="0:2189000 1:0 2:2343000"
level2_val5="1"
level2_val6="interactive"
level2_val7="306000"
level2_val8="2189000"
level2_val9="614000"
level2_val10="64"
level2_val11="18000"
level2_val12="138000"
level2_val13="58000 691000:38000 768000:78000 844000:138000 902000:78000 1056000:58000 1132000:98000 1286000:38000 1363000:78000 1516000:38000 1593000:158000"
level2_val14="52 384000:56 460000:64 614000:44 844000:56 902000:44 979000:6 1056000:32 1132000:1 1209000:5 1286000:32 1363000:68 1440000:32 1516000:64 1593000:56 2188000:52"
level2_val15="20000"
level2_val16="-1"
level2_val17="0"
level2_val18="0"
level2_val19="0"
level2_val20="0"
level2_val21="1"
level2_val22="0"
level2_val23="1"
level2_val24="0"
level2_val25="1"
level2_val26="interactive"
level2_val27="306000"
level2_val28="2343000"
level2_val29="1747000"
level2_val30="86"
level2_val31="18000"
level2_val32="38000"
level2_val33="198000 2150000:158000 2246000:18000"
level2_val34="12 384000:20 537000:48 614000:28 691000:64 748000:95 825000:72 902000:80 979000:72 1132000:86 1209000:72 1286000:96 1363000:93 1440000:60 1516000:40 1593000:15 1670000:52 1747000:99"
level2_val35="20000"
level2_val36="-1"
level2_val37="0"
level2_val38="0"
level2_val39="0"
level2_val40="0"
level2_val41="1"
level2_val42="0"
level2_val43="1"
level2_val44="0"
level2_val45="3"
level2_val46="20"
level2_val47="3"
level2_val48="0"
level2_val49="3"
level2_val50="2"
level2_val51="90"
level2_val52="1"
level2_val53="0"
level2_val54="1"
level2_val55="200000"
level2_val56="400000"
level2_val57="0"
level2_val58="0"
level2_val59="0:537000 1:0 2:537000"

# LEVEL 3
# lag percent: 49.7%
# battery life: 128.1%
level3_val1="0"
level3_val2="N"
level3_val3="0:306000 1:0 2:306000"
level3_val4="0:2189000 1:0 2:2343000"
level3_val5="1"
level3_val6="interactive"
level3_val7="306000"
level3_val8="2189000"
level3_val9="614000"
level3_val10="60"
level3_val11="18000"
level3_val12="98000"
level3_val13="38000 768000:138000 844000:78000 979000:158000 1056000:58000 1132000:78000 1209000:158000 1286000:118000 1363000:178000 1440000:118000 1593000:58000"
level3_val14="64 460000:68 537000:16 614000:52 691000:16 768000:56 844000:89 902000:68 979000:44 1056000:36 1132000:89 1209000:68 1286000:72 1363000:32 1440000:28 1516000:68 1593000:80 2188000:76"
level3_val15="20000"
level3_val16="-1"
level3_val17="0"
level3_val18="0"
level3_val19="0"
level3_val20="0"
level3_val21="1"
level3_val22="0"
level3_val23="1"
level3_val24="0"
level3_val25="1"
level3_val26="interactive"
level3_val27="306000"
level3_val28="2343000"
level3_val29="1747000"
level3_val30="96"
level3_val31="18000"
level3_val32="18000"
level3_val33="198000 2150000:158000 2246000:98000"
level3_val34="28 384000:20 537000:40 614000:48 691000:56 748000:97 825000:72 902000:80 979000:72 1132000:86 1209000:72 1286000:96 1363000:97 1440000:72 1516000:64 1593000:60 1670000:56 1747000:99"
level3_val35="20000"
level3_val36="-1"
level3_val37="0"
level3_val38="0"
level3_val39="0"
level3_val40="0"
level3_val41="1"
level3_val42="0"
level3_val43="1"
level3_val44="0"
level3_val45="5"
level3_val46="32"
level3_val47="5"
level3_val48="0"
level3_val49="3"
level3_val50="2"
level3_val51="90"
level3_val52="1"
level3_val53="0"
level3_val54="1"
level3_val55="200000"
level3_val56="400000"
level3_val57="0"
level3_val58="0"
level3_val59="0:1440000 1:0 2:748000"

# LEVEL 4
# lag percent: 74.9%
# battery life: 131.3%
level4_val1="0"
level4_val2="N"
level4_val3="0:306000 1:0 2:306000"
level4_val4="0:2189000 1:0 2:2343000"
level4_val5="1"
level4_val6="interactive"
level4_val7="306000"
level4_val8="2189000"
level4_val9="614000"
level4_val10="99"
level4_val11="18000"
level4_val12="98000"
level4_val13="158000 691000:18000 768000:118000 902000:98000 1056000:178000 1132000:138000 1286000:198000 1363000:158000 1440000:118000"
level4_val14="60 384000:44 460000:12 537000:64 614000:52 691000:44 768000:64 844000:60 902000:72 979000:48 1132000:52 1209000:76 1286000:48 1363000:36 1440000:60 2188000:68"
level4_val15="20000"
level4_val16="-1"
level4_val17="0"
level4_val18="0"
level4_val19="0"
level4_val20="0"
level4_val21="1"
level4_val22="0"
level4_val23="1"
level4_val24="0"
level4_val25="1"
level4_val26="interactive"
level4_val27="306000"
level4_val28="2343000"
level4_val29="1747000"
level4_val30="98"
level4_val31="18000"
level4_val32="18000"
level4_val33="198000 2150000:178000 2246000:138000"
level4_val34="24 384000:16 537000:9 614000:32 691000:56 748000:97 825000:80 902000:76 979000:68 1056000:72 1132000:86 1209000:80 1286000:97 1363000:96 1440000:72 1516000:93 1593000:32 1670000:44 1747000:99"
level4_val35="20000"
level4_val36="-1"
level4_val37="0"
level4_val38="0"
level4_val39="0"
level4_val40="0"
level4_val41="1"
level4_val42="0"
level4_val43="1"
level4_val44="0"
level4_val45="3"
level4_val46="32"
level4_val47="3"
level4_val48="0"
level4_val49="3"
level4_val50="2"
level4_val51="90"
level4_val52="1"
level4_val53="0"
level4_val54="1"
level4_val55="200000"
level4_val56="400000"
level4_val57="0"
level4_val58="0"
level4_val59="0:768000 1:0 2:537000"

# LEVEL 5
# lag percent: 98.8%
# battery life: 133.9%
level5_val1="0"
level5_val2="N"
level5_val3="0:306000 1:0 2:306000"
level5_val4="0:2189000 1:0 2:2343000"
level5_val5="1"
level5_val6="interactive"
level5_val7="306000"
level5_val8="2189000"
level5_val9="614000"
level5_val10="99"
level5_val11="18000"
level5_val12="58000"
level5_val13="198000 691000:38000 768000:118000 844000:98000 979000:118000 1056000:198000 1132000:118000 1209000:38000 1286000:138000 1440000:118000 1516000:98000 1593000:198000"
level5_val14="60 384000:32 537000:60 614000:52 691000:80 768000:72 844000:94 902000:80 979000:32 1056000:68 1132000:28 1209000:80 1286000:52 1363000:89 1440000:44 1516000:64 1593000:72 2188000:91"
level5_val15="20000"
level5_val16="-1"
level5_val17="0"
level5_val18="0"
level5_val19="0"
level5_val20="0"
level5_val21="1"
level5_val22="0"
level5_val23="1"
level5_val24="0"
level5_val25="1"
level5_val26="interactive"
level5_val27="306000"
level5_val28="2343000"
level5_val29="1747000"
level5_val30="98"
level5_val31="18000"
level5_val32="38000"
level5_val33="198000 2246000:118000"
level5_val34="14 384000:16 460000:15 537000:20 614000:8 691000:56 748000:97 825000:80 902000:76 979000:85 1056000:72 1132000:86 1209000:80 1286000:97 1363000:96 1440000:72 1516000:92 1593000:40 1747000:99"
level5_val35="20000"
level5_val36="-1"
level5_val37="0"
level5_val38="0"
level5_val39="0"
level5_val40="0"
level5_val41="1"
level5_val42="0"
level5_val43="1"
level5_val44="0"
level5_val45="4"
level5_val46="32"
level5_val47="4"
level5_val48="0"
level5_val49="3"
level5_val50="2"
level5_val51="90"
level5_val52="1"
level5_val53="0"
level5_val54="1"
level5_val55="200000"
level5_val56="400000"
level5_val57="0"
level5_val58="0"
level5_val59="0:844000 1:0 2:384000"

# LEVEL 6
# lag percent: 118.7%
# battery life: 135.7%
level6_val1="0"
level6_val2="N"
level6_val3="0:306000 1:0 2:306000"
level6_val4="0:2189000 1:0 2:2343000"
level6_val5="1"
level6_val6="interactive"
level6_val7="306000"
level6_val8="2189000"
level6_val9="614000"
level6_val10="97"
level6_val11="18000"
level6_val12="58000"
level6_val13="198000 691000:58000 768000:118000 902000:98000 979000:118000 1056000:38000 1132000:178000 1209000:38000 1286000:118000 1440000:158000 1516000:118000"
level6_val14="60 384000:44 460000:20 537000:64 614000:52 691000:89 768000:68 844000:93 902000:44 1056000:72 1132000:96 1209000:76 1286000:48 1363000:80 1440000:86 1516000:64 1593000:28 2188000:32"
level6_val15="20000"
level6_val16="-1"
level6_val17="0"
level6_val18="0"
level6_val19="0"
level6_val20="0"
level6_val21="1"
level6_val22="0"
level6_val23="1"
level6_val24="0"
level6_val25="1"
level6_val26="interactive"
level6_val27="306000"
level6_val28="2343000"
level6_val29="1747000"
level6_val30="98"
level6_val31="18000"
level6_val32="38000"
level6_val33="198000 2150000:178000 2246000:138000"
level6_val34="44 384000:24 460000:20 537000:76 614000:24 691000:56 748000:98 825000:80 902000:76 979000:85 1056000:72 1132000:86 1209000:80 1286000:97 1363000:96 1440000:72 1516000:92 1593000:36 1670000:44 1747000:99"
level6_val35="20000"
level6_val36="-1"
level6_val37="0"
level6_val38="0"
level6_val39="0"
level6_val40="0"
level6_val41="1"
level6_val42="0"
level6_val43="1"
level6_val44="0"
level6_val45="4"
level6_val46="32"
level6_val47="4"
level6_val48="0"
level6_val49="3"
level6_val50="2"
level6_val51="90"
level6_val52="1"
level6_val53="0"
level6_val54="1"
level6_val55="200000"
level6_val56="400000"
level6_val57="0"
level6_val58="0"
level6_val59="0:902000 1:0 2:537000"	
fi
else

# const variables
PARAM_NUM=59

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu2/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu2"

sysfs_obj1="/sys/module/msm_thermal/core_control/enabled"
sysfs_obj2="/sys/module/msm_thermal/parameters/enabled"
sysfs_obj3="/sys/module/msm_performance/parameters/cpu_min_freq"
sysfs_obj4="/sys/module/msm_performance/parameters/cpu_max_freq"
sysfs_obj5="${C0_DIR}/online"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj7="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj8="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj9="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj10="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj11="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj12="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj13="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj14="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj15="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj16="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj17="${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj18="${C0_GOVERNOR_DIR}/boost"
sysfs_obj19="${C0_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj20="${C0_GOVERNOR_DIR}/align_windows"
sysfs_obj21="${C0_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj22="${C0_GOVERNOR_DIR}/enable_prediction"
sysfs_obj23="${C0_GOVERNOR_DIR}/use_sched_load"
sysfs_obj24="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj25="${C1_DIR}/online"
sysfs_obj26="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj27="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj28="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj29="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj30="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj31="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj32="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj33="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj34="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj35="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj36="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj37="${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj38="${C1_GOVERNOR_DIR}/boost"
sysfs_obj39="${C1_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj40="${C1_GOVERNOR_DIR}/align_windows"
sysfs_obj41="${C1_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj42="${C1_GOVERNOR_DIR}/enable_prediction"
sysfs_obj43="${C1_GOVERNOR_DIR}/use_sched_load"
sysfs_obj44="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj45="${SCHED_DIR}/sched_downmigrate"
sysfs_obj46="${SCHED_DIR}/sched_upmigrate"
sysfs_obj47="${SCHED_DIR}/sched_downmigrate"
sysfs_obj48="${SCHED_DIR}/sched_freq_aggregate"
sysfs_obj49="${SCHED_DIR}/sched_ravg_hist_size"
sysfs_obj50="${SCHED_DIR}/sched_window_stats_policy"
sysfs_obj51="${SCHED_DIR}/sched_spill_load"
sysfs_obj52="${SCHED_DIR}/sched_restrict_cluster_spill"
sysfs_obj53="${SCHED_DIR}/sched_boost"
sysfs_obj54="${SCHED_DIR}/sched_prefer_sync_wakee_to_waker"
sysfs_obj55="${SCHED_DIR}/sched_freq_inc_notify"
sysfs_obj56="${SCHED_DIR}/sched_freq_dec_notify"
sysfs_obj57="/sys/module/msm_performance/parameters/touchboost"
sysfs_obj58="/sys/module/cpu_boost/parameters/input_boost_ms"
sysfs_obj59="/sys/module/cpu_boost/parameters/input_boost_freq"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 2.7%
# battery life: 92.5%
level0_val1="0"
level0_val2="N"
level0_val3="0:306000 1:0 2:306000"
level0_val4="0:1594000 1:0 2:2151000"
level0_val5="1"
level0_val6="interactive"
level0_val7="306000"
level0_val8="1594000"
level0_val9="422000"
level0_val10="90"
level0_val11="18000"
level0_val12="98000"
level0_val13="178000 480000:58000 556000:38000 652000:118000 1036000:58000 1113000:98000 1190000:118000 1228000:78000 1401000:118000 1478000:58000"
level0_val14="64 422000:68 480000:28 556000:44 652000:52 729000:76 844000:85 960000:72 1036000:12 1113000:68 1324000:72 1401000:68 1478000:76"
level0_val15="20000"
level0_val16="-1"
level0_val17="0"
level0_val18="0"
level0_val19="0"
level0_val20="0"
level0_val21="1"
level0_val22="0"
level0_val23="1"
level0_val24="0"
level0_val25="1"
level0_val26="interactive"
level0_val27="306000"
level0_val28="2151000"
level0_val29="1708000"
level0_val30="52"
level0_val31="18000"
level0_val32="98000"
level0_val33="198000 1785000:178000 1824000:198000 1996000:178000 2073000:158000"
level0_val34="16 403000:76 480000:44 556000:40 652000:20 729000:86 806000:98 883000:87 940000:76 1190000:80 1248000:89 1324000:60 1478000:28 1555000:80 1632000:85 1708000:99 2073000:98"
level0_val35="20000"
level0_val36="-1"
level0_val37="0"
level0_val38="0"
level0_val39="0"
level0_val40="0"
level0_val41="1"
level0_val42="0"
level0_val43="1"
level0_val44="0"
level0_val45="6"
level0_val46="28"
level0_val47="6"
level0_val48="0"
level0_val49="4"
level0_val50="2"
level0_val51="90"
level0_val52="1"
level0_val53="0"
level0_val54="1"
level0_val55="200000"
level0_val56="400000"
level0_val57="0"
level0_val58="2400"
level0_val59="0:480000 1:0 2:556000"

# LEVEL 1
# lag percent: 14.9%
# battery life: 106.4%
level1_val1="0"
level1_val2="N"
level1_val3="0:306000 1:0 2:306000"
level1_val4="0:1594000 1:0 2:2151000"
level1_val5="1"
level1_val6="interactive"
level1_val7="306000"
level1_val8="1594000"
level1_val9="480000"
level1_val10="60"
level1_val11="18000"
level1_val12="98000"
level1_val13="38000 652000:138000 729000:158000 844000:178000 960000:38000 1036000:118000 1113000:138000 1190000:58000 1228000:118000 1324000:138000 1401000:38000 1478000:158000"
level1_val14="89 422000:60 480000:48 556000:56 652000:48 729000:52 844000:68 960000:56 1036000:44 1113000:80 1190000:72 1228000:52 1324000:84 1401000:60 1478000:68 1593000:76"
level1_val15="20000"
level1_val16="-1"
level1_val17="0"
level1_val18="0"
level1_val19="0"
level1_val20="0"
level1_val21="1"
level1_val22="0"
level1_val23="1"
level1_val24="0"
level1_val25="1"
level1_val26="interactive"
level1_val27="306000"
level1_val28="2151000"
level1_val29="1708000"
level1_val30="94"
level1_val31="18000"
level1_val32="18000"
level1_val33="198000 1996000:178000 2073000:158000"
level1_val34="16 403000:28 480000:48 556000:76 652000:84 729000:72 806000:80 883000:76 1036000:72 1190000:98 1248000:92 1324000:80 1478000:40 1555000:56 1632000:32 1708000:99"
level1_val35="20000"
level1_val36="-1"
level1_val37="0"
level1_val38="0"
level1_val39="0"
level1_val40="0"
level1_val41="1"
level1_val42="0"
level1_val43="1"
level1_val44="0"
level1_val45="5"
level1_val46="40"
level1_val47="5"
level1_val48="0"
level1_val49="3"
level1_val50="2"
level1_val51="90"
level1_val52="1"
level1_val53="0"
level1_val54="1"
level1_val55="200000"
level1_val56="400000"
level1_val57="0"
level1_val58="0"
level1_val59="0:422000 1:0 2:1324000"

# LEVEL 2
# lag percent: 29.8%
# battery life: 111.8%
level2_val1="0"
level2_val2="N"
level2_val3="0:306000 1:0 2:306000"
level2_val4="0:1594000 1:0 2:2151000"
level2_val5="1"
level2_val6="interactive"
level2_val7="306000"
level2_val8="1594000"
level2_val9="652000"
level2_val10="60"
level2_val11="18000"
level2_val12="78000"
level2_val13="158000 844000:138000 1036000:158000 1113000:98000 1190000:18000 1228000:38000 1324000:138000 1401000:178000 1478000:118000"
level2_val14="90 422000:88 480000:40 556000:94 652000:56 729000:80 844000:68 1190000:87 1228000:36 1324000:89 1401000:44 1478000:60 1593000:52"
level2_val15="20000"
level2_val16="-1"
level2_val17="0"
level2_val18="0"
level2_val19="0"
level2_val20="0"
level2_val21="1"
level2_val22="0"
level2_val23="1"
level2_val24="0"
level2_val25="1"
level2_val26="interactive"
level2_val27="306000"
level2_val28="2151000"
level2_val29="1708000"
level2_val30="99"
level2_val31="18000"
level2_val32="18000"
level2_val33="198000 2073000:158000"
level2_val34="40 403000:44 480000:64 556000:72 806000:87 883000:80 1036000:72 1113000:90 1190000:98 1248000:84 1324000:80 1478000:11 1555000:72 1632000:32 1708000:99"
level2_val35="20000"
level2_val36="-1"
level2_val37="0"
level2_val38="0"
level2_val39="0"
level2_val40="0"
level2_val41="1"
level2_val42="0"
level2_val43="1"
level2_val44="0"
level2_val45="5"
level2_val46="44"
level2_val47="5"
level2_val48="0"
level2_val49="3"
level2_val50="2"
level2_val51="90"
level2_val52="1"
level2_val53="0"
level2_val54="1"
level2_val55="200000"
level2_val56="400000"
level2_val57="0"
level2_val58="0"
level2_val59="0:652000 1:0 2:883000"

# LEVEL 3
# lag percent: 49.7%
# battery life: 117.2%
level3_val1="0"
level3_val2="N"
level3_val3="0:306000 1:0 2:306000"
level3_val4="0:1594000 1:0 2:2151000"
level3_val5="1"
level3_val6="interactive"
level3_val7="306000"
level3_val8="1594000"
level3_val9="729000"
level3_val10="56"
level3_val11="18000"
level3_val12="178000"
level3_val13="158000 844000:178000 960000:78000 1036000:38000 1113000:118000 1190000:98000 1228000:138000 1324000:98000 1401000:78000 1478000:138000"
level3_val14="72 422000:40 480000:28 556000:72 652000:84 729000:64 844000:56 960000:84 1036000:76 1113000:93 1190000:84 1228000:80 1324000:72 1401000:80 1593000:20"
level3_val15="20000"
level3_val16="-1"
level3_val17="0"
level3_val18="0"
level3_val19="0"
level3_val20="0"
level3_val21="1"
level3_val22="0"
level3_val23="1"
level3_val24="0"
level3_val25="1"
level3_val26="interactive"
level3_val27="306000"
level3_val28="2151000"
level3_val29="1708000"
level3_val30="85"
level3_val31="18000"
level3_val32="38000"
level3_val33="198000 1996000:138000 2073000:178000"
level3_val34="32 480000:48 556000:36 652000:64 729000:72 806000:86 883000:80 1113000:84 1190000:95 1324000:28 1401000:94 1478000:48 1555000:4 1632000:48 1708000:99"
level3_val35="20000"
level3_val36="-1"
level3_val37="0"
level3_val38="0"
level3_val39="0"
level3_val40="0"
level3_val41="1"
level3_val42="0"
level3_val43="1"
level3_val44="0"
level3_val45="2"
level3_val46="52"
level3_val47="2"
level3_val48="0"
level3_val49="3"
level3_val50="3"
level3_val51="90"
level3_val52="1"
level3_val53="0"
level3_val54="1"
level3_val55="200000"
level3_val56="400000"
level3_val57="0"
level3_val58="0"
level3_val59="0:1036000 1:0 2:1113000"

# LEVEL 4
# lag percent: 74.8%
# battery life: 124.8%
level4_val1="0"
level4_val2="N"
level4_val3="0:306000 1:0 2:306000"
level4_val4="0:1594000 1:0 2:2151000"
level4_val5="1"
level4_val6="interactive"
level4_val7="306000"
level4_val8="1594000"
level4_val9="729000"
level4_val10="60"
level4_val11="18000"
level4_val12="78000"
level4_val13="178000 844000:158000 960000:138000 1036000:78000 1113000:158000 1190000:98000 1228000:118000 1324000:78000 1478000:118000"
level4_val14="86 422000:10 480000:32 556000:76 652000:72 729000:68 844000:95 960000:64 1036000:72 1113000:90 1190000:64 1228000:56 1324000:76 1401000:48 1478000:44 1593000:76"
level4_val15="20000"
level4_val16="-1"
level4_val17="0"
level4_val18="0"
level4_val19="0"
level4_val20="0"
level4_val21="1"
level4_val22="0"
level4_val23="1"
level4_val24="0"
level4_val25="1"
level4_val26="interactive"
level4_val27="306000"
level4_val28="2151000"
level4_val29="1708000"
level4_val30="86"
level4_val31="18000"
level4_val32="58000"
level4_val33="198000 1920000:178000 1996000:198000 2073000:158000"
level4_val34="32 403000:24 480000:40 556000:64 652000:72 806000:76 940000:80 1113000:93 1190000:95 1248000:97 1324000:64 1401000:99 1478000:3 1555000:36 1632000:5 1708000:99 2073000:98"
level4_val35="20000"
level4_val36="-1"
level4_val37="0"
level4_val38="0"
level4_val39="0"
level4_val40="0"
level4_val41="1"
level4_val42="0"
level4_val43="1"
level4_val44="0"
level4_val45="3"
level4_val46="56"
level4_val47="3"
level4_val48="0"
level4_val49="3"
level4_val50="3"
level4_val51="90"
level4_val52="1"
level4_val53="0"
level4_val54="1"
level4_val55="200000"
level4_val56="400000"
level4_val57="0"
level4_val58="0"
level4_val59="0:1228000 1:0 2:1478000"

# LEVEL 5
# lag percent: 99.0%
# battery life: 132.2%
level5_val1="0"
level5_val2="N"
level5_val3="0:306000 1:0 2:306000"
level5_val4="0:1594000 1:0 2:2151000"
level5_val5="1"
level5_val6="interactive"
level5_val7="306000"
level5_val8="1594000"
level5_val9="729000"
level5_val10="56"
level5_val11="18000"
level5_val12="98000"
level5_val13="198000 844000:178000 960000:118000 1036000:158000 1113000:58000 1228000:78000 1324000:158000 1401000:98000"
level5_val14="87 422000:40 480000:90 556000:93 652000:68 844000:87 960000:68 1036000:24 1113000:98 1190000:64 1324000:44 1401000:56 1478000:60 1593000:91"
level5_val15="20000"
level5_val16="-1"
level5_val17="0"
level5_val18="0"
level5_val19="0"
level5_val20="0"
level5_val21="1"
level5_val22="0"
level5_val23="1"
level5_val24="0"
level5_val25="1"
level5_val26="interactive"
level5_val27="306000"
level5_val28="2151000"
level5_val29="1708000"
level5_val30="86"
level5_val31="18000"
level5_val32="38000"
level5_val33="198000 1920000:178000 2073000:158000"
level5_val34="28 403000:36 480000:32 556000:72 729000:80 806000:76 883000:68 940000:80 1113000:96 1190000:97 1248000:89 1324000:96 1401000:76 1555000:32 1632000:44 1708000:99"
level5_val35="20000"
level5_val36="-1"
level5_val37="0"
level5_val38="0"
level5_val39="0"
level5_val40="0"
level5_val41="1"
level5_val42="0"
level5_val43="1"
level5_val44="0"
level5_val45="24"
level5_val46="56"
level5_val47="24"
level5_val48="0"
level5_val49="3"
level5_val50="3"
level5_val51="90"
level5_val52="1"
level5_val53="0"
level5_val54="1"
level5_val55="200000"
level5_val56="400000"
level5_val57="0"
level5_val58="0"
level5_val59="0:1036000 1:0 2:480000"

# LEVEL 6
# lag percent: 119.9%
# battery life: 137.0%
level6_val1="0"
level6_val2="N"
level6_val3="0:306000 1:0 2:306000"
level6_val4="0:1594000 1:0 2:2151000"
level6_val5="1"
level6_val6="interactive"
level6_val7="306000"
level6_val8="1594000"
level6_val9="729000"
level6_val10="60"
level6_val11="18000"
level6_val12="138000"
level6_val13="198000 960000:18000 1036000:118000 1190000:78000 1228000:58000 1324000:138000"
level6_val14="72 422000:68 480000:85 556000:90 652000:89 729000:68 844000:90 960000:80 1036000:56 1113000:98 1190000:56 1228000:76 1324000:40 1401000:24 1478000:60 1593000:84"
level6_val15="20000"
level6_val16="-1"
level6_val17="0"
level6_val18="0"
level6_val19="0"
level6_val20="0"
level6_val21="1"
level6_val22="0"
level6_val23="1"
level6_val24="0"
level6_val25="1"
level6_val26="interactive"
level6_val27="306000"
level6_val28="2151000"
level6_val29="1708000"
level6_val30="86"
level6_val31="18000"
level6_val32="18000"
level6_val33="198000 2073000:178000"
level6_val34="20 403000:40 480000:68 556000:60 652000:64 729000:87 806000:76 883000:64 940000:80 1113000:93 1190000:96 1248000:97 1401000:94 1478000:28 1708000:99"
level6_val35="20000"
level6_val36="-1"
level6_val37="0"
level6_val38="0"
level6_val39="0"
level6_val40="0"
level6_val41="1"
level6_val42="0"
level6_val43="1"
level6_val44="0"
level6_val45="24"
level6_val46="60"
level6_val47="24"
level6_val48="0"
level6_val49="3"
level6_val50="3"
level6_val51="90"
level6_val52="1"
level6_val53="0"
level6_val54="1"
level6_val55="200000"
level6_val56="400000"
level6_val57="0"
level6_val58="0"
level6_val59="0:652000 1:0 2:1785000"
fi

esac

case ${SOC} in msm8994* | msm8992*) #sd810/808


esac
case ${SOC} in apq8074* | apq8084* | msm8074* | msm8084* | msm8274* | msm8674* | msm8974*)  #sd800-801-805


esac
case ${SOC} in sdm660* | sda660*) #sd660

# const variables
PARAM_NUM=59

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu4/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu4"

sysfs_obj1="/sys/module/msm_thermal/core_control/enabled"
sysfs_obj2="/sys/module/msm_thermal/parameters/enabled"
sysfs_obj3="/sys/module/msm_performance/parameters/cpu_min_freq"
sysfs_obj4="/sys/module/msm_performance/parameters/cpu_max_freq"
sysfs_obj5="${C0_DIR}/online"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj7="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj8="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj9="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj10="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj11="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj12="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj13="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj14="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj15="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj16="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj17="${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj18="${C0_GOVERNOR_DIR}/boost"
sysfs_obj19="${C0_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj20="${C0_GOVERNOR_DIR}/align_windows"
sysfs_obj21="${C0_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj22="${C0_GOVERNOR_DIR}/enable_prediction"
sysfs_obj23="${C0_GOVERNOR_DIR}/use_sched_load"
sysfs_obj24="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj25="${C1_DIR}/online"
sysfs_obj26="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj27="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj28="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj29="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj30="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj31="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj32="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj33="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj34="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj35="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj36="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj37="${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj38="${C1_GOVERNOR_DIR}/boost"
sysfs_obj39="${C1_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj40="${C1_GOVERNOR_DIR}/align_windows"
sysfs_obj41="${C1_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj42="${C1_GOVERNOR_DIR}/enable_prediction"
sysfs_obj43="${C1_GOVERNOR_DIR}/use_sched_load"
sysfs_obj44="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj45="${SCHED_DIR}/sched_downmigrate"
sysfs_obj46="${SCHED_DIR}/sched_upmigrate"
sysfs_obj47="${SCHED_DIR}/sched_downmigrate"
sysfs_obj48="${SCHED_DIR}/sched_freq_aggregate"
sysfs_obj49="${SCHED_DIR}/sched_ravg_hist_size"
sysfs_obj50="${SCHED_DIR}/sched_window_stats_policy"
sysfs_obj51="${SCHED_DIR}/sched_spill_load"
sysfs_obj52="${SCHED_DIR}/sched_restrict_cluster_spill"
sysfs_obj53="${SCHED_DIR}/sched_boost"
sysfs_obj54="${SCHED_DIR}/sched_prefer_sync_wakee_to_waker"
sysfs_obj55="${SCHED_DIR}/sched_freq_inc_notify"
sysfs_obj56="${SCHED_DIR}/sched_freq_dec_notify"
sysfs_obj57="/sys/module/msm_performance/parameters/touchboost"
sysfs_obj58="/sys/module/cpu_boost/parameters/input_boost_ms"
sysfs_obj59="/sys/module/cpu_boost/parameters/input_boost_freq"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 0.0%
# battery life: 77.6%
level0_val1="0"
level0_val2="N"
level0_val3="0:632000 1:0 2:0 3:0 4:1112000"
level0_val4="0:1844000 1:0 2:0 3:0 4:2209000"
level0_val5="1"
level0_val6="interactive"
level0_val7="632000"
level0_val8="1844000"
level0_val9="902000"
level0_val10="72"
level0_val11="38000"
level0_val12="78000"
level0_val13="198000 1401000:78000 1536000:118000 1747000:38000"
level0_val14="28 902000:94 1113000:76 1401000:64 1536000:32 1747000:80 1843000:64"
level0_val15="20000"
level0_val16="-1"
level0_val17="0"
level0_val18="0"
level0_val19="0"
level0_val20="0"
level0_val21="1"
level0_val22="0"
level0_val23="1"
level0_val24="0"
level0_val25="1"
level0_val26="interactive"
level0_val27="1112000"
level0_val28="2209000"
level0_val29="1958000"
level0_val30="72"
level0_val31="18000"
level0_val32="18000"
level0_val33="198000"
level0_val34="90 1401000:28 1747000:11 1958000:99"
level0_val35="20000"
level0_val36="-1"
level0_val37="0"
level0_val38="0"
level0_val39="0"
level0_val40="0"
level0_val41="1"
level0_val42="0"
level0_val43="1"
level0_val44="0"
level0_val45="7"
level0_val46="52"
level0_val47="7"
level0_val48="0"
level0_val49="5"
level0_val50="2"
level0_val51="90"
level0_val52="1"
level0_val53="0"
level0_val54="1"
level0_val55="200000"
level0_val56="400000"
level0_val57="0"
level0_val58="2000"
level0_val59="0:1401000 1:0 2:0 3:0 4:1401000"

# LEVEL 1
# lag percent: 15.0%
# battery life: 96.9%
level1_val1="0"
level1_val2="N"
level1_val3="0:632000 1:0 2:0 3:0 4:1112000"
level1_val4="0:1844000 1:0 2:0 3:0 4:2209000"
level1_val5="1"
level1_val6="interactive"
level1_val7="632000"
level1_val8="1844000"
level1_val9="1113000"
level1_val10="80"
level1_val11="18000"
level1_val12="198000"
level1_val13="198000 1401000:38000 1536000:138000"
level1_val14="76 902000:87 1113000:68 1401000:80 1536000:72 1747000:60 1843000:80"
level1_val15="20000"
level1_val16="-1"
level1_val17="0"
level1_val18="0"
level1_val19="0"
level1_val20="0"
level1_val21="1"
level1_val22="0"
level1_val23="1"
level1_val24="0"
level1_val25="1"
level1_val26="interactive"
level1_val27="1112000"
level1_val28="2209000"
level1_val29="1958000"
level1_val30="76"
level1_val31="18000"
level1_val32="18000"
level1_val33="198000"
level1_val34="84 1401000:96 1747000:8 1958000:99"
level1_val35="20000"
level1_val36="-1"
level1_val37="0"
level1_val38="0"
level1_val39="0"
level1_val40="0"
level1_val41="1"
level1_val42="0"
level1_val43="1"
level1_val44="0"
level1_val45="76"
level1_val46="76"
level1_val47="76"
level1_val48="0"
level1_val49="3"
level1_val50="2"
level1_val51="90"
level1_val52="1"
level1_val53="0"
level1_val54="1"
level1_val55="200000"
level1_val56="400000"
level1_val57="0"
level1_val58="1700"
level1_val59="0:1401000 1:0 2:0 3:0 4:1113000"

# LEVEL 2
# lag percent: 30.0%
# battery life: 104.3%
level2_val1="0"
level2_val2="N"
level2_val3="0:632000 1:0 2:0 3:0 4:1112000"
level2_val4="0:1844000 1:0 2:0 3:0 4:2209000"
level2_val5="1"
level2_val6="interactive"
level2_val7="632000"
level2_val8="1844000"
level2_val9="1113000"
level2_val10="88"
level2_val11="18000"
level2_val12="158000"
level2_val13="198000 1401000:18000 1536000:38000 1747000:198000"
level2_val14="60 902000:80 1113000:68 1401000:97 1536000:72 1747000:64 1843000:72"
level2_val15="20000"
level2_val16="-1"
level2_val17="0"
level2_val18="0"
level2_val19="0"
level2_val20="0"
level2_val21="1"
level2_val22="0"
level2_val23="1"
level2_val24="0"
level2_val25="1"
level2_val26="interactive"
level2_val27="1112000"
level2_val28="2209000"
level2_val29="1958000"
level2_val30="72"
level2_val31="18000"
level2_val32="18000"
level2_val33="198000"
level2_val34="64 1401000:97 1747000:16 1958000:99"
level2_val35="20000"
level2_val36="-1"
level2_val37="0"
level2_val38="0"
level2_val39="0"
level2_val40="0"
level2_val41="1"
level2_val42="0"
level2_val43="1"
level2_val44="0"
level2_val45="96"
level2_val46="96"
level2_val47="96"
level2_val48="0"
level2_val49="3"
level2_val50="2"
level2_val51="90"
level2_val52="1"
level2_val53="0"
level2_val54="1"
level2_val55="200000"
level2_val56="400000"
level2_val57="0"
level2_val58="1500"
level2_val59="0:1401000 1:0 2:0 3:0 4:1113000"

# LEVEL 3
# lag percent: 49.9%
# battery life: 110.5%
level3_val1="0"
level3_val2="N"
level3_val3="0:632000 1:0 2:0 3:0 4:1112000"
level3_val4="0:1844000 1:0 2:0 3:0 4:2209000"
level3_val5="1"
level3_val6="interactive"
level3_val7="632000"
level3_val8="1844000"
level3_val9="1113000"
level3_val10="88"
level3_val11="18000"
level3_val12="178000"
level3_val13="198000 1401000:18000 1536000:78000"
level3_val14="56 902000:80 1113000:68 1401000:87 1536000:72 1747000:89 1843000:60"
level3_val15="20000"
level3_val16="-1"
level3_val17="0"
level3_val18="0"
level3_val19="0"
level3_val20="0"
level3_val21="1"
level3_val22="0"
level3_val23="1"
level3_val24="0"
level3_val25="1"
level3_val26="interactive"
level3_val27="1112000"
level3_val28="2209000"
level3_val29="1958000"
level3_val30="72"
level3_val31="18000"
level3_val32="18000"
level3_val33="198000"
level3_val34="93 1401000:97 1747000:56 1958000:99"
level3_val35="20000"
level3_val36="-1"
level3_val37="0"
level3_val38="0"
level3_val39="0"
level3_val40="0"
level3_val41="1"
level3_val42="0"
level3_val43="1"
level3_val44="0"
level3_val45="97"
level3_val46="97"
level3_val47="97"
level3_val48="0"
level3_val49="3"
level3_val50="2"
level3_val51="90"
level3_val52="1"
level3_val53="0"
level3_val54="1"
level3_val55="200000"
level3_val56="400000"
level3_val57="0"
level3_val58="1200"
level3_val59="0:1401000 1:0 2:0 3:0 4:1113000"

# LEVEL 4
# lag percent: 74.9%
# battery life: 118.4%
level4_val1="0"
level4_val2="N"
level4_val3="0:632000 1:0 2:0 3:0 4:1112000"
level4_val4="0:1844000 1:0 2:0 3:0 4:2209000"
level4_val5="1"
level4_val6="interactive"
level4_val7="632000"
level4_val8="1844000"
level4_val9="1113000"
level4_val10="89"
level4_val11="18000"
level4_val12="178000"
level4_val13="198000 1401000:18000 1747000:198000"
level4_val14="60 902000:76 1113000:72 1401000:87 1536000:72 1747000:89 1843000:64"
level4_val15="20000"
level4_val16="-1"
level4_val17="0"
level4_val18="0"
level4_val19="0"
level4_val20="0"
level4_val21="1"
level4_val22="0"
level4_val23="1"
level4_val24="0"
level4_val25="1"
level4_val26="interactive"
level4_val27="1112000"
level4_val28="2209000"
level4_val29="1958000"
level4_val30="76"
level4_val31="18000"
level4_val32="18000"
level4_val33="198000"
level4_val34="56 1401000:97 1747000:68 1958000:99"
level4_val35="20000"
level4_val36="-1"
level4_val37="0"
level4_val38="0"
level4_val39="0"
level4_val40="0"
level4_val41="1"
level4_val42="0"
level4_val43="1"
level4_val44="0"
level4_val45="98"
level4_val46="98"
level4_val47="98"
level4_val48="0"
level4_val49="3"
level4_val50="2"
level4_val51="90"
level4_val52="1"
level4_val53="0"
level4_val54="1"
level4_val55="200000"
level4_val56="400000"
level4_val57="0"
level4_val58="1100"
level4_val59="0:1401000 1:0 2:0 3:0 4:1113000"

# LEVEL 5
# lag percent: 98.9%
# battery life: 126.7%
level5_val1="0"
level5_val2="N"
level5_val3="0:632000 1:0 2:0 3:0 4:1112000"
level5_val4="0:1844000 1:0 2:0 3:0 4:2209000"
level5_val5="1"
level5_val6="interactive"
level5_val7="632000"
level5_val8="1844000"
level5_val9="1113000"
level5_val10="86"
level5_val11="18000"
level5_val12="158000"
level5_val13="18000 1401000:158000 1536000:58000 1747000:178000"
level5_val14="76 902000:80 1113000:68 1401000:89 1536000:72 1747000:86 1843000:60"
level5_val15="20000"
level5_val16="-1"
level5_val17="0"
level5_val18="0"
level5_val19="0"
level5_val20="0"
level5_val21="1"
level5_val22="0"
level5_val23="1"
level5_val24="0"
level5_val25="1"
level5_val26="interactive"
level5_val27="1112000"
level5_val28="2209000"
level5_val29="1958000"
level5_val30="76"
level5_val31="18000"
level5_val32="18000"
level5_val33="198000"
level5_val34="56 1401000:97 1747000:20 1958000:99"
level5_val35="20000"
level5_val36="-1"
level5_val37="0"
level5_val38="0"
level5_val39="0"
level5_val40="0"
level5_val41="1"
level5_val42="0"
level5_val43="1"
level5_val44="0"
level5_val45="97"
level5_val46="97"
level5_val47="97"
level5_val48="0"
level5_val49="3"
level5_val50="2"
level5_val51="90"
level5_val52="1"
level5_val53="0"
level5_val54="1"
level5_val55="200000"
level5_val56="400000"
level5_val57="0"
level5_val58="1000"
level5_val59="0:1113000 1:0 2:0 3:0 4:1113000"

# LEVEL 6
# lag percent: 119.3%
# battery life: 134.1%
level6_val1="0"
level6_val2="N"
level6_val3="0:632000 1:0 2:0 3:0 4:1112000"
level6_val4="0:1844000 1:0 2:0 3:0 4:2209000"
level6_val5="1"
level6_val6="interactive"
level6_val7="632000"
level6_val8="1844000"
level6_val9="902000"
level6_val10="89"
level6_val11="18000"
level6_val12="158000"
level6_val13="38000 1401000:198000 1536000:38000 1747000:198000"
level6_val14="60 902000:80 1113000:64 1401000:88 1536000:72 1747000:90 1843000:56"
level6_val15="20000"
level6_val16="-1"
level6_val17="0"
level6_val18="0"
level6_val19="0"
level6_val20="0"
level6_val21="1"
level6_val22="0"
level6_val23="1"
level6_val24="0"
level6_val25="1"
level6_val26="interactive"
level6_val27="1112000"
level6_val28="2209000"
level6_val29="1958000"
level6_val30="76"
level6_val31="18000"
level6_val32="18000"
level6_val33="198000"
level6_val34="84 1401000:96 1747000:44 1958000:99"
level6_val35="20000"
level6_val36="-1"
level6_val37="0"
level6_val38="0"
level6_val39="0"
level6_val40="0"
level6_val41="1"
level6_val42="0"
level6_val43="1"
level6_val44="0"
level6_val45="98"
level6_val46="98"
level6_val47="98"
level6_val48="0"
level6_val49="3"
level6_val50="2"
level6_val51="90"
level6_val52="1"
level6_val53="0"
level6_val54="1"
level6_val55="200000"
level6_val56="400000"
level6_val57="0"
level6_val58="1200"
level6_val59="0:1113000 1:0 2:0 3:0 4:1113000"


esac
case ${SOC} in msm8956* | msm8976*)  #sd652/653/650

# const variables
PARAM_NUM=59

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu4/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu4"

sysfs_obj1="/sys/module/msm_thermal/core_control/enabled"
sysfs_obj2="/sys/module/msm_thermal/parameters/enabled"
sysfs_obj3="/sys/module/msm_performance/parameters/cpu_min_freq"
sysfs_obj4="/sys/module/msm_performance/parameters/cpu_max_freq"
sysfs_obj5="${C0_DIR}/online"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj7="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj8="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj9="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj10="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj11="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj12="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj13="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj14="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj15="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj16="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj17="${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj18="${C0_GOVERNOR_DIR}/boost"
sysfs_obj19="${C0_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj20="${C0_GOVERNOR_DIR}/align_windows"
sysfs_obj21="${C0_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj22="${C0_GOVERNOR_DIR}/enable_prediction"
sysfs_obj23="${C0_GOVERNOR_DIR}/use_sched_load"
sysfs_obj24="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj25="${C1_DIR}/online"
sysfs_obj26="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj27="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj28="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj29="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj30="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj31="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj32="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj33="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj34="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj35="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj36="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj37="${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj38="${C1_GOVERNOR_DIR}/boost"
sysfs_obj39="${C1_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj40="${C1_GOVERNOR_DIR}/align_windows"
sysfs_obj41="${C1_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj42="${C1_GOVERNOR_DIR}/enable_prediction"
sysfs_obj43="${C1_GOVERNOR_DIR}/use_sched_load"
sysfs_obj44="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj45="${SCHED_DIR}/sched_downmigrate"
sysfs_obj46="${SCHED_DIR}/sched_upmigrate"
sysfs_obj47="${SCHED_DIR}/sched_downmigrate"
sysfs_obj48="${SCHED_DIR}/sched_freq_aggregate"
sysfs_obj49="${SCHED_DIR}/sched_ravg_hist_size"
sysfs_obj50="${SCHED_DIR}/sched_window_stats_policy"
sysfs_obj51="${SCHED_DIR}/sched_spill_load"
sysfs_obj52="${SCHED_DIR}/sched_restrict_cluster_spill"
sysfs_obj53="${SCHED_DIR}/sched_boost"
sysfs_obj54="${SCHED_DIR}/sched_prefer_sync_wakee_to_waker"
sysfs_obj55="${SCHED_DIR}/sched_freq_inc_notify"
sysfs_obj56="${SCHED_DIR}/sched_freq_dec_notify"
sysfs_obj57="/sys/module/msm_performance/parameters/touchboost"
sysfs_obj58="/sys/module/cpu_boost/parameters/input_boost_ms"
sysfs_obj59="/sys/module/cpu_boost/parameters/input_boost_freq"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 0.0%
# battery life: 71.8%
level0_val1="0"
level0_val2="N"
level0_val3="0:399000 1:0 2:0 3:0 4:399000"
level0_val4="0:1402000 1:0 2:0 3:0 4:1805000"
level0_val5="1"
level0_val6="interactive"
level0_val7="399000"
level0_val8="1402000"
level0_val9="691000"
level0_val10="76"
level0_val11="18000"
level0_val12="78000"
level0_val13="198000 806000:158000 1190000:98000 1305000:78000 1382000:178000"
level0_val14="76 691000:96 806000:32 1017000:76 1190000:40 1305000:72 1382000:80 1401000:68"
level0_val15="20000"
level0_val16="-1"
level0_val17="0"
level0_val18="0"
level0_val19="0"
level0_val20="0"
level0_val21="1"
level0_val22="0"
level0_val23="1"
level0_val24="0"
level0_val25="1"
level0_val26="interactive"
level0_val27="399000"
level0_val28="1805000"
level0_val29="1612000"
level0_val30="28"
level0_val31="18000"
level0_val32="18000"
level0_val33="198000"
level0_val34="36 883000:89 998000:60 1056000:52 1113000:68 1190000:96 1305000:64 1382000:72 1612000:99 1747000:98"
level0_val35="20000"
level0_val36="-1"
level0_val37="0"
level0_val38="0"
level0_val39="0"
level0_val40="0"
level0_val41="1"
level0_val42="0"
level0_val43="1"
level0_val44="0"
level0_val45="28"
level0_val46="56"
level0_val47="28"
level0_val48="0"
level0_val49="4"
level0_val50="2"
level0_val51="90"
level0_val52="1"
level0_val53="0"
level0_val54="1"
level0_val55="200000"
level0_val56="400000"
level0_val57="0"
level0_val58="2500"
level0_val59="0:1305000 1:0 2:0 3:0 4:883000"

# LEVEL 1
# lag percent: 14.6%
# battery life: 91.7%
level1_val1="0"
level1_val2="N"
level1_val3="0:399000 1:0 2:0 3:0 4:399000"
level1_val4="0:1402000 1:0 2:0 3:0 4:1805000"
level1_val5="1"
level1_val6="interactive"
level1_val7="399000"
level1_val8="1402000"
level1_val9="691000"
level1_val10="80"
level1_val11="18000"
level1_val12="158000"
level1_val13="18000 806000:178000 1017000:198000 1190000:38000 1382000:98000"
level1_val14="85 691000:48 806000:93 1017000:80 1190000:48 1305000:56 1382000:76 1401000:94"
level1_val15="20000"
level1_val16="-1"
level1_val17="0"
level1_val18="0"
level1_val19="0"
level1_val20="0"
level1_val21="1"
level1_val22="0"
level1_val23="1"
level1_val24="0"
level1_val25="1"
level1_val26="interactive"
level1_val27="399000"
level1_val28="1805000"
level1_val29="1612000"
level1_val30="68"
level1_val31="18000"
level1_val32="18000"
level1_val33="198000"
level1_val34="44 883000:76 940000:80 998000:68 1056000:28 1113000:97 1190000:88 1248000:44 1305000:80 1612000:99"
level1_val35="20000"
level1_val36="-1"
level1_val37="0"
level1_val38="0"
level1_val39="0"
level1_val40="0"
level1_val41="1"
level1_val42="0"
level1_val43="1"
level1_val44="0"
level1_val45="91"
level1_val46="91"
level1_val47="91"
level1_val48="0"
level1_val49="3"
level1_val50="2"
level1_val51="90"
level1_val52="1"
level1_val53="0"
level1_val54="1"
level1_val55="200000"
level1_val56="400000"
level1_val57="0"
level1_val58="1600"
level1_val59="0:1305000 1:0 2:0 3:0 4:400000"

# LEVEL 2
# lag percent: 30.0%
# battery life: 97.7%
level2_val1="0"
level2_val2="N"
level2_val3="0:399000 1:0 2:0 3:0 4:399000"
level2_val4="0:1402000 1:0 2:0 3:0 4:1805000"
level2_val5="1"
level2_val6="interactive"
level2_val7="399000"
level2_val8="1402000"
level2_val9="691000"
level2_val10="72"
level2_val11="18000"
level2_val12="138000"
level2_val13="18000 806000:158000 1017000:178000 1190000:38000 1382000:138000"
level2_val14="72 691000:16 806000:95 1017000:80 1190000:64 1305000:56 1382000:68 1401000:94"
level2_val15="20000"
level2_val16="-1"
level2_val17="0"
level2_val18="0"
level2_val19="0"
level2_val20="0"
level2_val21="1"
level2_val22="0"
level2_val23="1"
level2_val24="0"
level2_val25="1"
level2_val26="interactive"
level2_val27="399000"
level2_val28="1805000"
level2_val29="1612000"
level2_val30="68"
level2_val31="18000"
level2_val32="18000"
level2_val33="198000"
level2_val34="60 883000:16 940000:64 998000:44 1113000:96 1190000:89 1248000:32 1305000:87 1382000:80 1612000:99 1804000:98"
level2_val35="20000"
level2_val36="-1"
level2_val37="0"
level2_val38="0"
level2_val39="0"
level2_val40="0"
level2_val41="1"
level2_val42="0"
level2_val43="1"
level2_val44="0"
level2_val45="96"
level2_val46="96"
level2_val47="96"
level2_val48="0"
level2_val49="3"
level2_val50="2"
level2_val51="90"
level2_val52="1"
level2_val53="0"
level2_val54="1"
level2_val55="200000"
level2_val56="400000"
level2_val57="0"
level2_val58="1400"
level2_val59="0:1190000 1:0 2:0 3:0 4:400000"

# LEVEL 3
# lag percent: 49.8%
# battery life: 105.4%
level3_val1="0"
level3_val2="N"
level3_val3="0:399000 1:0 2:0 3:0 4:399000"
level3_val4="0:1402000 1:0 2:0 3:0 4:1805000"
level3_val5="1"
level3_val6="interactive"
level3_val7="399000"
level3_val8="1402000"
level3_val9="1382000"
level3_val10="80"
level3_val11="18000"
level3_val12="78000"
level3_val13="158000"
level3_val14="44 691000:48 806000:16 1017000:72 1190000:94 1305000:72 1382000:85"
level3_val15="20000"
level3_val16="-1"
level3_val17="0"
level3_val18="0"
level3_val19="0"
level3_val20="0"
level3_val21="1"
level3_val22="0"
level3_val23="1"
level3_val24="0"
level3_val25="1"
level3_val26="interactive"
level3_val27="399000"
level3_val28="1805000"
level3_val29="1612000"
level3_val30="85"
level3_val31="18000"
level3_val32="18000"
level3_val33="198000"
level3_val34="64 883000:16 940000:24 998000:52 1056000:90 1113000:94 1190000:90 1248000:44 1305000:84 1382000:72 1612000:99"
level3_val35="20000"
level3_val36="-1"
level3_val37="0"
level3_val38="0"
level3_val39="0"
level3_val40="0"
level3_val41="1"
level3_val42="0"
level3_val43="1"
level3_val44="0"
level3_val45="88"
level3_val46="88"
level3_val47="88"
level3_val48="0"
level3_val49="3"
level3_val50="3"
level3_val51="90"
level3_val52="1"
level3_val53="0"
level3_val54="1"
level3_val55="200000"
level3_val56="400000"
level3_val57="0"
level3_val58="0"
level3_val59="0:1190000 1:0 2:0 3:0 4:883000"

# LEVEL 4
# lag percent: 75.0%
# battery life: 115.9%
level4_val1="0"
level4_val2="N"
level4_val3="0:399000 1:0 2:0 3:0 4:399000"
level4_val4="0:1402000 1:0 2:0 3:0 4:1805000"
level4_val5="1"
level4_val6="interactive"
level4_val7="399000"
level4_val8="1402000"
level4_val9="1190000"
level4_val10="91"
level4_val11="48000"
level4_val12="148000"
level4_val13="198000 1305000:48000 1382000:198000"
level4_val14="9 691000:24 806000:36 1017000:90 1190000:72 1305000:52 1382000:76 1401000:90"
level4_val15="50000"
level4_val16="-1"
level4_val17="0"
level4_val18="0"
level4_val19="0"
level4_val20="0"
level4_val21="1"
level4_val22="0"
level4_val23="1"
level4_val24="0"
level4_val25="1"
level4_val26="interactive"
level4_val27="399000"
level4_val28="1805000"
level4_val29="1612000"
level4_val30="72"
level4_val31="48000"
level4_val32="48000"
level4_val33="198000"
level4_val34="60 883000:44 940000:76 998000:36 1056000:16 1113000:99 1190000:98 1248000:24 1305000:52 1382000:89 1612000:99"
level4_val35="50000"
level4_val36="-1"
level4_val37="0"
level4_val38="0"
level4_val39="0"
level4_val40="0"
level4_val41="1"
level4_val42="0"
level4_val43="1"
level4_val44="0"
level4_val45="91"
level4_val46="91"
level4_val47="91"
level4_val48="0"
level4_val49="4"
level4_val50="3"
level4_val51="90"
level4_val52="1"
level4_val53="0"
level4_val54="1"
level4_val55="200000"
level4_val56="400000"
level4_val57="0"
level4_val58="100"
level4_val59="0:1382000 1:0 2:0 3:0 4:400000"

# LEVEL 5
# lag percent: 98.9%
# battery life: 128.5%
level5_val1="0"
level5_val2="N"
level5_val3="0:399000 1:0 2:0 3:0 4:399000"
level5_val4="0:1402000 1:0 2:0 3:0 4:1805000"
level5_val5="1"
level5_val6="interactive"
level5_val7="399000"
level5_val8="1402000"
level5_val9="1017000"
level5_val10="60"
level5_val11="78000"
level5_val12="78000"
level5_val13="78000 1190000:238000 1305000:78000 1382000:158000"
level5_val14="24 691000:28 806000:32 1017000:76 1190000:99 1305000:60 1382000:76 1401000:80"
level5_val15="80000"
level5_val16="-1"
level5_val17="0"
level5_val18="0"
level5_val19="0"
level5_val20="0"
level5_val21="1"
level5_val22="0"
level5_val23="1"
level5_val24="0"
level5_val25="1"
level5_val26="interactive"
level5_val27="399000"
level5_val28="1805000"
level5_val29="1612000"
level5_val30="80"
level5_val31="78000"
level5_val32="78000"
level5_val33="238000 1747000:158000"
level5_val34="44 883000:76 940000:56 998000:76 1056000:56 1113000:97 1190000:94 1248000:24 1305000:76 1382000:44 1612000:99"
level5_val35="80000"
level5_val36="-1"
level5_val37="0"
level5_val38="0"
level5_val39="0"
level5_val40="0"
level5_val41="1"
level5_val42="0"
level5_val43="1"
level5_val44="0"
level5_val45="92"
level5_val46="92"
level5_val47="92"
level5_val48="0"
level5_val49="5"
level5_val50="3"
level5_val51="90"
level5_val52="1"
level5_val53="0"
level5_val54="1"
level5_val55="200000"
level5_val56="400000"
level5_val57="0"
level5_val58="200"
level5_val59="0:1382000 1:0 2:0 3:0 4:400000"

# LEVEL 6
# lag percent: 119.9%
# battery life: 137.4%
level6_val1="0"
level6_val2="N"
level6_val3="0:399000 1:0 2:0 3:0 4:399000"
level6_val4="0:1402000 1:0 2:0 3:0 4:1805000"
level6_val5="1"
level6_val6="interactive"
level6_val7="399000"
level6_val8="1402000"
level6_val9="1017000"
level6_val10="56"
level6_val11="78000"
level6_val12="78000"
level6_val13="78000 1190000:238000 1305000:158000"
level6_val14="24 691000:32 806000:36 1017000:76 1190000:99 1305000:56 1382000:85 1401000:89"
level6_val15="80000"
level6_val16="-1"
level6_val17="0"
level6_val18="0"
level6_val19="0"
level6_val20="0"
level6_val21="1"
level6_val22="0"
level6_val23="1"
level6_val24="0"
level6_val25="1"
level6_val26="interactive"
level6_val27="399000"
level6_val28="1805000"
level6_val29="1612000"
level6_val30="72"
level6_val31="78000"
level6_val32="78000"
level6_val33="238000 1747000:158000"
level6_val34="84 883000:40 940000:36 998000:96 1056000:44 1113000:94 1190000:95 1248000:56 1305000:76 1382000:87 1612000:99"
level6_val35="80000"
level6_val36="-1"
level6_val37="0"
level6_val38="0"
level6_val39="0"
level6_val40="0"
level6_val41="1"
level6_val42="0"
level6_val43="1"
level6_val44="0"
level6_val45="92"
level6_val46="92"
level6_val47="92"
level6_val48="0"
level6_val49="5"
level6_val50="3"
level6_val51="90"
level6_val52="1"
level6_val53="0"
level6_val54="1"
level6_val55="200000"
level6_val56="400000"
level6_val57="0"
level6_val58="100"
level6_val59="0:1305000 1:0 2:0 3:0 4:400000"

esac
case ${SOC} in sdm636* | sda636*) #sd636

# const variables
PARAM_NUM=59

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu4/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu4"

sysfs_obj1="/sys/module/msm_thermal/core_control/enabled"
sysfs_obj2="/sys/module/msm_thermal/parameters/enabled"
sysfs_obj3="/sys/module/msm_performance/parameters/cpu_min_freq"
sysfs_obj4="/sys/module/msm_performance/parameters/cpu_max_freq"
sysfs_obj5="${C0_DIR}/online"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj7="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj8="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj9="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj10="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj11="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj12="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj13="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj14="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj15="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj16="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj17="${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj18="${C0_GOVERNOR_DIR}/boost"
sysfs_obj19="${C0_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj20="${C0_GOVERNOR_DIR}/align_windows"
sysfs_obj21="${C0_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj22="${C0_GOVERNOR_DIR}/enable_prediction"
sysfs_obj23="${C0_GOVERNOR_DIR}/use_sched_load"
sysfs_obj24="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj25="${C1_DIR}/online"
sysfs_obj26="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj27="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj28="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj29="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj30="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj31="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj32="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj33="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj34="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj35="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj36="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj37="${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj38="${C1_GOVERNOR_DIR}/boost"
sysfs_obj39="${C1_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj40="${C1_GOVERNOR_DIR}/align_windows"
sysfs_obj41="${C1_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj42="${C1_GOVERNOR_DIR}/enable_prediction"
sysfs_obj43="${C1_GOVERNOR_DIR}/use_sched_load"
sysfs_obj44="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj45="${SCHED_DIR}/sched_downmigrate"
sysfs_obj46="${SCHED_DIR}/sched_upmigrate"
sysfs_obj47="${SCHED_DIR}/sched_downmigrate"
sysfs_obj48="${SCHED_DIR}/sched_freq_aggregate"
sysfs_obj49="${SCHED_DIR}/sched_ravg_hist_size"
sysfs_obj50="${SCHED_DIR}/sched_window_stats_policy"
sysfs_obj51="${SCHED_DIR}/sched_spill_load"
sysfs_obj52="${SCHED_DIR}/sched_restrict_cluster_spill"
sysfs_obj53="${SCHED_DIR}/sched_boost"
sysfs_obj54="${SCHED_DIR}/sched_prefer_sync_wakee_to_waker"
sysfs_obj55="${SCHED_DIR}/sched_freq_inc_notify"
sysfs_obj56="${SCHED_DIR}/sched_freq_dec_notify"
sysfs_obj57="/sys/module/msm_performance/parameters/touchboost"
sysfs_obj58="/sys/module/cpu_boost/parameters/input_boost_ms"
sysfs_obj59="/sys/module/cpu_boost/parameters/input_boost_freq"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 0.0%
# battery life: 76.4%
level0_val1="0"
level0_val2="N"
level0_val3="0:632000 1:0 2:0 3:0 4:1112000"
level0_val4="0:1613000 1:0 2:0 3:0 4:1805000"
level0_val5="1"
level0_val6="interactive"
level0_val7="632000"
level0_val8="1613000"
level0_val9="902000"
level0_val10="80"
level0_val11="18000"
level0_val12="138000"
level0_val13="198000 1113000:58000 1401000:118000"
level0_val14="72 902000:97 1113000:84 1401000:9 1536000:52 1612000:80"
level0_val15="20000"
level0_val16="-1"
level0_val17="0"
level0_val18="0"
level0_val19="0"
level0_val20="0"
level0_val21="1"
level0_val22="0"
level0_val23="1"
level0_val24="0"
level0_val25="1"
level0_val26="interactive"
level0_val27="1112000"
level0_val28="1805000"
level0_val29="1747000"
level0_val30="72"
level0_val31="18000"
level0_val32="18000"
level0_val33="198000"
level0_val34="72 1401000:24 1747000:99"
level0_val35="20000"
level0_val36="-1"
level0_val37="0"
level0_val38="0"
level0_val39="0"
level0_val40="0"
level0_val41="1"
level0_val42="0"
level0_val43="1"
level0_val44="0"
level0_val45="28"
level0_val46="56"
level0_val47="28"
level0_val48="0"
level0_val49="5"
level0_val50="2"
level0_val51="90"
level0_val52="1"
level0_val53="0"
level0_val54="1"
level0_val55="200000"
level0_val56="400000"
level0_val57="0"
level0_val58="2100"
level0_val59="0:1401000 1:0 2:0 3:0 4:1401000"

# LEVEL 1
# lag percent: 14.9%
# battery life: 90.8%
level1_val1="0"
level1_val2="N"
level1_val3="0:632000 1:0 2:0 3:0 4:1112000"
level1_val4="0:1613000 1:0 2:0 3:0 4:1805000"
level1_val5="1"
level1_val6="interactive"
level1_val7="632000"
level1_val8="1613000"
level1_val9="1113000"
level1_val10="88"
level1_val11="18000"
level1_val12="198000"
level1_val13="118000 1401000:38000 1536000:158000"
level1_val14="80 902000:98 1113000:68 1401000:72 1536000:28 1612000:80"
level1_val15="20000"
level1_val16="-1"
level1_val17="0"
level1_val18="0"
level1_val19="0"
level1_val20="0"
level1_val21="1"
level1_val22="0"
level1_val23="1"
level1_val24="0"
level1_val25="1"
level1_val26="interactive"
level1_val27="1112000"
level1_val28="1805000"
level1_val29="1747000"
level1_val30="72"
level1_val31="18000"
level1_val32="18000"
level1_val33="198000"
level1_val34="97 1401000:72 1747000:99"
level1_val35="20000"
level1_val36="-1"
level1_val37="0"
level1_val38="0"
level1_val39="0"
level1_val40="0"
level1_val41="1"
level1_val42="0"
level1_val43="1"
level1_val44="0"
level1_val45="86"
level1_val46="86"
level1_val47="86"
level1_val48="0"
level1_val49="3"
level1_val50="2"
level1_val51="90"
level1_val52="1"
level1_val53="0"
level1_val54="1"
level1_val55="200000"
level1_val56="400000"
level1_val57="0"
level1_val58="1800"
level1_val59="0:1401000 1:0 2:0 3:0 4:1113000"

# LEVEL 2
# lag percent: 29.9%
# battery life: 95.6%
level2_val1="0"
level2_val2="N"
level2_val3="0:632000 1:0 2:0 3:0 4:1112000"
level2_val4="0:1613000 1:0 2:0 3:0 4:1805000"
level2_val5="1"
level2_val6="interactive"
level2_val7="632000"
level2_val8="1613000"
level2_val9="1113000"
level2_val10="92"
level2_val11="18000"
level2_val12="198000"
level2_val13="178000 1401000:18000 1536000:138000"
level2_val14="56 902000:87 1113000:76 1401000:68 1536000:76 1612000:64"
level2_val15="20000"
level2_val16="-1"
level2_val17="0"
level2_val18="0"
level2_val19="0"
level2_val20="0"
level2_val21="1"
level2_val22="0"
level2_val23="1"
level2_val24="0"
level2_val25="1"
level2_val26="interactive"
level2_val27="1112000"
level2_val28="1805000"
level2_val29="1747000"
level2_val30="72"
level2_val31="18000"
level2_val32="18000"
level2_val33="198000"
level2_val34="28 1401000:93 1747000:99"
level2_val35="20000"
level2_val36="-1"
level2_val37="0"
level2_val38="0"
level2_val39="0"
level2_val40="0"
level2_val41="1"
level2_val42="0"
level2_val43="1"
level2_val44="0"
level2_val45="96"
level2_val46="96"
level2_val47="96"
level2_val48="0"
level2_val49="3"
level2_val50="2"
level2_val51="90"
level2_val52="1"
level2_val53="0"
level2_val54="1"
level2_val55="200000"
level2_val56="400000"
level2_val57="0"
level2_val58="1500"
level2_val59="0:1401000 1:0 2:0 3:0 4:1113000"

# LEVEL 3
# lag percent: 49.8%
# battery life: 99.8%
level3_val1="0"
level3_val2="N"
level3_val3="0:632000 1:0 2:0 3:0 4:1112000"
level3_val4="0:1613000 1:0 2:0 3:0 4:1805000"
level3_val5="1"
level3_val6="interactive"
level3_val7="632000"
level3_val8="1613000"
level3_val9="1113000"
level3_val10="98"
level3_val11="18000"
level3_val12="198000"
level3_val13="178000 1401000:18000 1536000:198000"
level3_val14="60 902000:91 1113000:76 1401000:68 1536000:76 1612000:68"
level3_val15="20000"
level3_val16="-1"
level3_val17="0"
level3_val18="0"
level3_val19="0"
level3_val20="0"
level3_val21="1"
level3_val22="0"
level3_val23="1"
level3_val24="0"
level3_val25="1"
level3_val26="interactive"
level3_val27="1112000"
level3_val28="1805000"
level3_val29="1747000"
level3_val30="76"
level3_val31="18000"
level3_val32="18000"
level3_val33="198000"
level3_val34="98 1401000:90 1747000:99"
level3_val35="20000"
level3_val36="-1"
level3_val37="0"
level3_val38="0"
level3_val39="0"
level3_val40="0"
level3_val41="1"
level3_val42="0"
level3_val43="1"
level3_val44="0"
level3_val45="98"
level3_val46="98"
level3_val47="98"
level3_val48="0"
level3_val49="3"
level3_val50="2"
level3_val51="90"
level3_val52="1"
level3_val53="0"
level3_val54="1"
level3_val55="200000"
level3_val56="400000"
level3_val57="0"
level3_val58="900"
level3_val59="0:1401000 1:0 2:0 3:0 4:1113000"

# LEVEL 4
# lag percent: 74.7%
# battery life: 106.9%
level4_val1="0"
level4_val2="N"
level4_val3="0:632000 1:0 2:0 3:0 4:1112000"
level4_val4="0:1613000 1:0 2:0 3:0 4:1805000"
level4_val5="1"
level4_val6="interactive"
level4_val7="632000"
level4_val8="1613000"
level4_val9="902000"
level4_val10="91"
level4_val11="18000"
level4_val12="198000"
level4_val13="18000 1113000:198000 1401000:178000"
level4_val14="60 902000:76 1113000:40 1401000:76 1536000:36 1612000:68"
level4_val15="20000"
level4_val16="-1"
level4_val17="0"
level4_val18="0"
level4_val19="0"
level4_val20="0"
level4_val21="1"
level4_val22="0"
level4_val23="1"
level4_val24="0"
level4_val25="1"
level4_val26="interactive"
level4_val27="1112000"
level4_val28="1805000"
level4_val29="1747000"
level4_val30="72"
level4_val31="18000"
level4_val32="18000"
level4_val33="198000"
level4_val34="80 1401000:92 1747000:99"
level4_val35="20000"
level4_val36="-1"
level4_val37="0"
level4_val38="0"
level4_val39="0"
level4_val40="0"
level4_val41="1"
level4_val42="0"
level4_val43="1"
level4_val44="0"
level4_val45="96"
level4_val46="96"
level4_val47="96"
level4_val48="0"
level4_val49="3"
level4_val50="2"
level4_val51="90"
level4_val52="1"
level4_val53="0"
level4_val54="1"
level4_val55="200000"
level4_val56="400000"
level4_val57="0"
level4_val58="0"
level4_val59="0:1401000 1:0 2:0 3:0 4:1401000"

# LEVEL 5
# lag percent: 98.9%
# battery life: 112.6%
level5_val1="0"
level5_val2="N"
level5_val3="0:632000 1:0 2:0 3:0 4:1112000"
level5_val4="0:1613000 1:0 2:0 3:0 4:1805000"
level5_val5="1"
level5_val6="interactive"
level5_val7="632000"
level5_val8="1613000"
level5_val9="1113000"
level5_val10="86"
level5_val11="18000"
level5_val12="118000"
level5_val13="198000 1536000:158000"
level5_val14="32 902000:72 1113000:44 1401000:80 1536000:32 1612000:89"
level5_val15="20000"
level5_val16="-1"
level5_val17="0"
level5_val18="0"
level5_val19="0"
level5_val20="0"
level5_val21="1"
level5_val22="0"
level5_val23="1"
level5_val24="0"
level5_val25="1"
level5_val26="interactive"
level5_val27="1112000"
level5_val28="1805000"
level5_val29="1747000"
level5_val30="80"
level5_val31="38000"
level5_val32="38000"
level5_val33="198000"
level5_val34="72 1401000:99"
level5_val35="20000"
level5_val36="-1"
level5_val37="0"
level5_val38="0"
level5_val39="0"
level5_val40="0"
level5_val41="1"
level5_val42="0"
level5_val43="1"
level5_val44="0"
level5_val45="64"
level5_val46="90"
level5_val47="64"
level5_val48="0"
level5_val49="3"
level5_val50="3"
level5_val51="90"
level5_val52="1"
level5_val53="0"
level5_val54="1"
level5_val55="200000"
level5_val56="400000"
level5_val57="0"
level5_val58="0"
level5_val59="0:1401000 1:0 2:0 3:0 4:1804000"

# LEVEL 6
# lag percent: 120.0%
# battery life: 117.9%
level6_val1="0"
level6_val2="N"
level6_val3="0:632000 1:0 2:0 3:0 4:1112000"
level6_val4="0:1613000 1:0 2:0 3:0 4:1805000"
level6_val5="1"
level6_val6="interactive"
level6_val7="632000"
level6_val8="1613000"
level6_val9="1113000"
level6_val10="76"
level6_val11="18000"
level6_val12="118000"
level6_val13="198000 1536000:78000"
level6_val14="36 902000:72 1113000:40 1401000:80 1536000:24 1612000:80"
level6_val15="20000"
level6_val16="-1"
level6_val17="0"
level6_val18="0"
level6_val19="0"
level6_val20="0"
level6_val21="1"
level6_val22="0"
level6_val23="1"
level6_val24="0"
level6_val25="1"
level6_val26="interactive"
level6_val27="1112000"
level6_val28="1805000"
level6_val29="1747000"
level6_val30="80"
level6_val31="38000"
level6_val32="18000"
level6_val33="198000"
level6_val34="88 1401000:98 1747000:99"
level6_val35="20000"
level6_val36="-1"
level6_val37="0"
level6_val38="0"
level6_val39="0"
level6_val40="0"
level6_val41="1"
level6_val42="0"
level6_val43="1"
level6_val44="0"
level6_val45="64"
level6_val46="92"
level6_val47="64"
level6_val48="0"
level6_val49="3"
level6_val50="3"
level6_val51="90"
level6_val52="1"
level6_val53="0"
level6_val54="1"
level6_val55="200000"
level6_val56="400000"
level6_val57="0"
level6_val58="0"
level6_val59="0:1401000 1:0 2:0 3:0 4:1401000"



esac
case ${SOC} in msm8953* )  #sd625/626
	
if [[ ${soc_revision} == "1.1" ]]; then

# const variables
PARAM_NUM=39

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpufreq/interactive"
C1_GOVERNOR_DIR=""
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu4"

sysfs_obj1="/sys/module/msm_thermal/core_control/enabled"
sysfs_obj2="/sys/module/msm_thermal/parameters/enabled"
sysfs_obj3="/sys/module/msm_performance/parameters/cpu_min_freq"
sysfs_obj4="/sys/module/msm_performance/parameters/cpu_max_freq"
sysfs_obj5="${C0_DIR}/online"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj7="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj8="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj9="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj10="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj11="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj12="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj13="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj14="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj15="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj16="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj17="${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj18="${C0_GOVERNOR_DIR}/boost"
sysfs_obj19="${C0_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj20="${C0_GOVERNOR_DIR}/align_windows"
sysfs_obj21="${C0_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj22="${C0_GOVERNOR_DIR}/enable_prediction"
sysfs_obj23="${C0_GOVERNOR_DIR}/use_sched_load"
sysfs_obj24="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj25="${SCHED_DIR}/sched_downmigrate"
sysfs_obj26="${SCHED_DIR}/sched_upmigrate"
sysfs_obj27="${SCHED_DIR}/sched_downmigrate"
sysfs_obj28="${SCHED_DIR}/sched_freq_aggregate"
sysfs_obj29="${SCHED_DIR}/sched_ravg_hist_size"
sysfs_obj30="${SCHED_DIR}/sched_window_stats_policy"
sysfs_obj31="${SCHED_DIR}/sched_spill_load"
sysfs_obj32="${SCHED_DIR}/sched_restrict_cluster_spill"
sysfs_obj33="${SCHED_DIR}/sched_boost"
sysfs_obj34="${SCHED_DIR}/sched_prefer_sync_wakee_to_waker"
sysfs_obj35="${SCHED_DIR}/sched_freq_inc_notify"
sysfs_obj36="${SCHED_DIR}/sched_freq_dec_notify"
sysfs_obj37="/sys/module/msm_performance/parameters/touchboost"
sysfs_obj38="/sys/module/cpu_boost/parameters/input_boost_ms"
sysfs_obj39="/sys/module/cpu_boost/parameters/input_boost_freq"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 0.0%
# battery life: 104.0%
level0_val1="0"
level0_val2="N"
level0_val3="0:651000 1:0 2:0 3:0"
level0_val4="0:2209000 1:0 2:0 3:0"
level0_val5="1"
level0_val6="interactive"
level0_val7="651000"
level0_val8="2209000"
level0_val9="1036000"
level0_val10="93"
level0_val11="98000"
level0_val12="98000"
level0_val13="198000 1401000:98000 1804000:198000"
level0_val14="36 1036000:97 1401000:36 1689000:60 1804000:99"
level0_val15="100000"
level0_val16="-1"
level0_val17="0"
level0_val18="0"
level0_val19="0"
level0_val20="0"
level0_val21="1"
level0_val22="0"
level0_val23="1"
level0_val24="0"
level0_val25="45"
level0_val26="45"
level0_val27="45"
level0_val28="0"
level0_val29="5"
level0_val30="3"
level0_val31="90"
level0_val32="1"
level0_val33="0"
level0_val34="1"
level0_val35="200000"
level0_val36="400000"
level0_val37="0"
level0_val38="2000"
level0_val39="0:1804000 1:0 2:0 3:0"

# LEVEL 1
# lag percent: 14.9%
# battery life: 108.6%
level1_val1="0"
level1_val2="N"
level1_val3="0:651000 1:0 2:0 3:0"
level1_val4="0:2209000 1:0 2:0 3:0"
level1_val5="1"
level1_val6="interactive"
level1_val7="651000"
level1_val8="2209000"
level1_val9="1804000"
level1_val10="80"
level1_val11="18000"
level1_val12="18000"
level1_val13="198000"
level1_val14="64 1036000:94 1401000:86 1689000:52 1804000:99"
level1_val15="20000"
level1_val16="-1"
level1_val17="0"
level1_val18="0"
level1_val19="0"
level1_val20="0"
level1_val21="1"
level1_val22="0"
level1_val23="1"
level1_val24="0"
level1_val25="45"
level1_val26="45"
level1_val27="45"
level1_val28="0"
level1_val29="4"
level1_val30="2"
level1_val31="90"
level1_val32="1"
level1_val33="0"
level1_val34="1"
level1_val35="200000"
level1_val36="400000"
level1_val37="0"
level1_val38="100"
level1_val39="0:1689000 1:0 2:0 3:0"

# LEVEL 2
# lag percent: 29.8%
# battery life: 111.1%
level2_val1="0"
level2_val2="N"
level2_val3="0:651000 1:0 2:0 3:0"
level2_val4="0:2209000 1:0 2:0 3:0"
level2_val5="1"
level2_val6="interactive"
level2_val7="651000"
level2_val8="2209000"
level2_val9="1804000"
level2_val10="97"
level2_val11="18000"
level2_val12="18000"
level2_val13="198000"
level2_val14="68 1036000:89 1401000:80 1689000:44 1804000:99"
level2_val15="20000"
level2_val16="-1"
level2_val17="0"
level2_val18="0"
level2_val19="0"
level2_val20="0"
level2_val21="1"
level2_val22="0"
level2_val23="1"
level2_val24="0"
level2_val25="45"
level2_val26="45"
level2_val27="45"
level2_val28="0"
level2_val29="4"
level2_val30="2"
level2_val31="90"
level2_val32="1"
level2_val33="0"
level2_val34="1"
level2_val35="200000"
level2_val36="400000"
level2_val37="0"
level2_val38="100"
level2_val39="0:1036000 1:0 2:0 3:0"

# LEVEL 3
# lag percent: 49.9%
# battery life: 113.3%
level3_val1="0"
level3_val2="N"
level3_val3="0:651000 1:0 2:0 3:0"
level3_val4="0:2209000 1:0 2:0 3:0"
level3_val5="1"
level3_val6="interactive"
level3_val7="651000"
level3_val8="2209000"
level3_val9="1804000"
level3_val10="76"
level3_val11="18000"
level3_val12="18000"
level3_val13="198000"
level3_val14="32 1036000:99 1401000:80 1689000:36 1804000:99"
level3_val15="20000"
level3_val16="-1"
level3_val17="0"
level3_val18="0"
level3_val19="0"
level3_val20="0"
level3_val21="1"
level3_val22="0"
level3_val23="1"
level3_val24="0"
level3_val25="45"
level3_val26="45"
level3_val27="45"
level3_val28="0"
level3_val29="3"
level3_val30="3"
level3_val31="90"
level3_val32="1"
level3_val33="0"
level3_val34="1"
level3_val35="200000"
level3_val36="400000"
level3_val37="0"
level3_val38="0"
level3_val39="0:1036000 1:0 2:0 3:0"

# LEVEL 4
# lag percent: 74.9%
# battery life: 115.5%
level4_val1="0"
level4_val2="N"
level4_val3="0:651000 1:0 2:0 3:0"
level4_val4="0:2209000 1:0 2:0 3:0"
level4_val5="1"
level4_val6="interactive"
level4_val7="651000"
level4_val8="2209000"
level4_val9="1804000"
level4_val10="80"
level4_val11="18000"
level4_val12="18000"
level4_val13="198000"
level4_val14="44 1036000:95 1401000:86 1689000:56 1804000:99"
level4_val15="20000"
level4_val16="-1"
level4_val17="0"
level4_val18="0"
level4_val19="0"
level4_val20="0"
level4_val21="1"
level4_val22="0"
level4_val23="1"
level4_val24="0"
level4_val25="45"
level4_val26="45"
level4_val27="45"
level4_val28="0"
level4_val29="3"
level4_val30="3"
level4_val31="90"
level4_val32="1"
level4_val33="0"
level4_val34="1"
level4_val35="200000"
level4_val36="400000"
level4_val37="0"
level4_val38="100"
level4_val39="0:1036000 1:0 2:0 3:0"

# LEVEL 5
# lag percent: 98.9%
# battery life: 117.1%
level5_val1="0"
level5_val2="N"
level5_val3="0:651000 1:0 2:0 3:0"
level5_val4="0:2209000 1:0 2:0 3:0"
level5_val5="1"
level5_val6="interactive"
level5_val7="651000"
level5_val8="2209000"
level5_val9="1804000"
level5_val10="80"
level5_val11="38000"
level5_val12="38000"
level5_val13="198000"
level5_val14="60 1036000:86 1401000:97 1689000:76 1804000:99"
level5_val15="20000"
level5_val16="-1"
level5_val17="0"
level5_val18="0"
level5_val19="0"
level5_val20="0"
level5_val21="1"
level5_val22="0"
level5_val23="1"
level5_val24="0"
level5_val25="45"
level5_val26="45"
level5_val27="45"
level5_val28="0"
level5_val29="5"
level5_val30="3"
level5_val31="90"
level5_val32="1"
level5_val33="0"
level5_val34="1"
level5_val35="200000"
level5_val36="400000"
level5_val37="0"
level5_val38="100"
level5_val39="0:1036000 1:0 2:0 3:0"

# LEVEL 6
# lag percent: 118.7%
# battery life: 118.2%
level6_val1="0"
level6_val2="N"
level6_val3="0:651000 1:0 2:0 3:0"
level6_val4="0:2209000 1:0 2:0 3:0"
level6_val5="1"
level6_val6="interactive"
level6_val7="651000"
level6_val8="2209000"
level6_val9="1804000"
level6_val10="84"
level6_val11="18000"
level6_val12="18000"
level6_val13="198000"
level6_val14="48 1036000:80 1401000:84 1689000:56 1804000:99"
level6_val15="20000"
level6_val16="-1"
level6_val17="0"
level6_val18="0"
level6_val19="0"
level6_val20="0"
level6_val21="1"
level6_val22="0"
level6_val23="1"
level6_val24="0"
level6_val25="45"
level6_val26="45"
level6_val27="45"
level6_val28="0"
level6_val29="4"
level6_val30="3"
level6_val31="90"
level6_val32="1"
level6_val33="0"
level6_val34="1"
level6_val35="200000"
level6_val36="400000"
level6_val37="0"
level6_val38="0"
level6_val39="0:1036000 1:0 2:0 3:0"
else

# const variables
PARAM_NUM=39

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpufreq/interactive"
C1_GOVERNOR_DIR=""
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu4"

sysfs_obj1="/sys/module/msm_thermal/core_control/enabled"
sysfs_obj2="/sys/module/msm_thermal/parameters/enabled"
sysfs_obj3="/sys/module/msm_performance/parameters/cpu_min_freq"
sysfs_obj4="/sys/module/msm_performance/parameters/cpu_max_freq"
sysfs_obj5="${C0_DIR}/online"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj7="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj8="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj9="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj10="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj11="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj12="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj13="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj14="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj15="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj16="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj17="${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif"
sysfs_obj18="${C0_GOVERNOR_DIR}/boost"
sysfs_obj19="${C0_GOVERNOR_DIR}/fast_ramp_down"
sysfs_obj20="${C0_GOVERNOR_DIR}/align_windows"
sysfs_obj21="${C0_GOVERNOR_DIR}/use_migration_notif"
sysfs_obj22="${C0_GOVERNOR_DIR}/enable_prediction"
sysfs_obj23="${C0_GOVERNOR_DIR}/use_sched_load"
sysfs_obj24="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj25="${SCHED_DIR}/sched_downmigrate"
sysfs_obj26="${SCHED_DIR}/sched_upmigrate"
sysfs_obj27="${SCHED_DIR}/sched_downmigrate"
sysfs_obj28="${SCHED_DIR}/sched_freq_aggregate"
sysfs_obj29="${SCHED_DIR}/sched_ravg_hist_size"
sysfs_obj30="${SCHED_DIR}/sched_window_stats_policy"
sysfs_obj31="${SCHED_DIR}/sched_spill_load"
sysfs_obj32="${SCHED_DIR}/sched_restrict_cluster_spill"
sysfs_obj33="${SCHED_DIR}/sched_boost"
sysfs_obj34="${SCHED_DIR}/sched_prefer_sync_wakee_to_waker"
sysfs_obj35="${SCHED_DIR}/sched_freq_inc_notify"
sysfs_obj36="${SCHED_DIR}/sched_freq_dec_notify"
sysfs_obj37="/sys/module/msm_performance/parameters/touchboost"
sysfs_obj38="/sys/module/cpu_boost/parameters/input_boost_ms"
sysfs_obj39="/sys/module/cpu_boost/parameters/input_boost_freq"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 0.0%
# battery life: 94.8%
level0_val1="0"
level0_val2="N"
level0_val3="0:651000 1:0 2:0 3:0"
level0_val4="0:2017000 1:0 2:0 3:0"
level0_val5="1"
level0_val6="interactive"
level0_val7="651000"
level0_val8="2017000"
level0_val9="1804000"
level0_val10="90"
level0_val11="18000"
level0_val12="38000"
level0_val13="198000"
level0_val14="56 1036000:84 1401000:68 1689000:28 1804000:99"
level0_val15="20000"
level0_val16="-1"
level0_val17="0"
level0_val18="0"
level0_val19="0"
level0_val20="0"
level0_val21="1"
level0_val22="0"
level0_val23="1"
level0_val24="0"
level0_val25="45"
level0_val26="45"
level0_val27="45"
level0_val28="0"
level0_val29="4"
level0_val30="3"
level0_val31="90"
level0_val32="1"
level0_val33="0"
level0_val34="1"
level0_val35="200000"
level0_val36="400000"
level0_val37="0"
level0_val38="2400"
level0_val39="0:1689000 1:0 2:0 3:0"

# LEVEL 1
# lag percent: 15.0%
# battery life: 100.6%
level1_val1="0"
level1_val2="N"
level1_val3="0:651000 1:0 2:0 3:0"
level1_val4="0:2017000 1:0 2:0 3:0"
level1_val5="1"
level1_val6="interactive"
level1_val7="651000"
level1_val8="2017000"
level1_val9="1804000"
level1_val10="60"
level1_val11="18000"
level1_val12="18000"
level1_val13="198000"
level1_val14="52 1036000:92 1401000:52 1689000:36 1804000:99"
level1_val15="20000"
level1_val16="-1"
level1_val17="0"
level1_val18="0"
level1_val19="0"
level1_val20="0"
level1_val21="1"
level1_val22="0"
level1_val23="1"
level1_val24="0"
level1_val25="45"
level1_val26="45"
level1_val27="45"
level1_val28="0"
level1_val29="3"
level1_val30="3"
level1_val31="90"
level1_val32="1"
level1_val33="0"
level1_val34="1"
level1_val35="200000"
level1_val36="400000"
level1_val37="0"
level1_val38="400"
level1_val39="0:1036000 1:0 2:0 3:0"

# LEVEL 2
# lag percent: 30.0%
# battery life: 103.0%
level2_val1="0"
level2_val2="N"
level2_val3="0:651000 1:0 2:0 3:0"
level2_val4="0:2017000 1:0 2:0 3:0"
level2_val5="1"
level2_val6="interactive"
level2_val7="651000"
level2_val8="2017000"
level2_val9="1804000"
level2_val10="68"
level2_val11="18000"
level2_val12="18000"
level2_val13="198000"
level2_val14="40 1036000:96 1401000:76 1689000:48 1804000:99"
level2_val15="20000"
level2_val16="-1"
level2_val17="0"
level2_val18="0"
level2_val19="0"
level2_val20="0"
level2_val21="1"
level2_val22="0"
level2_val23="1"
level2_val24="0"
level2_val25="45"
level2_val26="45"
level2_val27="45"
level2_val28="0"
level2_val29="3"
level2_val30="3"
level2_val31="90"
level2_val32="1"
level2_val33="0"
level2_val34="1"
level2_val35="200000"
level2_val36="400000"
level2_val37="0"
level2_val38="0"
level2_val39="0:1036000 1:0 2:0 3:0"

# LEVEL 3
# lag percent: 49.1%
# battery life: 105.5%
level3_val1="0"
level3_val2="N"
level3_val3="0:651000 1:0 2:0 3:0"
level3_val4="0:2017000 1:0 2:0 3:0"
level3_val5="1"
level3_val6="interactive"
level3_val7="651000"
level3_val8="2017000"
level3_val9="1804000"
level3_val10="76"
level3_val11="18000"
level3_val12="18000"
level3_val13="198000"
level3_val14="52 1036000:80 1689000:24 1804000:99"
level3_val15="20000"
level3_val16="-1"
level3_val17="0"
level3_val18="0"
level3_val19="0"
level3_val20="0"
level3_val21="1"
level3_val22="0"
level3_val23="1"
level3_val24="0"
level3_val25="45"
level3_val26="45"
level3_val27="45"
level3_val28="0"
level3_val29="3"
level3_val30="3"
level3_val31="90"
level3_val32="1"
level3_val33="0"
level3_val34="1"
level3_val35="200000"
level3_val36="400000"
level3_val37="0"
level3_val38="0"
level3_val39="0:1036000 1:0 2:0 3:0"

# LEVEL 4
# lag percent: 75.0%
# battery life: 107.6%
level4_val1="0"
level4_val2="N"
level4_val3="0:651000 1:0 2:0 3:0"
level4_val4="0:2017000 1:0 2:0 3:0"
level4_val5="1"
level4_val6="interactive"
level4_val7="651000"
level4_val8="2017000"
level4_val9="1804000"
level4_val10="80"
level4_val11="18000"
level4_val12="18000"
level4_val13="198000"
level4_val14="44 1036000:86 1401000:88 1689000:56 1804000:99"
level4_val15="20000"
level4_val16="-1"
level4_val17="0"
level4_val18="0"
level4_val19="0"
level4_val20="0"
level4_val21="1"
level4_val22="0"
level4_val23="1"
level4_val24="0"
level4_val25="45"
level4_val26="45"
level4_val27="45"
level4_val28="0"
level4_val29="3"
level4_val30="3"
level4_val31="90"
level4_val32="1"
level4_val33="0"
level4_val34="1"
level4_val35="200000"
level4_val36="400000"
level4_val37="0"
level4_val38="0"
level4_val39="0:1036000 1:0 2:0 3:0"

# LEVEL 5
# lag percent: 97.7%
# battery life: 109.1%
level5_val1="0"
level5_val2="N"
level5_val3="0:651000 1:0 2:0 3:0"
level5_val4="0:2017000 1:0 2:0 3:0"
level5_val5="1"
level5_val6="interactive"
level5_val7="651000"
level5_val8="2017000"
level5_val9="1804000"
level5_val10="85"
level5_val11="18000"
level5_val12="18000"
level5_val13="198000"
level5_val14="56 1036000:98 1401000:85 1689000:48 1804000:99"
level5_val15="20000"
level5_val16="-1"
level5_val17="0"
level5_val18="0"
level5_val19="0"
level5_val20="0"
level5_val21="1"
level5_val22="0"
level5_val23="1"
level5_val24="0"
level5_val25="45"
level5_val26="45"
level5_val27="45"
level5_val28="0"
level5_val29="3"
level5_val30="3"
level5_val31="90"
level5_val32="1"
level5_val33="0"
level5_val34="1"
level5_val35="200000"
level5_val36="400000"
level5_val37="0"
level5_val38="0"
level5_val39="0:1689000 1:0 2:0 3:0"

# LEVEL 6
# lag percent: 120.0%
# battery life: 110.3%
level6_val1="0"
level6_val2="N"
level6_val3="0:651000 1:0 2:0 3:0"
level6_val4="0:2017000 1:0 2:0 3:0"
level6_val5="1"
level6_val6="interactive"
level6_val7="651000"
level6_val8="2017000"
level6_val9="1804000"
level6_val10="97"
level6_val11="18000"
level6_val12="18000"
level6_val13="198000"
level6_val14="68 1036000:88 1401000:80 1689000:64 1804000:99"
level6_val15="20000"
level6_val16="-1"
level6_val17="0"
level6_val18="0"
level6_val19="0"
level6_val20="0"
level6_val21="1"
level6_val22="0"
level6_val23="1"
level6_val24="0"
level6_val25="45"
level6_val26="45"
level6_val27="45"
level6_val28="0"
level6_val29="4"
level6_val30="3"
level6_val31="90"
level6_val32="1"
level6_val33="0"
level6_val34="1"
level6_val35="200000"
level6_val36="400000"
level6_val37="0"
level6_val38="100"
level6_val39="0:1036000 1:0 2:0 3:0"
fi
esac
case ${SOC} in universal8895* | exynos8895*)  #EXYNOS8895 (S8)

# const variables
PARAM_NUM=35

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel/hmp"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu4/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu4"

sysfs_obj1="/sys/power/cpuhotplug/enabled"
sysfs_obj2="/sys/devices/system/cpu/cpuhotplug/enabled"
sysfs_obj3="${C0_DIR}/online"
sysfs_obj4="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj5="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj7="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj8="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj9="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj10="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj11="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj12="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj13="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj14="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj15="${C0_GOVERNOR_DIR}/boost"
sysfs_obj16="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj17="${C1_DIR}/online"
sysfs_obj18="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj19="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj20="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj21="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj22="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj23="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj24="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj25="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj26="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj27="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj28="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj29="${C1_GOVERNOR_DIR}/boost"
sysfs_obj30="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj31="${SCHED_DIR}/down_threshold"
sysfs_obj32="${SCHED_DIR}/up_threshold"
sysfs_obj33="${SCHED_DIR}/down_threshold"
sysfs_obj34="${SCHED_DIR}/load_avg_period_ms"
sysfs_obj35="${SCHED_DIR}/boost"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 65.8%
# battery life: 115.8%
level0_val1="0"
level0_val2="0"
level0_val3="1"
level0_val4="interactive"
level0_val5="454000"
level0_val6="1691000"
level0_val7="1456000"
level0_val8="90"
level0_val9="18000"
level0_val10="38000"
level0_val11="98000"
level0_val12="56 598000:32 715000:74 832000:36 949000:37 1053000:15 1248000:32 1456000:46 1690000:54"
level0_val13="20000"
level0_val14="12345678"
level0_val15="0"
level0_val16="0"
level0_val17="1"
level0_val18="interactive"
level0_val19="740000"
level0_val20="2315000"
level0_val21="1937000"
level0_val22="98"
level0_val23="18000"
level0_val24="38000"
level0_val25="198000"
level0_val26="70 858000:35 962000:77 1066000:51 1170000:82 1261000:89 1469000:95 1703000:77 1807000:72 1937000:99 2002000:98 2158000:99"
level0_val27="20000"
level0_val28="12345678"
level0_val29="0"
level0_val30="0"
level0_val31="238"
level0_val32="983"
level0_val33="238"
level0_val34="128"
level0_val35="0"

# LEVEL 1
# lag percent: 14.9%
# battery life: 96.8%
level1_val1="0"
level1_val2="0"
level1_val3="1"
level1_val4="interactive"
level1_val5="454000"
level1_val6="1691000"
level1_val7="1456000"
level1_val8="98"
level1_val9="18000"
level1_val10="18000"
level1_val11="78000"
level1_val12="75 598000:56 715000:71 832000:68 949000:76 1053000:71 1248000:86 1456000:64 1690000:65"
level1_val13="20000"
level1_val14="12345678"
level1_val15="0"
level1_val16="0"
level1_val17="1"
level1_val18="interactive"
level1_val19="740000"
level1_val20="2315000"
level1_val21="1937000"
level1_val22="73"
level1_val23="18000"
level1_val24="18000"
level1_val25="198000"
level1_val26="67 858000:49 962000:42 1066000:63 1170000:88 1261000:86 1469000:71 1703000:89 1807000:63 1937000:98 2002000:99 2314000:95"
level1_val27="20000"
level1_val28="12345678"
level1_val29="0"
level1_val30="0"
level1_val31="162"
level1_val32="762"
level1_val33="162"
level1_val34="128"
level1_val35="0"

# LEVEL 2
# lag percent: 29.8%
# battery life: 104.1%
level2_val1="0"
level2_val2="0"
level2_val3="1"
level2_val4="interactive"
level2_val5="454000"
level2_val6="1691000"
level2_val7="1456000"
level2_val8="91"
level2_val9="18000"
level2_val10="18000"
level2_val11="118000"
level2_val12="56 598000:57 715000:24 832000:29 949000:57 1053000:60 1248000:41 1456000:48 1690000:73"
level2_val13="20000"
level2_val14="12345678"
level2_val15="0"
level2_val16="0"
level2_val17="1"
level2_val18="interactive"
level2_val19="740000"
level2_val20="2315000"
level2_val21="1937000"
level2_val22="98"
level2_val23="18000"
level2_val24="38000"
level2_val25="198000"
level2_val26="70 858000:77 962000:59 1066000:5 1170000:82 1261000:89 1469000:95 1703000:75 1807000:71 1937000:99 2002000:98 2158000:99 2314000:95"
level2_val27="20000"
level2_val28="12345678"
level2_val29="0"
level2_val30="0"
level2_val31="162"
level2_val32="798"
level2_val33="162"
level2_val34="128"
level2_val35="0"

# LEVEL 3
# lag percent: 50.0%
# battery life: 110.8%
level3_val1="0"
level3_val2="0"
level3_val3="1"
level3_val4="interactive"
level3_val5="454000"
level3_val6="1691000"
level3_val7="1456000"
level3_val8="95"
level3_val9="18000"
level3_val10="58000"
level3_val11="58000"
level3_val12="36 598000:13 715000:35 832000:44 949000:30 1053000:44 1248000:22 1456000:66 1690000:78"
level3_val13="20000"
level3_val14="12345678"
level3_val15="0"
level3_val16="0"
level3_val17="1"
level3_val18="interactive"
level3_val19="740000"
level3_val20="2315000"
level3_val21="1937000"
level3_val22="94"
level3_val23="18000"
level3_val24="38000"
level3_val25="198000"
level3_val26="70 858000:32 962000:69 1066000:55 1170000:82 1261000:90 1469000:96 1703000:78 1807000:69 1937000:99 2314000:98"
level3_val27="20000"
level3_val28="12345678"
level3_val29="0"
level3_val30="0"
level3_val31="223"
level3_val32="954"
level3_val33="223"
level3_val34="128"
level3_val35="0"

# LEVEL 4
# lag percent: 75.0%
# battery life: 118.7%
level4_val1="0"
level4_val2="0"
level4_val3="1"
level4_val4="interactive"
level4_val5="454000"
level4_val6="1691000"
level4_val7="1456000"
level4_val8="91"
level4_val9="18000"
level4_val10="58000"
level4_val11="98000"
level4_val12="52 598000:40 715000:39 832000:61 949000:7 1053000:43 1248000:18 1456000:49 1690000:29"
level4_val13="20000"
level4_val14="12345678"
level4_val15="0"
level4_val16="0"
level4_val17="1"
level4_val18="interactive"
level4_val19="740000"
level4_val20="2315000"
level4_val21="1937000"
level4_val22="98"
level4_val23="18000"
level4_val24="18000"
level4_val25="198000"
level4_val26="70 858000:40 962000:79 1066000:31 1170000:82 1261000:91 1469000:97 1703000:80 1807000:78 1937000:99 2314000:95"
level4_val27="20000"
level4_val28="12345678"
level4_val29="0"
level4_val30="0"
level4_val31="235"
level4_val32="996"
level4_val33="235"
level4_val34="128"
level4_val35="0"

# LEVEL 5
# lag percent: 99.0%
# battery life: 125.4%
level5_val1="0"
level5_val2="0"
level5_val3="1"
level5_val4="interactive"
level5_val5="454000"
level5_val6="1691000"
level5_val7="1456000"
level5_val8="87"
level5_val9="18000"
level5_val10="58000"
level5_val11="58000"
level5_val12="53 598000:19 715000:34 832000:45 949000:39 1053000:24 1248000:28 1456000:65"
level5_val13="20000"
level5_val14="12345678"
level5_val15="0"
level5_val16="0"
level5_val17="1"
level5_val18="interactive"
level5_val19="740000"
level5_val20="2315000"
level5_val21="1937000"
level5_val22="96"
level5_val23="18000"
level5_val24="18000"
level5_val25="198000"
level5_val26="67 858000:46 962000:29 1066000:9 1170000:82 1261000:90 1469000:95 1703000:82 1807000:68 1937000:99 2314000:97"
level5_val27="20000"
level5_val28="12345678"
level5_val29="0"
level5_val30="0"
level5_val31="537"
level5_val32="961"
level5_val33="537"
level5_val34="128"
level5_val35="1"

# LEVEL 6
# lag percent: 119.9%
# battery life: 130.3%
level6_val1="0"
level6_val2="0"
level6_val3="1"
level6_val4="interactive"
level6_val5="454000"
level6_val6="1691000"
level6_val7="1456000"
level6_val8="89"
level6_val9="18000"
level6_val10="138000"
level6_val11="158000"
level6_val12="40 598000:36 715000:48 832000:38 949000:44 1053000:38 1248000:21 1456000:64 1690000:82"
level6_val13="20000"
level6_val14="12345678"
level6_val15="0"
level6_val16="0"
level6_val17="1"
level6_val18="interactive"
level6_val19="740000"
level6_val20="2315000"
level6_val21="1937000"
level6_val22="99"
level6_val23="18000"
level6_val24="18000"
level6_val25="198000"
level6_val26="60 858000:42 962000:73 1066000:45 1170000:82 1261000:88 1469000:95 1703000:82 1807000:74 1937000:99 2002000:98 2158000:99 2314000:94"
level6_val27="20000"
level6_val28="12345678"
level6_val29="0"
level6_val30="0"
level6_val31="627"
level6_val32="968"
level6_val33="627"
level6_val34="128"
level6_val35="0"


esac
case ${SOC} in universal8890* | exynos8890*)  #EXYNOS8890 (S7)

# const variables
PARAM_NUM=35

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel/hmp"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu4/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu4"

sysfs_obj1="/sys/power/cpuhotplug/enabled"
sysfs_obj2="/sys/devices/system/cpu/cpuhotplug/enabled"
sysfs_obj3="${C0_DIR}/online"
sysfs_obj4="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj5="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj7="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj8="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj9="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj10="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj11="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj12="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj13="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj14="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj15="${C0_GOVERNOR_DIR}/boost"
sysfs_obj16="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj17="${C1_DIR}/online"
sysfs_obj18="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj19="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj20="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj21="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj22="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj23="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj24="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj25="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj26="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj27="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj28="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj29="${C1_GOVERNOR_DIR}/boost"
sysfs_obj30="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj31="${SCHED_DIR}/down_threshold"
sysfs_obj32="${SCHED_DIR}/up_threshold"
sysfs_obj33="${SCHED_DIR}/down_threshold"
sysfs_obj34="${SCHED_DIR}/load_avg_period_ms"
sysfs_obj35="${SCHED_DIR}/boost"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 20.2%
# battery life: 110.6%
level0_val1="0"
level0_val2="0"
level0_val3="1"
level0_val4="interactive"
level0_val5="441000"
level0_val6="1587000"
level0_val7="1482000"
level0_val8="73"
level0_val9="18000"
level0_val10="178000"
level0_val11="58000"
level0_val12="47 546000:59 754000:23 858000:50 962000:25 1066000:57 1170000:64 1274000:88 1378000:54 1482000:72 1586000:80"
level0_val13="20000"
level0_val14="12345678"
level0_val15="0"
level0_val16="0"
level0_val17="1"
level0_val18="interactive"
level0_val19="727000"
level0_val20="2601000"
level0_val21="1872000"
level0_val22="65"
level0_val23="18000"
level0_val24="98000"
level0_val25="198000 2080000:178000 2184000:118000 2288000:198000 2392000:118000 2496000:58000"
level0_val26="19 832000:6 936000:37 1040000:88 1144000:98 1248000:80 1352000:49 1456000:88 1560000:79 1664000:80 1768000:66 1872000:98 1976000:99 2080000:98 2392000:97 2496000:53 2600000:96"
level0_val27="20000"
level0_val28="12345678"
level0_val29="0"
level0_val30="0"
level0_val31="607"
level0_val32="621"
level0_val33="607"
level0_val34="128"
level0_val35="0"

# LEVEL 1
# lag percent: 14.7%
# battery life: 106.6%
level1_val1="0"
level1_val2="0"
level1_val3="1"
level1_val4="interactive"
level1_val5="441000"
level1_val6="1587000"
level1_val7="1378000"
level1_val8="92"
level1_val9="18000"
level1_val10="158000"
level1_val11="158000 1482000:118000"
level1_val12="64 546000:34 858000:31 962000:77 1066000:67 1170000:57 1274000:97 1378000:67 1482000:3 1586000:48"
level1_val13="20000"
level1_val14="12345678"
level1_val15="0"
level1_val16="0"
level1_val17="1"
level1_val18="interactive"
level1_val19="727000"
level1_val20="2601000"
level1_val21="1872000"
level1_val22="61"
level1_val23="18000"
level1_val24="18000"
level1_val25="198000 2080000:178000 2184000:138000 2288000:198000 2392000:118000 2496000:58000"
level1_val26="17 832000:22 936000:11 1040000:78 1144000:17 1248000:82 1352000:42 1456000:93 1560000:79 1664000:80 1768000:76 1872000:99 2080000:98 2184000:97 2288000:98 2392000:86 2496000:83 2600000:97"
level1_val27="20000"
level1_val28="12345678"
level1_val29="0"
level1_val30="0"
level1_val31="590"
level1_val32="590"
level1_val33="590"
level1_val34="128"
level1_val35="1"

# LEVEL 2
# lag percent: 29.8%
# battery life: 116.3%
level2_val1="0"
level2_val2="0"
level2_val3="1"
level2_val4="interactive"
level2_val5="441000"
level2_val6="1587000"
level2_val7="1482000"
level2_val8="69"
level2_val9="18000"
level2_val10="58000"
level2_val11="18000"
level2_val12="39 546000:57 754000:7 858000:29 962000:61 1066000:59 1170000:57 1274000:75 1378000:48 1482000:63 1586000:57"
level2_val13="20000"
level2_val14="12345678"
level2_val15="0"
level2_val16="0"
level2_val17="1"
level2_val18="interactive"
level2_val19="727000"
level2_val20="2601000"
level2_val21="1872000"
level2_val22="66"
level2_val23="18000"
level2_val24="98000"
level2_val25="198000 2184000:158000 2288000:118000 2392000:98000"
level2_val26="56 832000:64 936000:83 1040000:86 1144000:90 1248000:80 1352000:93 1456000:89 1560000:37 1664000:72 1768000:44 1872000:98 1976000:99 2080000:98 2184000:96 2288000:98 2392000:84 2496000:75 2600000:19"
level2_val27="20000"
level2_val28="12345678"
level2_val29="0"
level2_val30="0"
level2_val31="649"
level2_val32="668"
level2_val33="649"
level2_val34="128"
level2_val35="0"

# LEVEL 3
# lag percent: 50.0%
# battery life: 125.7%
level3_val1="0"
level3_val2="0"
level3_val3="1"
level3_val4="interactive"
level3_val5="441000"
level3_val6="1587000"
level3_val7="1482000"
level3_val8="65"
level3_val9="18000"
level3_val10="98000"
level3_val11="18000"
level3_val12="45 546000:23 754000:14 858000:10 962000:79 1066000:27 1170000:33 1274000:31 1378000:53 1482000:71 1586000:80"
level3_val13="20000"
level3_val14="12345678"
level3_val15="0"
level3_val16="0"
level3_val17="1"
level3_val18="interactive"
level3_val19="727000"
level3_val20="2601000"
level3_val21="1872000"
level3_val22="65"
level3_val23="18000"
level3_val24="118000"
level3_val25="198000 2184000:178000 2392000:18000"
level3_val26="57 832000:81 936000:17 1040000:85 1144000:97 1248000:72 1352000:94 1456000:89 1560000:60 1664000:57 1768000:82 1872000:98 1976000:99 2184000:96 2392000:70 2496000:61 2600000:91"
level3_val27="20000"
level3_val28="12345678"
level3_val29="0"
level3_val30="0"
level3_val31="712"
level3_val32="736"
level3_val33="712"
level3_val34="128"
level3_val35="0"

# LEVEL 4
# lag percent: 74.7%
# battery life: 134.0%
level4_val1="0"
level4_val2="0"
level4_val3="1"
level4_val4="interactive"
level4_val5="441000"
level4_val6="1587000"
level4_val7="1482000"
level4_val8="73"
level4_val9="38000"
level4_val10="18000"
level4_val11="18000"
level4_val12="41 546000:43 754000:7 858000:6 962000:20 1066000:22 1170000:26 1274000:65 1378000:61 1482000:66 1586000:98"
level4_val13="20000"
level4_val14="12345678"
level4_val15="0"
level4_val16="0"
level4_val17="1"
level4_val18="interactive"
level4_val19="727000"
level4_val20="2601000"
level4_val21="1872000"
level4_val22="65"
level4_val23="18000"
level4_val24="138000"
level4_val25="198000 2184000:178000 2288000:58000 2392000:178000 2496000:138000"
level4_val26="64 832000:53 936000:27 1040000:71 1144000:98 1248000:90 1352000:93 1456000:87 1560000:83 1664000:75 1768000:61 1872000:98 1976000:99 2288000:98 2392000:89 2496000:20 2600000:50"
level4_val27="20000"
level4_val28="12345678"
level4_val29="0"
level4_val30="0"
level4_val31="773"
level4_val32="780"
level4_val33="773"
level4_val34="128"
level4_val35="0"

# LEVEL 5
# lag percent: 99.0%
# battery life: 143.6%
level5_val1="0"
level5_val2="0"
level5_val3="1"
level5_val4="interactive"
level5_val5="441000"
level5_val6="1587000"
level5_val7="1482000"
level5_val8="86"
level5_val9="18000"
level5_val10="38000"
level5_val11="38000"
level5_val12="44 546000:27 754000:36 858000:38 962000:8 1066000:3 1170000:16 1274000:92 1378000:53 1482000:70 1586000:65"
level5_val13="20000"
level5_val14="12345678"
level5_val15="0"
level5_val16="0"
level5_val17="1"
level5_val18="interactive"
level5_val19="727000"
level5_val20="2601000"
level5_val21="1872000"
level5_val22="77"
level5_val23="18000"
level5_val24="58000"
level5_val25="198000 2184000:138000 2288000:58000 2392000:78000"
level5_val26="61 832000:92 936000:83 1040000:95 1144000:91 1248000:81 1352000:96 1456000:87 1560000:77 1664000:80 1768000:58 1872000:99 2288000:97 2392000:40 2496000:42 2600000:72"
level5_val27="20000"
level5_val28="12345678"
level5_val29="0"
level5_val30="0"
level5_val31="643"
level5_val32="927"
level5_val33="643"
level5_val34="128"
level5_val35="0"

# LEVEL 6
# lag percent: 119.7%
# battery life: 150.7%
level6_val1="0"
level6_val2="0"
level6_val3="1"
level6_val4="interactive"
level6_val5="441000"
level6_val6="1587000"
level6_val7="1482000"
level6_val8="82"
level6_val9="18000"
level6_val10="138000"
level6_val11="158000"
level6_val12="30 546000:33 754000:38 962000:16 1066000:26 1170000:12 1274000:95 1378000:66 1482000:83 1586000:63"
level6_val13="20000"
level6_val14="12345678"
level6_val15="0"
level6_val16="0"
level6_val17="1"
level6_val18="interactive"
level6_val19="727000"
level6_val20="2601000"
level6_val21="1872000"
level6_val22="79"
level6_val23="18000"
level6_val24="38000"
level6_val25="198000 2288000:78000 2392000:178000 2496000:78000"
level6_val26="59 832000:93 936000:83 1040000:97 1144000:91 1248000:90 1352000:97 1456000:92 1560000:83 1664000:79 1768000:65 1872000:98 1976000:99 2184000:98 2288000:96 2392000:54 2496000:46 2600000:71"
level6_val27="20000"
level6_val28="12345678"
level6_val29="0"
level6_val30="0"
level6_val31="644"
level6_val32="960"
level6_val33="644"
level6_val34="128"
level6_val35="0"



esac
case ${SOC} in universal7420* | exynos7420*) #EXYNOS7420 (S6)

# const variables
PARAM_NUM=35

# sysfs_objx example:
# sysfs_obj1="${C0_GOVERNOR_DIR}/target_loads"
SCHED_DIR="/proc/sys/kernel/hmp"
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu4/cpufreq/interactive"
C0_DIR="/sys/devices/system/cpu/cpu0"
C1_DIR="/sys/devices/system/cpu/cpu4"

sysfs_obj1="/sys/power/cpuhotplug/enabled"
sysfs_obj2="/sys/devices/system/cpu/cpuhotplug/enabled"
sysfs_obj3="${C0_DIR}/online"
sysfs_obj4="${C0_DIR}/cpufreq/scaling_governor"
sysfs_obj5="${C0_DIR}/cpufreq/scaling_min_freq"
sysfs_obj6="${C0_DIR}/cpufreq/scaling_max_freq"
sysfs_obj7="${C0_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj8="${C0_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj9="${C0_GOVERNOR_DIR}/min_sample_time"
sysfs_obj10="${C0_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj11="${C0_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj12="${C0_GOVERNOR_DIR}/target_loads"
sysfs_obj13="${C0_GOVERNOR_DIR}/timer_rate"
sysfs_obj14="${C0_GOVERNOR_DIR}/timer_slack"
sysfs_obj15="${C0_GOVERNOR_DIR}/boost"
sysfs_obj16="${C0_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj17="${C1_DIR}/online"
sysfs_obj18="${C1_DIR}/cpufreq/scaling_governor"
sysfs_obj19="${C1_DIR}/cpufreq/scaling_min_freq"
sysfs_obj20="${C1_DIR}/cpufreq/scaling_max_freq"
sysfs_obj21="${C1_GOVERNOR_DIR}/hispeed_freq"
sysfs_obj22="${C1_GOVERNOR_DIR}/go_hispeed_load"
sysfs_obj23="${C1_GOVERNOR_DIR}/min_sample_time"
sysfs_obj24="${C1_GOVERNOR_DIR}/max_freq_hysteresis"
sysfs_obj25="${C1_GOVERNOR_DIR}/above_hispeed_delay"
sysfs_obj26="${C1_GOVERNOR_DIR}/target_loads"
sysfs_obj27="${C1_GOVERNOR_DIR}/timer_rate"
sysfs_obj28="${C1_GOVERNOR_DIR}/timer_slack"
sysfs_obj29="${C1_GOVERNOR_DIR}/boost"
sysfs_obj30="${C1_GOVERNOR_DIR}/boostpulse_duration"
sysfs_obj31="${SCHED_DIR}/down_threshold"
sysfs_obj32="${SCHED_DIR}/up_threshold"
sysfs_obj33="${SCHED_DIR}/down_threshold"
sysfs_obj34="${SCHED_DIR}/load_avg_period_ms"
sysfs_obj35="${SCHED_DIR}/boost"


# level x example:
# lag percent: 90.0%
# battery life: 110.0%
# levelx_val1="38000"
# levelx_val2="85 1190000:90"

# LEVEL 0
# lag percent: 12.5%
# battery life: 105.4%
level0_val1="0"
level0_val2="0"
level0_val3="1"
level0_val4="interactive"
level0_val5="399000"
level0_val6="1501000"
level0_val7="900000"
level0_val8="76"
level0_val9="18000"
level0_val10="158000"
level0_val11="158000 1000000:138000 1100000:58000 1200000:78000 1300000:178000 1400000:118000"
level0_val12="80 600000:65 700000:50 800000:37 900000:81 1000000:65 1100000:78 1200000:74 1300000:25 1400000:72 1500000:94"
level0_val13="20000"
level0_val14="12345678"
level0_val15="0"
level0_val16="0"
level0_val17="1"
level0_val18="interactive"
level0_val19="799000"
level0_val20="2101000"
level0_val21="1700000"
level0_val22="75"
level0_val23="18000"
level0_val24="18000"
level0_val25="198000"
level0_val26="13 900000:16 1000000:50 1100000:82 1200000:78 1300000:81 1400000:74 1500000:63 1600000:61 1700000:99"
level0_val27="20000"
level0_val28="12345678"
level0_val29="0"
level0_val30="0"
level0_val31="555"
level0_val32="555"
level0_val33="555"
level0_val34="128"
level0_val35="0"

# LEVEL 1
# lag percent: 15.0%
# battery life: 107.1%
level1_val1="0"
level1_val2="0"
level1_val3="1"
level1_val4="interactive"
level1_val5="399000"
level1_val6="1501000"
level1_val7="900000"
level1_val8="76"
level1_val9="18000"
level1_val10="58000"
level1_val11="58000 1000000:138000 1100000:78000 1200000:198000 1300000:38000 1400000:98000"
level1_val12="84 500000:76 600000:39 700000:53 800000:60 900000:18 1000000:79 1100000:86 1200000:68 1300000:60 1400000:58 1500000:80"
level1_val13="20000"
level1_val14="12345678"
level1_val15="0"
level1_val16="0"
level1_val17="1"
level1_val18="interactive"
level1_val19="799000"
level1_val20="2101000"
level1_val21="1700000"
level1_val22="82"
level1_val23="18000"
level1_val24="18000"
level1_val25="198000"
level1_val26="17 900000:16 1000000:90 1100000:81 1200000:66 1300000:65 1400000:79 1500000:83 1600000:61 1700000:99"
level1_val27="20000"
level1_val28="12345678"
level1_val29="0"
level1_val30="0"
level1_val31="561"
level1_val32="561"
level1_val33="561"
level1_val34="128"
level1_val35="1"

# LEVEL 2
# lag percent: 30.0%
# battery life: 112.2%
level2_val1="0"
level2_val2="0"
level2_val3="1"
level2_val4="interactive"
level2_val5="399000"
level2_val6="1501000"
level2_val7="900000"
level2_val8="67"
level2_val9="18000"
level2_val10="78000"
level2_val11="58000 1000000:138000 1100000:78000 1200000:198000 1300000:58000 1400000:78000"
level2_val12="52 500000:78 600000:61 700000:47 800000:73 900000:44 1000000:95 1100000:72 1200000:82 1300000:43 1400000:88 1500000:91"
level2_val13="20000"
level2_val14="12345678"
level2_val15="0"
level2_val16="0"
level2_val17="1"
level2_val18="interactive"
level2_val19="799000"
level2_val20="2101000"
level2_val21="1700000"
level2_val22="99"
level2_val23="18000"
level2_val24="38000"
level2_val25="198000"
level2_val26="15 900000:8 1000000:90 1100000:80 1200000:71 1300000:82 1400000:80 1500000:90 1600000:61 1700000:99"
level2_val27="20000"
level2_val28="12345678"
level2_val29="0"
level2_val30="0"
level2_val31="620"
level2_val32="620"
level2_val33="620"
level2_val34="128"
level2_val35="0"

# LEVEL 3
# lag percent: 49.5%
# battery life: 117.3%
level3_val1="0"
level3_val2="0"
level3_val3="1"
level3_val4="interactive"
level3_val5="399000"
level3_val6="1501000"
level3_val7="1100000"
level3_val8="73"
level3_val9="18000"
level3_val10="78000"
level3_val11="198000 1200000:138000 1300000:178000 1400000:138000"
level3_val12="57 500000:86 600000:37 700000:57 800000:50 900000:72 1000000:66 1100000:57 1200000:63 1300000:61 1400000:85 1500000:95"
level3_val13="20000"
level3_val14="12345678"
level3_val15="0"
level3_val16="0"
level3_val17="1"
level3_val18="interactive"
level3_val19="799000"
level3_val20="2101000"
level3_val21="1700000"
level3_val22="99"
level3_val23="18000"
level3_val24="38000"
level3_val25="198000"
level3_val26="69 900000:24 1000000:90 1100000:80 1200000:70 1300000:82 1400000:80 1500000:92 1600000:61 1700000:99"
level3_val27="20000"
level3_val28="12345678"
level3_val29="0"
level3_val30="0"
level3_val31="600"
level3_val32="807"
level3_val33="600"
level3_val34="128"
level3_val35="1"

# LEVEL 4
# lag percent: 74.7%
# battery life: 123.9%
level4_val1="0"
level4_val2="0"
level4_val3="1"
level4_val4="interactive"
level4_val5="399000"
level4_val6="1501000"
level4_val7="1100000"
level4_val8="76"
level4_val9="18000"
level4_val10="58000"
level4_val11="198000 1200000:78000 1300000:178000 1400000:78000"
level4_val12="82 500000:26 600000:43 800000:63 900000:71 1000000:76 1100000:58 1200000:67 1300000:91 1400000:89 1500000:88"
level4_val13="20000"
level4_val14="12345678"
level4_val15="0"
level4_val16="0"
level4_val17="1"
level4_val18="interactive"
level4_val19="799000"
level4_val20="2101000"
level4_val21="1700000"
level4_val22="99"
level4_val23="18000"
level4_val24="18000"
level4_val25="198000"
level4_val26="57 900000:23 1000000:90 1100000:81 1200000:71 1300000:82 1400000:80 1500000:92 1600000:60 1700000:99"
level4_val27="20000"
level4_val28="12345678"
level4_val29="0"
level4_val30="0"
level4_val31="603"
level4_val32="901"
level4_val33="603"
level4_val34="128"
level4_val35="1"

# LEVEL 5
# lag percent: 98.8%
# battery life: 130.0%
level5_val1="0"
level5_val2="0"
level5_val3="1"
level5_val4="interactive"
level5_val5="399000"
level5_val6="1501000"
level5_val7="1000000"
level5_val8="73"
level5_val9="18000"
level5_val10="118000"
level5_val11="198000 1300000:78000 1400000:98000"
level5_val12="75 500000:64 600000:36 700000:33 800000:63 900000:77 1000000:55 1100000:97 1200000:59 1300000:87 1400000:43 1500000:98"
level5_val13="20000"
level5_val14="12345678"
level5_val15="0"
level5_val16="0"
level5_val17="1"
level5_val18="interactive"
level5_val19="799000"
level5_val20="2101000"
level5_val21="1700000"
level5_val22="99"
level5_val23="18000"
level5_val24="18000"
level5_val25="198000"
level5_val26="34 900000:19 1000000:90 1100000:80 1200000:73 1300000:82 1400000:79 1500000:92 1600000:61 1700000:99"
level5_val27="20000"
level5_val28="12345678"
level5_val29="0"
level5_val30="0"
level5_val31="660"
level5_val32="934"
level5_val33="660"
level5_val34="128"
level5_val35="1"

# LEVEL 6
# lag percent: 119.3%
# battery life: 134.9%
level6_val1="0"
level6_val2="0"
level6_val3="1"
level6_val4="interactive"
level6_val5="399000"
level6_val6="1501000"
level6_val7="1000000"
level6_val8="78"
level6_val9="18000"
level6_val10="138000"
level6_val11="198000 1200000:178000 1300000:138000 1400000:118000"
level6_val12="94 500000:85 600000:22 700000:33 800000:75 900000:70 1000000:56 1100000:95 1200000:98 1300000:58 1400000:46 1500000:93"
level6_val13="20000"
level6_val14="12345678"
level6_val15="0"
level6_val16="0"
level6_val17="1"
level6_val18="interactive"
level6_val19="799000"
level6_val20="2101000"
level6_val21="1700000"
level6_val22="99"
level6_val23="18000"
level6_val24="38000"
level6_val25="198000"
level6_val26="18 900000:24 1000000:91 1100000:79 1200000:96 1300000:82 1400000:88 1500000:95 1600000:62 1700000:98 1800000:99"
level6_val27="20000"
level6_val28="12345678"
level6_val29="0"
level6_val30="0"
level6_val31="664"
level6_val32="954"
level6_val33="664"
level6_val34="128"
level6_val35="1"

esac
case ${SOC} in kirin970* | hi3670*)  # Huawei Kirin 970


esac
case ${SOC} in kirin960* | hi3660*)  # Huawei Kirin 960


esac
case ${SOC} in kirin950* | hi3650* | kirin955* | hi3655*) # Huawei Kirin 950


esac
case ${SOC} in mt6797*) #Helio X25 / X20

	
esac
case ${SOC} in mt6795*) #Helio X10

esac
case ${SOC} in moorefield*) # Intel Atom

	
esac
case ${SOC} in msm8939* | msm8952*)  #sd615/616/617 by@ 橘猫520

esac

case ${SOC} in kirin650* | kirin655* | kirin658* | kirin659* | hi625*)  #KIRIN650 by @橘猫520

	
esac
case ${SOC} in apq8026* | apq8028* | apq8030* | msm8226* | msm8228* | msm8230* | msm8626* | msm8628* | msm8630* | msm8926* | msm8928* | msm8930*)  

esac
case ${SOC} in apq8016* | msm8916* | msm8216* | msm8917* | msm8217*)  #sd410/sd425 series by @cjybyjk

esac
case ${SOC} in msm8937*)  #sd430 series by @cjybyjk

esac
case ${SOC} in msm8940*)  #sd435 series by @cjybyjk

esac
case ${SOC} in sdm450*)  #sd450 series by @cjybyjk

esac
case ${SOC} in mt6755*)  #mtk6755 series by @cjybyjk


esac


apply_level() 
{
	# 0. SELinux permissive
	# setenforce 0
    # 1. backup
    backup_default
    # 2. apply modification
	n=0
	while [ ${n} -le ${PARAM_NUM} ]
	do
 
        eval obj="$"sysfs_obj${n}
        eval val="$"level${1}_val${n}
        lock_value "${val}" ${obj}
	n=$(( ${n} + 1 ))
    done
    # 3. save current level to file
    echo ${1} > ${CUR_LEVEL_FILE}
}

backup_default()
{
    if [ ${HAS_BAK} -eq 0 ]; then
        # clear previous backup file
        echo "" > ${PARAM_BAK_FILE}
        for n in `seq ${PARAM_NUM}`
        do
            eval obj="$"sysfs_obj${n}
            echo "bak_obj${n}=${obj}" >> ${PARAM_BAK_FILE}
            echo "bak_val${n}=\"`cat ${obj}`\"" >> ${PARAM_BAK_FILE}
        done
        echo "Backup default parameters has completed."
    else
        echo "Backup file already exists, skip backup."
    fi
}

restore_default()
{
    if [ -f ${PARAM_BAK_FILE} ]; then
        # read backup variables
        while read line
        do
            eval ${line}
        done < ${PARAM_BAK_FILE}
        # set backup variables
        for n in `seq ${PARAM_NUM}`
        do
            eval obj="$"bak_obj${n}
            eval val="$"bak_val${n}
            lock_value "${val}" ${obj}
        done
        echo "Restore OK"
    else
        echo "Backup file for default parameters not found."
        echo "Restore FAIL"
    fi
}


if [ ${PROFILE} -eq 0 ]; then
    echo "Applying powersave..."
    apply_level 6
    echo "Applying powersave done."
fi

if [ ${PROFILE} -eq 1 ]; then
    echo "Applying balance..."
    apply_level 3
    echo "Applying balance done."
fi

if [ ${PROFILE} -eq 2 ]; then
    echo "Applying performance..."
    apply_level 1
    echo "Applying performance done."
fi

if [ ${PROFILE} -eq 3 ]; then
    echo "Applying turbo..."
    apply_level 0
    echo "Applying turbo done."
fi

	after_modify
fi

    # Enable thermal & BCL core_control now
	if [ -f "/sys/module/msm_thermal/core_control/enabled" ]; then
    write /sys/module/msm_thermal/core_control/enabled "1"
    # Choose Hotplug, all others must be set to 0
    write /sys/kernel/intelli_plug/intelli_plug_active "0"
    write /sys/module/blu_plug/parameters/enabled "0"
    write /sys/devices/virtual/misc/mako_hotplug_control/enabled "0"
    write /sys/module/autosmp/parameters/enabled "0"
    write /sys/kernel/zen_decision/enabled "0"
	elif [ -f "/sys/module/msm_thermal/parameters/enabled" ]; then
    write /sys/module/msm_thermal/parameters/enabled "Y"
	elif [ -f "/sys/power/cpuhotplug/enabled" ]; then
	lock_value 1 /sys/power/cpuhotplug/enabled
	elif [ -f "/sys/devices/system/cpu/cpuhotplug/enabled" ]; then
	lock_value 1 /sys/devices/system/cpu/cpuhotplug/enabled
	fi
	
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        echo $bcl_hotplug_mask > $hotplug_mask
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done
	
    # Enable all low power modes
    # write /sys/module/lpm_levels/parameters/sleep_disabled "N" 2>/dev/null  # pass not causing lag

}

# =========
# CPU Governor Tuning
# =========
stop "thermald"
stop "thermal-engine"
stop "thermal-hal-1-0"
stop "mpdecision"
if [ $support -eq 1 ];then
    LOGDATA "#  [✓] SOC CHECK SUCCEEDED"
    cputuning
elif [ $support -eq 2 ];then
    LOGDATA "#  [✓] SOC CHECK SUCCEEDED"
    LOGDATA "#  [INFO] THIS DEVICE IS PARTIALLY SUPPORTED BY LKT"
    cputuning
else
    LOGDATA "#  [×] SOC CHECK FAILED"
    LOGDATA "#  [INFO] THIS DEVICE DOES NOT SUPPORT THE CURRENT LKT VERSION"
fi
start "thermald"
start "thermal-engine"
start "thermal-hal-1-0"
start "mpdecision"
# Disable KSM to save CPU cycles
if [ -e '/sys/kernel/mm/uksm/run' ]; then
LOGDATA "#  [INFO] DISABLING uKSM"
write '/sys/kernel/mm/uksm/run' 0;
setprop ro.config.uksm.support false;
elif [ -e '/sys/kernel/mm/ksm/run' ]; then
LOGDATA "#  [INFO] DISABLING KSM"
write '/sys/kernel/mm/ksm/run' 0;
setprop ro.config.ksm.support false;
fi;
if [ -e '/sys/kernel/fp_boost/enabled' ]; then
write '/sys/kernel/fp_boost/enabled' 1;
LOGDATA "#  [INFO] ENABLING FINGER PRINT BOOST"
fi;
# =========
# GPU Tweaks
# =========
if [ -e "/sys/module/adreno_idler" ]; then

	if [ ${PROFILE} -eq 0 ];then
	LOGDATA "#  [INFO] ENABLING GPU ADRENO IDLER " 
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "10000"
	write /sys/module/adreno_idler/parameters/adreno_idler_downdifferential '40'
	write /sys/module/adreno_idler/parameters/adreno_idler_idlewait '24'
	else
	LOGDATA "#  [INFO] ENABLING GPU ADRENO IDLER " 
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "6000"
	write /sys/module/adreno_idler/parameters/adreno_idler_downdifferential '15'
	write /sys/module/adreno_idler/parameters/adreno_idler_idlewait '15'
	fi
	
fi
# Various GPU enhancements
if [ ${GPU_MAX} -eq 0 ] || [ -z ${GPU_MODEL} ] ;then
GPU_PWR=$(cat $GPU_DIR/num_pwrlevels) 2>/dev/null
GPU_PWR=$(($GPU_PWR-1))
GPU_BATT=$(awk -v x=$GPU_PWR 'BEGIN{print((x/2)-0.5)}')
GPU_BATT=$(round ${GPU_BATT} 0)
GPU_TURBO=$(awk -v x=$GPU_PWR 'BEGIN{print((x/2)+0.5)}')
GPU_TURBO=$(round ${GPU_TURBO} 0)
gpu_idle=$(cat /data/adb/idle_timer.txt) 2>/dev/null
idle_batt=$(awk -v x=$gpu_idle 'BEGIN{print x*2}')
idle_balc=$(awk -v x=$gpu_idle 'BEGIN{print (x*3)/4}')
idle_perf=$(awk -v x=$gpu_idle 'BEGIN{print x/2}')
gpu_nap=$(cat /data/adb/deep_nap_timer.txt) 2>/dev/null
nap_batt=$(awk -v x=$gpu_nap 'BEGIN{print x*2}')
nap_balc=$(awk -v x=$gpu_nap 'BEGIN{print (x*3)/4}')
nap_perf=$(awk -v x=$gpu_nap 'BEGIN{print x/2}')
idle_batt=$(round ${idle_batt} 0)
idle_balc=$(round ${idle_balc} 0)
idle_perf=$(round ${idle_perf} 0)
nap_batt=$(round ${nap_batt} 0)
nap_balc=$(round ${nap_balc} 0)
nap_perf=$(round ${nap_perf} 0)
#if [[ "$GPU_GOV" == *"simple_ondemand"* ]]; then
#write "$GPU_DIR/devfreq/governor" "simple_ondemand"
#fi
lock_value $GPU_MAX "$GPU_DIR/max_gpuclk"
lock_value $GPU_MAX "$GPU_DIR/devfreq/max_freq" 
lock_value $GPU_MIN "$GPU_DIR/devfreq/min_freq" 
lock_value $GPU_MIN "$GPU_DIR/devfreq/target_freq" 

lock_value 0 "$GPU_DIR/throttling"
lock_value 0 "$GPU_DIR/force_no_nap"
lock_value 1 "$GPU_DIR/bus_split"
lock_value 0 "$GPU_DIR/force_bus_on"
lock_value 0 "$GPU_DIR/force_clk_on"
lock_value 0 "$GPU_DIR/force_rail_on"
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" 1
write "/proc/mali/dvfs_enable" 1

	if [ ${PROFILE} -eq 0 ];then
lock_value $GPU_BATT "$GPU_DIR/max_pwrlevel"
lock_value $GPU_PWR "$GPU_DIR/min_pwrlevel"
lock_value 0 "$GPU_DIR/force_no_nap"
#lock_value $nap_batt "$GPU_DIR/deep_nap_timer"
#lock_value $idle_batt "$GPU_DIR/idle_timer"
#chmod 0644 "/sys/devices/14ac0000.mali/dvfs"
#chmod 0644 "/sys/devices/14ac0000.mali/dvfs_max_lock"
#chmod 0644 "/sys/devices/14ac0000.mali/dvfs_min_lock"
	elif [ ${PROFILE} -eq 1 ];then
lock_value 0 "$GPU_DIR/max_pwrlevel"
lock_value $GPU_PWR "$GPU_DIR/min_pwrlevel"
lock_value 0 "$GPU_DIR/force_no_nap"
#lock_value $idle_balc "$GPU_DIR/deep_nap_timer"
#lock_value $nap_balc "$GPU_DIR/idle_timer"
	elif [ ${PROFILE} -eq 2 ];then
lock_value 0 "$GPU_DIR/max_pwrlevel"
lock_value$GPU_PWR "$GPU_DIR/min_pwrlevel"
lock_value 1 "$GPU_DIR/force_no_nap"
#lock_value $nap_perf "$GPU_DIR/deep_nap_timer"
#lock_value $idle_perf "$GPU_DIR/idle_timer" 
	elif [ ${PROFILE} -eq 3 ];then
lock_value 0 "$GPU_DIR/max_pwrlevel"
lock_value $GPU_TURBO "$GPU_DIR/min_pwrlevel"
lock_value 1 "$GPU_DIR/force_no_nap"
lock_value 0 "$GPU_DIR/bus_split"
lock_value 1 "$GPU_DIR/force_bus_on"
lock_value 1 "$GPU_DIR/force_clk_on"
lock_value 1 "$GPU_DIR/force_rail_on"
#lock_value $nap_perf "$GPU_DIR/deep_nap_timer"
#lock_value $idle_perf  "$GPU_DIR/idle_timer" 
	fi
	
for i in ${GPU_DIR}/devfreq/*
do
chmod 0644 $i
done
for i in ${GPU_DIR}/*
do
chmod 0644 $i
done
fi
# =========
# RAM TWEAKS
# =========
ramtuning
# =========
# I/O TWEAKS
# =========
LOGDATA "#  [INFO] CONFIGURING STORAGE I/O SCHEDULER " 
if [ -d /sys/block/dm-0 ] || [ -d /sys/devices/virtual/block/dm-0 ]; then
if [ -e /sys/devices/virtual/block/dm-0/queue/scheduler ]; then
    DM_PATH=/sys/devices/virtual/block/dm-0/queue
fi
if [ -e /sys/block/dm-0/queue/scheduler ]; then
    DM_PATH=/sys/block/dm-0/queue
fi
sch=$(</sys/devices/virtual/block/dm-0/queue/scheduler);
if [[ $sch == *"maple"* ]]; then
   if [ -e $DM_PATH/scheduler_hard ]; then
   write $DM_PATH/scheduler_hard "maple"
   fi
   write $DM_PATH/scheduler "maple"
   sleep 2
   write $DM_PATH/iosched/async_read_expire 666;
   write $DM_PATH/iosched/async_write_expire 1666;
   write $DM_PATH/iosched/fifo_batch 16;
   write $DM_PATH/iosched/sleep_latency_multiple 5;
   write $DM_PATH/iosched/sync_read_expire 333;
   write $DM_PATH/iosched/sync_write_expire 1166;
   write $DM_PATH/iosched/writes_starved 3;
   write $DM_PATH/iosched/read_ahead_kb 128;
if [ -e "/sys/devices/virtual/block/dm-0/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 2048
   else
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 128
   fi
fi

if [ -e "/sys/block/sda/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/block/sda/bdi/read_ahead_kb 2048
   else
   write /sys/block/sda/bdi/read_ahead_kb 128
   fi
fi
else
if [[ $sch == *"cfq"* ]]; then
   if [ -e $DM_PATH/scheduler_hard ]; then
   write $DM_PATH/scheduler_hard "cfq"
   fi
   write $DM_PATH/scheduler "cfq"
   write $DM_PATH/iosched/low_latency 0;
   write $DM_PATH/iosched/slice_idle 0;
   write $DM_PATH/iosched/group_idle 8;
   
if [ -e "/sys/devices/virtual/block/dm-0/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 512
   else
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 128
   fi
fi

if [ -e "/sys/block/sda/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/block/sda/bdi/read_ahead_kb 512
   else
   write /sys/block/sda/bdi/read_ahead_kb 128
   fi
fi
fi
fi
	write $DM_PATH/add_random 0
	write $DM_PATH/iostats 0
   	write $DM_PATH/nomerges 2
   	write $DM_PATH/rotational 0
   	write $DM_PATH/rq_affinity 1
fi
sch=$(</sys/block/sda/queue/scheduler);
if [[ $sch == *"maple"* ]]; then
	for i in /sys/block/*; do
	    set_io maple $i;
	done;
	set_io maple /sys/block/mmcblk0
	set_io maple /sys/block/sda
	else
	if [[ $sch == *"cfq"* ]]; then
	for i in /sys/block/*; do
	    set_io cfq $i;
	done;
	set_io cfq /sys/block/mmcblk0
	set_io cfq /sys/block/sda
	fi
fi
for i in /sys/block/*; do
	write $i/queue/add_random 0
	write $i/queue/iostats 0
   	write $i/queue/nomerges 2
   	write $i/queue/rotational 0
   	write $i/queue/rq_affinity 1
done;

# =========
# REDUCE DEBUGGING
# =========
LOGDATA "#  [INFO] CUTTING EXCESSIVE KERNEL DEBUGGING " 
#write "/sys/module/wakelock/parameters/debug_mask" 0
#write "/sys/module/userwakelock/parameters/debug_mask" 0
write "/sys/module/earlysuspend/parameters/debug_mask" 0
write "/sys/module/alarm/parameters/debug_mask" 0
write "/sys/module/alarm_dev/parameters/debug_mask" 0
write "/sys/module/binder/parameters/debug_mask" 0
write "/sys/devices/system/edac/cpu/log_ce" 0
write "/sys/devices/system/edac/cpu/log_ue" 0
write "/sys/module/binder/parameters/debug_mask" 0
write "/sys/module/bluetooth/parameters/disable_ertm" "Y"
write "/sys/module/bluetooth/parameters/disable_esco" "Y"
write "/sys/module/debug/parameters/enable_event_log" 0
write "/sys/module/dwc3/parameters/ep_addr_rxdbg_mask" 0 
write "/sys/module/dwc3/parameters/ep_addr_txdbg_mask" 0
write "/sys/module/edac_core/parameters/edac_mc_log_ce" 0
write "/sys/module/edac_core/parameters/edac_mc_log_ue" 0
write "/sys/module/glink/parameters/debug_mask" 0
write "/sys/module/hid_apple/parameters/fnmode" 0
write "/sys/module/hid_magicmouse/parameters/emulate_3button" "N"
write "/sys/module/hid_magicmouse/parameters/emulate_scroll_wheel" "N"
write "/sys/module/ip6_tunnel/parameters/log_ecn_error" "N"
write "/sys/module/lowmemorykiller/parameters/debug_level" 0
write "/sys/module/mdss_fb/parameters/backlight_dimmer" "N"
write "/sys/module/msm_show_resume_irq/parameters/debug_mask" 0
write "/sys/module/msm_smd/parameters/debug_mask" 0
write "/sys/module/msm_smem/parameters/debug_mask" 0 
write "/sys/module/otg_wakelock/parameters/enabled" "N" 
write "/sys/module/service_locator/parameters/enable" 0 
write "/sys/module/sit/parameters/log_ecn_error" "N"
write "/sys/module/smem_log/parameters/log_enable" 0
write "/sys/module/smp2p/parameters/debug_mask" 0
write "/sys/module/sync/parameters/fsync_enabled" "N"
write "/sys/module/touch_core_base/parameters/debug_mask" 0
write "/sys/module/usb_bam/parameters/enable_event_log" 0
write "/sys/module/printk/parameters/console_suspend" "Y"
write "/proc/sys/debug/exception-trace" 0
write "/proc/sys/kernel/printk" "0 0 0 0"
write "/proc/sys/kernel/compat-log" "0"
sysctl -e -w kernel.panic_on_oops=0
sysctl -e -w kernel.panic=0
if [ -e /sys/module/logger/parameters/log_mode ]; then
 write /sys/module/logger/parameters/log_mode 2
fi;
if [ -e /sys/module/printk/parameters/console_suspend ]; then
 write /sys/module/printk/parameters/console_suspend 'Y'
fi;
for i in $(find /sys/ -name debug_mask); do
 write $i 0;
done
for i in $(find /sys/ -name debug_level); do
 write $i 0;
done
for i in $(find /sys/ -name edac_mc_log_ce); do
 write $i 0;
done
for i in $(find /sys/ -name edac_mc_log_ue); do
 write $i 0;
done
for i in $(find /sys/ -name enable_event_log); do
 write $i 0;
done
for i in $(find /sys/ -name log_ecn_error); do
 write $i 0;
done
for i in $(find /sys/ -name snapshot_crashdumper); do
 write $i 0;
done
# =========
# FIX DEEPSLEEP
# =========
for i in $(ls /sys/class/scsi_disk/); do
 lock_value 'temporary none' '/sys/class/scsi_disk/$i/cache_type';
done;
# =========
# TCP TWEAKS
# =========
algos=$(</proc/sys/net/ipv4/tcp_available_congestion_control);
if [[ $algos == *"westwood"* ]]
then
write /proc/sys/net/ipv4/tcp_congestion_control "westwood"
LOGDATA "#  [INFO] ENABLING WESTWOOD TCP ALGORITHM  " 
else
write /proc/sys/net/ipv4/tcp_congestion_control "cubic"
fi
# Increase WI-FI scan delay
# sqlite=/system/xbin/sqlite3 wifi_idle_wait=36000 
# =========
# Blocking Wakelocks
# =========
WK=0
if [ -e "/sys/module/bcmdhd/parameters/wlrx_divide" ]; then
write /sys/module/bcmdhd/parameters/wlrx_divide "8"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/bcmdhd/parameters/wlctrl_divide" ]; then
write /sys/module/bcmdhd/parameters/wlctrl_divide "8"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluetooth_timer" ]; then
write /sys/module/wakeup/parameters/enable_bluetooth_timer "Y"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ipa_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_ipa_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_pno_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_pno_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws" ]; then
write /sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/wlan_wake" ]; then
write /sys/module/wakeup/parameters/wlan_wake "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/wlan_ctrl_wake" ]; then
write /sys/module/wakeup/parameters/wlan_ctrl_wake "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/wlan_rx_wake" ]; then
write /sys/module/wakeup/parameters/wlan_rx_wake "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_msm_hsic_ws" ]; then
write /sys/module/wakeup/parameters/enable_msm_hsic_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
write /sys/module/wakeup/parameters/enable_si_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
write /sys/module/wakeup/parameters/enable_si_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluedroid_timer_ws" ]; then
write /sys/module/wakeup/parameters/enable_bluedroid_timer_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_ipa_ws" ]; then
write /sys/module/wakeup/parameters/enable_ipa_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_netlink_ws" ]; then
write /sys/module/wakeup/parameters/enable_netlink_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_netmgr_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_netmgr_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws" ]; then
write /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_timerfd_ws" ]; then
write /sys/module/wakeup/parameters/enable_timerfd_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_rx_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_rx_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wow_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/smb135x_charger/parameters/use_wlock" ]; then
write /sys/module/smb135x_charger/parameters/use_wlock "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_smb135x_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_smb135x_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
write /sys/module/wakeup/parameters/enable_si_wsk "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluesleep_ws" ]; then
write /sys/module/wakeup/parameters/enable_bluesleep_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/bcmdhd/parameters/wlrx_divide" ]; then
write /sys/module/bcmdhd/parameters/wlrx_divide "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/bcmdhd/parameters/wlctrl_divide" ]; then
write /sys/module/bcmdhd/parameters/wlctrl_divide "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/xhci_hcd/parameters/wl_divide" ]; then
write /sys/module/xhci_hcd/parameters/wl_divide "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/smb135x_charger/parameters/use_wlock" ]; then
write /sys/module/smb135x_charger/parameters/use_wlock "N"
WK=$(( ${WK} + 1 ))
fi
if [ ${WK} -gt 0 ] ;then
LOGDATA "#  [INFO] BLOCKING ${WK} DETECTED KERNEL WAKELOCKS"
fi
if [ -e "/sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker" ]; then
LOGDATA "#  [INFO] ENABLING BOEFFLA WAKELOCK BLOCKER "
write /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;[timerfd];hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK"
fi
# =========
# Google Services Drain fix by @Alcolawl @Oreganoian
# =========
LOGDATA "#  [INFO] Fixing SystemUpdateService BATTERY DRAIN"
su -c pm enable com.google.android.gms/.update.SystemUpdateActivity 
su -c pm enable com.google.android.gms/.update.SystemUpdateService
su -c pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver 
su -c pm enable com.google.android.gms/.update.SystemUpdateService$Receiver 
su -c pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver 
su -c pm enable com.google.android.gsf/.update.SystemUpdateActivity 
su -c pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity 
su -c pm enable com.google.android.gsf/.update.SystemUpdateService 
su -c pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver 
su -c pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver
# FS-TRIM
fstrim -v /cache
fstrim -v /data
fstrim -v /system
LOGDATA "#  [INFO] EXECUTING FS-TRIM "
# =========
# Battery Check
# =========
LOGDATA "# =================================" 
LOGDATA "#  BATTERY LEVEL: $BATT_LEV % "
LOGDATA "#  BATTERY TECHNOLOGY: $BATT_TECH"
LOGDATA "#  BATTERY HEALTH: $BATT_HLTH"
LOGDATA "#  BATTERY TEMP: $BATT_TEMP °C"
LOGDATA "#  BATTERY VOLTAGE: $BATT_VOLT VOLTS "
LOGDATA "# =================================" 
LOGDATA "#  FINISHED : $(date +"%d-%m-%Y %r")"
