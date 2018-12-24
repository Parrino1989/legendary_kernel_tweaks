#!/system/bin/sh
# ====================================================#
# Codename: LKT
# Author: korom42 @ XDA
# Device: Universal
# Version : 1.3.3
# Last Update: 23.DEC.2018
# ====================================================#
# THE BEST BATTERY MOD YOU CAN EVER USE
# JUST FLASH AND FORGET
# ====================================================#
# ##### Credits
#
# ** AKT contributors **
# @Alcolawl @soniCron @Asiier @Freak07 @Mostafa Wael 
# @Senthil360 @TotallyAnxious @RenderBroken @adanteon  
# @Kyuubi10 @ivicask @RogerF81 @joshuous @boyd95 
# @ZeroKool76 @ZeroInfinity
#
# ** Project WIPE contributors **
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
#
# Give proper credits when using this in your work
# ====================================================#


# helper functions to allow Android init like script
function write() {
#if [ -e $1 ]; then
    echo -n $2 > $1
#fi
}

function copy() {
    cat $1 > $2
}

function round() {
  printf "%.${2}f" "${1}"
}

function trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}

function set_value() {
	if [ -f $2 ]; then
		# chown 0.0 $2
		chmod 0644 $2
		echo $1 > $2
		chmod 0444 $2
	fi
}


# $1:display-name $2:file path
function print_value() {
	if [ -f $2 ]; then
		echo $1
		cat $2
	fi
}

# $1:cpu0 $2:timer_rate $3:value
function set_param() {
	echo $3 > /sys/devices/system/cpu/$1/cpufreq/interactive/$2
}
function set_param_eas() {
	echo $3 > /sys/devices/system/cpu/$1/cpufreq/schedutil/$2
}


# $1:cpu0 $2:timer_rate
function print_param() {
	echo "$1: $2"
	cat /sys/devices/system/cpu/$1/cpufreq/interactive/$2
}

# $1:io-scheduler $2:block-path
function set_io() {
	if [ -f $2/queue/scheduler ]; then
		if [ `grep -c $1 $2/queue/scheduler` = 1 ]; then
			write $2/queue/scheduler $1
			set_value 0 $2/queue/iostats
			set_value 128 $2/queue/nr_requests
			set_value 0 $2/queue/iosched/slice_idle
			set_value 1 $2/queue/rq_affinity
			set_value 1 $2/queue/nomerges
			set_value 0 $2/queue/add_random
			set_value 0 $2/queue/rotational
			set_value 0 $2/bdi/min_ratio
			set_value 100 $2/bdi/max_ratio
			if [ "$1" == "cfq" ];then
			write $2/queue/read_ahead_kb 128
			else
			write $2/queue/read_ahead_kb 2048
			fi
  		fi
	fi
}


RETRY_INTERVAL=5 #in seconds
MAX_RETRY=60
retry=${MAX_RETRY}

#wait for boot completed
while (("$retry" > "0")) && [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep ${RETRY_INTERVAL}
  ((retry--))
done

sleep 15

    #MOD Variable
    V="<VER>"
    PROFILE=<PROFILE_MODE>
    LOG=/data/LKT.prop
    dt=$(date '+%d/%m/%Y %H:%M:%S');
    sbusybox=`busybox | awk 'NR==1{print $2}'` 
   
    # RAM variables
    TOTAL_RAM=$(free | grep Mem | awk '{print $2}')
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{printf("%.f\n", (x/1000000)+0.5)}')
    memg=$(round ${memg} 0) 

	# CPU variables
    arch_type=`uname -m`
    gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)
    govn=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    bcl_soc_hotplug_mask=`cat /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask`
    bcl_hotplug_mask=`cat /sys/devices/soc/soc:qcom,bcl/hotplug_mask`
    if [ -e "/sys/kernel/cpu_input_boost/enabled" ]; then
    inpboost="/sys/kernel/cpu_input_boost/ib_freqs"
    else
    inpboost="/sys/module/cpu_boost/parameters/input_boost_freq"
    fi
	# Device infos
    BATT_LEV=`cat /sys/class/power_supply/battery/capacity`
    BATT_TECH=`cat /sys/class/power_supply/battery/technology`
    BATT_HLTH=`cat /sys/class/power_supply/battery/health`
    BATT_TEMP=`cat /sys/class/power_supply/battery/temp`
    BATT_TEMP=$(awk -v x=$BATT_TEMP 'BEGIN{print x/10}')
    BATT_VOLT=`dumpsys battery | awk '/^ +voltage:/ && $NF!=0{print $NF}'`
    BATT_VOLT=$(awk -v x=$BATT_VOLT 'BEGIN{print x/1000}')
    BATT_VOLT=$(round ${BATT_VOLT} 1) 
    VENDOR=`getprop ro.product.brand | tr '[:lower:]' '[:upper:]'`
    KERNEL="$(uname -r)"
    OS=`getprop ro.build.version.release`
    APP=`getprop ro.product.model`
    SOC=$(awk '/^Hardware/{print tolower($NF)}' /proc/cpuinfo)
    SOC1=`getprop ro.product.board | tr '[:upper:]' '[:lower:]'`
    SOC2=`getprop ro.product.platform | tr '[:upper:]' '[:lower:]'`
    SOC3=`getprop ro.chipname | tr '[:upper:]' '[:lower:]'`
    SOC4=`getprop ro.hardware | tr '[:upper:]' '[:lower:]'`
    CPU_FILE="/data/soc.txt"

    if grep -q 'CPU=' $CPU_FILE
    then
    SOC5=$(awk -F= '{ print tolower($2) }' $CPU_FILE)
    else
    SOC5=$(cat $CPU_FILE | tr '[:upper:]' '[:lower:]')
    fi
    error=0
    support=0
    snapdragon=0
    chip=0

    function logdata() {
        echo $1 |  tee -a $LOG;
    }

    if [ -e $LOG ]; then
     rm $LOG;
    fi;

	    cores=`grep -c ^processor /proc/cpuinfo`
    coresmax=$(cat /sys/devices/system/cpu/kernel_max)

    quad_core=4
    hexa_core=6
    octa_core=8
    deca_core=10
    bcores=4

    if [ $cores -eq $quad_core ];then
    bcores=2
    elif [ $cores -eq $hexa_core ];then
    bcores=4
    elif [ $cores -eq $octa_core ];then
    bcores=4
    elif [ $cores -eq $deca_core ];then
    bcores=4
    else
    bcores=4
    fi

    if [ -e /sys/devices/system/cpu/cpu0/cpufreq ]; then
    GOV_PATH_L=/sys/devices/system/cpu/cpu0/cpufreq
    fi
    if [ -e /sys/devices/system/cpu/cpu$bcores/cpufreq ]; then
    GOV_PATH_B=/sys/devices/system/cpu/cpu$bcores/cpufreq
    fi

    if [ -e /sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors ]; then
    SILVER=/sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors;
    fi
    if [ -e /sys/devices/system/cpu/cpufreq/policy0 ]; then
    SVD=/sys/devices/system/cpu/cpufreq/policy0
    fi
	
    if [ -e /sys/devices/system/cpu/cpufreq/policy$bcores/scaling_available_governors ]; then 
    GOLD=/sys/devices/system/cpu/cpufreq/policy$bcores/scaling_available_governors;
	elif [ -e /sys/devices/system/cpu/cpufreq/policy$bcores/scaling_available_governors ]; then 
    GOLD=/sys/devices/system/cpu/cpufreq/policy$bcores/scaling_available_governors;  
    fi
	 
    if [ -e /sys/devices/system/cpu/cpufreq/policy$bcores ]; then 
    GLD=/sys/devices/system/cpu/cpufreq/policy$bcores
    elif [ -e /sys/devices/system/cpu/cpufreq/policy$bcores ]; then 
    GLD=/sys/devices/system/cpu/cpufreq/policy$bcores
    fi
	
    maxfreq=$(cat "$GOV_PATH_B/scaling_max_freq")
    maxfreq=$(awk -v x=$maxfreq 'BEGIN{print x/1000000}')
    maxfreq=$(round ${maxfreq} 2)
	
	if [ $PROFILE -eq 0 ];then
	PROFILE_M="Battery"
	elif [ $PROFILE -eq 1 ];then
	PROFILE_M="Balanced"
	elif [ $PROFILE -eq 2 ];then
	PROFILE_M="Performance"
	elif [ $PROFILE -eq 3 ];then
	PROFILE_M="Turbo"
	fi

logdata "###### LKT™ $V" 
logdata "###### Profile : $PROFILE_M" 
logdata "" 
logdata "#  START : $(date +"%d-%m-%Y %r")" 
logdata "#  ==============================" 
logdata "#  Vendor : $VENDOR" 
logdata "#  Device : $APP" 
logdata "#  CPU : $SOC @ $maxfreq GHz ($cores x cores)" 
logdata "#  RAM : $memg GB" 
logdata "#  ==============================" 
logdata "#  Android : $OS" 
logdata "#  Kernel : $KERNEL" 
logdata "#  BusyBox  : $sbusybox" 
logdata "# ==============================" 

    if [ "$SOC" == "" ];then
    error=1
    logdata "# *WARNING* SoC detection method(1) failed .. Trying alternatives"
    if [ "$SOC1" != "${SOC1/msm/}" ] || [ "$SOC1" != "${SOC1/sda/}" ] || [ "$SOC1" != "${SOC1/exynos/}" ] || [ "$SOC1" != "${SOC1/sdm/}" ] || [ "$SOC1" != "${SOC1/universal/}" ] || [ "$SOC1" != "${SOC1/kirin/}" ] || [ "$SOC1" != "${SOC1/moorefield/}" ] || [ "$SOC1" != "${SOC1/mt/}" ];then
    SOC=$SOC1
    error=0
    fi
    fi
	
    if [ "$SOC" == "" ];then
    error=1
    logdata "# *WARNING* SoC detection method(2) failed .. Trying alternatives"
    if [ "$SOC2" != "${SOC2/msm/}" ] || [ "$SOC2" != "${SOC2/sda/}" ] || [ "$SOC2" != "${SOC2/exynos/}" ] || [ "$SOC2" != "${SOC2/sdm/}" ] || [ "$SOC2" != "${SOC2/universal/}" ] || [ "$SOC2" != "${SOC2/kirin/}" ] || [ "$SOC2" != "${SOC2/moorefield/}" ] || [ "$SOC2" != "${SOC2/mt/}" ];then
    SOC=$SOC2
    error=0
    fi
    fi
    
    if [ "$SOC" == "" ];then
    error=1
    logdata "# *WARNING* SoC detection method(3) failed .. Trying alternatives"
	if [ "$SOC3" != "${SOC3/msm/}" ] || [ "$SOC3" != "${SOC3/sda/}" ] || [ "$SOC3" != "${SOC3/exynos/}" ] || [ "$SOC3" != "${SOC3/sdm/}" ] || [ "$SOC3" != "${SOC3/universal/}" ] || [ "$SOC3" != "${SOC3/kirin/}" ] || [ "$SOC3" != "${SOC3/moorefield/}" ] || [ "$SOC3" != "${SOC3/mt/}" ];then
    SOC=$SOC3
    error=0
    fi
    fi

    if [ "$SOC" == "" ];then
    error=1
    logdata "# *WARNING* SoC detection method(4) failed .. Trying alternatives"
    if [ "$SOC4" != "${SOC4/msm/}" ] || [ "$SOC4" != "${SOC4/sda/}" ] || [ "$SOC4" != "${SOC4/exynos/}" ] || [ "$SOC4" != "${SOC4/sdm/}" ] || [ "$SOC4" != "${SOC4/universal/}" ] || [ "$SOC4" != "${SOC4/kirin/}" ] || [ "$SOC4" != "${SOC4/moorefield/}" ] || [ "$SOC4" != "${SOC4/mt/}" ];then
    SOC=$SOC4
    error=0
    fi
    fi

    if [ "$SOC" == "" ];then
    error=1
    logdata "# *WARNING* SoC detection method(5) failed .. Trying alternatives"
    if [ "$SOC5" != "${SOC5/msm/}" ] || [ "$SOC5" != "${SOC5/sda/}" ] || [ "$SOC5" != "${SOC5/exynos/}" ] || [ "$SOC5" != "${SOC4/sdm/}" ] || [ "$SOC5" != "${SOC4/universal/}" ] || [ "$SOC5" != "${SOC5/kirin/}" ] || [ "$SOC5" != "${SOC5/moorefield/}" ] || [ "$SOC5" != "${SOC5/mt/}" ];then
    SOC=$SOC5
    error=0
    else
    error=2
    logdata "# *ERROR* Manual SoC detection method failed"
    logdata "# *HINT* $CPU_FILE does not contain a valid CPU model"
    fi
    fi

    if [ "$SOC" == "" ];then
    if [ ! -f $CPU_FILE ]; then
    logdata "# *ERROR* SoC detection failed"
    logdata "#  "
    logdata "#  "
    logdata "#  "
    logdata "#  "
    logdata "# 1) Using a ROOT file explorer"
    logdata "#  "
    logdata "# 2) Go to $CPU_FILE and edit it with your CPU model"
    logdata "#  "
    logdata "#    example (Huawei kirin 970)       CPU=kirin970"
    logdata "#    example (Snapdragon 845)         CPU=sdm845"
    logdata "#    example (Snapdragon 820 or 821)  CPU=msm8996"
    logdata "#    example (Galaxy S8 exynos8890)   CPU=universal8890"
    logdata "#  "
    logdata "# 3) Save changes & Reboot"
    logdata "#  "
    logdata "#  "
    logdata "#  "
    logdata "#  "
    logdata "# Tip: Use CPU-Z app or find your correct CPU Model number on this page"
    logdata "#  "
    logdata "# https://en.wikipedia.org/wiki/List_of_Qualcomm_Snapdragon_systems-on-chip"
    write $CPU_FILE "CPU="
    exit 0
    else
    rm $LOG;
    SOC=$SOC5

    if [ "$SOC" == "" ];then
    error=3
    logdata "# *ERROR* Manual SoC detection method failed"
    logdata "# *HINT* $CPU_FILE is empty"
    fi

    fi
    fi
   
## Had to split into multiple small arrays because one large array would not work
SOCS01=("sdm845" "sda845" "msm8998" "apq8098" "apq8098_latv" "msm8996" "msm8996pro")
SOCS02=("msm8996au" "msm8996sg" "msm8996pro-aa" "msm8996pro-ab" "msm8996pro-ac" "apq8096")
SOCS03=("apq8096_latv" "msm8994" "msm8994pro" "msm8994pro-aa" "msm8994pro-ab")
SOCS04=("msm8994pro-ac" "msm8992" "msm8992pro" "msm8992pro-aa" "msm8992pro-ab")
SOCS05=("msm8992pro-ac" "msm8974" "msm8974pro-ab" "msm8974pro-aa" "msm8974pro-ac")
SOCS06=("msm8974pro" "apq8084" "sdm660" "msm8956" "msm8976" "msm8976sg" "sdm636" "msm8953")
SOCS07=("msm8953pro" "universal8895" "exynos8895" "universal8890" "exynos8890" "universal7420" "exynos7420" "kirin970" "kirin960")
SOCS08=("kirin960s" "kirin950" "kirin955" "mt6797t" "mt6797" "mt6795" "moorefield" "msm8939" "exynos9810" "universal9810")
SOCS09=("msm8939v2" "kirin650" "kirin655" "kirin658" "kirin659" "sda660" "apq8026")
SOCS10=("msm8226" "msm8626" "msm8926" "apq8028" "msm8228" "msm8628" "msm8928" "msm8230")
SOCS11=("msm8630" "msm8930" "msm8930aa" "apq8030ab" "msm8230ab" "sd410" "msm8916" "apq8016")
SOCS12=("sdm427" "sd427" "msm8920" "sdm425" "sd425" "msm8917" "sdm430" "sd430" "msm8937")
SOCS13=("sdm435" "sd435" "msm8940" "sdm450" "sd450" "apq8026" "msm8226" "msm8926")

## now loop through the above arrays
for i in "${SOCS01[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done


for i in "${SOCS02[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS03[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS04[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS05[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS06[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS07[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS08[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS09[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS10[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS11[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS12[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

for i in "${SOCS13[@]}"
do
    if [ "$SOC" == "$i" ];then
    support=1
	fi
done

    if [ "$SOC" != "${SOC/msm/}" ] || [ "$SOC" != "${SOC/sda/}" ] || [ "$SOC" != "${SOC/sdm/}" ] || [ "$SOC" != "${SOC/apq/}" ]; then
    snapdragon=1
    else
    snapdragon=0
    fi



    function before_modify()
{
	chown 0.0 $GOV_PATH_L/interactive/*
	chown 0.0 $GOV_PATH_B/interactive/*
	chmod 0666 $GOV_PATH_L/interactive/*	
 chmod 0666 $GOV_PATH_B/interactive/*
}

    function after_modify()
{
	chmod 0444 $GOV_PATH_L/interactive/*	
  chmod 0444 $GOV_PATH_B/interactive/*
}

    function before_modify_eas()
{
	chown 0.0 $GOV_PATH_L/schedutil/*
	chown 0.0 $GOV_PATH_B/schedutil/*
	chmod 0666 $GOV_PATH_L/schedutil/*	
	chmod 0666 $GOV_PATH_B/schedutil/*
	chmod 0666 $SVD/schedutil/*
	chmod 0666 $GLD/schedutil/*
}

    function after_modify_eas()
{
	chmod 0444 $SVD/schedutil/*
	chmod 0444 $GLD/schedutil/*
	chmod 0444 $GOV_PATH_L/schedutil/*	
	chmod 0444 $GOV_PATH_B/schedutil/*
}

function enable_bcl() {

if [ $snapdragon -eq 1 ];then

    write /sys/module/msm_thermal/core_control/enabled "1"
    write /sys/devices/soc/soc:qcom,bcl/mode -n disable
    write /sys/devices/soc/soc:qcom,bcl/hotplug_mask $bcl_hotplug_mask
    write /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask $bcl_soc_hotplug_mask
    write /sys/devices/soc/soc:qcom,bcl/mode -n enable

else
	set_value 1 /sys/power/cpuhotplug/enabled
	set_value 1 /sys/devices/system/cpu/cpuhotplug/enabled
fi

}

zram_dev()
{
	local idx="$1"
	echo "/dev/zram${idx:-0}"
}

zram_reset()
{
	local dev="$1"
	local proc_entry="/sys/block/$( basename "$dev" )/reset"
	echo "1" >"$proc_entry"
}

function disable_swap() {

	if [ -f /system/bin/swapoff ] ; then
        swff="/system/bin/swapoff"
	elif [ -f /system/xbin/swapoff ] ; then
        swff="/system/xbin/swapoff"
	else
	swff="swapoff"
	fi

	local zram_dev

	for zram_dev in $( grep zram /proc/swaps |awk '{print $1}' ); do {
		swff "$zram_dev" && zram_reset "$zram_dev"
		local dev_index="$( echo $zram_dev | grep -o "[0-9]*$" )"
		if [ $dev_index -ne 0 ]; then
			echo $dev_index > /sys/class/zram-control/hot_remove
		fi
	} done

	for f in /dev/block/vnswap*; do
	swff $f
	done

	for i in /sys/block/zram*; do
	set_value "1" $i/reset;
	set_value "0" $i/disksize
	done

	for j in /sys/block/swap*; do
	set_value "1" $j/reset;
	set_value "0" $j/disksize
	done

	for k in /sys/block/vnswap*; do
	set_value "1" $k/reset;
	set_value "0" $k/disksize
	done

	resetprop -n vnswap.enabled false
	resetprop -n ro.config.zram false
	resetprop -n ro.config.zram.support false
	resetprop -n zram.disksize 0
	set_value 0 /proc/sys/vm/swappiness
	sysctl -w vm.swappiness=0
}

function disable_lmk() {
if [ -e "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" ]; then
 set_value 0 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
 set_value 0 /sys/module/process_reclaim/parameters/enable_process_reclaim
    resetprop -n lmk.autocalc false
 else
 	logdata '# *WARNING* Adaptive LMK is not present on your Kernel' 
fi;
}

function ramtuning() { 
    
    calculator=3

    if [ $TOTAL_RAM -lt 2097152 ]; then
    calculator="2.4"
    disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 28

    elif [ $TOTAL_RAM -lt 3145728 ]; then
    calculator="2.6"
    disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 32
	
    elif [ $TOTAL_RAM -lt 4194304 ]; then
    calculator="2.7"
    disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 36
    fi
 
    if [ $TOTAL_RAM -gt 4194304 ]; then
    calculator="2.77"
    disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 64

    elif [ $TOTAL_RAM -gt 6291456 ]; then
    calculator="2.8"
    disable_swap
    #disable_lmk
    resetprop -n ro.sys.fw.bg_apps_limit 128
    fi

  # LMK Calculator
  # This is a Calculator for the Android Low Memory Killer 
  # It detects the Free RAM and set the LMK to right configuration
  # for more RAM but also better Multitasking 
  # Algorithms COPYRIGHT by PDesire and the THDR Alliance 
  # Code COPYRIGHT korom42


divisor=$(awk -v x=$TOTAL_RAM 'BEGIN{print x/256}')
var_one=$(awk -v x=$TOTAL_RAM -v y=2 'BEGIN{print sqrt(x)*sqrt(2)}')
var_two=$(awk -v x=$TOTAL_RAM -v p=3.14 'BEGIN{print x*sqrt(p)}')
var_three=$(awk -v x=$var_one -v y=$var_two -v z=$divisor 'BEGIN{print (x+y)/z}')
var_four=$(awk -v x=$var_three -v p=3.14 'BEGIN{print x/(sqrt(p)*2)}')
f_LMK=$(awk -v x=$var_four -v p=3.14 'BEGIN{print x/(p*2)}')
LMK=$(round ${f_LMK} 0)

 # Low Memory Killer Generator
 # Settings inspired by HTC stock firmware 
 # Tuned by korom42 for multi-tasking and saving CPU cycles

LIGHT=("1.25" "1.5" "1.75" "2" "2.75" "3.25")
BALANCED=("1.6" "1.25" "2.25" "3" "4" "5.25")
AGGRESSIVE=("1.25" "1.5" "3" "4.8" "5.5" "7")

if [ $PROFILE -eq 0 ];then
c=("${LIGHT[@]}")
elif [ $PROFILE -eq 1 ];then
c=("${BALANCED[@]}")
elif [ $PROFILE -eq 2 ];then
c=("${BALANCED[@]}")
elif [ $PROFILE -eq 3 ];then
c=("${AGGRESSIVE[@]}")
fi

f_LMK1=$(awk -v x=$LMK -v y=${c[0]} -v z=$calculator 'BEGIN{print x*y*z*1024/4}') #Low Memory Killer 1
LMK1=$(round ${f_LMK1} 0)

f_LMK2=$(awk -v x=$LMK1 -v y=${c[1]} 'BEGIN{print x*y}') #Low Memory Killer 2
LMK2=$(round ${f_LMK2} 0)

f_LMK3=$(awk -v x=$LMK1 -v y=${c[2]} 'BEGIN{print x*y}') #Low Memory Killer 3
LMK3=$(round ${f_LMK3} 0)

f_LMK4=$(awk -v x=$LMK1 -v y=${c[3]} 'BEGIN{print x*y}') #Low Memory Killer 4
LMK4=$(round ${f_LMK4} 0)

f_LMK5=$(awk -v x=$LMK1 -v y=${c[4]} 'BEGIN{print x*y}') #Low Memory Killer 5
LMK5=$(round ${f_LMK5} 0)

f_LMK6=$(awk -v x=$LMK1 -v y=${c[5]} 'BEGIN{print x*y}') #Low Memory Killer 6
LMK6=$(round ${f_LMK6} 0)


if [ -e "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" ]; then
	set_value 1 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
else
	logdata "#  *WARNING* Adaptive LMK is not present on your Kernel" 
fi


if [ -e "/sys/module/lowmemorykiller/parameters/minfree" ]; then
	set_value "$LMK1,$LMK2,$LMK3,$LMK4,$LMK5,$LMK6" /sys/module/lowmemorykiller/parameters/minfree
else
	logdata "#  *WARNING* LMK cannot currently be modified on your Kernel" 
fi


# =========
# Vitual Memory
# =========

chmod 0644 /proc/sys/*;

if [ $PROFILE -le 1 ];then
sysctl -e -w  vm.drop_caches=1 \
vm.dirty_background_ratio=1 \
vm.dirty_ratio=5 \
vm.vfs_cache_pressure=70 \
vm.laptop_mode=5 \
vm.block_dump=0 \
vm.dirty_writeback_centisecs=0 \
vm.dirty_expire_centisecs=0 \
vm.compact_memory=1 \
vm.compact_unevictable_allowed=1 \
vm.page-cluster=0 \
vm.panic_on_oom=0 &> /dev/null

sysctl -w kernel.random.read_wakeup_threshold=64
sysctl -w kernel.random.write_wakeup_threshold=128
else
sysctl -e -w  vm.drop_caches=1 \
vm.dirty_background_ratio=5 \
vm.dirty_ratio=20 \
vm.vfs_cache_pressure=100 \
vm.laptop_mode=0 \
vm.block_dump=0 \
vm.dirty_writeback_centisecs=500 \
vm.dirty_expire_centisecs=1500 \
vm.compact_memory=1 \
vm.compact_unevictable_allowed=1 \
vm.page-cluster=0 \
vm.panic_on_oom=0 &> /dev/null

sysctl -e -w kernel.random.read_wakeup_threshold=64
sysctl -e -w kernel.random.write_wakeup_threshold=896
fi

chmod 0444 /proc/sys/*;

logdata "#  Virtual Memory Tuning .. DONE" 

sync;

}

function cputuning() {

    if [ $snapdragon -eq 1 ];then

    logdata "#  Snapdragon SoC detected" 

    # disable thermal bcl hotplug to switch governor
    write /sys/module/msm_thermal/core_control/enabled "0"
    write /sys/module/msm_thermal/parameters/enabled "N"
	
    else

    logdata "#  Non-snapdragon SoC detected" 

    # Linaro HMP, between 0 and 1024, maybe compare to the capacity of current cluster
    # PELT and period average smoothing sampling, so the parameter style differ from WALT by Qualcomm a lot.
    # https://lists.linaro.org/pipermail/linaro-dev/2012-November/014485.html
    # https://www.anandtech.com/show/9330/exynos-7420-deep-dive/6
    # set_value 60 /sys/kernel/hmp/load_avg_period_ms
    set_value 256 /sys/kernel/hmp/down_threshold
    set_value 640 /sys/kernel/hmp/up_threshold
    set_value 0 /sys/kernel/hmp/boost

    # Exynos hotplug
    set_value 0 /sys/power/cpuhotplug/enabled
    set_value 0 /sys/devices/system/cpu/cpuhotplug/enabled
    fi

	if [ $support -eq 1 ];then
    logdata "# SoC Check= SUCCESS - Your device is supported by LKT"
	fi

    if [ -e /sys/devices/soc/soc:qcom,bcl/mode ]; then
    chmod 644 /sys/devices/soc/soc:qcom,bcl/mode
    write /sys/devices/soc/soc:qcom,bcl/mode -n disable
    write /sys/devices/soc/soc:qcom,bcl/hotplug_mask 0
    write /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask 0
    write /sys/devices/soc/soc:qcom,bcl/mode -n enable
    fi
	
	# Perfd, nothing to worry about, if error the script will continue

	if [ -e /data/system/perfd ]; then
	stop perfd
	fi
	
	if [ -e /data/system/perfd/default_values ]; then
	rm /data/system/perfd/default_values
	fi
	 
	sleep "0.001"
	 
	# A simple loop to bring all cores online that we counted earlier
	 
	num=0
	
	while [ $num -lt $cores ]
	
	do
	
	set_value 1 /sys/devices/system/cpu/cpu$num/online
	
	#num=`expr $num + 1`
	num=$(( $num + 1 ))
	
	sleep "0.001"
	
	done

	write /sys/devices/system/cpu/online "0-$coresmax"

	set_value 90 /proc/sys/kernel/sched_spill_load
	set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
	set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify

	# set_value 85 /proc/sys/kernel/sched_downmigrate
	# set_value 95 /proc/sys/kernel/sched_upmigrate

	set_value 0 /sys/module/msm_performance/parameters/touchboost
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_ms" ]; then
	set_value 80 /sys/module/cpu_boost/parameters/input_boost_ms
	elif [ -e "/sys/kernel/cpu_input_boost/enabled" ]; then
	set_value 1 /sys/kernel/cpu_input_boost/enabled
	set_value 80 /sys/kernel/cpu_input_boost/ib_duration_ms
	else
	logdata "#  *WARNING* Your Kernel does not support CPU BOOST  " 
	fi

	available_governors=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)
	string1=/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors;
	string2=/sys/devices/system/cpu/cpu$bcores/cpufreq/scaling_available_governors;
	gov_l=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
	gov_b=$(cat /sys/devices/system/cpu/cpu$bcores/cpufreq/scaling_governor)

if [[ "$available_governors" == *"schedutil"* ]] || [[ "$available_governors" == *"sched"* ]]; then

	if [ -e $SVD ] && [ -e $GLD ]; then

	before_modify_eas

	if [[ "$available_governors" == *"sched"* ]]; then
	set_value "sched" $SVD/scaling_governor 
	set_value "sched" $GLD/scaling_governor
	elif [[ "$available_governors" == *"schedutil"* ]]; then
	set_value "schedutil" $SVD/scaling_governor 
	set_value "schedutil" $GLD/scaling_governor
	fi
	
	logdata "#  EAS Kernel Detected .. Tuning $govn"

	case "$SOC" in
	"universal9810" | "exynos9810") #exynos9810
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	if [ $PROFILE -eq 0 ];then
	set_value "0:1690000 4:1980000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1080000 4:0" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1080000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 1 ]; then
	set_value "0:1794000 4:2380000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1080000 4:0" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1280000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1280000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 2 ]; then
	set_value "0:1794000 4:2680000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1180000 4:0" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1380000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1480000
	set_param_eas cpu4 hispeed_load 95
	set_param_eas cpu4 pl 1
	elif [ $PROFILE -eq 3 ]; then # Turbo
	set_value "0:1794000 4:2680000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1480000 4:1680000" $inpboost
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1480000
	set_param_eas cpu0 hispeed_load 85
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1480000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 1
	fi
	;;
	"sdm845" | "sda845") #sd845 
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	if [ $PROFILE -eq 0 ];then
	set_value "0:1680000 4:1880000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1080000 4:0" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1080000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 1 ]; then
	set_value "0:1780000 4:2280000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1080000 4:0" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1280000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1280000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 2 ]; then
	set_value "0:1780000 4:2880000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1180000 4:0" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1380000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1480000
	set_param_eas cpu4 hispeed_load 95
	set_param_eas cpu4 pl 1
	elif [ $PROFILE -eq 3 ]; then # Turbo
	set_value "0:1780000 4:2280000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1480000 4:1680000" $inpboost
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1480000
	set_param_eas cpu0 hispeed_load 85
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1480000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 1
	fi
	;;
    "msm8998" | "apq8098" | "apq8098_latv" | "kirin710" | "kirin960" | "kirin960s" | "kirin970" ) #	Cortex-A73/-A53

	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	if [ $PROFILE -eq 0 ];then
	set_value "0:1880000 4:1680000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1080000 4:0" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1080000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 1 ]; then
	set_value "4:2080000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1080000 4:0" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1280000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1280000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 2 ]; then
	set_value "4:2480000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1180000 4:0" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1380000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1480000
	set_param_eas cpu4 hispeed_load 95
	set_param_eas cpu4 pl 1
	elif [ $PROFILE -eq 3 ]; then # Turbo
	set_value "4:2080000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1480000 4:1680000" $inpboost
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1480000
	set_param_eas cpu0 hispeed_load 85
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1480000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 1
	fi
	;;
    "msm8996" | "msm8996pro" | "msm8996au" |  "msm8996sg" | "msm8996pro-aa"| "msm8996pro-ab" | "msm8996pro-ac" | "apq8096" | "apq8096_latv") #sd820


	# avoid permission problem, do not set 0444
	set_value 1 /dev/cpuset/background/cpus
	set_value 0-1 /dev/cpuset/system-background/cpus
	set_value 0-1,2-3 /dev/cpuset/foreground/cpus
	set_value 0-1,2-3 /dev/cpuset/top-app/cpus

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate

	if [ $PROFILE -eq 0 ];then
	set_value "0:1440000 2:1600000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1080000 2:0" $inpboost
	set_value 0 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 1 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1080000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 1 ]; then
	set_value "2:1600000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1080000 2:0" $inpboost
	set_value 0 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1380000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 2 ]; then
	set_value "0:1593600 2:2150400" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1180000 2:0" $inpboost
	set_value 1 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1480000
	set_param_eas cpu4 hispeed_load 95
	set_param_eas cpu4 pl 1
	elif [ $PROFILE -eq 3 ]; then # Turbo
	set_value "2:1600000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1480000 2:1580000" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1480000
	set_param_eas cpu0 hispeed_load 85
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1480000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 1
	fi
	;;
    "msm8994" | "msm8994pro" | "msm8994pro-aa"| "msm8994pro-ab" | "msm8994pro-ac" | "msm8992" | "msm8992pro" | "msm8992pro-aa" | "msm8992pro-ab" | "msm8992pro-ac") #sd810/808


	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	set_value 0-3,4-5 /dev/cpuset/foreground/cpus
	set_value 0-3,4-5 /dev/cpuset/top-app/cpus

	set_value 85 /proc/sys/kernel/sched_downmigrate
	set_value 99 /proc/sys/kernel/sched_upmigrate

	set_value 0 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus


	write /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 1344000
	write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 1440000


	if [ $PROFILE -eq 0 ];then
	set_value "0:1080000 4:0" $inpboost
	set_value "0:1344000 4:1440000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 880000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 1 ]; then
	set_value "0:1080000 4:0" $inpboost
	set_value "0:1344000 4:1440000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_param_eas cpu0 hispeed_freq 1280000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 880000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 2 ]; then
	set_value "0:1180000 4:0" $inpboost
	set_value "0:1555200 4:1958400" /sys/module/msm_performance/parameters/cpu_max_freq
	set_param_eas cpu0 hispeed_freq 1280000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1180000
	set_param_eas cpu4 hispeed_load 95
	set_param_eas cpu4 pl 1
	elif [ $PROFILE -eq 3 ]; then # Turbo
	set_value "0:1344000 4:1440000" $inpboost
	set_value "0:1344000 4:1440000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_param_eas cpu0 hispeed_freq 1344000
	set_param_eas cpu0 hispeed_load 85
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1180000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 1
	fi

	;;

	"msm8953" | "msm8953pro")  #sd625/626
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	if [ $PROFILE -eq 0 ];then
	set_value "4:1680000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:980000" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1080000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 1 ]; then
	set_value "4:1680000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:980000" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1380000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 2 ]; then
	set_value "4:2200000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:980000" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1180000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1480000
	set_param_eas cpu4 hispeed_load 95
	set_param_eas cpu4 pl 1
	elif [ $PROFILE -eq 3 ]; then # Turbo
	set_value "4:1880000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:980000" $inpboost
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1480000
	set_param_eas cpu0 hispeed_load 85
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1480000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 1
	fi

	;;
	"sdm636" | "sda636") #sd636

	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	if [ $PROFILE -eq 0 ];then
	set_value "4:1380000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "4:1080000" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1080000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1080000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 1 ]; then
	set_value "4:1380000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "4:1080000" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1080000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 0
	set_param_eas cpu4 hispeed_freq 1080000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 0
	elif [ $PROFILE -eq 2 ]; then
	set_value "4:1800000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "4:1180000" $inpboost
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1380000
	set_param_eas cpu0 hispeed_load 90
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1280000
	set_param_eas cpu4 hispeed_load 95
	set_param_eas cpu4 pl 1
	elif [ $PROFILE -eq 3 ]; then # Turbo
	set_value "4:1680000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value "0:1380000 4:1480000" $inpboost
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas cpu0 hispeed_freq 1280000
	set_param_eas cpu0 hispeed_load 85
	set_param_eas cpu0 pl 1
	set_param_eas cpu4 hispeed_freq 1380000
	set_param_eas cpu4 hispeed_load 90
	set_param_eas cpu4 pl 1
	fi
	;;

	*)

	logdata "#  *WARNING* EAS governor tweaks for your device are not available"
	logdata "#  *NOTE* Consider switching to HMP Kernel if possible" 

	;;


	esac

        after_modify_eas

	fi

	else

	set_value "interactive" /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	set_value "interactive" /sys/devices/system/cpu/cpu$bcores/cpufreq/scaling_governor
	if [ "$gov_l" != "interactive" ] || [ "$gov_b" != "interactive" ];then
	logdata "#  *Error* Cannot switch to interactive as default governor" 
	fi

	logdata "#  HMP Kernel Detected .. Tuning $govn" 

        before_modify

	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu$bcores timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu$bcores timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu$bcores boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu$bcores boostpulse_duration 0
	set_param cpu0 use_sched_load 1
	set_param cpu$bcores use_sched_load 1
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu$bcores ignore_hispeed_on_notif 0
	set_value 0 /sys/devices/system/cpu/cpu0/cpufreq/interactive/enable_prediction
	set_value 0 /sys/devices/system/cpu/cpu$bcores/cpufreq/interactive/enable_prediction

	if [ -e "/sys/module/cpu_boost/parameters/input_boost_ms" ]; then
	set_value 2500 /sys/module/cpu_boost/parameters/input_boost_ms
        elif [ -e "/sys/kernel/cpu_input_boost/enabled" ]; then
        set_value 1 /sys/kernel/cpu_input_boost/enabled
	set_value 2500 /sys/kernel/cpu_input_boost/ib_duration_ms
	else
	logdata "#  *WARNING* Your Kernel does not support CPU BOOST  " 
	fi

	if [ -e "/sys/module/cpu_boost/parameters/boost_ms" ]; then
	set_value 0 /sys/module/cpu_boost/parameters/boost_ms
	fi

	#Disable TouchBoost
	if [ -e "/sys/module/msm_performance/parameters/touchboost" ]; then
	set_value 0 /sys/module/msm_performance/parameters/touchboost
	else
	logdata "#  *WARNING* Your Kernel does not support TOUCH BOOST  " 
	fi

	if [ $PROFILE -eq 0 ];then
	case "$SOC" in
	"msm8998" | "apq8098" | "apq8098_latv") #sd835
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value "0:380000 4:380000" $inpboost

  	set_param cpu0 above_hispeed_delay "18000 1380000:58000 1480000:18000 1580000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:59 480000:51 580000:29 780000:92 880000:76 1180000:90 1280000:98 1380000:84 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1480000:58000 1580000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1280000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 380000:45 480000:36 580000:41 680000:65 780000:88 1080000:92 1280000:98 1380000:90 1580000:97"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
    "msm8996" | "msm8996pro" | "msm8996au" |  "msm8996sg" | "msm8996pro-aa"| "msm8996pro-ab" | "msm8996pro-ac" | "apq8096" | "apq8096_latv") #sd820
	set_value "0:380000 2:380000" $inpboost
	
	set_value 1 /dev/cpuset/background/cpus
	set_value 0-1 /dev/cpuset/system-background/cpus
	set_value 0-1,2-3 /dev/cpuset/foreground/cpus
	set_value 0-1,2-3 /dev/cpuset/top-app/cpus

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate

	set_param cpu0 above_hispeed_delay "18000 1180000:78000 1280000:98000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:5 580000:42 680000:60 780000:70 880000:83 980000:92 1180000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1280000:98000 1380000:58000 1480000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 380000:53 480000:38 580000:63 780000:69 880000:85 1080000:93 1380000:72 1480000:98"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
    "msm8994" | "msm8994pro" | "msm8994pro-aa"| "msm8994pro-ab" | "msm8994pro-ac" | "msm8992" | "msm8992pro" | "msm8992pro-aa" | "msm8992pro-ab" | "msm8992pro-ac") #sd810/808
	set_value "0:580000 4:480000" $inpboost
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	set_value 0-3,4-5 /dev/cpuset/foreground/cpus
	set_value 0-3,4-5 /dev/cpuset/top-app/cpus
	
	set_param cpu0 above_hispeed_delay "98000 1280000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 580000:27 680000:48 780000:68 880000:82 1180000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1180000:98000 1380000:18000"
	set_param cpu$bcores hispeed_freq 880000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 580000:49 680000:40 780000:58 880000:94 1180000:98"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
    "msm8974" | "msm8974pro-ab" | "msm8974pro-aa" | "msm8974pro-ac" | "msm8974pro" | "apq8084")  #sd800-801-805
    

	stop mpdecision

	setprop ro.qualcomm.perf.cores_online 2
	set_value "380000" $inpboost

	set_param cpu0 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:6 580000:25 680000:43 880000:61 980000:86 1180000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 97
	set_param cpu$bcores target_loads "80 380000:6 580000:25 680000:43 880000:61 980000:86 1180000:97"
	set_param cpu$bcores min_sample_time 18000
	
	
	start mpdecision
	;;
	esac
	
	case "$SOC" in
    "sdm660" | "sda660") #sd660

	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value "0:880000 4:1380000" $inpboost

	set_param cpu0 above_hispeed_delay "38000 1380000:98000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:45 1080000:64 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1080000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 1680000:98"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
    "msm8956" | "msm8976" | "msm8976sg")  #sd652/650
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_value "0:680000 4:880000" $inpboost

	set_param cpu0 above_hispeed_delay "98000 1380000:78000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 95
	set_param cpu0 target_loads "80 680000:58 980000:68 1280000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1280000:38000 1380000:18000 1580000:98000"
	set_param cpu$bcores hispeed_freq 1080000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 880000:51 980000:69 1080000:90 1280000:72 1380000:94 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
    "sdm636" | "sda636" ) #sd636
	set_value "0:880000 4:1380000" $inpboost
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "18000 1380000:78000 1480000:98000 1580000:38000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:62 1080000:98 1380000:84 1480000:97"
	set_param cpu0 min_sample_time 58000
	set_param cpu$bcores above_hispeed_delay "18000 1680000:98000"
	set_param cpu$bcores hispeed_freq 1080000
	set_param cpu$bcores go_hispeed_load 86
	set_param cpu$bcores target_loads "80 1380000:84 1680000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"msm8953" | "msm8953pro")  #sd625/626
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate

	set_value "0:980000" $inpboost
	
	set_param cpu0 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 94
	set_param cpu0 target_loads "80 980000:66 1380000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores go_hispeed_load 94
	set_param cpu$bcores target_loads "80 980000:66 1380000:96"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"universal8895" | "exynos8895")  #EXYNOS8895 (S8)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "38000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 82
	set_param cpu0 target_loads "80 680000:27 780000:39 880000:61 980000:68 1380000:98 1680000:94"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 780000:73 880000:79 980000:55 1080000:69 1180000:84 1380000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"universal8890" | "exynos8890")  #EXYNOS8890 (S7)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "38000 1280000:18000 1480000:98000 1580000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 96
	set_param cpu0 target_loads "80 480000:51 680000:28 780000:56 880000:63 1080000:71 1180000:75 1280000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1480000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1280000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 780000:4 880000:77 980000:14 1080000:90 1180000:68 1280000:92 1480000:96"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"universal7420" | "exynos7420") #EXYNOS7420 (S6)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "38000 1280000:78000 1380000:98000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 96
	set_param cpu0 target_loads "80 480000:28 580000:19 680000:37 780000:51 880000:61 1080000:83 1180000:66 1280000:91 1380000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1480000
	set_param cpu$bcores go_hispeed_load 97
	set_param cpu$bcores target_loads "80 880000:74 980000:56 1080000:80 1180000:92 1380000:85 1480000:93 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"kirin970")  # Huawei Kirin 970
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "18000 1380000:38000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 980000:60 1180000:87 1380000:70 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1580000:98000 1780000:138000"
	set_param cpu$bcores hispeed_freq 1280000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 1280000:98 1480000:91 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
	"kirin960" | "kirin960s")  # Huawei Kirin 960
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "38000 1680000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:93 1380000:97"
	set_param cpu0 min_sample_time 58000
	set_param cpu$bcores above_hispeed_delay "18000 1780000:138000"
	set_param cpu$bcores hispeed_freq 880000
	set_param cpu$bcores go_hispeed_load 84
	set_param cpu$bcores target_loads "80 1380000:98"
	set_param cpu$bcores min_sample_time 38000
	
	;;
	esac
	
	case "$SOC" in
	"kirin950" | "kirin955") # Huawei Kirin 950
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:62 980000:71 1280000:77 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1480000:98000 1780000:138000"
	set_param cpu$bcores hispeed_freq 780000
	set_param cpu$bcores go_hispeed_load 80
	set_param cpu$bcores target_loads "80 1180000:89 1480000:98"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
	"mt6797t" | "mt6797") #Helio X25 / X20	 
	set_value 90 /proc/hps/up_threshold
	set_value "2 2 0" /proc/hps/num_base_perf_serv
	
	set_value 40 /proc/hps/down_threshold
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	set_value 0-3,4-7,8 /dev/cpuset/foreground/cpus
	set_value 0-3,4-7,8 /dev/cpuset/top-app/cpus

	set_param cpu0 above_hispeed_delay "18000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 94
	set_param cpu0 target_loads "80 380000:15 480000:25 780000:36 880000:80 980000:66 1180000:91 1280000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1380000:98000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 94
	set_param cpu$bcores target_loads "80 380000:15 480000:25 780000:36 880000:80 980000:66 1180000:91 1280000:96"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
	"mt6795") #Helio X10
	
	set_value 90 /proc/hps/up_threshold
	set_value 2 /proc/hps/num_base_perf_serv
	
	set_value 40 /proc/hps/down_threshold
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "38000 1280000:18000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:51 1180000:65 1280000:83 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "38000 1280000:18000 1480000:98000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 780000:51 1180000:65 1280000:83 1480000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
    case "$SOC" in
    "moorefield") # Intel Atom
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 95
	set_param cpu0 target_loads "80 580000:56 680000:44 780000:33 880000:48 980000:62 1080000:74 1280000:89 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1480000:98000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 95
	set_param cpu$bcores target_loads "80 580000:56 680000:44 780000:33 880000:48 980000:62 1080000:74 1280000:89 1480000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
    esac
	
    case "$SOC" in
	"msm8939" | "msm8939v2")  #sd615/616
	logdata "#  *WARNING* $PROFILE_M profile governor tweaks are not available for your device"

    esac
	
    case "$SOC" in
	"kirin650")  #sd615/616
	logdata "#  *WARNING* $PROFILE_M profile governor tweaks are not available for your device"

    esac

	if [ -e "/sys/module/lazyplug" ]; then
	write /sys/module/lazyplug/parameters/cpu_nr_run_theshold '1250'
	write /sys/module/lazyplug/parameters/cpu_nr_hysteresis '5'
	write /sys/module/lazyplug/parameters/nr_run_profile_sel '0'
	fi

	elif [ $PROFILE -eq 1 ];then

	 case "$SOC" in
    "msm8998" | "apq8098" | "apq8098_latv") #sd835
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value "0:380000 4:380000" $inpboost

	set_param cpu0 above_hispeed_delay "18000 1580000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:30 480000:41 580000:29 680000:4 780000:60 1180000:88 1280000:70 1380000:78 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1380000:78000 1480000:18000 1580000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1280000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 380000:39 580000:58 780000:63 980000:81 1080000:92 1180000:77 1280000:98 1380000:86 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
    "msm8996" | "msm8996pro" | "msm8996au" |  "msm8996sg" | "msm8996pro-aa"| "msm8996pro-ab" | "msm8996pro-ac" | "apq8096" | "apq8096_latv") #sd820
	set_value "0:380000 2:380000" $inpboost
	
	set_value 1 /dev/cpuset/background/cpus
	set_value 0-1 /dev/cpuset/system-background/cpus
	set_value 0-1,2-3 /dev/cpuset/foreground/cpus
	set_value 0-1,2-3 /dev/cpuset/top-app/cpus
	
	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate

	set_param cpu0 above_hispeed_delay "58000 1280000:98000 1580000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:9 580000:36 780000:62 880000:71 980000:87 1080000:75 1180000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "38000 1480000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 380000:39 480000:35 680000:29 780000:63 880000:71 1180000:91 1380000:83 1480000:98"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
    "msm8994" | "msm8994pro" | "msm8994pro-aa"| "msm8994pro-ab" | "msm8994pro-ac" | "msm8992" | "msm8992pro" | "msm8992pro-aa" | "msm8992pro-ab" | "msm8992pro-ac") #sd810/808
	set_value "0:580000 4:480000" $inpboost
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	set_value 0-3,4-5 /dev/cpuset/foreground/cpus
	set_value 0-3,4-5 /dev/cpuset/top-app/cpus
	
	set_param cpu0 above_hispeed_delay "98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 580000:59 680000:54 780000:63 880000:85 1180000:98 1280000:94"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "18000 1180000:98000"
	set_param cpu$bcores hispeed_freq 880000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 580000:64 680000:58 780000:19 880000:97"
	set_param cpu$bcores min_sample_time 78000
	;;
	esac
	
	case "$SOC" in
    "msm8974" | "msm8974pro-ab" | "msm8974pro-aa" | "msm8974pro-ac" | "msm8974pro" | "apq8084")  #sd800-801-805
    

	stop mpdecision

	setprop ro.qualcomm.perf.cores_online 2
	set_value "380000" $inpboost

	set_param cpu0 above_hispeed_delay "38000 1480000:78000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:32 580000:47 680000:82 880000:32 980000:39 1180000:83 1480000:79 1680000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "38000 1480000:78000 1680000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 97
	set_param cpu$bcores target_loads "80 380000:32 580000:47 680000:82 880000:32 980000:39 1180000:83 1480000:79 1680000:98"
	set_param cpu$bcores min_sample_time 18000
	
	
	start mpdecision
	;;
	esac
	
	case "$SOC" in
    "sdm660" | "sda660") #sd660

	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value "0:880000 4:1380000" $inpboost

	set_param cpu0 above_hispeed_delay "98000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:59 1080000:90 1380000:78 1480000:98"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1080000
	set_param cpu$bcores go_hispeed_load 83
	set_param cpu$bcores target_loads "80 1380000:70 1680000:98"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
    "msm8956" | "msm8976" | "msm8976sg")  #sd652/650
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_value "0:680000 4:880000" $inpboost

	set_param cpu0 above_hispeed_delay "98000 1380000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 680000:68 780000:60 980000:97 1180000:63 1280000:97 1380000:84"
	set_param cpu0 min_sample_time 58000
	set_param cpu$bcores above_hispeed_delay "18000 1580000:98000"
	set_param cpu$bcores hispeed_freq 1280000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 880000:47 980000:68 1280000:74 1380000:92 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
    "sdm636" | "sda636" ) #sd636
	set_value "0:880000 4:1380000" $inpboost
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "18000 1380000:78000 1480000:98000 1580000:78000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:62 1080000:94 1380000:75 1480000:96"
	set_param cpu0 min_sample_time 58000
	set_param cpu$bcores above_hispeed_delay "18000 1680000:98000"
	set_param cpu$bcores hispeed_freq 1080000
	set_param cpu$bcores go_hispeed_load 81
	set_param cpu$bcores target_loads "80 1380000:70 1680000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"msm8953" | "msm8953pro")  #sd625/626
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate

	set_value "0:980000" $inpboost
	
	set_param cpu0 above_hispeed_delay "98000 1880000:138000"
	set_param cpu0 hispeed_freq 1680000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:63 1380000:72 1680000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1680000
	set_param cpu$bcores go_hispeed_load 97
	set_param cpu$bcores target_loads "80 980000:63 1380000:72 1680000:97"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"universal8895" | "exynos8895")  #EXYNOS8895 (S8)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "38000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:53 880000:70 980000:50 1180000:71 1380000:97 1680000:92"
	set_param cpu0 min_sample_time 58000
	set_param cpu$bcores above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 780000:40 880000:34 980000:66 1080000:31 1180000:72 1380000:86 1680000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"universal8890" | "exynos8890")  #EXYNOS8890 (S7)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "18000 1280000:38000 1480000:98000 1580000:18000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 480000:49 680000:34 780000:61 880000:33 980000:63 1080000:69 1180000:77 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1580000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores go_hispeed_load 93
	set_param cpu$bcores target_loads "80 780000:33 880000:67 980000:42 1080000:75 1180000:65 1280000:74 1480000:97"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"universal7420" | "exynos7420") #EXYNOS7420 (S6)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "58000 1280000:18000 1380000:98000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 480000:29 580000:12 680000:69 780000:22 880000:36 1080000:80 1180000:89 1480000:63"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "18000 1480000:78000 1580000:98000 1880000:138000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores go_hispeed_load 96
	set_param cpu$bcores target_loads "80 880000:27 980000:44 1080000:71 1180000:32 1280000:64 1380000:78 1480000:87 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"kirin970")  # Huawei Kirin 970
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "18000 1480000:38000 1680000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:61 1180000:88 1380000:70 1480000:96"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "18000 1580000:98000 1780000:138000"
	set_param cpu$bcores hispeed_freq 1280000
	set_param cpu$bcores go_hispeed_load 94
	set_param cpu$bcores target_loads "80 980000:72 1280000:77 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
	"kirin960" | "kirin960s")  # Huawei Kirin 960
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "38000 1680000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:97 1380000:78 1680000:98"
	set_param cpu0 min_sample_time 78000
	set_param cpu$bcores above_hispeed_delay "18000 1380000:98000 1780000:138000"
	set_param cpu$bcores hispeed_freq 880000
	set_param cpu$bcores go_hispeed_load 95
	set_param cpu$bcores target_loads "80 1380000:59 1780000:98"
	set_param cpu$bcores min_sample_time 38000
	
	;;
	esac
	
	case "$SOC" in
	"kirin950" | "kirin955") # Huawei Kirin 950
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 780000:69 980000:76 1280000:80 1480000:96"
	set_param cpu0 min_sample_time 58000
	set_param cpu$bcores above_hispeed_delay "18000 1780000:138000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 80
	set_param cpu$bcores target_loads "80 1180000:75 1480000:93 1780000:98"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
	"mt6797t" | "mt6797") #Helio X25 / X20	 
	set_value 80 /proc/hps/up_threshold
	set_value "3 3 0" /proc/hps/num_base_perf_serv
	
	set_value 40 /proc/hps/down_threshold
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	set_value 0-3,4-7,8 /dev/cpuset/foreground/cpus
	set_value 0-3,4-7,8 /dev/cpuset/top-app/cpus

	set_param cpu0 above_hispeed_delay "18000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 93
	set_param cpu0 target_loads "80 380000:8 580000:14 680000:9 780000:41 880000:56 1080000:65 1180000:92 1380000:85 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1380000:98000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 93
	set_param cpu$bcores target_loads "80 380000:8 580000:14 680000:9 780000:41 880000:56 1080000:65 1180000:92 1380000:85 1480000:97"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
	"mt6795") #Helio X10
	
	set_value 80 /proc/hps/up_threshold
	set_value 3 /proc/hps/num_base_perf_serv
	
	set_value 40 /proc/hps/down_threshold
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:60 1180000:86 1280000:79 1480000:97"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "18000 1480000:98000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 780000:60 1180000:86 1280000:79 1480000:97"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
    case "$SOC" in
    "moorefield") # Intel Atom
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 580000:53 680000:38 880000:49 980000:60 1180000:65 1280000:82 1380000:63 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1480000:98000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 580000:53 680000:38 880000:49 980000:60 1180000:65 1280000:82 1380000:63 1480000:97"
	set_param cpu$bcores min_sample_time 18000
	;;
    esac
	
    case "$SOC" in
	"msm8939" | "msm8939v2")  #sd615/616 by@ 橘猫520
	set_param cpu$bcores hispeed_freq 400000
	set_param cpu0 hispeed_freq 883000
	set_param cpu$bcores target_loads "98 40000:40 499000:80 533000:95 800000:75 998000:99"
	set_param cpu0 target_loads "98 883000:40 1036000:80 1113000:95 1267000:99"
	set_param cpu$bcores above_hispeed_delay "20000 499000:60000 533000:150000"
	set_param cpu0 above_hispeed_delay "20000 1036000:60000 1130000:150000"
	set_param cpu0 min_sample_time 40000
	set_param cpu$bcores min_sample_time 10000
	set_param cpu$bcores go_hispeed_load 99
	set_param cpu0 go_hispeed_load 99
	set_param cpu$bcores boostpulse_duration 80000
	set_param cpu0 boostpulse_duration 80000
	set_param cpu$bcores use_sched_load 1
	set_param cpu0 use_sched_load 1
	set_param cpu$bcores use_migration_notif 1
	set_param cpu0 use_migration_notif 1
	set_param cpu$bcores boost 0
	set_param cpu0 boost 0
    esac
	
    case "$SOC" in
	"kirin650" | "kirin655" | "kirin658" | "kirin659")  #KIRIN650 by @橘猫520
	set_param cpu0 hispeed_freq 807000
	set_param cpu$bcores hispeed_freq 1402000
	set_param cpu0 target_loads "98 480000:75 807000:95 1306000:99"
	set_param cpu$bcores target_loads "98 1402000:95"
	set_param cpu0 above_hispeed_delay "20000 480000:60000 807000:150000"
	set_param cpu$bcores above_hispeed_delay "20000 1402000:160000"
	set_param cpu$bcores min_sample_time 50000
	set_param cpu0 min_sample_time 50000
	set_param cpu$bcores boost 0
	set_param cpu0 boost 0
	set_param cpu$bcores go_hispeed_load 99
	set_param cpu0 go_hispeed_load 99
	set_param cpu$bcores boostpulse_duration 80000
	set_param cpu0 boostpulse_duration 80000
	set_param cpu$bcores use_sched_load 1
	set_param cpu0 use_sched_load 1
	set_param cpu$bcores use_migration_notif 1
	set_param cpu0 use_migration_notif 1
    esac
	
    case "$SOC" in
    "universal9810" | "exynos9810") # S9 exynos_9810 by @橘猫520
	set_param cpu0 boostpulse_duration 4000
	set_param cpu$bcores boostpulse_duration 4000
	set_param cpu0 boost 1
	set_param cpu$bcores boost 1
	set_param cpu0 timer_rate 20000
	set_param cpu$bcores timer_rate 20000
	set_param cpu0 timer_slack 10000
	set_param cpu$bcores timer_slack 10000
	set_param cpu0 min_sample_time 12000
	set_param cpu$bcores min_sample_time 12000
	set_param cpu0 io_is_busy 0
	set_param cpu$bcores io_is_busy 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu$bcores ignore_hispeed_on_notif 0
	set_param cpu$bcores go_hispeed_load 73
	set_param cpu0 go_hispeed_load 65
	set_param cpu$bcores hispeed_freq 1066000
	set_param cpu0 hispeed_freq 715000
	set_param cpu$bcores above_hispeed_delay "4000 741000:77000 962000:99000 1170000:110000 1469000:130000 1807000:140000 2002000:1500000 2314000:160000 2496000:171000 2652000:184000 2704000:195000"
	set_param cpu0 above_hispeed_delay "4000 455000:77000 715000:95000 1053000:110000 1456000:130000 1690000:1500000 1794000:163000"
	set_param cpu$bcores target_loads "55 741000:44 962000:51 1170000:58 1469000:66 1807000:73 2002000:82 2314000:89 2496000:93 2652000:97 2704000:100"
	set_param cpu0 target_loads "45 455000:48 715000:68 949000:71 1248000:86 1690000:91 1794000:100"
	
	;;
    esac
	
	elif [ $PROFILE -eq 2 ];then
	
    case "$SOC" in
    "msm8998" | "apq8098" | "apq8098_latv") #sd835
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value "0:380000 4:380000" $inpboost

	set_param cpu0 above_hispeed_delay "18000 1580000:98000 1780000:38000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:42 580000:80 680000:15 980000:36 1080000:9 1180000:90 1280000:59 1480000:88 1680000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1580000:98000 1880000:38000"
	set_param cpu$bcores hispeed_freq 1280000
	set_param cpu$bcores go_hispeed_load 94
	set_param cpu$bcores target_loads "80 380000:44 480000:19 680000:54 780000:63 980000:54 1080000:63 1280000:71 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
    "msm8996" | "msm8996pro" | "msm8996au" |  "msm8996sg" | "msm8996pro-aa"| "msm8996pro-ab" | "msm8996pro-ac" | "apq8096" | "apq8096_latv") #sd820
	set_value "0:380000 2:380000" $inpboost
	
	set_value 1 /dev/cpuset/background/cpus
	set_value 0-1 /dev/cpuset/system-background/cpus
	set_value 0-1,2-3 /dev/cpuset/foreground/cpus
	set_value 0-1,2-3 /dev/cpuset/top-app/cpus
	
	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate

	set_param cpu0 above_hispeed_delay "18000 1280000:98000 1480000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:7 480000:31 580000:13 680000:58 780000:63 980000:73 1180000:98"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "18000 1580000:98000 1880000:38000"
	set_param cpu$bcores hispeed_freq 1480000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 380000:34 680000:40 780000:63 880000:57 1080000:72 1380000:78 1480000:98"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
    "msm8994" | "msm8994pro" | "msm8994pro-aa"| "msm8994pro-ab" | "msm8994pro-ac" | "msm8992" | "msm8992pro" | "msm8992pro-aa" | "msm8992pro-ab" | "msm8992pro-ac") #sd810/808
	set_value "0:580000 4:480000" $inpboost
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	set_value 0-3,4-5 /dev/cpuset/foreground/cpus
	set_value 0-3,4-5 /dev/cpuset/top-app/cpus
	
	set_value 85 /proc/sys/kernel/sched_downmigrate
	set_value 99 /proc/sys/kernel/sched_upmigrate

	set_value 0 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus

	set_param cpu0 above_hispeed_delay "38000 1280000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 580000:63 680000:54 780000:60 880000:32 1180000:98 1280000:93"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "78000 1280000:38000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 480000:44 580000:65 680000:61 780000:20 880000:90 1180000:74 1280000:98"
	set_param cpu$bcores min_sample_time 78000
	;;
	esac
	
	case "$SOC" in
    "msm8974" | "msm8974pro-ab" | "msm8974pro-aa" | "msm8974pro-ac" | "msm8974pro" | "apq8084")  #sd800-801-805
    

	stop mpdecision

	setprop ro.qualcomm.perf.cores_online 2
	set_value "380000" $inpboost

	set_param cpu0 above_hispeed_delay "18000 1480000:98000 1880000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:32 580000:45 680000:81 880000:63 980000:47 1180000:89 1480000:79 1680000:98"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "18000 1480000:98000 1880000:38000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 97
	set_param cpu$bcores target_loads "80 380000:32 580000:45 680000:81 880000:63 980000:47 1180000:89 1480000:79 1680000:98"
	set_param cpu$bcores min_sample_time 38000
		
	start mpdecision
	;;
	esac
	
	case "$SOC" in
    "sdm660" | "sda660") #sd660

	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value "0:880000 4:1380000" $inpboost

	set_param cpu0 above_hispeed_delay "18000 1380000:98000 1680000:38000"
	set_param cpu0 hispeed_freq 880000
	set_param cpu0 go_hispeed_load 89
	set_param cpu0 target_loads "80 880000:60 1080000:80 1380000:54 1480000:98"
	set_param cpu0 min_sample_time 78000
	set_param cpu$bcores above_hispeed_delay "18000 1380000:78000 1680000:98000 1880000:38000"
	set_param cpu$bcores hispeed_freq 1080000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 1380000:65 1680000:98"
	set_param cpu$bcores min_sample_time 78000
	
	;;
	esac
	
	case "$SOC" in
    "msm8956" | "msm8976" | "msm8976sg")  #sd652/650
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_value "0:680000 4:880000" $inpboost

	set_param cpu0 above_hispeed_delay "98000 1280000:38000 1380000:78000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 96
	set_param cpu0 target_loads "80 680000:90 780000:57 980000:61 1180000:96 1380000:7"
	set_param cpu0 min_sample_time 78000
	set_param cpu$bcores above_hispeed_delay "98000 1680000:38000"
	set_param cpu$bcores hispeed_freq 1580000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 880000:47 1080000:52 1180000:63 1280000:71 1380000:76 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
    "sdm636" | "sda636" ) #sd636
	set_value "0:880000 4:1380000" $inpboost
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "18000 1380000:98000 1480000:38000"
	set_param cpu0 hispeed_freq 880000
	set_param cpu0 go_hispeed_load 85
	set_param cpu0 target_loads "80 880000:59 1080000:77 1380000:52 1480000:98 1580000:94"
	set_param cpu0 min_sample_time 78000
	set_param cpu$bcores above_hispeed_delay "18000 1380000:78000 1680000:38000"
	set_param cpu$bcores hispeed_freq 1080000
	set_param cpu$bcores go_hispeed_load 89
	set_param cpu$bcores target_loads "80 1380000:64 1680000:98"
	set_param cpu$bcores min_sample_time 78000
	;;
	esac
	
	case "$SOC" in
	"msm8953" | "msm8953pro")  #sd625/626
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate

	set_value "0:980000" $inpboost
	
	set_param cpu0 above_hispeed_delay "18000 1680000:98000 1880000:38000"
	set_param cpu0 hispeed_freq 980000
	set_param cpu0 go_hispeed_load 89
	set_param cpu0 target_loads "80 980000:55 1380000:75 1680000:98"
	set_param cpu0 min_sample_time 78000
	set_param cpu$bcores above_hispeed_delay "18000 1680000:98000 1880000:38000"
	set_param cpu$bcores hispeed_freq 980000
	set_param cpu$bcores go_hispeed_load 89
	set_param cpu$bcores target_loads "80 980000:55 1380000:75 1680000:98"
	set_param cpu$bcores min_sample_time 78000
	;;
	esac
	
	case "$SOC" in
	"universal8895" | "exynos8895")  #EXYNOS8895 (S8)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 780000:31 880000:62 980000:42 1180000:69 1380000:95 1680000:78"
	set_param cpu0 min_sample_time 58000
	set_param cpu$bcores above_hispeed_delay "18000 1680000:98000 1880000:38000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores go_hispeed_load 96
	set_param cpu$bcores target_loads "80 780000:22 880000:3 980000:14 1080000:34 1180000:47 1380000:63 1680000:72 1780000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"universal8890" | "exynos8890")  #EXYNOS8890 (S7)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "18000 1480000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 480000:54 780000:61 880000:24 980000:63 1080000:57 1180000:81 1280000:71 1480000:96 1580000:87"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "18000 1580000:98000 1880000:38000"
	set_param cpu$bcores hispeed_freq 1480000
	set_param cpu$bcores go_hispeed_load 90
	set_param cpu$bcores target_loads "80 780000:6 880000:37 980000:59 1180000:42 1280000:67 1580000:96"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"universal7420" | "exynos7420") #EXYNOS7420 (S6)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "18000 1280000:98000 1380000:38000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 480000:26 580000:32 680000:69 780000:50 880000:15 1080000:80 1180000:85 1480000:56"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "18000 880000:38000 980000:58000 1080000:18000 1180000:38000 1280000:18000 1480000:78000 1580000:98000 1880000:38000"
	set_param cpu$bcores hispeed_freq 780000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 880000:4 980000:29 1080000:57 1280000:66 1480000:44 1580000:66 1680000:98"
	set_param cpu$bcores min_sample_time 18000
	;;
	esac
	
	case "$SOC" in
	"kirin970")  # Huawei Kirin 970
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "18000 1680000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 980000:63 1180000:76 1480000:96"
	set_param cpu0 min_sample_time 78000
	set_param cpu$bcores above_hispeed_delay "18000 1580000:98000 1780000:38000"
	set_param cpu$bcores hispeed_freq 1480000
	set_param cpu$bcores go_hispeed_load 86
	set_param cpu$bcores target_loads "80 980000:57 1280000:70 1480000:65 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
	"kirin960" | "kirin960s")  # Huawei Kirin 960
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "38000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:58 1380000:75 1680000:98"
	set_param cpu0 min_sample_time 78000
	set_param cpu$bcores above_hispeed_delay "18000 1380000:38000 1780000:138000"
	set_param cpu$bcores hispeed_freq 880000
	set_param cpu$bcores go_hispeed_load 93
	set_param cpu$bcores target_loads "80 1380000:59 1780000:97"
	set_param cpu$bcores min_sample_time 38000
	
	;;
	esac
	
	case "$SOC" in
	"kirin950" | "kirin955") # Huawei Kirin 950
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_param cpu0 above_hispeed_delay "18000 1480000:38000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 780000:66 980000:17 1280000:81 1480000:96 1780000:87"
	set_param cpu0 min_sample_time 78000
	set_param cpu$bcores above_hispeed_delay "18000 1780000:138000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 80
	set_param cpu$bcores target_loads "80 1180000:65 1480000:85 1780000:96"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
	"mt6797t" | "mt6797") #Helio X25 / X20	 
	set_value 70 /proc/hps/up_threshold
	set_value "3 3 1" /proc/hps/num_base_perf_serv
	
	set_value 40 /proc/hps/down_threshold
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	set_value 0-3,4-7,8 /dev/cpuset/foreground/cpus
	set_value 0-3,4-7,8 /dev/cpuset/top-app/cpus

	set_param cpu0 above_hispeed_delay "18000 1380000:58000 1480000:98000 1680000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 85
	set_param cpu0 target_loads "80 380000:10 780000:57 1080000:27 1180000:65 1280000:82 1380000:6 1480000:80 1580000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "18000 1380000:58000 1480000:98000 1680000:38000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores go_hispeed_load 85
	set_param cpu$bcores target_loads "80 380000:10 780000:57 1080000:27 1180000:65 1280000:82 1380000:6 1480000:80 1580000:98"
	set_param cpu$bcores min_sample_time 18000
	
	;;
	esac
	
	case "$SOC" in
	"mt6795") #Helio X10
	
	set_value 70 /proc/hps/up_threshold
	set_value 3 /proc/hps/num_base_perf_serv
	
	set_value 40 /proc/hps/down_threshold
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_param cpu0 above_hispeed_delay "38000 1580000:98000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:61 1180000:65 1280000:83 1480000:63 1580000:96"
	set_param cpu0 min_sample_time 38000
	set_param cpu$bcores above_hispeed_delay "38000 1580000:98000"
	set_param cpu$bcores hispeed_freq 1480000
	set_param cpu$bcores go_hispeed_load 98
	set_param cpu$bcores target_loads "80 780000:61 1180000:65 1280000:83 1480000:63 1580000:96"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
    case "$SOC" in
    "moorefield") # Intel Atom
	set_param cpu0 above_hispeed_delay "38000 1580000:98000 1680000:38000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 95
	set_param cpu0 target_loads "80 580000:59 680000:36 780000:75 880000:39 1080000:56 1380000:52 1480000:57 1580000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu$bcores above_hispeed_delay "38000 1580000:98000 1680000:38000"
	set_param cpu$bcores hispeed_freq 1480000
	set_param cpu$bcores go_hispeed_load 95
	set_param cpu$bcores target_loads "80 580000:59 680000:36 780000:75 880000:39 1080000:56 1380000:52 1480000:57 1580000:97"
	set_param cpu$bcores min_sample_time 18000
	;;
    esac
	
    case "$SOC" in
	"msm8939" | "msm8939v2")  #sd615/616
	logdata "#  *WARNING* $PROFILE_M profile governor tweaks are not available for your device"

    esac
	
    case "$SOC" in
	"kirin650")  #sd615/616
	logdata "#  *WARNING* $PROFILE_M profile governor tweaks are not available for your device"

    esac
	
	elif [ $PROFILE -eq 3 ];then
    

case "$SOC" in
    "msm8998" | "apq8098" | "apq8098_latv") #sd835
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value "0:1480000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1480000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1780000:198000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 target_loads "80 1880000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq

	set_param cpu$bcores above_hispeed_delay "18000 1880000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
    "msm8996" | "msm8996pro" | "msm8996au" |  "msm8996sg" | "msm8996pro-aa"| "msm8996pro-ab" | "msm8996pro-ac" | "apq8096" | "apq8096_latv") #sd820
	
	set_value 1 /dev/cpuset/background/cpus
	set_value 0-1 /dev/cpuset/system-background/cpus
	set_value 0-1,2-3 /dev/cpuset/foreground/cpus
	set_value 0-1,2-3 /dev/cpuset/top-app/cpus
	set_value "0:1080000 2:1380000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate

	set_value 1080000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1480000:198000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 target_loads "80 1580000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq

	set_param cpu$bcores above_hispeed_delay "18000 1880000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	
	;;
	esac
	
	case "$SOC" in
    "msm8994" | "msm8994pro" | "msm8994pro-aa"| "msm8994pro-ab" | "msm8994pro-ac" | "msm8992" | "msm8992pro" | "msm8992pro-aa" | "msm8992pro-ab" | "msm8992pro-ac") #sd810/808
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	set_value 0-3,4-5 /dev/cpuset/foreground/cpus
	set_value 0-3,4-5 /dev/cpuset/top-app/cpus
	set_value "0:880000 4:880000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 85 /proc/sys/kernel/sched_downmigrate
	set_value 99 /proc/sys/kernel/sched_upmigrate

	set_value 0 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus

	set_value 880000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1180000:198000"
	set_param cpu0 hispeed_freq 880000
	set_param cpu0 target_loads "80 1280000:90"
	set_param cpu0 min_sample_time 38000
	set_value 880000 ${GOV_PATH_B}/scaling_min_freq

	set_param cpu$bcores above_hispeed_delay "18000 1280000:198000"
	set_param cpu$bcores hispeed_freq 880000
	set_param cpu$bcores target_loads "80 1380000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
    "msm8974" | "msm8974pro-ab" | "msm8974pro-aa" | "msm8974pro-ac" | "msm8974pro" | "apq8084")  #sd800-801-805
	stop mpdecision

	setprop ro.qualcomm.perf.cores_online 2
	set_value "0:1480000 4:1480000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1480000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1880000:198000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 target_loads "80 1980000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1480000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1880000:198000"
	set_param cpu$bcores hispeed_freq 1480000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	
	
	start mpdecision
	;;
	esac
	
	case "$SOC" in
    "sdm660" | "sda660") #sd660

	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	set_value "0:1080000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1080000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1680000:198000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1880000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	
	;;
	esac
	
	case "$SOC" in
    "msm8956" | "msm8976" | "msm8976sg")  #sd652/650
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	
	set_value "0:1180000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1180000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1280000:198000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 target_loads "80 1380000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1680000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1780000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
    "sdm636" | "sda636" ) #sd636
	
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	set_value "0:1080000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1080000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1480000:198000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 target_loads "80 1580000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1680000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1780000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
	"msm8953" | "msm8953pro")  #sd625/626
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 

	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate
	set_value "0:1380000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1380000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1880000:198000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 target_loads "80 1980000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1880000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
	"universal8895" | "exynos8895")  #EXYNOS8895 (S8)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	set_value "0:1180000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1180000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1380000:198000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 target_loads "80 1680000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1880000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
	"universal8890" | "exynos8890")  #EXYNOS8890 (S7)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	set_value "0:1280000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1280000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1480000:198000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 target_loads "80 1580000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1880000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
	"universal7420" | "exynos7420") #EXYNOS7420 (S6)
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	set_value "0:1280000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1280000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1380000:198000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 target_loads "80 1480000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1880000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
	"kirin970")  # Huawei Kirin 970
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	set_value "0:1480000 4:1280000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1480000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1680000:198000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1280000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1780000:198000"
	set_param cpu$bcores hispeed_freq 1280000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	
	;;
	esac
	
	case "$SOC" in
	"kirin960" | "kirin960s")  # Huawei Kirin 960
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	set_value "0:1380000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1380000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1680000:198000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1780000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	
	;;
	esac
	
	case "$SOC" in
	"kirin950" | "kirin955") # Huawei Kirin 950
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	set_value "0:1480000 4:1180000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1480000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1480000:198000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1180000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1780000:198000"
	set_param cpu$bcores hispeed_freq 1180000
	set_param cpu$bcores target_loads "80 1980000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
	case "$SOC" in
	"mt6797t" | "mt6797") #Helio X25 / X20	 
	set_value 60 /proc/hps/up_threshold
	set_value "4 4 1" /proc/hps/num_base_perf_serv
	
	set_value 40 /proc/hps/down_threshold
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	set_value 0-3,4-7,8 /dev/cpuset/foreground/cpus
	set_value 0-3,4-7,8 /dev/cpuset/top-app/cpus
	set_value "0:1280000 4:1280000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1280000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1680000:198000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1280000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1680000:198000"
	set_param cpu$bcores hispeed_freq 1280000
	set_param cpu$bcores target_loads "80 1780000:90"
	set_param cpu$bcores min_sample_time 38000
	
	;;
	esac
	
	case "$SOC" in
	"mt6795") #Helio X10
	
	set_value 60 /proc/hps/up_threshold
	set_value 4 /proc/hps/num_base_perf_serv
	
	set_value 40 /proc/hps/down_threshold
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write  /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/foreground/cpus "0-3,4-7" 
	set_value "0:1280000 4:1280000" /sys/module/msm_performance/parameters/cpu_min_freq

	set_value 1280000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1580000:198000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 target_loads "80 1880000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1280000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1580000:198000"
	set_param cpu$bcores hispeed_freq 1280000
	set_param cpu$bcores target_loads "80 1880000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
	esac
	
    case "$SOC" in
    "moorefield") # Intel Atom
	set_value "0:1380000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1380000 ${GOV_PATH_L}/scaling_min_freq
	set_param cpu0 above_hispeed_delay "18000 1680000:198000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 target_loads "80 1780000:90"
	set_param cpu0 min_sample_time 38000
	set_value 1380000 ${GOV_PATH_B}/scaling_min_freq
	set_param cpu$bcores above_hispeed_delay "18000 1680000:198000"
	set_param cpu$bcores hispeed_freq 1380000
	set_param cpu$bcores target_loads "80 1780000:90"
	set_param cpu$bcores min_sample_time 38000
	;;
    esac
	
    case "$SOC" in
	"msm8939" | "msm8939v2")  #sd615/616
	logdata "#  *WARNING* $PROFILE_M profile governor tweaks are not available for your device"

    esac
	
    case "$SOC" in
	"kirin650")  #sd615/616
	logdata "#  *WARNING* $PROFILE_M profile governor tweaks are not available for your device"
    esac

    fi

after_modify
 
# =========
# HMP Scheduler Tweaks
# =========

set_value 90 /proc/sys/kernel/sched_spill_load
set_value 0 /proc/sys/kernel/sched_boost
set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
set_value 40 /proc/sys/kernel/sched_init_task_load
set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify

write /proc/sys/kernel/sched_window_stats_policy 2
#write /proc/sys/kernel/sched_select_prev_cpu_us 1000
write /proc/sys/kernel/sched_spill_nr_run 3
#write /proc/sys/kernel/sched_restrict_cluster_spill 1
#write /proc/sys/kernel/sched_upmigrate 45
#write /proc/sys/kernel/sched_downmigrate 25


#if [ -e "/proc/sys/kernel/sched_heavy_task" ]; then
#    write /proc/sys/kernel/sched_heavy_task 0
#fi
#write /proc/sys/kernel/sched_upmigrate_min_nice 15
write /proc/sys/kernel/sched_ravg_hist_size 4
#if [ -e "/proc/sys/kernel/sched_small_wakee_task_load" ]; then
#write /proc/sys/kernel/sched_small_wakee_task_load 65
#fi
#if [ -e "/proc/sys/kernel/sched_wakeup_load_threshold" ]; then
#write /proc/sys/kernel/sched_wakeup_load_threshold 110
#fi
#if [ -e "/proc/sys/kernel/sched_small_task" ]; then
#write /proc/sys/kernel/sched_small_task 10
#fi
if [ -e "/proc/sys/kernel/sched_big_waker_task_load" ]; then
write /proc/sys/kernel/sched_big_waker_task_load 35
fi
if [ -e "/proc/sys/kernel/sched_rt_runtime_us" ]; then
write /proc/sys/kernel/sched_rt_runtime_us 950000
fi
if [ -e "/proc/sys/kernel/sched_rt_period_us" ]; then
write /proc/sys/kernel/sched_rt_period_us 1000000
fi
#if [ -e "/proc/sys/kernel/sched_enable_thread_grouping" ]; then
#write /proc/sys/kernel/sched_enable_thread_grouping 0
#fi
#if [ -e "/proc/sys/kernel/sched_rr_timeslice_ms" ]; then
#write /proc/sys/kernel/sched_rr_timeslice_ms 20
#fi
#if [ -e "/proc/sys/kernel/sched_migration_fixup" ]; then
#write /proc/sys/kernel/sched_migration_fixup 1
#fi
if [ -e "/proc/sys/kernel/sched_enable_power_aware" ]; then
write /proc/sys/kernel/sched_enable_power_aware 1
fi

	fi
	
	# Enable Thermal engine
	enable_bcl

        # Enable power efficient work_queue mode
	if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
	chmod 644 /sys/module/workqueue/parameters/power_efficient 
	write /sys/module/workqueue/parameters/power_efficient 'Y'
	logdata "# Enabling power efficient work queue mode .. DONE" 
	else
	logdata "# *WARNING* Your kernel does not support power efficient work queue mode" 
	fi

	if [ -e "/sys/devices/system/cpu/cpu0/cpufreq/interactive/powersave_bias" ]; then
		set_param cpu0 powersave_bias 1
	fi

}

# =========
# CPU Governor Tuning
# =========
if [ $support -eq 1 ] && [ $error -eq 0 ] ;then
cputuning
else
    logdata "# SoC Check= FAIL - Your device is not supported by LKT"
fi

# Disable KSM to save CPU cycles

if [ -e /sys/kernel/mm/uksm/run ]; then
write /sys/kernel/mm/uksm/run "0";
resetprop -n ro.config.ksm.support false;
elif [ -e /sys/kernel/mm/ksm/run ]; then
write /sys/kernel/mm/ksm/run "0";
resetprop -n ro.config.ksm.support false;
fi;

logdata "#  Governor Tuning  .. DONE" 

# =========
# GPU Tweaks
# =========

if [ -e "/sys/module/adreno_idler" ]; then

if [ $PROFILE -le 1 ];then
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "10000"

	# set GPU default power level to 6 instead of 4 or 5

	if [ $PROFILE -le 1 ];then
	set_value /sys/class/kgsl/kgsl-3d0/default_pwrlevel 6
	fi

else
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "8000"
fi
 logdata "# Enabling GPU adreno Idler .. DONE" 


 else
 logdata "#  *WARNING* Your Kernel does not support Adreno Idler" 
 fi


# =========
# RAM TWEAKS
# =========

ramtuning

# =========
# I/O TWEAKS
# =========

sch=$(</sys/block/mmcblk0/queue/scheduler);

if [[ $sch == *"maple"* ]]
then
	set_io maple /sys/block/mmcblk0
	set_io maple /sys/block/sda
else
	set_io cfq /sys/block/mmcblk0
	set_io cfq /sys/block/sda
fi


for i in /sys/block/loop*; do
	write $i/queue/add_random 0
	write $i/queue/iostats 0
   	write $i/queue/nomerges 1
   	write $i/queue/rotational 0
   	write $i/queue/rq_affinity 1
done

for j in /sys/block/ram*; do
	write $j/queue/add_random 0
	write $j/queue/iostats 0
	write $j/queue/nomerges 1
	write $j/queue/rotational 0
   	write $j/queue/rq_affinity 1
done

for k in /sys/block/sd*; do
	write $k/queue/add_random 0
	write $k/queue/iostats 0
done


logdata "#  Storage I/O Tuning  .. DONE" 


# =========
# TCP TWEAKS
# =========

algos=$(</proc/sys/net/ipv4/tcp_available_congestion_control);
if [[ $algos == *"westwood"* ]]
then
write /proc/sys/net/ipv4/tcp_congestion_control "westwood"
logdata "# Enabling westwood TCP algorithm  .. DONE" 
else
write /proc/sys/net/ipv4/tcp_congestion_control "cubic"

fi

# Increase WI-FI scan delay
# sqlite=/system/xbin/sqlite3 wifi_idle_wait=36000 

logdata "#  Enabling Misc Tweaks .. DONE" 

# =========
# Blocking Wakelocks
# =========

if [ -e "/sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker" ]; then
write /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;[timerfd];hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;"
logdata "#  Enabling Boeffla wake-locks blocker .. DONE" 
fi

if [ -e "/sys/module/wakeup/parameters" ]; then
if [ -e "/sys/module/bcmdhd/parameters/wlrx_divide" ]; then
set_value /sys/module/bcmdhd/parameters/wlrx_divide 8
fi
if [ -e "/sys/module/bcmdhd/parameters/wlctrl_divide" ]; then
set_value /sys/module/bcmdhd/parameters/wlctrl_divide 8
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluetooth_timer" ]; then
set_value /sys/module/wakeup/parameters/enable_bluetooth_timer Y
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ipa_ws" ]; then
set_value /sys/module/wakeup/parameters/enable_wlan_ipa_ws N
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_pno_wl_ws N" ]; then
set_value /sys/module/wakeup/parameters/enable_wlan_pno_wl_ws N
fi
if [ -e "/sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws N" ]; then
set_value /sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws N
fi
if [ -e "/sys/module/wakeup/parameters/wlan_wake" ]; then
set_value N /sys/module/wakeup/parameters/wlan_wake
fi
if [ -e "/sys/module/wakeup/parameters/wlan_ctrl_wake" ]; then
set_value N /sys/module/wakeup/parameters/wlan_ctrl_wake
fi
if [ -e "/sys/module/wakeup/parameters/wlan_rx_wake" ]; then
set_value N /sys/module/wakeup/parameters/wlan_rx_wake
fi
if [ -e "/sys/module/wakeup/parameters/enable_msm_hsic_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_msm_hsic_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_si_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_si_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluedroid_timer_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_bluedroid_timer_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_ipa_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_ipa_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_netlink_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_netlink_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_netmgr_wl_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_netmgr_wl_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_timerfd_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_timerfd_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_rx_wake_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_rx_wake_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wake_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_wake_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wow_wl_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws
fi
logdata "# Enabling kernel Wake-locks Blocking .. DONE" 
else
logdata "# *WARNING* Your kernel does not support wake-lock Blocking" 
fi


# =========
# Google Services Drain fix
# =========

sleep "0.001"
su -c "pm enable com.google.android.gms"
sleep "0.001"
su -c "pm enable com.google.android.gsf"
sleep "0.001"
su -c "pm enable com.google.android.gms/.update.SystemUpdateActivity"
sleep "0.001"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService"
sleep "0.001"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver"
sleep "0.001"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$Receiver"
sleep "0.001"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver"
sleep "0.001"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateActivity"
sleep "0.001"
su -c "pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity"
sleep "0.001"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService"
sleep "0.001"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver"
sleep "0.001"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver"

# FS-TRIM

fstrim -v /cache
fstrim -v /data
fstrim -v /system

logdata "#  FS-TRIM .. DONE" 

start perfd

# =========
# Battery Check
# =========

logdata "# ==============================" 
logdata "#  Battery Technology: $BATT_TECH"
logdata "#  Battery Health: $BATT_HLTH"
logdata "#  Battery Temp: $BATT_TEMP °C"
logdata "#  Battery Voltage: $BATT_VOLT Volts "
logdata "#  Battery Level: $BATT_LEV % "
logdata "# ==============================" 
logdata "#  Finished : $(date +"%d-%m-%Y %r")" 

logdata "" 
logdata "#  NOTE : WARNINGS ARE NORMAL"

exit 0

