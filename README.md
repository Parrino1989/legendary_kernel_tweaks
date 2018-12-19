<h1 align="center">LKT - Magisk 🏁</h1>

<div align="center">
  <strong>legendary.kernel.tweaks</strong>
</div>
<div align="center">
LKT can identify your device <code>hardware</code> and optimize your <code>kernel</code> settigns for maximum power efficiency without performance loss
</div>
<br />
<p align="center">
 <a href="https://forum.xda-developers.com/apps/magisk/xz-lxt-1-0-insane-battery-life-12h-sot-t3700688"><img src="https://img.shields.io/badge/XDA-Thread-orange.svg"></a><br /><a href="https://t.me/LKT_XDA"><img src="https://img.shields.io/badge/Telegram-Channel-blue.svg"></a>
</p>
 
## Why LKT ?
LKT is a cumilation of different strategies that target certain <code>kernel</code> settings.

What makes this special and stand out from the crowd is being universal and device specific at the same time. And it's also BS free.
Using simple functions LKT detects the <code>hardware</code> of your device then it applies the corresponding changes. It does support all mainstream platforms including <code>Snapdragon, Kirin, MediaTek etc.</code> covering hundreds of devices.

## Features
LKT aims to achieve the **balance** between **power consumption** and **performance**.
Compared to tuning the parameters manually, LKT adopts Project WIPE excellent open source parameters for almost all mainstream SOCs that are generated via machine learning (A.I) and can adapt to multiple styles of workload sequences. This idea is similar to <code>EAS</code>, which takes into account both performance and power consumption costs through power consumption models and workload sequence, but obviously, <code>EAS</code> has a much lower response time and replaces tuning with decision logic. In addition, it also includes other parameter tuning, such as **HMP parameters, Virtual Memory, GPU, I/O scheduler, TCP and Doze rules** to unify the rest of the <code>kernel</code> parameters for a more consistent experience.

## Requirements
```
• Magisk 17+
• Busybox
```

## Compability
```
Snapdragon 615-616
Snapdragon 625-626
Snapdragon 636
Snapdragon 652-650
Snapdragon 660
Snapdragon 801-800-805
Snapdragon 810-808
Snapdragon 820-821
Snapdragon 835
Snapdragon 845
Exynos 7420 (Samsung)
Exynos 8890 (Samsung)
Exynos 8895 (Samsung)
Helio x10 (MEDIATEK)
Helio x20-x25 (MEDIATEK)
Kirin 950-955 (HUAWEI)
Kirin 960 (HUAWEI)
Kirin 970 (HUAWEI)
```
Please note that even if your device isn't listed some parameters may stil apply

## Changelog
### v1.3.0 (19/12/2018)
- Fixed hardware auto-detection fail after last update for some devices
- Updated to latest UNITY template 2.0
- Bug fixes and refinemetns

### v1.2.9 (18/12/2018)
- Important chip detection fixes
- Improved swap detection & removal
- Minor bug fixes

### v1.2.8 (18/12/2018)
- Bug fixes for manual chip detection workarround

### v1.2.7 (18/12/2018)
- Minor fixes

### v1.2.6 (17/12/2018)
- Added manual workarround for devices with unrecognized chip (Huawei,Xiaomi etc..)
- Removed EAS support (except sd845) untill further notice (too experimental)
- Corrected SD845 configs
- Agressive tunded LMK for Turbo profile for better gaming experience
- Fixed Termux app conflicts
- Bug fixes and refinemetns

### v1.2.5 (17/12/2018)
- Added Performance & Turbo profiles
- Added partial support (balanced profile only) for exynos9810, kirin650, sd615
- Fixed battery drain for EAS devices
- Fixed some devices not being recognized (again)
- Fixed some bugs with low RAM devices
- Fixed RAM capacity not being displayed correctlly
- Script refinements
- A ton of bug fixes

### v1.2.4 (16/12/2018)
- Fixed connectivity issues for some devices
- Improved SOC chip recognition for some devices
- Other minor bug fixes & refinements
 Thanks to @pKrysenko & all telegram group members for testing

### v1.2.3 (15/12/2018)
- Minor bug fixes

### v1.2.2 (14/12/2018)
- EAS parameters enhacements
- Memory tuning enhancements
- Added support to SD615/SD616
- Changed hardware detection method
- I/O scheduler changes
- Removed forced doze for GMS & ril services
- Improved scrolling & FPS in applications
- Added detailed battery health check
- Other minor bug fixes & improvements

### v1.2.1 (07/12/2018)
- Fixed a bug that makes governor parameters not stick after a while
- Fixed a bug where CPU is not recognized correctly (Improved SoC detecting)
- Other minor bug fixes & improvements

### v1.2 (05/12/2018)
- Added missing cpu boost for some SoCs on balanced profile
- Improved swap detection & disabling (again)
- Reviewed & removed some stuff
- Other minor bug fixes & improvements

### v1.1 (04/12/2018)
- Fixed a bug where chip name in upper case isn't recognized
- Swap partitions detecting improvements
- Some small but important script code fixes
 Thanks to whalesplaho @XDA for testing and discovering this

### v1.0 (04/12/2018)
- First release

## How to make sure that it is working ?
Using a <code>root</code> file manager check the logs by navigating to `/data/LKT.prop`
You may screenshot & upload your logs to share them in case of having troubles

## Disclaimer
LKT is an advanced tweaks collection that act on `kernel` level. If you don't know how it works then use it at your own risk. I won't be responsible for any damage or loss. Always have backups.

## Credits
### Author
**Omar Koulache** - [korom42](https://github.com/korom42)

### Thanks goes to these wonderful people
103
- ### [Project WIPE contributors](https://github.com/yc9559/cpufreq-interactive-opt/tree/master/project/20180603-2) 
```
@yc9559 @cjybyjk
```
- ### [AKT contributors](https://github.com/mostafawael/OP5-AKT) 
```
@Alcolawl @soniCron @Asiier @Freak07 @Mostafa Wael 
@Senthil360 @TotallyAnxious @RenderBroken @adanteon  
@Kyuubi10 @ivicask @RogerF81 @joshuous @boyd95 
@ZeroKool76 @ZeroInfinity
```
- ### [Unity template](https://forum.xda-developers.com/android/software/module-audio-modification-library-t3579612) & [Keycheck Method](https://forum.xda-developers.com/android/software/guide-volume-key-selection-flashable-zip-t3773410) by @ahrion & @Zackptg5 

- ### [Magisk](https://github.com/topjohnwu/Magisk) by @topjohnwu

See also the list of [contributors](https://github.com/korom42/LKT/contributors) who participated in this project.

### References
- https://www.kernel.org/doc/Documentation
- https://developer.arm.com/open-source/energy-aware-scheduling
- http://man7.org/linux/man-pages/man5/proc.5.html
- https://developer.ibm.com/linuxonpower/docs/linux-on-power-low-latency-tuning/
- https://doc.opensuse.org/documentation/leap/tuning/html/book.sle.tuning/cha.tuning.taskscheduler.html
- https://access.redhat.com/solutions/177953
