ui_print " "
# Use the current running profile in case of upgrade
if $KEEPPROFILE ; then
	PROFILEMODE=$(cat /data/adb/.lkt_cur_level | tr -d '\n')
fi

  ui_print "   db      db   dD d888888b "
  ui_print "   88      88 ,8P   ~~88~~  "
  ui_print "   88      88,8P      88    "
  ui_print "   88      888b       88    "
  ui_print "   88booo. 88 88.     88    "
  ui_print "   Y88888P YP   YD    YP    "
  ui_print " "
  ui_print "   legendary.kernel.tweaks"
  ui_print " "
  ui_print "      BY-KOROM42 @XDA"
  ui_print " "
 
 sleep "1"

if [ -z $PROFILEMODE ] ; then
  ui_print " "

  ui_print "- LKT Profiles "
  ui_print " "
  ui_print "   1. Battery"
  ui_print "   2. Balanced (Recommended)"
  ui_print "   3. Performance"
  ui_print "   4. Turbo"
  ui_print " "
  ui_print "- Please choose tweaks mode "
  ui_print " "
  ui_print "   Vol(+) = Battery"
  ui_print "   Vol(-) = Show more options.."
  ui_print " "

  if $VKSEL; then
    PROFILEMODE=0
    ui_print "   Battery profile selected."
    ui_print " "

  else
  ui_print "- Please choose tweaks mode "
  ui_print " "
  ui_print "   Vol(+) = Balanced"
  ui_print "   Vol(-) = Show more options.."
  ui_print " "

  if $VKSEL; then
    PROFILEMODE=1
    ui_print "   Balanced profile selected."
    ui_print " "

  else

  ui_print "- Please choose tweaks mode "
  ui_print " "
  ui_print "   Vol(+) = Performance"
  ui_print "   Vol(-) = Show more options.."
  ui_print " "

  if $VKSEL; then
    PROFILEMODE=2
    ui_print "   Performance profile selected."
    ui_print " "

  else

  ui_print "- Please choose tweaks mode "
  ui_print " "
  ui_print "   Vol(+) = Turbo"
  ui_print " "

  if $VKSEL; then
    PROFILEMODE=3
    ui_print "   Turbo profile selected."
    ui_print " "

  else
    PROFILEMODE=1
    ui_print "- Incorrect entry."
    ui_print "- Balanced profile selected by default."
    ui_print " "
  fi
  fi
  fi
  fi
  elif [ ${PROFILEMODE} -eq 0 ];then
  ui_print "- Using saved profile = Battery"
  ui_print " "
  elif [ ${PROFILEMODE} -eq 1 ];then
  ui_print "- Using saved profile = Balanced"
  ui_print " "
  elif [ ${PROFILEMODE} -eq 2 ];then
  ui_print "- Using saved profile = Performance"
  ui_print " "
  elif [ ${PROFILEMODE} -eq 3 ];then
  ui_print "- Using saved profile = Turbo"
  ui_print " "
  else
  ui_print "- Using LKT Profile specified in zipname!"
  ui_print " "
  fi
  
  VER=$(cat ${TMPDIR}/module.prop | grep -oE 'version=v[0-9].[0-9]+' | awk -F= '{ print $2 }' )
  
  sed -i "s/<VER>/${VER}/g" ${TMPDIR}/common/service.sh
  sed -i "s/<PROFILE_MODE>/${PROFILEMODE}/g" ${TMPDIR}/common/service.sh

  ui_print "- Installation was successful !!.."
  ui_print " "
  ui_print "- To change profile or access terminal commands"
  ui_print "  type lkt in terminal app"

ui_print " "
