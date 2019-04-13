<h1 align="center">LKT - Magisk 🏁</h1>
<p align="center">
 <strong>legendary.kernel.tweaks</strong></div>
</p>

LKT is an advanced governor and <code>kernel</code> tweaks collection that aims to greatly enhance power efficiency and performance.

<p align="center">
</a> <img src="https://img.shields.io/badge/Version-1.8-lightgrey.svg"></a> <img src="https://img.shields.io/badge/Updated-April%2014%2C%202019-brightgreen.svg"></a> <a href="https://forum.xda-developers.com/apps/magisk/xz-lxt-1-0-insane-battery-life-12h-sot-t3700688"><img src="https://img.shields.io/badge/-XDA-orange.svg"></a> <a href="https://t.me/LKT_XDA"><img src="https://img.shields.io/badge/-Telegram-9cf.svg"></a>
</p>

<p align="center">
<a href="https://www.paypal.me/korom42"><img src="https://img.shields.io/badge/PyPal-Donate-blue.svg?"></a>
</p>

## FAQ
Read about frequently asked questions [here](https://telegra.ph/LKT---FAQ-03-25).

## Features
LKT aims to achieve a fair **balance** between **power consumption** and **performance**.
Instead to tuning the parameters manually, LKT adopts Project WIPE open source <code>interactive</code> parameters for all mainstream SOCs that are generated via machine learning <code>AI</code> and can adapt to multiple styles of workload sequences.
This idea is similar to <code>EAS</code>, which takes into account both performance and power consumption costs through power consumption models and workload sequence. But obviously, <code>EAS</code> has a much lower response time and replaces tuning with decision logic.<br><br>In addition, it also includes other parameter tuning, such as <code>HMP scheduler parameters, virtual Memory, GPU, I/O scheduler</code> to unify the rest of the <code>kernel</code> parameters for a more consistent experience.
<br><br>LKT also supports <code>schedutil</code> and <code>schedutil</code> based governos in <code>EAS</code> devices like the Pixel 2/3.

## Requirements
- [Magisk](https://github.com/topjohnwu/Magisk/releases) or init.d support if not using magisk
- [Busybox](https://sourceforge.net/projects/magiskfiles/files/module-uploads/busybox-ndk-13015.zip/download) (Needed for terminal commands).

## Compatibility
```
Snapdragon 400
Snapdragon 410
Snapdragon 412
Snapdragon 425
Snapdragon 430
Snapdragon 435
Snapdragon 450
Snapdragon 615
Snapdragon 616
Snapdragon 625
Snapdragon 626
Snapdragon 636
Snapdragon 652
Snapdragon 650
Snapdragon 660
Snapdragon 800
Snapdragon 801
Snapdragon 805
Snapdragon 810
Snapdragon 808
Snapdragon 820
Snapdragon 821
Snapdragon 835
Snapdragon 845
Snapdragon 855
Exynos 7420 (Samsung)
Exynos 8895 (Samsung)
Exynos 8890 (Samsung)
Exynos 9810 (Samsung)
Exynos 9820 (Samsung)
Kirin 650 (Huawei)
Kirin 655 (Huawei)
Kirin 658 (Huawei)
Kirin 659 (Huawei)
Kirin 950 (Huawei)
Kirin 955 (Huawei)
Kirin 960 (Huawei)
Kirin 970 (Huawei)
Helio P10 (MT6755)
Helio X10 (MT6795/T)
Helio X20 - X25 (MT6797/T)
Intel Atom Z3560
Intel Atom Z3580
*All other SoCs using schedutil governor are compatible
```
## Changelog
### v1.8.0 (14/04/2019)
- EAS adjustments
- More compatibility fixes for Snapdragon 855
- Fixed battery drain after the last update for some devices

### v1.7.1 (10/04/2019)
- Performance enhancements for Snapdragon 845 and EAS devices (Balanced, Performance and Turbo profiles)
- Compatibility fixes for Snapdragon 855
- Bug fixes

### v1.7 (08/04/2019)
- Unity template update 4.0 (Magisk 19 support)
- Added support for snapdragon 855
- Removed clock speed restrictions for EAS Turbo profile
- Bug fixes

### v1.6 (23/03/2019)
- Responsiveness enhancements for EAS
- Fixed lockscreen stutter/lag issue
- Increased wait time at boot to avoid system conflicts
- Many bug fixes and code & optimisations

### v1.5.2 (11/03/2019)
- Disabled GPU thermal restrictions on Mediatek SoCs
- Various fixes and CPU enhancements for Mediatek SoCs
- Removed zRAM (SWAP) configuration
- Other minor changes & enhancements 
- Bug fixes

### v1.5.1 (07/03/2019)
- Bug fixes

### v1.5.0 (06/03/2019)
- EAS fixes and performance enhancements
- GPU parameters adjustements
- Disabled GPU thermal restrictions on Snapdragon SoCs
- Adreno Idler tweaks enhancements
- Storage scheduler enhancements
- Memory management enhancements
- Various zRAM & SWAP optimisations
- Other minor changes & enhancements 
- Bug fixes

### v1.4.9 (09/02/2019)
- Memory management adjustments
- Fixed interactive governor parameters being overwritten by system after a while for some devices
- Added back deep-sleep enhancements props
- SWAPs/zRAM are no longer disabled
- Auto-detect existing profile when upgrading (user interaction is not needed anymore)
- Minor bug fixes

### v1.4.8 (05/02/2019)
- Increased delay after boot
- Bug fixes

### v1.4.7 (04/02/2019)
- EAS profiles fixes
- CPU boost fixes for some devices
- Memory management enhancements
- Removed any deep-sleep related tweaks
- Bug fixes

### v1.4.6 (02/02/2019)
- Important bug fixes
- zRAM is not tweaked anymore and left for the kernel (only disabled for devices +6GB RAM)

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

To access the new commands screen using terminal type:
```
su
lkt
```
Then follow the given instructions.

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

## Disclaimer
LKT is an advanced tweaks collection that acts on `kernel` level !
Use it at your own risk, and always have backups. I won't be responsible for any damage or loss.

## Credits
### Author
**Omar Koulache** - [korom42](https://github.com/korom42)

Thanks goes to those wonderful people
- [Project WIPE](https://github.com/yc9559/cpufreq-interactive-opt/tree/master/project/20180603-2) @yc9559 @cjybyjk
- [Unity template](https://github.com/Zackptg5/Unity) @ahrion & @Zackptg5 
- [Magisk](https://github.com/topjohnwu/Magisk) @topjohnwu

See also the list of [contributors](https://github.com/korom42/LKT/contributors) who participated in this project.

<p align="center">
 <a href="http://hits.dwyl.io/Korom42/Magisk-Modules-Repo/legendary_kernel_tweaks"><img src="http://hits.dwyl.io/Korom42/Magisk-Modules-Repo/legendary_kernel_tweaks.svg"></a>
</p>
