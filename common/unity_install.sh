ui_print " "
# Use the current running profile in case of upgrade
if $KEEPPROFILE ; then
	PROFILEMODE=$(cat /data/adb/lktprofile.txt | tr -d '\n')
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
  ui_print "   Using saved profile = Battery"
  ui_print " "
  elif [ ${PROFILEMODE} -eq 1 ];then
  ui_print "   Using saved profile = Balanced"
  ui_print " "
  elif [ ${PROFILEMODE} -eq 2 ];then
  ui_print "   Using saved profile = Performance"
  ui_print " "
  elif [ ${PROFILEMODE} -eq 3 ];then
  ui_print "   Using saved profile = Turbo"
  ui_print " "
  else
  ui_print "   LKT Profile specified in zipname!"
  ui_print " "
  fi

  VER=$(cat ${TMPDIR}/module.prop | grep -oE 'version=v[0-9].[0-9]+' | awk -F= '{ print $2 }' )
  
  sed -i "s/<VER>/${VER}/g" ${TMPDIR}/common/service.sh
  sed -i "s/<PROFILE_MODE>/${PROFILEMODE}/g" ${TMPDIR}/common/service.sh

  ui_print "- Installation was successful !!.."
  ui_print " "
  ui_print "- To access terminal commands use : lkt"
   ui_print " "
ui_print "   This build is achieved with the help"
ui_print "   Of following people from @ CoolApk"
ui_print " "
ui_print "   @yc9559 @cjybyjk @Fdss45 @yy688go(好像不见了)"
ui_print "   @lpc3123191239 @小方叔叔 @星辰紫光 @ℳ๓叶落情殇"
ui_print "   @屁屁痒 @发热不卡算我输# @予北 @選擇遺忘 @想飞的小伙"
ui_print "   @白而出清 @AshLight @微风阵阵 @半阳半 @Jouiz @AhZHI"
ui_print "   @悲欢余生有人听 @YaomiHwang @花生味 @胡同口卖菜的"
ui_print "   @gce8980 @vesakam @q1006237211 @Runds @鹰雏"
ui_print "   @lmentor @萝莉控の胜利 @iMeaCore @Dfift半島鐵盒"
ui_print "   @wenjiahong @星空未来 @水瓶 @瓜瓜皮 @默认用户名8"
ui_print "   @影灬无神 @橘猫520 @此用户名已存在 @ピロちゃん @Jaceﮥ"
ui_print "   @黑白颠倒的年华0 @九日不能贱 @fineable @zokkkk"
ui_print "   @永恒的丶齿轮 @L风云 @Immature_H @揪你鸡儿 @ちぃ"
ui_print "   @Ace蒙奇 @木子茶i同学 @HEX_Stan @_暗香浮动月黄昏"
ui_print "   @子喜 @ft1858336 @xxxxuanran @Scorpiring"
ui_print "   @猫见 @僞裝灬 @请叫我芦柑 @吃瓜子的小白 @HELISIGN"
ui_print "   @贫家boy有何贵干 @xujiyuan723 @哑剧 @Yoooooo"
ui_print " "

