#!/system/bin/sh
# fbind init
# Copyright (C) 2017-2019, VR25 @ xda-developers
# License: GPL V3+


(umask 0
modPath=/system
log=/data/media/0/.FBind/logs/fbind-boot-$(getprop ro.product.device | grep .. || getprop ro.build.product).log

# log
mkdir -p ${log%/*}
[ -f $log ] && mv $log $log.old
exec 1>$log 2>&1
date
echo "Device=$(getprop ro.product.device | grep .. || getprop ro.build.product)"
echo
set -x
 
. $modPath/bin/fbindcore.sh

# disable "force FUSE" if that causes bootloop
if [ -e $modData/.fuse ]; then
  rm $modData/.fuse
else
  touch $modData/.fuse
fi

if grep -q noAutoMount $config; then
  rm $modData/.fuse 2>/dev/null
  exit 0
fi

apply_config # and mount partitions & loop devices
grep -Eq '^int_extf|^bind_mount |^obb.*|^from_to |^target ' $config && bind_mount_wrapper
grep -q '^remove ' $config && remove_wrapper
rm $modData/.fuse 2>/dev/null
exit 0 &) &
