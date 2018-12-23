
keytest() {
  ui_print "** Vol Key Test **"
  ui_print "** Press Vol UP **"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $KEYCHECK
  $KEYCHECK
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    ui_print "**  Vol key not detected **"
    abort "** Use name change method in TWRP **"
  fi
}

# Tell user aml is needed if applicable
#if $MAGISK && ! $SYSOVERRIDE; then
#  if $BOOTMODE; then LOC="/sbin/.core/img/*/system $MOUNTPATH/*/system"; else LOC="$MOUNTPATH/*/system"; fi
#  FILES=$(find $LOC -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" 2>/dev/null)
#  if [ ! -z "$FILES" ] && [ ! "$(echo $FILES | grep '/aml/')" ]; then
#    ui_print " "
#    ui_print "   ! Conflicting audio mod found!"
#    ui_print "   ! You will need to install !"
#    ui_print "   ! Audio Modification Library !"
#    sleep 3
#  fi
#fi

# GET OLD/NEW FROM ZIP NAME
case $(echo $(basename $ZIP) | tr '[:upper:]' '[:lower:]') in
  *batt*) PROFILEMODE=0;;
  *balanc*) PROFILEMODE=1;;
  *perf*) PROFILEMODE=2;;
  *turb*) PROFILEMODE=3;;
esac


# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
KEYCHECK=$INSTALLER/common/keycheck
chmod 755 $KEYCHECK


ui_print " "
if [ -z $PROFILEMODE ] ; then
  if keytest; then
    FUNCTION=chooseport
  else
    FUNCTION=chooseportold
    ui_print "** Volume button programming **"
    ui_print " "
    ui_print "** Press Vol UP again **"
    $FUNCTION "UP"
    ui_print "**  Press Vol DOWN **"
    $FUNCTION "DOWN"
  fi
  ui_print " "
  sleep "0.3"
  ui_print ".%%......%%..%%..%%%%%%."
  sleep "0.01"
  ui_print ".%%......%%.%%.....%%..."
  ui_print ".%%......%%%%......%%..."
  ui_print ".%%......%%.%%.....%%..."
  ui_print ".%%%%%%..%%..%%....%%..."
  ui_print "........................"
  ui_print " "
  sleep "0.3"
  ui_print "** LKT Profiles **"
  ui_print " "
  ui_print "   1. Battery"
  ui_print "   2. Balanced"
  ui_print "   3. Performance"
  ui_print "   4. Turbo"
  ui_print " "
  sleep "1"
  ui_print "** Please choose tweaks mode **"
  ui_print " "
  sleep "0.01"
  ui_print "   Vol(+) = Battery"
  ui_print "   Vol(-) = skip & show more .."
  ui_print " "

  if $FUNCTION; then
    PROFILEMODE=0
    ui_print "   Battery profile selected."
    ui_print " "

  else
  ui_print "** Please choose tweaks mode **"
  ui_print " "
  ui_print "   Vol(+) = Balanced"
  ui_print "   Vol(-) = skip & show more .."
  ui_print " "

  if $FUNCTION; then
    PROFILEMODE=1
    ui_print "   Balanced profile selected."
    ui_print " "

  else

  ui_print "** Please choose tweaks mode **"
  ui_print " "
  ui_print "   Vol(+) = Performance"
  ui_print "   Vol(-) = skip & show more .."
  ui_print " "

  if $FUNCTION; then
    PROFILEMODE=2
    ui_print "   Performance profile selected."
    ui_print " "

  else

  ui_print "** Please choose tweaks mode **"
  ui_print " "
  ui_print "   Vol(+) = Turbo"
  ui_print " "

  if $FUNCTION; then
    PROFILEMODE=3
    ui_print "   Turbo profile selected."
    ui_print " "

  else
    PROFILEMODE=1
    ui_print "   Incorrect entry."
    ui_print "   Balanced profile selected by default."
    ui_print " "
  fi
  fi
  fi
  fi
  else
    ui_print "   LKT Profile specified in zipname!"
  fi

 VER=$(cat ${INSTALLER}/module.prop | grep -oE 'version=v[0-9].[0-9].[0-9]+' | awk -F= '{ print $2 }' )
 sed -i "s/<PROFILE_MODE>/${PROFILEMODE}/g" ${INSTALLER}/common/service.sh
 sed -i "s/<VER>/${VER}/g" ${INSTALLER}/common/service.sh
    
    ui_print " "
    ui_print "   Installation was succesfull .."
    ui_print "   After you reboot .."
    ui_print "   You can check logs in /data/LKT.prop (use root explorer)"
 sleep "0.5"
    ui_print " "
    ui_print "   LINKS"
    ui_print "      - Telegram : t.me/LKT_XDA"
    ui_print "      - Github : github.com/Magisk-Modules-Repo/legendary_kernel_tweaks"
    ui_print "      - XDA Forums : forum.xda-developers.com/apps/magisk/xz-lxt-1-0-insane-battery-life-12h-sot-t3700688"




