<h1 align="center">LKT - Magisk 🏁</h1>
<p align="center">
 <strong>legendary.kernel.tweaks</strong></div>
</p>

LKT can identify your device <code>hardware</code> and optimize <code>kernel</code> settings to greatly enhance power efficiency without decreasing performance.

<p align="center">
 <a href="https://forum.xda-developers.com/apps/magisk/xz-lxt-1-0-insane-battery-life-12h-sot-t3700688"><img src="https://img.shields.io/badge/XDA-Thread-orange.svg"></a>  <a href="https://t.me/LKT_XDA"><img src="https://img.shields.io/badge/Telegram-Channel-blue.svg"></a>  <a href="https://saythanks.io/to/korom42"><img src="https://img.shields.io/badge/Say-Thanks-brightgreen.svg"></a>
</p>

## What is LKT ?
LKT is a cumilation of different strategies that target certain <code>kernel</code> settings.
What makes this special and stand out from the crowd is being universal and device specific at the same time.
Using simple functions LKT detects the <code>hardware</code> of your device then it applies the corresponding changes.

## Features
LKT aims to achieve the **balance** between **power consumption** and **performance**.
Compared to tuning the parameters manually, LKT adopts Project WIPE open source <code>interactive</code> parameters for all mainstream SOCs that are generated via machine learning <code>AI</code> and can adapt to multiple styles of workload sequences.
This idea is similar to <code>EAS</code>, which takes into account both performance and power consumption costs through power consumption models and workload sequence. But obviously, <code>EAS</code> has a much lower response time and replaces tuning with decision logic.<br><br>In addition, it also includes other parameter tuning, such as <code>HMP scheduler parameters, virtual Memory, GPU, I/O scheduler, and doze rules</code> to unify the rest of the <code>kernel</code> parameters for a more consistent experience.
<br><br>LKT also supports <code>schedutil</code> and <code>schedutil</code> based governos in <code>EAS</code> devices like the Pixel 2. <code>schedutil</code> does not provide a wide range of tuning parameters but there are some workarounds.<br><br> In <code>Snapdragon 835</code> for example depending on what profile is selected, LKT limits the maximum frequency of big cores accordingly because big clusters power efficiency dramatically decreases above 2 Ghz, as a trade of losing 15% performance, improving power consumption by 40% or more is a much better deal.

## Requirements
- [Magisk](https://github.com/topjohnwu/Magisk/releases) or SuperSU or init.d support
- [Busybox](https://forum.xda-developers.com/attachment.php?attachmentid=4654214&d=1543441627)

## Compatibility
```
Snapdragon 845
Snapdragon 835
Snapdragon 820-821
Snapdragon 810-808
Snapdragon 801-800-805
Snapdragon 660
Snapdragon 652-650
Snapdragon 636
Snapdragon 625-626
Snapdragon 615-616
Snapdragon 450
Snapdragon 435
Snapdragon 430
Snapdragon 425
Snapdragon 410-412
Snapdragon 400
Exynos 9810 (Samsung)
Exynos 8895 (Samsung)
Exynos 8890 (Samsung)
Exynos 7420 (Samsung)
Kirin 970 (Huawei)
Kirin 960 (Huawei)
Kirin 950-955 (Huawei)
kirin 650-655-658-659 (Huawei)
Helio x20-x25 (MT6797-MT6797T)
Helio x10 (MT6795-MT6795T)
Helio P10 (MT6755)
Intel Atom (Z3560-Z3580)
```
## Changelog
### v1.4.5 (01/02/2019)
- Re-worked EAS profiles
- Prefer schedutil on EAS kernels
- Added CPUSET optimizations
- Added schedtune optimizations
- Added control groups (CGroups) optimization
- Enabled zRAM for 4GB RAM devices
- Enabled & adjusted Low memory killer 
- IO block tuning enhancements
- FileSystem (FS) enhancements
- Enabled Fast Dormancy (may help with cellular network idle drain)
- Major bug fixes


### v1.4.4 (19/01/2019)
- Unity template update 3.2
- SoC detecion enhancements
- Increased delay at boot before applying tweaks to 1 min
- Minor enhancements
- Bug fixes

### v1.4.3 (16/01/2019)
- Unity template update v3.1
- Fixed changing LKT profile not sticking after reboot
- Added ability to change profiles with simple commands (useful for tasker)
```
lkt 1 : for battery profile
lkt 2 : for balanced profile
lkt 3 : for performance profile
lkt 4 : for turbo profile
```
- EAS fixes
- Improved compatibility for custom kernels
- Removed Low Memory Killer tweaks
- Swapping is no longer disabled for devices less than 4GB RAM 
- Bug fixes

### v1.4.2 (01/01/2019)
- More Bug fixes

### v1.4.1 (01/01/2019)
- Fixed some bugs after last update

### v1.4.0 (01/01/2019)
- SoC detecion enhancements
- Bug fixes

### v1.3.9 (29/12/2018)
- Added command line controls
- Now LKT perefers interactive if kernel has both schedutil & interactive
- Less aggressive LMK
- Crash fix for some devices
- Other minor changes & bug fixes

To access the new commands screen using terminal type
```
su
lkt
```
Then follow the instructions

### v1.3.8 (28/12/2018)
- SoC detection issues fixes for samsung & other devices

### v1.3.7 (27/12/2018)
- Fixed system crash & missing logs after last update
- Other minor changes

### v1.3.6 (27/12/2018)
- Fixed soc.txt file not being created when SoC detection fail
- Added new wakelocks to block
- Adreno Idler parameters changes
- Minor enhancements
- Bug fixes

### v1.3.5 (26/12/2018)
- SoC detection issues fixes
- Reduced entropy values 
- Minor enhancements
- Bug fixes

### v1.3.4 (24/12/2018)
- Added support for snapdragon 4xx series
- Added support for Helio P10 (MT6755), kirin655, kirin658, kirin659
- Fixed LTE Signal bug
- Fixed some parameters not being applied
- Fixed detection bug for snapdragon 660
- Added device support check in logs
- Unity template update 2.2
- Script enhancements
- Bug fixes

### v1.3.3 (23/12/2018)
- EAS parameters adjustments
- Reverted HMP scheduler changes
- Fixed RAM capacity & CPU frequency not displayed properly in LKT.prop
- Crashes bug fix
- Scrolling bug fix
- Crashing apps bug fix
- Minor enhancements
- Bug fixes

### v1.3.2 (22/12/2018)
- Minor installation bug fixes

### v1.3.1 (22/12/2018)
- EAS tuning is back for more devices (manual parameters - not WIPE) 
- EAS parameters adjustments
- HMP scheduler adjustments
- Updated RAM detection method
- Memory management fixes
- LMK enhancements
- Added Lazyplug tunning
- Removed busybox check
- Module template updated to latest UNITY 2.1
- Module installation fixes
- Minor enhancements
- Bug fixes

### v1.3.0 (19/12/2018)
- Fixed hardware auto-detection fail after last update for some devices
- Added support for sultanxda cpu boost implementations
- Updated to latest UNITY template 2.0
- Bug fixes and refinemetns

### v1.2.9 (18/12/2018)
- Important chip detection fixes
- Improved swap detection & removal
- Bug fixes

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
- A lot of bug fixes

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

## [FAQ](https://telegra.ph/FAQ-12-24-2)

## Disclaimer
LKT is an advanced tweaks collection that acts on `kernel` level. If you don't know how it works then use it at your own risk. I won't be responsible for any damage or loss. Always have backups.

## Credits
### Author
**Omar Koulache** - [korom42](https://github.com/korom42)

Thanks goes to those wonderful people
- [Project WIPE](https://github.com/yc9559/cpufreq-interactive-opt/tree/master/project/20180603-2) @yc9559 @cjybyjk
- [Unity template](https://github.com/Zackptg5/Unity) @ahrion & @Zackptg5 
- [Magisk](https://github.com/topjohnwu/Magisk) @topjohnwu

See also the list of [contributors](https://github.com/korom42/LKT/contributors) who participated in this project.

### References
- [Diving Deep into the Interactive World by @phantom146](https://forum.xda-developers.com/showpost.php?p=64749469&postcount=4)
- https://www.kernel.org/doc/Documentation
- https://developer.arm.com/open-source/energy-aware-scheduling
- http://man7.org/linux/man-pages/man5/proc.5.html
- https://developer.ibm.com/linuxonpower/docs/linux-on-power-low-latency-tuning/
- https://doc.opensuse.org/documentation/leap/tuning/html/book.sle.tuning/cha.tuning.taskscheduler.html
- https://access.redhat.com/solutions/177953

<p align="center">
 <a href="http://hits.dwyl.io/Korom42/Magisk-Modules-Repo/legendary_kernel_tweaks"><img src="http://hits.dwyl.io/Korom42/Magisk-Modules-Repo/legendary_kernel_tweaks.svg"></a>
</p>
