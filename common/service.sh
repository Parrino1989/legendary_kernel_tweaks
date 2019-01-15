#!/system/bin/sh
# =======================================================#
# Codename: LKT
# Author: korom42 @ XDA
# Device: Universal
# Version : 1.4.3
# Last Update: 16.JAN.2018
# =======================================================#
# THE BEST BATTERY MOD YOU CAN EVER USE
# JUST FLASH AND FORGET
# =======================================================#
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
# =======================================================#
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
max()
{
    local m="$1"
    for n in "$@"
    do
        [ "$n" -gt "$m" ] && m="$n"
    done
    echo "$m"
}
function set_value() {
	if [ -f $2 ]; then
		# chown 0.0 $2
		chmod 0644 $2
		echo $1 > $2
		chmod 0444 $2
	fi
}
# $1:io-scheduler $2:block-path
function set_io() {
	if [ -f $2/queue/scheduler ]; then
		if [ `grep -c $1 $2/queue/scheduler` = 1 ]; then
			write $2/queue/scheduler $1
			if [ "$1" == "cfq" ];then
			write $2/queue/read_ahead_kb 128
			else
			write $2/queue/read_ahead_kb 2048
			fi
  		fi
	fi
}
function is_int() { return $(test "$@" -eq "$@" > /dev/null 2>&1); }
function set_boost() {
	#Tune Input Boost
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_ms" ]; then
	set_value $1 /sys/module/cpu_boost/parameters/input_boost_ms
	elif [ -e "/sys/module/cpu_boost/parameters/input_boost_ms_s2" ]; then
	set_value 0 /sys/module/cpu_boost/parameters/input_boost_ms_s2
	elif [ -e /sys/module/cpu_boost/parameters/input_boost_enabled ]; then
	set_value 1 /sys/module/cpu_boost/parameters/input_boost_enabled
	elif [ -e /sys/module/cpu_boost/parameters/sched_boost_on_input ]; then
	set_value "N" /sys/module/cpu_boost/parameters/sched_boost_on_input
	elif [ -e "/sys/kernel/cpu_input_boost/enabled" ]; then
	set_value 0 /sys/kernel/cpu_input_boost/enabled
	set_value 0 /sys/kernel/cpu_input_boost/ib_duration_ms
	fi
	#Disable Touch Boost
	if [ -e "/sys/module/msm_performance/parameters/touchboost" ]; then
	set_value 0 /sys/module/msm_performance/parameters/touchboost
	elif [ -e /sys/power/pnpmgr/touch_boost ]; then
	set_value 0 /sys/power/pnpmgr/touch_boost
	fi
	#Disable CPU Boost
	if [ -e "/sys/module/cpu_boost/parameters/boost_ms" ]; then
	set_value 0 /sys/module/cpu_boost/parameters/boost_ms
	fi
}
function set_boost_freq() {
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq" ]; then
	if [ "$2" == "" ];then
	set_value "$1" /sys/module/cpu_boost/parameters/input_boost_freq
	else
	set_value "$1 $2" /sys/module/cpu_boost/parameters/input_boost_freq
	fi
	elif [ -e "/sys/kernel/cpu_input_boost/ib_freqs" ]; then
	if [ "$2" == "" ];then
	set_value "$1" /sys/kernel/cpu_input_boost/ib_freqs
	else
	set_value "$1 $2" /sys/kernel/cpu_input_boost/ib_freqs
	fi
	elif [ -e "/sys/module/cpu_boost/parameters/input_boost_freq_s2" ]; then
	freq="0:0"
	i=1
	while [ $i -lt $cores ]
	do
	freq="$i:0 $freq"
	i=$(( $i + 1 ))
	done
	freq=$(echo $freq | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
	set_value "$freq" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	fi
}
function backup_boost() {
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq" ]; then
	echo $(cat /sys/module/cpu_boost/parameters/input_boost_freq | tr -d '\n') "#" $(cat /sys/module/cpu_boost/parameters/input_boost_ms | tr -d '\n') > "/data/adb/boost1.txt"
	elif [ -e "/sys/kernel/cpu_input_boost/ib_freqs" ]; then
	echo $(cat /sys/kernel/cpu_input_boost/ib_freqs | tr -d '\n') "#" $(cat /sys/kernel/cpu_input_boost/ib_duration_ms | tr -d '\n') > "/data/adb/boost2.txt"
	elif [ -e "/sys/module/cpu_boost/parameters/input_boost_freq_s2" ]; then
	echo $(cat /sys/module/cpu_boost/parameters/input_boost_freq_s2 | tr -d '\n') "#" $(cat /sys/module/cpu_boost/parameters/input_boost_ms_s2 | tr -d '\n') > "/data/adb/boost3.txt"
	fi
}
function restore_boost() {
	if [ -e "/data/adb/boost1.txt" ]; then
	FREQ_FILE="/data/adb/boost1.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	set_value "$FREQ" /sys/module/cpu_boost/parameters/input_boost_freq
	set_value $BOOSTMS /sys/module/cpu_boost/parameters/input_boost_ms
	elif [ -e "/data/adb/boost2.txt" ]; then
	FREQ_FILE="/data/adb/boost2.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	set_value "$FREQ" /sys/kernel/cpu_input_boost/ib_freqs
	set_value $BOOSTMS /sys/kernel/cpu_input_boost/ib_duration_ms
	elif [ -e "/data/adb/boost3.txt" ]; then
	FREQ_FILE="/data/adb/boost3.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	set_value "$FREQ" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	set_value $BOOSTMS /sys/module/cpu_boost/parameters/input_boost_ms_s2
	fi
}
LOG="/data/LKT.prop"
RETRY_INTERVAL=5 #in seconds
MAX_RETRY=60
retry=${MAX_RETRY}
#wait for boot completed
while (("$retry" > "0")) && [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep ${RETRY_INTERVAL}
  ((retry--))
done
if [ -e $LOG ]; then
  rm $LOG;
fi;
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
backup_boost
fi;
    if [ "$1" == "" ];then
    PROFILE="<PROFILE_MODE>"
    if [ -e "/data/adb/lktprofile.txt" ]; then
	PROFILE=$(cat /data/adb/lktprofile.txt | tr -d '\n')
	fi
	else
    PROFILE=$1
	rm /data/adb/lktprofile.txt
	if [ ! -f /data/adb/lktprofile.txt ]; then
	echo $1 > /data/adb/lktprofile.txt
    fi
	fi
    if [ "$2" == "" ];then
    bootdelay=45
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
    TOTAL_RAM=$(free | grep Mem | awk '{print $2}') 2>/dev/null
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{printf("%.f\n", (x/1000000)+0.5)}')
    memg=$(round ${memg} 0)
    if [ $memg -gt 32 ];then
    unit="MB"
    else
    unit="GB"
    fi
    # CPU variables
    arch_type=`uname -m` 2>/dev/null
    gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors | tr -d '\n') 2>/dev/null
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
    BATT_HLTH="Good"
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
    SOC1=`getprop ro.product.board | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC2=`getprop ro.product.platform | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC3=`getprop ro.chipname | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC4=`getprop ro.hardware | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    CPU_FILE="/data/soc.txt"
    error=0
    support=0
    snapdragon=0
    chip=0
	EAS=0
	HMP=0
	shared=1
	shared_hmp=1
    function LOGDATA() {
        echo $1 |  tee -a $LOG;
    }
    cores=`grep -c ^processor /proc/cpuinfo` 2>/dev/null
    coresmax=$(cat /sys/devices/system/cpu/kernel_max) 2>/dev/null
	if [[ $((cores % 2)) -eq 0 ]];then
    echo "$cores is even"
    else 
    echo "$cores is odd"
	cores=$(( ${cores} + 1 ))
	fi
	if [[ $((coresmax % 2)) -eq 0 ]];then
    echo "$coresmax is even"
	coresmax=$(( ${coresmax} - 1 ))
	fi
    if [ ${cores} -eq 4 ];then
    bcores="2"
    else
    bcores="4"
    fi
    if [ -e /sys/devices/system/cpu/cpu0/cpufreq ]; then
    GOV_PATH_L=/sys/devices/system/cpu/cpu0/cpufreq
    fi
    if [ -e "/sys/devices/system/cpu/cpu${bcores}/cpufreq" ]; then
    GOV_PATH_B="/sys/devices/system/cpu/cpu${bcores}/cpufreq"
    fi
    if [ -e /sys/devices/system/cpu/cpufreq/policy0 ]; then
    SILVER=/sys/devices/system/cpu/cpufreq/policy0
    fi
    if [ -e "/sys/devices/system/cpu/cpufreq/policy${bcores}" ]; then 
    GOLD="/sys/devices/system/cpu/cpufreq/policy${bcores}"
    fi
    maxfreq_l=$(cat "$GOV_PATH_L/cpuinfo_max_freq") 2>/dev/null	
    maxfreq_b=$(cat "$GOV_PATH_B/cpuinfo_max_freq") 2>/dev/null	
	if [[ $maxfreq_b = "" ]] || [[ $maxfreq_b -eq 0 ]]; then 
    maxfreq_l=$(cat "$SILVER/cpuinfo_max_freq") 2>/dev/null	
    maxfreq_b=$(cat "$GOLD/cpuinfo_max_freq") 2>/dev/null
    fi
	if [[ $maxfreq_b = "" ]] || [[ $maxfreq_b -eq 0 ]]; then 
	freqs_list0=$(cat $GOV_PATH_L/scaling_available_frequencies) 2>/dev/null
    freqs_list4=$(cat $GOV_PATH_B/scaling_available_frequencies) 2>/dev/null
	maxfreq_l="$(max $freqs_list0)"
	maxfreq_b="$(max $freqs_list4)"
    fi
    maxfreq=$(awk -v x=$maxfreq_b 'BEGIN{print x/1000000}')
    maxfreq=$(round ${maxfreq} 2)
if [ ${maxfreq_l} -ne ${maxfreq_b} ] ; then
is_big_little=true
else
is_big_little=false
fi
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu${bcores}/cpufreq/interactive"
C0_CPUFREQ_DIR="/sys/devices/system/cpu/cpu0/cpufreq"
C1_CPUFREQ_DIR="/sys/devices/system/cpu/cpu${bcores}/cpufreq"
if ! $is_big_little ; then
	C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpufreq/interactive"
	C1_GOVERNOR_DIR=""
	C0_CPUFREQ_DIR="/sys/devices/system/cpu/cpu0/cpufreq"
	C1_CPUFREQ_DIR=""
fi
function set_param_little() 
{
	echo ${2} > ${C0_GOVERNOR_DIR}/${1}
}
function set_param_big() 
{
	echo ${2} > ${C1_GOVERNOR_DIR}/${1}
}
function set_param_all() 
{
	set_param_little ${1} "${2}"
	$is_big_little && set_param_big ${1} "${2}"
}
function set_param_HMP()
{
	echo ${2} > /proc/sys/kernel/${1}
}
function set_param() {
	echo $3 > /sys/devices/system/cpu/$1/cpufreq/interactive/$2
}
function set_param_eas() {
	echo $4 > /sys/devices/system/cpu/$2/cpufreq/$1/$3
}
	if [ $PROFILE -eq 0 ];then
	PROFILE_M="Battery"
	elif [ $PROFILE -eq 1 ];then
	PROFILE_M="Balanced"
	elif [ $PROFILE -eq 2 ];then
	PROFILE_M="Performance"
	elif [ $PROFILE -eq 3 ];then
	PROFILE_M="Turbo"
	fi
	LOGDATA "###### LKT™ $V" 
	LOGDATA "###### PROFILE : $PROFILE_M"
    if [ "$SOC" == "" ];then
	error=1
    SOC=$SOC0
	else
    #LOGDATA "#  [WARNING] SOC DETECTION FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    ;;
	*)
	error=2
    SOC=$SOC0
    ;;
	esac
    fi
    if [ "$SOC" == "" ];then
	error=1
	SOC=$SOC1
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(0) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    ;;
	*)
	error=2
	SOC=$SOC1
    ;;
	esac
    fi
    fi
    if [ "$SOC" == "" ];then
	error=1
	SOC=$SOC2
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(1) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    ;;
	*)
	error=2
	SOC=$SOC2
    ;;
	esac
    fi
    fi
    if [ "$SOC" == "" ];then
	error=1
	SOC=$SOC3
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(2) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    ;;
	*)
	error=2
 	SOC=$SOC3
    ;;
	esac
    fi
    fi
    if [ "$SOC" == "" ];then
	error=1
	SOC=$SOC4
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "#  [WARNING] SOC DETECTION METHOD(3) FAILED. TRYING ALTERNATIVES"
    case ${SOC} in msm* | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
     ;;
	*)
	error=2
    SOC=$SOC4
    ;;
	esac
    fi
    fi
    if [ "$SOC" == "" ];then
    LOGDATA "#  [WARNING] SOC DETECTION FAILED. USING MANUAL METHOD"
    if [ -e $CPU_FILE ]; then
    if grep -q 'CPU=' $CPU_FILE
    then
    SOC5=$(awk -F= '{ print tolower($2) }' $CPU_FILE) 2>/dev/null
    else
    SOC5=$(cat $CPU_FILE | tr '[:upper:]' '[:lower:]') 2>/dev/null
    fi	
    SOC=$SOC5
    if [ "$SOC" == "" ];then
    error=3
    LOGDATA "#  [ERROR] MANUAL SOC DETECTION FAILED"
    LOGDATA "#  [INFO] $CPU_FILE IS EMPTY"
    LOGDATA "#  [INFO] PLEASE EDIT $CPU_FILE FILE WITH YOUR SOC MODEL NUMBER THEN REBOOT"
    exit 0
    fi
    case ${SOC} in msm* | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
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
    LOGDATA "#  START : $(date +"%d-%m-%Y %r")" 
    LOGDATA "#  =================================" 
    LOGDATA "#  VENDOR : $VENDOR" 
    LOGDATA "#  DEVICE : $APP" 
    LOGDATA "#  CPU : $SOC @ $maxfreq GHz ($cores x cores)"
    LOGDATA "#  RAM : $memg $unit" 
    LOGDATA "#  =================================" 
    LOGDATA "#  ANDROID : $OS" 
    LOGDATA "#  KERNEL : $KERNEL" 
    LOGDATA "#  BUSYBOX  : $sbusybox" 
    LOGDATA "# =================================" 
	case ${SOC} in sdm845* | sda845* ) #sd835
    support=1
	esac
	case ${SOC} in universal9810* | exynos9810*) #exynos9810
    support=1
	shared=0
	esac
	case ${SOC} in msm8998* | apq8098*) #sd835
    support=1
	esac
	case ${SOC} in msm8996* | apq8096*) #sd820
    support=1
	esac
	case ${SOC} in msm8994* | msm8992*) #sd810/808
    support=1
	esac
	case ${SOC} in apq8074* | apq8084* | msm8274* | msm8674*| msm8974*)  #sd800-801-805
    support=1
	shared_hmp=0
	esac
	case ${SOC} in sdm660* | sda660*) #sd660
    support=1
	esac
	case ${SOC} in msm8956* | msm8976*)  #sd652/650
    support=1
	esac
	case ${SOC} in sdm636* | sda636*) #sd636
    support=1
	esac
	case ${SOC} in msm8953* | sdm630* | sda630* )  #sd625/626/630
    support=1
	esac
	case ${SOC} in universal8895* | exynos8895*)  #EXYNOS8895 (S8)
    support=1
	shared_hmp=0
	shared=0
	esac
	case ${SOC} in universal8890* | exynos8890*)  #EXYNOS8890 (S7)
    support=1
	shared_hmp=0
	shared=0
	esac
	case ${SOC} in universal7420* | exynos7420*) #EXYNOS7420 (S6)
    support=1
	shared_hmp=0
	shared=0
	esac
	case ${SOC} in kirin970* | hi3670*)  # Huawei Kirin 970
    support=1
	shared_hmp=0
	shared=0
	esac
	case ${SOC} in kirin960* | hi3660*)  # Huawei Kirin 960
    support=1
	shared_hmp=0
	shared=0
	esac
	case ${SOC} in kirin950* | hi3650* | kirin955* | hi3655*) # Huawei Kirin 950
    support=1
	shared_hmp=0
	shared=0
	esac
	case ${SOC} in mt6797*) #Helio X25 / X20	 
    support=1
	shared_hmp=0
	shared=0
	esac
	case ${SOC} in mt6795*) #Helio X10
    support=1
	shared_hmp=0
	shared=0
	esac
	case ${SOC} in moorefield*) # Intel Atom
    support=1
	shared_hmp=0
	shared=0
	esac
	available_governors=$(cat ${GOV_PATH_L}/scaling_available_governors)
	if [[ "$available_governors" == *"interactive"* ]]; then
	case ${SOC} in msm8939* | msm8952*)  #sd615/616/617 by@ 橘猫520
    support=1
	shared=0
	if [ $PROFILE -lt 1 ] || [ $PROFILE -gt 1 ] ;then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
	PROFILE=1
	fi
    esac
    case ${SOC} in kirin650* | kirin655* | kirin658* | kirin659* | hi625*)  #KIRIN650 by @橘猫520
    support=1
	shared_hmp=0
	if [ $PROFILE -lt 1 ] || [ $PROFILE -gt 1 ] ;then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
	PROFILE=1
	fi
    esac
    case ${SOC} in universal9810* | exynos9810*) # S9 exynos_9810 by @橘猫520
	support=1
	shared_hmp=0
	if [ $PROFILE -lt 1 ] || [ $PROFILE -gt 1 ] ;then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
	PROFILE=1
	fi
    esac
    case ${SOC} in apq8026* | apq8028* | apq8030* | msm8226* | msm8228* | msm8230* | msm8626* | msm8628* | msm8630* | msm8926* | msm8928* | msm8930*)  #sd400 series by @cjybyjk
    support=1
	shared=0
	if [ $PROFILE -lt 1 ] || [ $PROFILE -gt 1 ] ;then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
	PROFILE=1
	fi
    esac
	case ${SOC} in apq8016* | msm8916* | msm8216* | msm8917* | msm8217*)  #sd410/sd425 series by @cjybyjk
    support=1
	shared=0
	if [ $PROFILE -lt 1 ] || [ $PROFILE -gt 2 ] ;then
	LOGDATA "#  [WARNING] ONLY BALANCED & PERFORMANCE AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
	PROFILE=1
	fi
    esac
	case ${SOC} in msm8937*)  #sd430 series by @cjybyjk
    support=1
	shared=0
	if [ $PROFILE -lt 1 ] || [ $PROFILE -gt 1 ] ;then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
	PROFILE=1
	fi
    esac
	case ${SOC} in msm8940*)  #sd435 series by @cjybyjk
    support=1
	shared=0
	if [ $PROFILE -lt 1 ] || [ $PROFILE -gt 1 ] ;then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
	PROFILE=1
	fi
    esac
	case ${SOC} in sdm450*)  #sd450 series by @cjybyjk
    support=1
	shared=0
	if [ $PROFILE -lt 1 ] || [ $PROFILE -gt 1 ] ;then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
	PROFILE=1
	fi
    esac
	case ${SOC} in mt6755*)  #sd450 series by @cjybyjk
    support=1
	shared=0
	if [ $PROFILE -lt 1 ] || [ $PROFILE -gt 2 ] ;then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	LOGDATA "#  [INFO] LKT IS SWITCHED TO BALANCED PROFILE"
	PROFILE=1
	fi
    esac
	else
	case ${SOC} in msm8939* | msm8952*)  #sd615/616/617 by@ 橘猫520
    support=1
	shared=0
    esac
    case ${SOC} in kirin650* | kirin655* | kirin658* | kirin659* | hi625*)  #KIRIN650 by @橘猫520
    support=1
	shared_hmp=0
    esac
    case ${SOC} in universal9810* | exynos9810*) # S9 exynos_9810 by @橘猫520
	support=1
	shared_hmp=0
    esac
    case ${SOC} in apq8026* | apq8028* | apq8030* | msm8226* | msm8228* | msm8230* | msm8626* | msm8628* | msm8630* | msm8926* | msm8928* | msm8930*)  #sd400 series by @cjybyjk
    support=1
	shared=0
    esac
	case ${SOC} in apq8016* | msm8916* | msm8216* | msm8917* | msm8217*)  #sd410/sd425 series by @cjybyjk
    support=1
	shared=0
    esac
	case ${SOC} in msm8937*)  #sd430 series by @cjybyjk
    support=1
	shared=0
    esac
	case ${SOC} in msm8940*)  #sd435 series by @cjybyjk
    support=1
	shared=0
    esac
	case ${SOC} in sdm450*)  #sd450 series by @cjybyjk
    support=1
	shared=0
    esac
	case ${SOC} in mt6755*)  #sd450 series by @cjybyjk
    support=1
	shared=0
    esac
fi
    if [ "$SOC" != "${SOC/msm/}" ] || [ "$SOC" != "${SOC/sda/}" ] || [ "$SOC" != "${SOC/sdm/}" ] || [ "$SOC" != "${SOC/apq/}" ];     then
    snapdragon=1
    else
    snapdragon=0
    fi
    function before_modify()
{
	chown 0.0 ${GOV_PATH_L}/interactive/*
	chown 0.0 ${GOV_PATH_B}/interactive/*
	chmod 0666 ${GOV_PATH_L}/interactive/*	
	chmod 0666 ${GOV_PATH_B}/interactive/*
}
    function after_modify()
{
	chmod 0444 ${GOV_PATH_L}/interactive/*	
	chmod 0444 ${GOV_PATH_B}/interactive/*
}
    function before_modify_eas()
{
	chown 0.0 ${GOV_PATH_L}/$1/*
	chown 0.0 ${GOV_PATH_B}/$1/*
	chmod 0666 ${GOV_PATH_L}/$1/*	
	chmod 0666 ${GOV_PATH_B}/$1/*
	chmod 0666 $SVD/$1/*
	chmod 0666 $GLD/$1/*
}
    function after_modify_eas()
{
	chmod 0444 ${GOV_PATH_L}/$1/*	
	chmod 0444 ${GOV_PATH_B}/$1/*
	chmod 0444 $SVD/$1/*
	chmod 0444 $GLD/$1/*
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
		$swff "$zram_dev" && zram_reset "$zram_dev"
		local dev_index="$( echo $zram_dev | grep -o "[0-9]*$" )"
		if [ $dev_index -ne 0 ]; then
			echo $dev_index > /sys/class/zram-control/hot_remove
		fi
	} done
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
 	LOGDATA '# [WARNING] ADAPTIVE LMK IS NOT PRESENT ON YOUR KERNEL' 
fi;
}
function ramtuning() { 
    calculator="2.5"
    if [ $TOTAL_RAM -lt 2097152 ]; then
    calculator="2"
    #disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 36
    elif [ $TOTAL_RAM -lt 3145728 ]; then
    #disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 48
    elif [ $TOTAL_RAM -lt 4194304 ]; then
    disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 56
    fi
    if [ $TOTAL_RAM -gt 4194304 ]; then
    disable_swap
    resetprop -n ro.sys.fw.bg_apps_limit 72
    elif [ $TOTAL_RAM -gt 6291456 ]; then
    disable_swap
    #disable_lmk
    resetprop -n ro.sys.fw.bg_apps_limit 88
    fi
# =========
# Vitual Memory
# =========
LOGDATA "#  [INFO] TUNING ANDROID VM" 
chmod 0644 /proc/sys/*;
if [ $PROFILE -le 1 ];then
sysctl -e -w  vm.drop_caches=1 \
vm.dirty_background_ratio=1 \
vm.dirty_ratio=5 \
vm.vfs_cache_pressure=30 \
vm.laptop_mode=5 \
vm.block_dump=0 \
vm.dirty_writeback_centisecs=500 \
vm.dirty_expire_centisecs=1500 \
vm.compact_memory=1 \
vm.compact_unevictable_allowed=1 \
vm.page-cluster=0 \
vm.panic_on_oom=0 &> /dev/null
sysctl -w kernel.random.read_wakeup_threshold=16
sysctl -w kernel.random.write_wakeup_threshold=32
else
sysctl -e -w  vm.drop_caches=1 \
vm.dirty_background_ratio=5 \
vm.dirty_ratio=20 \
vm.vfs_cache_pressure=70 \
vm.laptop_mode=0 \
vm.block_dump=0 \
vm.dirty_writeback_centisecs=500 \
vm.dirty_expire_centisecs=1500 \
vm.compact_memory=1 \
vm.compact_unevictable_allowed=1 \
vm.page-cluster=0 \
vm.panic_on_oom=0 &> /dev/null
sysctl -e -w kernel.random.read_wakeup_threshold=64
sysctl -e -w kernel.random.write_wakeup_threshold=128
fi
chmod 0444 /proc/sys/*;
sync;
}
function cputuning() {
	if [ $support -eq 1 ];then
    LOGDATA "#  [✓] SOC CHECK OKAY "
    LOGDATA "#  [INFO] THIS DEVICE IS SUPPORTED BY LKT"
	elif [ $support -eq 2 ];then
    LOGDATA "#  [✓] SOC CHECK OKAY "
    LOGDATA "#  [INFO] THIS DEVICE IS PARTIALLY SUPPORTED BY LKT"
	fi
    if [ $snapdragon -eq 1 ];then
    LOGDATA "#  [INFO] SNAPDRAGON SOC DETECTED" 
    # disable thermal bcl hotplug to switch governor
    write /sys/module/msm_thermal/core_control/enabled "0"
    write /sys/module/msm_thermal/parameters/enabled "N"
    else
    LOGDATA "#  [INFO] NON-SNAPDRAGON SOC DETECTED" 
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
	set_value 1 /sys/devices/system/cpu/cpu4/online
	set_value 1 /sys/devices/system/cpu/cpu5/online
	set_value 1 /sys/devices/system/cpu/cpu6/online
	set_value 1 /sys/devices/system/cpu/cpu7/online
    fi
	    # disable thermal & BCL core_control to update interactive gov settings
    echo 0 > /sys/module/msm_thermal/core_control/enabled
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        bcl_hotplug_mask=`cat $hotplug_mask`
        echo 0 > $hotplug_mask
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
        echo 0 > $hotplug_soc_mask
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done
	# Perfd, nothing to worry about, if error the script will continue
	if [ -e /data/system/perfd ]; then
	stop perfd
	fi
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
	write /sys/devices/system/cpu/online "0-$coresmax"
	string1="${GOV_PATH_L}/scaling_available_governors";
	string2="${GOV_PATH_B}/scaling_available_governors";
	if [ $PROFILE -eq 0 ];then
	if [ -e "/sys/module/lazyplug" ]; then
	write /sys/module/lazyplug/parameters/cpu_nr_run_theshold '1250'
	write /sys/module/lazyplug/parameters/cpu_nr_hysteresis '5'
	write /sys/module/lazyplug/parameters/nr_run_profile_sel '0'
	fi
	fi
	# Enable power efficient work_queue mode
	if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
	chmod 644 /sys/module/workqueue/parameters/power_efficient 
	write /sys/module/workqueue/parameters/power_efficient 'Y'
	LOGDATA "#  [INFO] ENABLING POWER EFFICIENT WORKQUEUE MODE " 
	else
	LOGDATA "#  [WARNING] YOUR KERNEL DOESN'T SUPPORT POWER EFFICIENT WORKQUEUE" 
	fi
## INTERACTIVE
if [[ "$available_governors" == *"interactive"* ]]; then
if [ ${EAS} -eq 0 ];then
HMP=1
    chmod 644 ${GOV_PATH_L}/scaling_governor
    $is_big_little && chmod 644 ${GOV_PATH_B}/scaling_governor
	write ${GOV_PATH_L}/scaling_governor "interactive"
	$is_big_little && write ${GOV_PATH_B}/scaling_governor "interactive"
	sleep 1
	gov_l=$(cat ${GOV_PATH_L}/scaling_governor)
	gov_b=$(cat ${GOV_PATH_B}/scaling_governor)
	if [ "$gov_l" != "interactive" ];then
	LOGDATA "#  [ERROR] CANNOT SWITCH TO INTERACTIVE AS DEFAULT GOVERNOR" 
	fi
	LOGDATA "#  [INFO] HMP KERNEL DETECTED" 
	LOGDATA "#  [INFO] TUNING $gov_l"
	before_modify
	if [ -e "/sys/devices/system/cpu/cpu0/cpufreq/interactive/powersave_bias" ]; then
	set_param cpu0 powersave_bias 1
	fi
	if [ ${shared} -eq 1 ]; then
	set_boost 2500
	fi
	sleep 2
	case ${SOC} in msm8998* | apq8098*) #sd835
	set_value 280000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 280000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:280000 4:280000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 90 /proc/sys/kernel/sched_spill_load
	set_value 0 /proc/sys/kernel/sched_boost
	set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
	set_value 40 /proc/sys/kernel/sched_init_task_load
	set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	# set_value 85 /proc/sys/kernel/sched_downmigrate
	# set_value 95 /proc/sys/kernel/sched_upmigrate
	set_param_little use_sched_load 1
	set_value 0 ${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C0_GOVERNOR_DIR}/enable_prediction
	set_param_big use_sched_load 1
	set_value 0 ${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C1_GOVERNOR_DIR}/enable_prediction
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_boost_freq "0:380000 4:380000"
	set_param_little above_hispeed_delay "18000 1380000:58000 1480000:18000 1580000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 380000:59 480000:51 580000:29 780000:92 880000:76 1180000:90 1280000:98 1380000:84 1480000:97"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1480000:58000 1580000:98000 1880000:138000"
	set_param_big hispeed_freq 1280000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 380000:45 480000:36 580000:41 680000:65 780000:88 1080000:92 1280000:98 1380000:90 1580000:97"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_boost_freq "0:380000 4:380000"
	set_param_little above_hispeed_delay "18000 1580000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 380000:30 480000:41 580000:29 680000:4 780000:60 1180000:88 1280000:70 1380000:78 1480000:97"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1380000:78000 1480000:18000 1580000:98000 1880000:138000"
	set_param_big hispeed_freq 1280000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 380000:39 580000:58 780000:63 980000:81 1080000:92 1180000:77 1280000:98 1380000:86 1580000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_boost_freq "0:380000 4:380000"
	set_param_little above_hispeed_delay "18000 1580000:98000 1780000:38000"
	set_param_little hispeed_freq 1480000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 380000:42 580000:80 680000:15 980000:36 1080000:9 1180000:90 1280000:59 1480000:88 1680000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1580000:98000 1880000:38000"
	set_param_big hispeed_freq 1280000
	set_param_big go_hispeed_load 94
	set_param_big target_loads "80 380000:44 480000:19 680000:54 780000:63 980000:54 1080000:63 1280000:71 1580000:98"
	set_param_big min_sample_time 18000
   	elif [ $PROFILE -eq 3 ];then
	restore_boost
	set_value "0:1480000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1480000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1780000:198000"
	set_param_little hispeed_freq 1480000
	set_param_little target_loads "80 1880000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1880000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in msm8996* | apq8096*) #sd820
	set_value 280000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 280000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:280000 2:280000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 90 /proc/sys/kernel/sched_spill_load
	set_value 0 /proc/sys/kernel/sched_boost
	set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
	set_value 40 /proc/sys/kernel/sched_init_task_load
	set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus 1
	write /dev/cpuset/system-background/cpus "0-1"
	write /dev/cpuset/foreground/cpus "0-1,2-3"
	write /dev/cpuset/top-app/cpus "0-1,2-3"
	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate
	set_param_little use_sched_load 1
	set_value 0 ${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C0_GOVERNOR_DIR}/enable_prediction
	set_param_big use_sched_load 1
	set_value 0 ${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C1_GOVERNOR_DIR}/enable_prediction
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_boost_freq "0:380000 2:380000"
	set_param_little above_hispeed_delay "18000 1180000:78000 1280000:98000"
	set_param_little hispeed_freq 1080000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 380000:5 580000:42 680000:60 780000:70 880000:83 980000:92 1180000:97"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1280000:98000 1380000:58000 1480000:98000 1880000:138000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 380000:53 480000:38 580000:63 780000:69 880000:85 1080000:93 1380000:72 1480000:98"
	set_param_big min_sample_time 18000
	set_param cpu2 min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_boost_freq "0:380000 2:380000"
	set_param_little above_hispeed_delay "58000 1280000:98000 1580000:58000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 380000:9 580000:36 780000:62 880000:71 980000:87 1080000:75 1180000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "38000 1480000:98000 1880000:138000"
	set_param_big hispeed_freq 1380000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 380000:39 480000:35 680000:29 780000:63 880000:71 1180000:91 1380000:83 1480000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_boost_freq "0:380000 2:380000"
	set_param_little above_hispeed_delay "18000 1280000:98000 1480000:38000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 380000:7 480000:31 580000:13 680000:58 780000:63 980000:73 1180000:98"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "18000 1580000:98000 1880000:38000"
	set_param_big hispeed_freq 1480000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 380000:34 680000:40 780000:63 880000:57 1080000:72 1380000:78 1480000:98"
	set_param_big min_sample_time 18000
	set_param cpu2 min_sample_time 18000
   	elif [ $PROFILE -eq 3 ];then
	restore_boost
	set_value "0:1080000 2:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1080000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1480000:198000"
	set_param_little hispeed_freq 1080000
	set_param_little target_loads "80 1580000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1880000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in msm8994* | msm8992*) #sd810/808
	set_value "0:380000 4:380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 380000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value 90 /proc/sys/kernel/sched_spill_load
	set_value 0 /proc/sys/kernel/sched_boost
	set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
	set_value 40 /proc/sys/kernel/sched_init_task_load
	set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-5"
	write /dev/cpuset/top-app/cpus "0-3,4-5"
	set_value 85 /proc/sys/kernel/sched_downmigrate
	set_value 99 /proc/sys/kernel/sched_upmigrate
	set_value 0 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_value "0:1344000 4:1440000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_value 1344000 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	set_value 1440000 /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
	set_param_little use_sched_load 1
	set_value 0 ${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C0_GOVERNOR_DIR}/enable_prediction
	set_param_big use_sched_load 1
	set_value 0 ${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C1_GOVERNOR_DIR}/enable_prediction
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_boost_freq "0:580000 4:480000"
	set_param_little above_hispeed_delay "98000 1280000:38000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 580000:27 680000:48 780000:68 880000:82 1180000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1180000:98000 1380000:18000"
	set_param_big hispeed_freq 880000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 580000:49 680000:40 780000:58 880000:94 1180000:98"
	set_param_big min_sample_time 38000
	elif [ $PROFILE -eq 1 ];then
	set_boost_freq "0:580000 4:480000"
	set_param_little above_hispeed_delay "98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 580000:59 680000:54 780000:63 880000:85 1180000:98 1280000:94"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "18000 1180000:98000"
	set_param_big hispeed_freq 880000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 580000:64 680000:58 780000:19 880000:97"
	set_param_big min_sample_time 78000
	elif [ $PROFILE -eq 2 ];then
	set_boost_freq "0:580000 4:480000"
	set_param_little above_hispeed_delay "38000 1280000:58000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 580000:63 680000:54 780000:60 880000:32 1180000:98 1280000:93"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "78000 1280000:38000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 480000:44 580000:65 680000:61 780000:20 880000:90 1180000:74 1280000:98"
	set_param_big min_sample_time 78000
   	elif [ $PROFILE -eq 3 ];then
	restore_boost
	set_value "0:880000 4:880000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 880000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1180000:198000"
	set_param_little hispeed_freq 880000
	set_param_little target_loads "80 1280000:90"
	set_param_little min_sample_time 38000
	set_value 880000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1280000:198000"
	set_param_big hispeed_freq 880000
	set_param_big target_loads "80 1380000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in apq8074* | apq8084* | msm8274* | msm8674*| msm8974*)  #sd800-801-805
	stop mpdecision
	setprop ro.qualcomm.perf.cores_online 2
	set_value 280000 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	set_value 280000 /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
	set_value 280000 /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
	set_value 280000 /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
	set_value "0:280000 2:280000" /sys/module/msm_performance/parameters/cpu_min_freq
	setprop ro.qualcomm.perf.cores_online 2
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_param_little above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 380000:6 580000:25 680000:43 880000:61 980000:86 1180000:97"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 97
	set_param_big target_loads "80 380000:6 580000:25 680000:43 880000:61 980000:86 1180000:97"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_param_little above_hispeed_delay "38000 1480000:78000 1680000:98000 1880000:138000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 380000:32 580000:47 680000:82 880000:32 980000:39 1180000:83 1480000:79 1680000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "38000 1480000:78000 1680000:98000 1880000:138000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 97
	set_param_big target_loads "80 380000:32 580000:47 680000:82 880000:32 980000:39 1180000:83 1480000:79 1680000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_param_little above_hispeed_delay "18000 1480000:98000 1880000:38000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 380000:32 580000:45 680000:81 880000:63 980000:47 1180000:89 1480000:79 1680000:98"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "18000 1480000:98000 1880000:38000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 97
	set_param_big target_loads "80 380000:32 580000:45 680000:81 880000:63 980000:47 1180000:89 1480000:79 1680000:98"
	set_param_big min_sample_time 38000
   	elif [ $PROFILE -eq 3 ];then
	restore_boost
	set_value "0:1480000 2:1480000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1480000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1880000:198000"
	set_param_little hispeed_freq 1480000
	set_param_little target_loads "80 1980000:90"
	set_param_little min_sample_time 38000
	set_value 1480000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1880000:198000"
	set_param_big hispeed_freq 1480000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
	start mpdecision
esac
case ${SOC} in sdm660* | sda660*) #sd660
	set_value 580000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 1080000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:580000 4:1080000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 90 /proc/sys/kernel/sched_spill_load
	set_value 0 /proc/sys/kernel/sched_boost
	set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
	set_value 40 /proc/sys/kernel/sched_init_task_load
	set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	# set_value 85 /proc/sys/kernel/sched_downmigrate
	# set_value 95 /proc/sys/kernel/sched_upmigrate
	set_param_little use_sched_load 1
	set_value 0 ${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C0_GOVERNOR_DIR}/enable_prediction
	set_param_big use_sched_load 1
	set_value 0 ${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C1_GOVERNOR_DIR}/enable_prediction
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param_little above_hispeed_delay "38000 1380000:98000"
	set_param_little hispeed_freq 1080000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 880000:45 1080000:64 1480000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param_big hispeed_freq 1080000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 1680000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param_little above_hispeed_delay "98000"
	set_param_little hispeed_freq 1480000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 880000:59 1080000:90 1380000:78 1480000:98"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param_big hispeed_freq 1080000
	set_param_big go_hispeed_load 83
	set_param_big target_loads "80 1380000:70 1680000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param_little above_hispeed_delay "18000 1380000:98000 1680000:38000"
	set_param_little hispeed_freq 880000
	set_param_little go_hispeed_load 89
	set_param_little target_loads "80 880000:60 1080000:80 1380000:54 1480000:98"
	set_param_little min_sample_time 78000
	set_param_big above_hispeed_delay "18000 1380000:78000 1680000:98000 1880000:38000"
	set_param_big hispeed_freq 1080000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 1380000:65 1680000:98"
	set_param_big min_sample_time 78000
   	elif [ $PROFILE -eq 3 ];then
	restore_boost
	set_value "0:580000 4:1080000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1080000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1680000:198000"
	set_param_little hispeed_freq 1080000
	set_param_little target_loads "80 1780000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1880000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in msm8956* | msm8976*)  #sd652/650
	set_value 380000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:380000 4:380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 90 /proc/sys/kernel/sched_spill_load
	set_value 0 /proc/sys/kernel/sched_boost
	set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
	set_value 40 /proc/sys/kernel/sched_init_task_load
	set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	# set_value 85 /proc/sys/kernel/sched_downmigrate
	# set_value 95 /proc/sys/kernel/sched_upmigrate
	set_param_little use_sched_load 1
	set_value 0 ${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C0_GOVERNOR_DIR}/enable_prediction
	set_param_big use_sched_load 1
	set_value 0 ${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C1_GOVERNOR_DIR}/enable_prediction
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_boost_freq "0:680000 4:880000"
	set_param_little above_hispeed_delay "98000 1380000:78000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 95
	set_param_little target_loads "80 680000:58 980000:68 1280000:97"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1280000:38000 1380000:18000 1580000:98000"
	set_param_big hispeed_freq 1080000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 880000:51 980000:69 1080000:90 1280000:72 1380000:94 1580000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_boost_freq "0:680000 4:880000"
	set_param_little above_hispeed_delay "98000 1380000:58000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 680000:68 780000:60 980000:97 1180000:63 1280000:97 1380000:84"
	set_param_little min_sample_time 58000
	set_param_big above_hispeed_delay "18000 1580000:98000"
	set_param_big hispeed_freq 1280000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 880000:47 980000:68 1280000:74 1380000:92 1580000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_boost_freq "0:680000 4:880000"
	set_param_little above_hispeed_delay "98000 1280000:38000 1380000:78000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 96
	set_param_little target_loads "80 680000:90 780000:57 980000:61 1180000:96 1380000:7"
	set_param_little min_sample_time 78000
	set_param_big above_hispeed_delay "98000 1680000:38000"
	set_param_big hispeed_freq 1580000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 880000:47 1080000:52 1180000:63 1280000:71 1380000:76 1580000:98"
	set_param_big min_sample_time 18000
   	elif [ $PROFILE -eq 3 ];then
	restore_boost
	set_value "0:1180000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1180000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1280000:198000"
	set_param_little hispeed_freq 1180000
	set_param_little target_loads "80 1380000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1680000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1780000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in sdm636* | sda636*) #sd636
	set_value 580000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 1080000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:580000 4:1080000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 90 /proc/sys/kernel/sched_spill_load
	set_value 0 /proc/sys/kernel/sched_boost
	set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
	set_value 40 /proc/sys/kernel/sched_init_task_load
	set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	# set_value 85 /proc/sys/kernel/sched_downmigrate
	# set_value 95 /proc/sys/kernel/sched_upmigrate
	set_param_little use_sched_load 1
	set_value 0 ${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C0_GOVERNOR_DIR}/enable_prediction
	set_param_big use_sched_load 1
	set_value 0 ${C1_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C1_GOVERNOR_DIR}/enable_prediction
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param_little above_hispeed_delay "18000 1380000:78000 1480000:98000 1580000:38000"
	set_param_little hispeed_freq 1080000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 880000:62 1080000:98 1380000:84 1480000:97"
	set_param_little min_sample_time 58000
	set_param_big above_hispeed_delay "18000 1680000:98000"
	set_param_big hispeed_freq 1080000
	set_param_big go_hispeed_load 86
	set_param_big target_loads "80 1380000:84 1680000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param_little above_hispeed_delay "18000 1380000:78000 1480000:98000 1580000:78000"
	set_param_little hispeed_freq 1080000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 880000:62 1080000:94 1380000:75 1480000:96"
	set_param_little min_sample_time 58000
	set_param_big above_hispeed_delay "18000 1680000:98000"
	set_param_big hispeed_freq 1080000
	set_param_big go_hispeed_load 81
	set_param_big target_loads "80 1380000:70 1680000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param_little above_hispeed_delay "18000 1380000:98000 1480000:38000"
	set_param_little hispeed_freq 880000
	set_param_little go_hispeed_load 85
	set_param_little target_loads "80 880000:59 1080000:77 1380000:52 1480000:98 1580000:94"
	set_param_little min_sample_time 78000
	set_param_big above_hispeed_delay "18000 1380000:78000 1680000:38000"
	set_param_big hispeed_freq 1080000
	set_param_big go_hispeed_load 89
	set_param_big target_loads "80 1380000:64 1680000:98"
	set_param_big min_sample_time 78000
   	elif [ $PROFILE -eq 3 ];then
	restore_boost
	set_value "0:1080000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1080000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1480000:198000"
	set_param_little hispeed_freq 1080000
	set_param_little target_loads "80 1580000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1680000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1780000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in msm8953* | sdm630* | sda630* )  #sd625/626/630
	set_value 580000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:580000 4:580000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 90 /proc/sys/kernel/sched_spill_load
	set_value 0 /proc/sys/kernel/sched_boost
	set_value 1 /proc/sys/kernel/sched_prefer_sync_wakee_to_waker
	set_value 40 /proc/sys/kernel/sched_init_task_load
	set_value 3000000 /proc/sys/kernel/sched_freq_inc_notify
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	set_value 25 /proc/sys/kernel/sched_downmigrate
	set_value 45 /proc/sys/kernel/sched_upmigrate
	set_param_little use_sched_load 1
	set_value 0 ${C0_GOVERNOR_DIR}/ignore_hispeed_on_notif
	set_value 0 ${C0_GOVERNOR_DIR}/enable_prediction
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_boost_freq "0:980000 4:0"
	set_param_little above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param_little hispeed_freq 1380000
	set_param_little go_hispeed_load 94
	set_param_little target_loads "80 980000:66 1380000:96"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param_big hispeed_freq 1380000
	set_param_big go_hispeed_load 94
	set_param_big target_loads "80 980000:66 1380000:96"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_boost_freq "0:980000 4:0"
	set_param_little above_hispeed_delay "98000 1880000:138000"
	set_param_little hispeed_freq 1680000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 980000:63 1380000:72 1680000:97"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "98000 1880000:138000"
	set_param_big hispeed_freq 1680000
	set_param_big go_hispeed_load 97
	set_param_big target_loads "80 980000:63 1380000:72 1680000:97"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_boost_freq "0:980000 4:0"
	set_param_little above_hispeed_delay "18000 1680000:98000 1880000:38000"
	set_param_little hispeed_freq 980000
	set_param_little go_hispeed_load 89
	set_param_little target_loads "80 980000:55 1380000:75 1680000:98"
	set_param_little min_sample_time 78000
	set_param_big above_hispeed_delay "18000 1680000:98000 1880000:38000"
	set_param_big hispeed_freq 980000
	set_param_big go_hispeed_load 89
	set_param_big target_loads "80 980000:55 1380000:75 1680000:98"
	set_param_big min_sample_time 78000
   	elif [ $PROFILE -eq 3 ];then
	restore_boost
	set_value "0:1380000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1380000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1880000:198000"
	set_param_little hispeed_freq 1380000
	set_param_little target_loads "80 1980000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1880000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in universal8895* | exynos8895*)  #EXYNOS8895 (S8)
	set_value 580000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 680000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:580000 4:680000" /sys/module/msm_performance/parameters/cpu_min_freq
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_param_little above_hispeed_delay "38000 1380000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 82
	set_param_little target_loads "80 680000:27 780000:39 880000:61 980000:68 1380000:98 1680000:94"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param_big hispeed_freq 1380000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 780000:73 880000:79 980000:55 1080000:69 1180000:84 1380000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_param_little above_hispeed_delay "38000 1380000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 780000:53 880000:70 980000:50 1180000:71 1380000:97 1680000:92"
	set_param_little min_sample_time 58000
	set_param_big above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param_big hispeed_freq 1380000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 780000:40 880000:34 980000:66 1080000:31 1180000:72 1380000:86 1680000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_param_little above_hispeed_delay "38000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 780000:31 880000:62 980000:42 1180000:69 1380000:95 1680000:78"
	set_param_little min_sample_time 58000
	set_param_big above_hispeed_delay "18000 1680000:98000 1880000:38000"
	set_param_big hispeed_freq 1380000
	set_param_big go_hispeed_load 96
	set_param_big target_loads "80 780000:22 880000:3 980000:14 1080000:34 1180000:47 1380000:63 1680000:72 1780000:98"
	set_param_big min_sample_time 18000
   	elif [ $PROFILE -eq 3 ];then
	set_value "0:1180000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1180000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1380000:198000"
	set_param_little hispeed_freq 1180000
	set_param_little target_loads "80 1680000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1880000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in universal8890* | exynos8890*)  #EXYNOS8890 (S7)
	set_value 380000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 680000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:380000 4:680000" /sys/module/msm_performance/parameters/cpu_min_freq
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_param_little above_hispeed_delay "38000 1280000:18000 1480000:98000 1580000:58000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 96
	set_param_little target_loads "80 480000:51 680000:28 780000:56 880000:63 1080000:71 1180000:75 1280000:97"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1480000:98000 1880000:138000"
	set_param_big hispeed_freq 1280000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 780000:4 880000:77 980000:14 1080000:90 1180000:68 1280000:92 1480000:96"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_param_little above_hispeed_delay "18000 1280000:38000 1480000:98000 1580000:18000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 480000:49 680000:34 780000:61 880000:33 980000:63 1080000:69 1180000:77 1480000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1580000:98000 1880000:138000"
	set_param_big hispeed_freq 1380000
	set_param_big go_hispeed_load 93
	set_param_big target_loads "80 780000:33 880000:67 980000:42 1080000:75 1180000:65 1280000:74 1480000:97"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_param_little above_hispeed_delay "18000 1480000:38000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 480000:54 780000:61 880000:24 980000:63 1080000:57 1180000:81 1280000:71 1480000:96 1580000:87"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "18000 1580000:98000 1880000:38000"
	set_param_big hispeed_freq 1480000
	set_param_big go_hispeed_load 90
	set_param_big target_loads "80 780000:6 880000:37 980000:59 1180000:42 1280000:67 1580000:96"
	set_param_big min_sample_time 18000
   	elif [ $PROFILE -eq 3 ];then
	set_value "0:1280000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1280000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1480000:198000"
	set_param_little hispeed_freq 1280000
	set_param_little target_loads "80 1580000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1880000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in universal7420* | exynos7420*) #EXYNOS7420 (S6)
	set_value 380000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 780000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:380000 4:780000" /sys/module/msm_performance/parameters/cpu_min_freq
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_param_little above_hispeed_delay "38000 1280000:78000 1380000:98000 1480000:58000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 96
	set_param_little target_loads "80 480000:28 580000:19 680000:37 780000:51 880000:61 1080000:83 1180000:66 1280000:91 1380000:96"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "98000 1880000:138000"
	set_param_big hispeed_freq 1480000
	set_param_big go_hispeed_load 97
	set_param_big target_loads "80 880000:74 980000:56 1080000:80 1180000:92 1380000:85 1480000:93 1580000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_param_little above_hispeed_delay "58000 1280000:18000 1380000:98000 1480000:58000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 480000:29 580000:12 680000:69 780000:22 880000:36 1080000:80 1180000:89 1480000:63"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "18000 1480000:78000 1580000:98000 1880000:138000"
	set_param_big hispeed_freq 1380000
	set_param_big go_hispeed_load 96
	set_param_big target_loads "80 880000:27 980000:44 1080000:71 1180000:32 1280000:64 1380000:78 1480000:87 1580000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_param_little above_hispeed_delay "18000 1280000:98000 1380000:38000 1480000:58000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 480000:26 580000:32 680000:69 780000:50 880000:15 1080000:80 1180000:85 1480000:56"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "18000 880000:38000 980000:58000 1080000:18000 1180000:38000 1280000:18000 1480000:78000 1580000:98000 1880000:38000"
	set_param_big hispeed_freq 780000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 880000:4 980000:29 1080000:57 1280000:66 1480000:44 1580000:66 1680000:98"
	set_param_big min_sample_time 18000
   	elif [ $PROFILE -eq 3 ];then
	set_value "0:1280000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1280000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1380000:198000"
	set_param_little hispeed_freq 1280000
	set_param_little target_loads "80 1480000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1880000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in kirin970* | hi3670* | hi3670*)  # Huawei Kirin 970
	set_value 480000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 680000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:480000 4:680000" /sys/module/msm_performance/parameters/cpu_min_freq
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0	
	if [ $PROFILE -eq 0 ];then
	set_param_little above_hispeed_delay "18000 1380000:38000 1480000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 980000:60 1180000:87 1380000:70 1480000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1580000:98000 1780000:138000"
	set_param_big hispeed_freq 1280000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 1280000:98 1480000:91 1580000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_param_little above_hispeed_delay "18000 1480000:38000 1680000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 980000:61 1180000:88 1380000:70 1480000:96"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "18000 1580000:98000 1780000:138000"
	set_param_big hispeed_freq 1280000
	set_param_big go_hispeed_load 94
	set_param_big target_loads "80 980000:72 1280000:77 1580000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_param_little above_hispeed_delay "18000 1680000:38000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 980000:63 1180000:76 1480000:96"
	set_param_little min_sample_time 78000
	set_param_big above_hispeed_delay "18000 1580000:98000 1780000:38000"
	set_param_big hispeed_freq 1480000
	set_param_big go_hispeed_load 86
	set_param_big target_loads "80 980000:57 1280000:70 1480000:65 1580000:98"
	set_param_big min_sample_time 18000
   	elif [ $PROFILE -eq 3 ];then
	set_value "0:1480000 4:1280000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1480000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1680000:198000"
	set_param_little hispeed_freq 1480000
	set_param_little target_loads "80 1780000:90"
	set_param_little min_sample_time 38000
	set_value 1280000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1780000:198000"
	set_param_big hispeed_freq 1280000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in kirin960* | hi3660*)  # Huawei Kirin 960
	set_value 480000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 880000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:480000 4:880000" /sys/module/msm_performance/parameters/cpu_min_freq
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0	
	if [ $PROFILE -eq 0 ];then
	set_param_little above_hispeed_delay "38000 1680000:98000"
	set_param_little hispeed_freq 1380000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 980000:93 1380000:97"
	set_param_little min_sample_time 58000
	set_param_big above_hispeed_delay "18000 1780000:138000"
	set_param_big hispeed_freq 880000
	set_param_big go_hispeed_load 84
	set_param_big target_loads "80 1380000:98"
	set_param_big min_sample_time 38000
	elif [ $PROFILE -eq 1 ];then
	set_param_little above_hispeed_delay "38000 1680000:98000"
	set_param_little hispeed_freq 1380000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 980000:97 1380000:78 1680000:98"
	set_param_little min_sample_time 78000
	set_param_big above_hispeed_delay "18000 1380000:98000 1780000:138000"
	set_param_big hispeed_freq 880000
	set_param_big go_hispeed_load 95
	set_param_big target_loads "80 1380000:59 1780000:98"
	set_param_big min_sample_time 38000
	elif [ $PROFILE -eq 2 ];then
	set_param_little above_hispeed_delay "38000"
	set_param_little hispeed_freq 1380000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 980000:58 1380000:75 1680000:98"
	set_param_little min_sample_time 78000
	set_param_big above_hispeed_delay "18000 1380000:38000 1780000:138000"
	set_param_big hispeed_freq 880000
	set_param_big go_hispeed_load 93
	set_param_big target_loads "80 1380000:59 1780000:97"
	set_param_big min_sample_time 38000
   	elif [ $PROFILE -eq 3 ];then
	set_value "0:1380000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1380000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1680000:198000"
	set_param_little hispeed_freq 1380000
	set_param_little target_loads "80 1780000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1780000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in kirin950* | hi3650* | kirin955* | hi3655*) # Huawei Kirin 950
	set_value 480000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value 780000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:480000 4:780000" /sys/module/msm_performance/parameters/cpu_min_freq
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_param_little above_hispeed_delay "18000 1480000:98000"
	set_param_little hispeed_freq 1280000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 780000:62 980000:71 1280000:77 1480000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1480000:98000 1780000:138000"
	set_param_big hispeed_freq 780000
	set_param_big go_hispeed_load 80
	set_param_big target_loads "80 1180000:89 1480000:98"
	set_param_big min_sample_time 38000
	elif [ $PROFILE -eq 1 ];then
	set_param_little above_hispeed_delay "18000 1480000:98000"
	set_param_little hispeed_freq 1280000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 780000:69 980000:76 1280000:80 1480000:96"
	set_param_little min_sample_time 58000
	set_param_big above_hispeed_delay "18000 1780000:138000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 80
	set_param_big target_loads "80 1180000:75 1480000:93 1780000:98"
	set_param_big min_sample_time 38000
	elif [ $PROFILE -eq 2 ];then
	set_param_little above_hispeed_delay "18000 1480000:38000"
	set_param_little hispeed_freq 1280000
	set_param_little go_hispeed_load 97
	set_param_little target_loads "80 780000:66 980000:17 1280000:81 1480000:96 1780000:87"
	set_param_little min_sample_time 78000
	set_param_big above_hispeed_delay "18000 1780000:138000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 80
	set_param_big target_loads "80 1180000:65 1480000:85 1780000:96"
	set_param_big min_sample_time 38000
   	elif [ $PROFILE -eq 3 ];then
	set_value "0:1480000 4:1180000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1480000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1480000:198000"
	set_param_little hispeed_freq 1480000
	set_param_little target_loads "80 1780000:90"
	set_param_little min_sample_time 38000
	set_value 1180000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1780000:198000"
	set_param_big hispeed_freq 1180000
	set_param_big target_loads "80 1980000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in mt6797*) #Helio X25 / X20
	set_value 280000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:280000 4:280000" /sys/module/msm_performance/parameters/cpu_min_freq
	# CORE CONTROL
	set_value 40 /proc/hps/down_threshold
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7,8"
	write /dev/cpuset/top-app/cpus "0-3,4-7,8"
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_value 90 /proc/hps/up_threshold
	set_value "2 2 0" /proc/hps/num_base_perf_serv
	set_param_little above_hispeed_delay "18000 1380000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 94
	set_param_little target_loads "80 380000:15 480000:25 780000:36 880000:80 980000:66 1180000:91 1280000:96"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1380000:98000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 94
	set_param_big target_loads "80 380000:15 480000:25 780000:36 880000:80 980000:66 1180000:91 1280000:96"
	set_param_big min_sample_time 18000	
	elif [ $PROFILE -eq 1 ];then
	set_value 80 /proc/hps/up_threshold
	set_value "3 3 0" /proc/hps/num_base_perf_serv
	set_param_little above_hispeed_delay "18000 1380000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 93
	set_param_little target_loads "80 380000:8 580000:14 680000:9 780000:41 880000:56 1080000:65 1180000:92 1380000:85 1480000:97"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1380000:98000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 93
	set_param_big target_loads "80 380000:8 580000:14 680000:9 780000:41 880000:56 1080000:65 1180000:92 1380000:85 1480000:97"
	set_param_big min_sample_time 18000	
	elif [ $PROFILE -eq 2 ];then
	set_value 70 /proc/hps/up_threshold
	set_value "3 3 1" /proc/hps/num_base_perf_serv
	set_param_little above_hispeed_delay "18000 1380000:58000 1480000:98000 1680000:38000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 85
	set_param_little target_loads "80 380000:10 780000:57 1080000:27 1180000:65 1280000:82 1380000:6 1480000:80 1580000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1380000:58000 1480000:98000 1680000:38000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 85
	set_param_big target_loads "80 380000:10 780000:57 1080000:27 1180000:65 1280000:82 1380000:6 1480000:80 1580000:98"
	set_param_big min_sample_time 18000	
   	elif [ $PROFILE -eq 3 ];then
	set_value "0:1280000 4:1280000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 60 /proc/hps/up_threshold
	set_value "4 4 1" /proc/hps/num_base_perf_serv
	set_value 1280000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1680000:198000"
	set_param_little hispeed_freq 1280000
	set_param_little target_loads "80 1780000:90"
	set_param_little min_sample_time 38000
	set_value 1280000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1680000:198000"
	set_param_big hispeed_freq 1280000
	set_param_big target_loads "80 1780000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in mt6795*) #Helio X10
	set_value 380000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:380000 4:380000" /sys/module/msm_performance/parameters/cpu_min_freq
	# CORE CONTROL
	set_value 40 /proc/hps/down_threshold
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "2-3"
	write /dev/cpuset/system-background/cpus "0-3"
	write /dev/cpuset/foreground/cpus "0-3,4-7"
	write /dev/cpuset/top-app/cpus "0-3,4-7"
	if [ $PROFILE -eq 0 ];then
	set_value 90 /proc/hps/up_threshold
	set_value 2 /proc/hps/num_base_perf_serv
	set_param_little above_hispeed_delay "38000 1280000:18000 1480000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 780000:51 1180000:65 1280000:83 1480000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "38000 1280000:18000 1480000:98000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 780000:51 1180000:65 1280000:83 1480000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_value 80 /proc/hps/up_threshold
	set_value 3 /proc/hps/num_base_perf_serv
	set_param_little above_hispeed_delay "18000 1480000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 780000:60 1180000:86 1280000:79 1480000:97"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "18000 1480000:98000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 780000:60 1180000:86 1280000:79 1480000:97"
	set_param_big min_sample_time 38000
	elif [ $PROFILE -eq 2 ];then
	set_value 70 /proc/hps/up_threshold
	set_value 3 /proc/hps/num_base_perf_serv
	set_param_little above_hispeed_delay "38000 1580000:98000"
	set_param_little hispeed_freq 1480000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 780000:61 1180000:65 1280000:83 1480000:63 1580000:96"
	set_param_little min_sample_time 38000
	set_param_big above_hispeed_delay "38000 1580000:98000"
	set_param_big hispeed_freq 1480000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 780000:61 1180000:65 1280000:83 1480000:63 1580000:96"
	set_param_big min_sample_time 38000
   	elif [ $PROFILE -eq 3 ];then
	set_value "0:1280000 4:1280000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 60 /proc/hps/up_threshold
	set_value 4 /proc/hps/num_base_perf_serv
	set_value 1280000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1580000:198000"
	set_param_little hispeed_freq 1280000
	set_param_little target_loads "80 1880000:90"
	set_param_little min_sample_time 38000
	set_value 1280000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1580000:198000"
	set_param_big hispeed_freq 1280000
	set_param_big target_loads "80 1880000:90"
	set_param_big min_sample_time 38000
	fi
	esac
    case ${SOC} in moorefield*) # Intel Atom
	set_value 480000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_value "0:480000 2:480000" /sys/module/msm_performance/parameters/cpu_min_freq
	# shared interactive parameters
	set_param_little timer_rate 20000
	set_param_little timer_slack 180000
	set_param_little boost 0
	set_param_little boostpulse_duration 0
	set_param_big timer_rate 20000
	set_param_big timer_slack 180000
	set_param_big boost 0
	set_param_big boostpulse_duration 0
	if [ $PROFILE -eq 0 ];then
	set_param_little above_hispeed_delay "18000 1480000:98000"
	set_param_little hispeed_freq 1180000
	set_param_little go_hispeed_load 95
	set_param_little target_loads "80 580000:56 680000:44 780000:33 880000:48 980000:62 1080000:74 1280000:89 1480000:98"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1480000:98000"
	set_param_big hispeed_freq 1180000
	set_param_big go_hispeed_load 95
	set_param_big target_loads "80 580000:56 680000:44 780000:33 880000:48 980000:62 1080000:74 1280000:89 1480000:98"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 1 ];then
	set_param_little above_hispeed_delay "18000 1480000:98000"
	set_param_little hispeed_freq 1380000
	set_param_little go_hispeed_load 98
	set_param_little target_loads "80 580000:53 680000:38 880000:49 980000:60 1180000:65 1280000:82 1380000:63 1480000:97"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "18000 1480000:98000"
	set_param_big hispeed_freq 1380000
	set_param_big go_hispeed_load 98
	set_param_big target_loads "80 580000:53 680000:38 880000:49 980000:60 1180000:65 1280000:82 1380000:63 1480000:97"
	set_param_big min_sample_time 18000
	elif [ $PROFILE -eq 2 ];then
	set_param_little above_hispeed_delay "38000 1580000:98000 1680000:38000"
	set_param_little hispeed_freq 1480000
	set_param_little go_hispeed_load 95
	set_param_little target_loads "80 580000:59 680000:36 780000:75 880000:39 1080000:56 1380000:52 1480000:57 1580000:97"
	set_param_little min_sample_time 18000
	set_param_big above_hispeed_delay "38000 1580000:98000 1680000:38000"
	set_param_big hispeed_freq 1480000
	set_param_big go_hispeed_load 95
	set_param_big target_loads "80 580000:59 680000:36 780000:75 880000:39 1080000:56 1380000:52 1480000:57 1580000:97"
	set_param_big min_sample_time 18000
   	elif [ $PROFILE -eq 3 ];then
	set_value "0:1380000 2:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
	set_value 1380000 ${C0_CPUFREQ_DIR}/scaling_min_freq
	set_param_little above_hispeed_delay "18000 1680000:198000"
	set_param_little hispeed_freq 1380000
	set_param_little target_loads "80 1780000:90"
	set_param_little min_sample_time 38000
	set_value 1380000 ${C1_CPUFREQ_DIR}/scaling_min_freq
	set_param_big above_hispeed_delay "18000 1680000:198000"
	set_param_big hispeed_freq 1380000
	set_param_big target_loads "80 1780000:90"
	set_param_big min_sample_time 38000
fi
esac
case ${SOC} in msm8939* | msm8952*)  #sd615/616/617 by@ 橘猫520
	if [ $PROFILE -eq 0 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	elif [ $PROFILE -eq 1 ];then
	set_param "cpu${bcores}" hispeed_freq 400000
	set_param cpu0 hispeed_freq 883000
	set_param "cpu${bcores}" target_loads "98 40000:40 499000:80 533000:95 800000:75 998000:99"
	set_param cpu0 target_loads "98 883000:40 1036000:80 1113000:95 1267000:99"
	set_param "cpu${bcores}" above_hispeed_delay "20000 499000:60000 533000:150000"
	set_param cpu0 above_hispeed_delay "20000 1036000:60000 1130000:150000"
	set_param cpu0 min_sample_time 40000
	set_param "cpu${bcores}" min_sample_time 10000
	set_param "cpu${bcores}" go_hispeed_load 99
	set_param cpu0 go_hispeed_load 99
	set_param "cpu${bcores}" boostpulse_duration 80000
	set_param cpu0 boostpulse_duration 80000
	set_param "cpu${bcores}" use_sched_load 1
	set_param cpu0 use_sched_load 1
	set_param "cpu${bcores}" use_migration_notif 1
	set_param cpu0 use_migration_notif 1
	set_param "cpu${bcores}" boost 0
	set_param cpu0 boost 0
	elif [ $PROFILE -eq 2 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
   	elif [ $PROFILE -eq 3 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	fi
	esac
    case ${SOC} in kirin650* | kirin655* | kirin658* | kirin659* | hi625*)  #KIRIN650 by @橘猫520
	if [ $PROFILE -eq 0 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	elif [ $PROFILE -eq 1 ];then
	set_param cpu0 hispeed_freq 807000
	set_param "cpu${bcores}" hispeed_freq 1402000
	set_param cpu0 target_loads "98 480000:75 807000:95 1306000:99"
	set_param "cpu${bcores}" target_loads "98 1402000:95"
	set_param cpu0 above_hispeed_delay "20000 480000:60000 807000:150000"
	set_param "cpu${bcores}" above_hispeed_delay "20000 1402000:160000"
	set_param "cpu${bcores}" min_sample_time 50000
	set_param cpu0 min_sample_time 50000
	set_param "cpu${bcores}" boost 0
	set_param cpu0 boost 0
	set_param "cpu${bcores}" go_hispeed_load 99
	set_param cpu0 go_hispeed_load 99
	set_param "cpu${bcores}" boostpulse_duration 80000
	set_param cpu0 boostpulse_duration 80000
	set_param "cpu${bcores}" use_sched_load 1
	set_param cpu0 use_sched_load 1
	set_param "cpu${bcores}" use_migration_notif 1
	set_param cpu0 use_migration_notif 1
	elif [ $PROFILE -eq 2 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
   	elif [ $PROFILE -eq 3 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	fi
	esac
    case ${SOC} in universal9810* | exynos9810*) # S9 exynos_9810 by @橘猫520
	if [ $PROFILE -eq 0 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	elif [ $PROFILE -eq 1 ];then
	set_param cpu0 boostpulse_duration 4000
	set_param "cpu${bcores}" boostpulse_duration 4000
	set_param cpu0 boost 1
	set_param "cpu${bcores}" boost 1
	set_param cpu0 timer_rate 20000
	set_param "cpu${bcores}" timer_rate 20000
	set_param cpu0 timer_slack 10000
	set_param "cpu${bcores}" timer_slack 10000
	set_param cpu0 min_sample_time 12000
	set_param "cpu${bcores}" min_sample_time 12000
	set_param cpu0 io_is_busy 0
	set_param "cpu${bcores}" io_is_busy 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param "cpu${bcores}" ignore_hispeed_on_notif 0
	set_param "cpu${bcores}" go_hispeed_load 73
	set_param cpu0 go_hispeed_load 65
	set_param "cpu${bcores}" hispeed_freq 1066000
	set_param cpu0 hispeed_freq 715000
	set_param "cpu${bcores}" above_hispeed_delay "4000 741000:77000 962000:99000 1170000:110000 1469000:130000 1807000:140000 2002000:1500000 2314000:160000 2496000:171000 2652000:184000 2704000:195000"
	set_param cpu0 above_hispeed_delay "4000 455000:77000 715000:95000 1053000:110000 1456000:130000 1690000:1500000 1794000:163000"
	set_param "cpu${bcores}" target_loads "55 741000:44 962000:51 1170000:58 1469000:66 1807000:73 2002000:82 2314000:89 2496000:93 2652000:97 2704000:100"
	set_param cpu0 target_loads "45 455000:48 715000:68 949000:71 1248000:86 1690000:91 1794000:100"
	elif [ $PROFILE -eq 2 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
   	elif [ $PROFILE -eq 3 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
fi
esac
case ${SOC} in apq8026* | apq8028* | apq8030* | msm8226* | msm8228* | msm8230* | msm8626* | msm8628* | msm8630* | msm8926* | msm8928* | msm8930*)  #sd400 series by @cjybyjk
	if [ $PROFILE -eq 0 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	elif [ $PROFILE -eq 1 ];then
	set_param_all go_hispeed_load 99
	set_param_all above_hispeed_delay "20000 600000:60000 787000:150000"
	set_param_all timer_rate 20000
	set_param_all hispeed_freq 600000
	set_param_all timer_slack 80000
	set_param_all target_loads "98 384000:75 600000:95 787000:40 998000:80 1094000:99"
	set_param_all min_sample_time 50000
	set_param_all boost 0
	elif [ $PROFILE -eq 2 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
   	elif [ $PROFILE -eq 3 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
fi
esac
case ${SOC} in apq8016* | msm8916* | msm8216* | msm8917* | msm8217*)  #sd410/sd425 series by @cjybyjk
	if [ $PROFILE -eq 0 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	elif [ $PROFILE -eq 1 ];then
	set_param_all go_hispeed_load 99
	set_param_all above_hispeed_delay "0 998000:25000 1152000:41000 1209000:55000"
	set_param_all timer_rate 60000
	set_param_all hispeed_freq 800000
	set_param_all timer_slack 480000
	set_param_all target_loads "98 400000:68 553000:82 800000:72 998000:92 1094000:83 1152000:99 1209000:100"
	set_param_all min_sample_time 0
	set_param_all ignore_hispeed_on_notif 0
	set_param_all boost 0
	set_param_all fast_ramp_down 0
	set_param_all align_windows 0
	set_param_all use_migration_notif 1
	set_param_all use_sched_load 0
	set_param_all max_freq_hysteresis 0
	set_param_all boostpulse_duration 0
	elif [ $PROFILE -eq 2 ];then
	set_param_all go_hispeed_load 99
	set_param_all above_hispeed_delay "0 998000:25000 1152000:41000 1209000:55000"
	set_param_all timer_rate 60000
	set_param_all hispeed_freq 1094000
	set_param_all timer_slack 480000
	set_param_all target_loads "80 400000:68 553000:82 800000:72 998000:92 1094000:83 1152000:99 1209000:100"
	set_param_all min_sample_time 0
	set_param_all ignore_hispeed_on_notif 0
	set_param_all boost 0
	set_param_all fast_ramp_down 0
	set_param_all align_windows 0
	set_param_all use_migration_notif 1
	set_param_all use_sched_load 0
	set_param_all max_freq_hysteresis 0
	set_param_all boostpulse_duration 0
   	elif [ $PROFILE -eq 3 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
fi
esac
case ${SOC} in msm8937*)  #sd430 series by @cjybyjk
	if [ $PROFILE -eq 0 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	elif [ $PROFILE -eq 1 ];then
	set_param_little go_hispeed_load 99
	set_param_little above_hispeed_delay "20000 960000:50000 1094000:150000"
	set_param_little timer_rate 20000
	set_param_little hispeed_freq 960000
	set_param_little timer_slack 80000
	set_param_little target_loads "98 768000:75 960000:95 1094000:40 1209000:80 1344000:99"
	set_param_little min_sample_time 50000
	set_param_little boost 0
	set_param_little boostpulse_duration 80000
	set_param_big go_hispeed_load 99
	set_param_big above_hispeed_delay "20000 998000:60000 1094000:150000"
	set_param_big timer_rate 20000
	set_param_big hispeed_freq 998000
	set_param_big timer_slack 80000
	set_param_big target_loads "98 902000:75 998000:95 1094000:99"
	set_param_big min_sample_time 50000
	set_param_big boost 0
	set_param_big boostpulse_duration 80000
	elif [ $PROFILE -eq 2 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
   	elif [ $PROFILE -eq 3 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
fi
esac
case ${SOC} in msm8940*)  #sd435 series by @cjybyjk
	if [ $PROFILE -eq 0 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	elif [ $PROFILE -eq 1 ];then
	set_param_little go_hispeed_load 110
	set_param_little above_hispeed_delay 20000
	set_param_little timer_rate 60000
	set_param_little hispeed_freq 902000
	set_param_little timer_slack 380000
	set_param_little target_loads "85 768000:70 902000:82 998000:84 1094000:82"
	set_param_little min_sample_time 0
	set_param_little ignore_hispeed_on_notif 0
	set_param_little boost 0
	set_param_little fast_ramp_down 0
	set_param_little align_windows 0
	set_param_little use_migration_notif 1
	set_param_little use_sched_load 1
	set_param_little max_freq_hysteresis 0
	set_param_little boostpulse_duration 0
	set_param_big go_hispeed_load 110
	set_param_big above_hispeed_delay 20000
	set_param_big timer_rate 60000
	set_param_big hispeed_freq 1094000
	set_param_big timer_slack 380000
	set_param_big target_loads "85 960000:70 1094000:82 1209000:84 1248000:82"
	set_param_big min_sample_time 0
	set_param_big ignore_hispeed_on_notif 0
	set_param_big boost 0
	set_param_big fast_ramp_down 0
	set_param_big align_windows 0
	set_param_big use_migration_notif 1
	set_param_big use_sched_load 1
	set_param_big max_freq_hysteresis 0
	set_param_big boostpulse_duration 0
	elif [ $PROFILE -eq 2 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
   	elif [ $PROFILE -eq 3 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
fi
esac
case ${SOC} in sdm450*)  #sd450 series by @cjybyjk
	if [ $PROFILE -eq 0 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	elif [ $PROFILE -eq 1 ];then
	set_param_big hispeed_freq 1401000
	set_param_little hispeed_freq 1036000
	set_param_big above_hispeed_delay "20000 1401000:60000 1689000:150000"
	set_param_little above_hispeed_delay "20000 1036000:60000 1401000:150000"
	set_param_big target_loads "98 1036000:80 1209000:95 1401000:99"
	set_param_little target_loads "98 652000:80 1036000:95 1401000:99"
	set_param_all min_sample_time 24000
	set_param_all use_sched_load 1
	set_param_all use_migration_notif 1
	set_param_all go_hispeed_load 99
	elif [ $PROFILE -eq 2 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
   	elif [ $PROFILE -eq 3 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
fi
esac
case ${SOC} in mt6755*)  #mtk6755 series by @cjybyjk
	if [ $PROFILE -eq 0 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
	elif [ $PROFILE -eq 1 ];then
	set_param_little go_hispeed_load 99
	set_param_little above_hispeed_delay "0 689000:61000 871000:65000 1014000:71000 1144000:75000"
	set_param_little timer_rate 60000
	set_param_little hispeed_freq 689000
	set_param_little timer_slack 480000
	set_param_little target_loads "98 338000:68 494000:82 598000:72 689000:92 871000:83 1014000:99 1144000:100"
	set_param_little min_sample_time 0
	set_param_little ignore_hispeed_on_notif 0
	set_param_little boost 0
	set_param_little fast_ramp_down 0
	set_param_little align_windows 0
	set_param_little use_migration_notif 1
	set_param_little use_sched_load 0
	set_param_little max_freq_hysteresis 0
	set_param_little boostpulse_duration 0
	set_param_little io_is_busy 0
	set_param_big go_hispeed_load 99
	set_param_big above_hispeed_delay "20000 1027000:60000 1196000:150000"
	set_param_big timer_rate 20000
	set_param_big hispeed_freq 663000
	set_param_big timer_slack 80000
	set_param_big target_loads "98 663000:40 1027000:80 1196000:95 1573000:75 1755000:99 1950000:100"
	set_param_big min_sample_time 50000
	set_param_big ignore_hispeed_on_notif 0
	set_param_big boost 0
	set_param_big fast_ramp_down 0
	set_param_big align_windows 0
	set_param_big use_migration_notif 1
	set_param_big use_sched_load 0
	set_param_big max_freq_hysteresis 0
	set_param_big boostpulse_duration 80000
	set_param_big io_is_busy 0
	elif [ $PROFILE -eq 2 ];then
	set_param_little go_hispeed_load 99
	set_param_little above_hispeed_delay "0 689000:41000 871000:45000 1014000:51000 1144000:55000"
	set_param_little timer_rate 60000
	set_param_little hispeed_freq 1014000
	set_param_little timer_slack 480000
	set_param_little target_loads "80 338000:68 494000:82 598000:72 689000:92 871000:83 1014000:99 1144000:100"
	set_param_little min_sample_time 0
	set_param_little ignore_hispeed_on_notif 0
	set_param_little boost 0
	set_param_little fast_ramp_down 0
	set_param_little align_windows 0
	set_param_little use_migration_notif 1
	set_param_little use_sched_load 0
	set_param_little max_freq_hysteresis 0
	set_param_little boostpulse_duration 0
	set_param_little io_is_busy 0
	set_param_big go_hispeed_load 99
	set_param_big above_hispeed_delay "20000 1027000:60000 1196000:150000"
	set_param_big timer_rate 20000
	set_param_big hispeed_freq 663000
	set_param_big timer_slack 80000
	set_param_big target_loads "98 663000:40 1027000:80 1196000:95 1573000:75 1755000:99 1950000:100"
	set_param_big min_sample_time 50000
	set_param_big ignore_hispeed_on_notif 0
	set_param_big boost 0
	set_param_big fast_ramp_down 0
	set_param_big align_windows 0
	set_param_big use_migration_notif 1
	set_param_big use_sched_load 0
	set_param_big max_freq_hysteresis 0
	set_param_big boostpulse_duration 80000
	set_param_big io_is_busy 0
   	elif [ $PROFILE -eq 3 ];then
	LOGDATA "#  [WARNING] $PROFILE_M PROFILE GOVERNOR TWEAKS ARE NOT AVAILABLE FOR YOUR DEVICE"
   	fi
   	esac
	after_modify
fi
fi
if [[ "$available_governors" == *"schedutil"* ]] || [[ "$available_governors" == *"sched"* ]] || [[ "$available_governors" == *"blu_schedutil"* ]] || [[ "$available_governors" == *"pwrutil"* ]] || [[ "$available_governors" == *"pwrutilx"* ]]; then
if [ ${HMP} -eq 0 ];then
EAS=1
	if [[ "$available_governors" == *"sched"* ]]; then
	set_value "sched" $SVD/scaling_governor 
	set_value "sched" $GLD/scaling_governor
	elif [[ "$available_governors" == *"schedutil"* ]]; then
	set_value "schedutil" $SVD/scaling_governor 
	set_value "schedutil" $GLD/scaling_governor
	fi
    govn=$(cat ${GOV_PATH_L}/scaling_governor)
	case ${govn} in sched* | blu_sched* | pwrutil*) #exynos9810
	govn=$(cat ${GOV_PATH_L}/scaling_governor)
	;;
	*)
	govn="schedutil"
	;;
	esac
	before_modify_eas ${govn}
	LOGDATA "#  [INFO] EAS KERNEL DETECTED"
	LOGDATA "#  [INFO] TUNING ${govn}"
	set_param_HMP sched_spill_load 90
	set_param_HMP sched_prefer_sync_wakee_to_waker 1
	set_param_HMP sched_freq_inc_notify 3000000
	var1=$((${cores}/2))
	var2=$((${cores}/4))
	var3=$((${var2}+1))
	# avoid permission problem, do not set 0444
	write /dev/cpuset/background/cpus "$var2-$var3"
	write /dev/cpuset/system-background/cpus "0-$var3"
	write /dev/cpuset/foreground/cpus "0-$var3,$var1-${coresmax}"
	write /dev/cpuset/top-app/cpus "0-$var3,$var1-${coresmax}"
	set_boost 80
	sleep 2
	if [ $PROFILE -eq 0 ];then
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost 5
	elif [ $PROFILE -eq 1 ]; then
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost 8
	elif [ $PROFILE -eq 2 ]; then
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost 10
	elif [ $PROFILE -eq 3 ]; then
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost 17
	fi
	case ${SOC} in sdm845* | sda845*) #sd845 
	if [ $PROFILE -eq 0 ];then
	set_value "0:1680000 4:1880000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_boost_freq "0:1080000 4:0"
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1180000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 0
	set_param_eas ${govn} cpu4 hispeed_freq 1080000
	set_param_eas ${govn} cpu4 hispeed_load 90
	set_param_eas ${govn} cpu4 pl 0
	elif [ $PROFILE -eq 1 ]; then
	set_value "0:1780000 4:2280000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_boost_freq "0:1080000 4:0"
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1280000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 0
	set_param_eas ${govn} cpu4 hispeed_freq 1280000
	set_param_eas ${govn} cpu4 hispeed_load 90
	set_param_eas ${govn} cpu4 pl 0
	elif [ $PROFILE -eq 2 ]; then
	set_value "0:1780000 4:2880000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_boost_freq "0:1180000 4:0"
	set_value 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1380000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 1
	set_param_eas ${govn} cpu4 hispeed_freq 1480000
	set_param_eas ${govn} cpu4 hispeed_load 95
	set_param_eas ${govn} cpu4 pl 1
	elif [ $PROFILE -eq 3 ]; then # Turbo
	set_value "0:1780000 4:2280000" /sys/module/msm_performance/parameters/cpu_max_freq
	set_boost_freq "0:1480000 4:1680000"
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1480000
	set_param_eas ${govn} cpu0 hispeed_load 85
	set_param_eas ${govn} cpu0 pl 1
	set_param_eas ${govn} cpu4 hispeed_freq 1480000
	set_param_eas ${govn} cpu4 hispeed_load 90
	set_param_eas ${govn} cpu4 pl 1
	fi
	;;
	*)
	batt_freq_l=$(awk -v x=$maxfreq_l 'BEGIN{print x*0.9438202247191011}')
    batt_freq_l=$(round ${batt_freq_l} 0)
	batt_freq=$(awk -v x=$maxfreq_b 'BEGIN{print x*0.6527777777777778}')
    batt_freq=$(round ${batt_freq} 0)
	balc_freq=$(awk -v x=$maxfreq_b 'BEGIN{print x*0.7916666666666667}')
    balc_freq=$(round ${balc_freq} 0)
	if [ $PROFILE -eq 0 ];then
	set_value "0:$batt_freq_l ${bcores}:$batt_freq" /sys/module/msm_performance/parameters/cpu_max_freq
	set_boost_freq "0:1080000 ${bcores}:0"
	set_value 2 /sys/devices/system/cpu/cpu${bcores}/core_ctl/min_cpus
	set_value 2 /sys/devices/system/cpu/cpu${bcores}/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1180000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 0
	set_param_eas ${govn} cpu${bcores} hispeed_freq 1080000
	set_param_eas ${govn} cpu${bcores} hispeed_load 90
	set_param_eas ${govn} cpu${bcores} pl 0
	elif [ $PROFILE -eq 1 ]; then
	set_value "0:$maxfreq_l ${bcores}:$balc_freq" /sys/module/msm_performance/parameters/cpu_max_freq
	set_boost_freq "0:1080000 ${bcores}:0"
	set_value 2 /sys/devices/system/cpu/cpu${bcores}/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu${bcores}/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1280000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 0
	set_param_eas ${govn} cpu${bcores} hispeed_freq 1280000
	set_param_eas ${govn} cpu${bcores} hispeed_load 90
	set_param_eas ${govn} cpu${bcores} pl 0
	elif [ $PROFILE -eq 2 ]; then
	set_value "0:$maxfreq_l ${bcores}:$maxfreq_b" /sys/module/msm_performance/parameters/cpu_max_freq
	set_boost_freq "0:1180000 ${bcores}:0"
	set_value 2 /sys/devices/system/cpu/cpu${bcores}/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu${bcores}/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1380000
	set_param_eas ${govn} cpu0 hispeed_load 90
	set_param_eas ${govn} cpu0 pl 1
	set_param_eas ${govn} cpu${bcores} hispeed_freq 1480000
	set_param_eas ${govn} cpu${bcores} hispeed_load 95
	set_param_eas ${govn} cpu${bcores} pl 1
	elif [ $PROFILE -eq 3 ]; then # Turbo
	set_value "0:$maxfreq_l ${bcores}:$balc_freq" /sys/module/msm_performance/parameters/cpu_max_freq
	set_boost_freq "0:1480000 ${bcores}:1680000"
	set_value 4 /sys/devices/system/cpu/cpu${bcores}/core_ctl/min_cpus
	set_value 4 /sys/devices/system/cpu/cpu${bcores}/core_ctl/max_cpus
	set_param_eas ${govn} cpu0 hispeed_freq 1480000
	set_param_eas ${govn} cpu0 hispeed_load 85
	set_param_eas ${govn} cpu0 pl 1
	set_param_eas ${govn} cpu${bcores} hispeed_freq 1480000
	set_param_eas ${govn} cpu${bcores} hispeed_load 90
	set_param_eas ${govn} cpu${bcores} pl 1
	fi
	;;
	esac
	after_modify_eas ${govn}
fi
fi
    # re-enable thermal & BCL core_control now
    echo 1 > /sys/module/msm_thermal/core_control/enabled
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
    write /sys/module/lpm_levels/parameters/sleep_disabled N
    for i in $( find /sys/module/msm_pm/modes/ -name suspend_enabled); do
     write $i 1;
    done;
    for i in $( find /sys/module/msm_pm/modes/ -name idle_enabled); do
     write $i 1;
    done;
}
# =========
# CPU Governor Tuning
# =========
if [ $support -ge 1 ] && [ $error -eq 0 ] ;then
cputuning
else
    LOGDATA "#  [×] SOC CHECK FAILED"
    LOGDATA "#  [INFO] THIS DEVICE IS UNSUPPORTED BY LKT"
fi
# Disable KSM to save CPU cycles
if [ -e /sys/kernel/mm/uksm/run ]; then
write /sys/kernel/mm/uksm/run "0";
resetprop -n ro.config.ksm.support false;
elif [ -e /sys/kernel/mm/ksm/run ]; then
write /sys/kernel/mm/ksm/run "0";
resetprop -n ro.config.ksm.support false;
fi;
# =========
# GPU Tweaks
# =========
if [ -e "/sys/module/adreno_idler" ]; then
if [ $PROFILE -le 1 ];then
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "10000"
	write /sys/module/adreno_idler/parameters/adreno_idler_downdifferential '40'
	write /sys/module/adreno_idler/parameters/adreno_idler_idlewait '24'
else
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "7000"
	write /sys/module/adreno_idler/parameters/adreno_idler_downdifferential '40'
	write /sys/module/adreno_idler/parameters/adreno_idler_idlewait '24'
fi
 LOGDATA "#  [INFO] ENABLING GPU ADRENO IDLER " 
 else
 LOGDATA "#  [WARNING] YOUR KERNEL DOESN'T SUPPORT ADRENO IDLER" 
 fi
# =========
# RAM TWEAKS
# =========
ramtuning
# =========
# I/O TWEAKS
# =========
LOGDATA "#  [INFO] TUNING STORAGE I/O SCHEDULER " 
sch=$(</sys/block/mmcblk0/queue/scheduler);
if [[ $sch == *"maple"* ]]
then
	set_io maple /sys/block/mmcblk0
	set_io maple /sys/block/sda
else
	set_io cfq /sys/block/mmcblk0
	set_io cfq /sys/block/sda
fi
for i in /sys/block/*; do
	write $i/queue/add_random 0
	write $i/queue/iostats 0
   	write $i/queue/nomerges 1
   	write $i/queue/rotational 0
   	write $i/queue/rq_affinity 1
done;
for i in /sys/block/*/queue/iosched; do
  echo 1 > $i/group_idle;
done;
for i in /sys/block/*/queue/iosched; do
  echo 0 > $i/low_latency;
done;
# =========
# REDUCE DEBUGGING
# =========
logdata "#  [INFO] CUTTING EXCESSIVE KERNEL DEBUGGING " 
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
sysctl -e -w kernel.panic_on_oops=0
sysctl -e -w kernel.panic=0
if [ -e /sys/module/logger/parameters/log_mode ]; then
 write /sys/module/logger/parameters/log_mode 2
fi;
if [ -e /sys/module/printk/parameters/console_suspend ]; then
 write /sys/module/printk/parameters/console_suspend 'Y'
fi;
for i in $( find /sys/ -name debug_mask); do
 write $i 0;
done;
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
for i in $($B ls /sys/class/scsi_disk/); do
 write /sys/class/scsi_disk/"$i"/cache_type "temporary none";
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
write /proc/sys/net/ipv4/tcp_ecn 2
write /proc/sys/net/ipv4/tcp_dsack 1
write /proc/sys/net/ipv4/tcp_low_latency 1
write /proc/sys/net/ipv4/tcp_timestamps 1
write /proc/sys/net/ipv4/tcp_sack 1
write /proc/sys/net/ipv4/tcp_window_scaling 1
# Increase WI-FI scan delay
# sqlite=/system/xbin/sqlite3 wifi_idle_wait=36000 
# =========
# Blocking Wakelocks
# =========
if [ -e "/sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker" ]; then
write /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;[timerfd];hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK"
fi
if [ -e "/sys/module/bcmdhd/parameters/wlrx_divide" ]; then
set_value 8 /sys/module/bcmdhd/parameters/wlrx_divide
fi
if [ -e "/sys/module/bcmdhd/parameters/wlctrl_divide" ]; then
set_value 8 /sys/module/bcmdhd/parameters/wlctrl_divide
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluetooth_timer" ]; then
set_value Y /sys/module/wakeup/parameters/enable_bluetooth_timer
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ipa_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_ipa_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_pno_wl_ws N" ]; then
set_value N /sys/module/wakeup/parameters/enable_wlan_pno_wl_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws N" ]; then
set_value N /sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws
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
if [ -e "/sys/module/smb135x_charger/parameters/use_wlock" ]; then
set_value N /sys/module/smb135x_charger/parameters/use_wlock
fi
if [ -e "/sys/module/wakeup/parameters/enable_smb135x_wake_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_smb135x_wake_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_si_wsk
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluesleep_ws" ]; then
set_value N /sys/module/wakeup/parameters/enable_bluesleep_ws
fi
if [ -e "/sys/module/bcmdhd/parameters/wlrx_divide" ]; then
set_value N /sys/module/bcmdhd/parameters/wlrx_divide
fi
if [ -e "/sys/module/bcmdhd/parameters/wlctrl_divide" ]; then
set_value N /sys/module/bcmdhd/parameters/wlctrl_divide
fi
if [ -e "/sys/module/xhci_hcd/parameters/wl_divide" ]; then
set_value N /sys/module/xhci_hcd/parameters/wl_divide
fi
if [ -e "/sys/module/smb135x_charger/parameters/use_wlock" ]; then
set_value N /sys/module/smb135x_charger/parameters/use_wlock
fi
# =========
# Google Services Drain fix by @Alcolawl @Oreganoian
# =========
echo "  [INFO] Fixing SystemUpdateService Battery Drain"
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
start perfd
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
exit 0
