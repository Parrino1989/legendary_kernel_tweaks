  if [ -f "/data/LKT.prop" ]; then
    rm -f "/data/LKT.prop"
  fi
  if [ -f "/data/soc.txt" ]; then
    rm -f "/data/soc.txt"
  fi
  if [ -e "/data/adb/lktprofile.txt" ]; then
    rm "/data/adb/lktprofile.txt"
  fi;
  if [ -e "/data/adb/boost1.txt" ]; then
    rm "/data/adb/boost1.txt"
  fi;
  if [ -e "/data/adb/boost2.txt" ]; then
    rm "/data/adb/boost2.txt"
  fi;
  if [ -e "/data/adb/boost3.txt" ]; then
    rm "/data/adb/boost3.txt"
  fi;
