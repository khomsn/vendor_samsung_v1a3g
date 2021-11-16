#!/system/bin/sh

while [ $(getprop sys.boot_completed) -ne 1 ] || [ "$(getprop init.svc.bootanim | tr '[:upper:]' '[:lower:]')" != "stopped" ]; do
  sleep 1
done

MODPATH="/system/pre-install/APK"
PATHCHECK="/data/local/traces"
INSTALL_LOG="$PATHCHECK/install.log"

if [ -d $MODPATH ]; then
    if ls $MODPATH | grep -e ".zip"; then
        /system/xbin/su 0 mount -o remount,rw /
        mv $MODPATH/DsUI.zip $MODPATH/DsUI.apk
        mv $MODPATH/v4afx-2.7.2.1.zip $MODPATH/v4afx-2.7.2.1.apk
        mv $MODPATH/com.sonyericsson.music_9.4.8.A.0.13.zip $MODPATH/com.sonyericsson.music_9.4.8.A.0.13.apk
        mv $MODPATH/GalaxyStore_4.5.33.8.zip $MODPATH/GalaxyStore_4.5.33.8.apk
    fi
fi

install_check(){
 if grep "$apk_to_install" $INSTALL_LOG ; then
    if [ -e "$MODPATH/upgrade" ]; then
        if grep "$apk_to_install" $MODPATH/upgrade ; then
            if [ "$APP" ]; then
                pm uninstall $apk_to_install
                rm -rf /data/data/$apk_to_install
                pm install $MODPATH/$APKNAME
                pm disable $apk_to_install
                pm enable $apk_to_install
            fi
        fi
    fi
 else
    if [ "$APP" ]; then
        STATUS="$(pm list packages -d | grep '$apk_to_install')"
        if [ -f "$MODPATH/disable" ] && [ ! "$STATUS" ]; then
            pm disable $apk_to_install
        elif [ ! -f "$MODPATH/disable" ] && [ "$STATUS" ]; then
            pm enable $apk_to_install
        fi
    elif [ ! "$APP" ]; then
        echo "$apk_to_install" >> $INSTALL_LOG
        pm install $MODPATH/$APKNAME
        pm disable $apk_to_install
        pm enable $apk_to_install
    fi
 fi
}
#DsUI
APKNAME="DsUI.apk"
if [ -e $MODPATH/$APKNAME ];then
    apk_to_install="com.dolby.ds1appUI"
    APP=$(pm list packages -3 | grep $apk_to_install)
    install_check
    STATUS="$(pm list packages -d | grep '$apk_to_install')"
    if [ $STATUS ]; then
        pm enable $apk_to_install
    fi
fi
#V4A_FX
APKNAME="v4afx-2.7.2.1.apk"
if [ -e $MODPATH/$APKNAME ];then
    apk_to_install="com.pittvandewitt.viperfx"
    APP=$(pm list packages -3 | grep $apk_to_install)
    install_check
    STATUS="$(pm list packages -d | grep '$apk_to_install')"
    if [ $STATUS ]; then
        pm enable $apk_to_install
    fi
fi
#Sonymusic
APKNAME="com.sonyericsson.music_9.4.8.A.0.13.apk"
if [ -e $MODPATH/$APKNAME ];then
    apk_to_install="com.sonyericsson.music"
    APP=$(pm list packages -3 | grep $apk_to_install)
    install_check
    STATUS="$(pm list packages -d | grep '$apk_to_install')"
    if [ $STATUS ]; then
        pm enable $apk_to_install
    fi
fi
#GalaxyStore
APKNAME="GalaxyStore_4.5.33.8.apk"
if [ -e $MODPATH/$APKNAME ];then
    apk_to_install="com.sec.android.app.samsungapps"
    APP=$(pm list packages -3 | grep $apk_to_install)
    install_check
    STATUS="$(pm list packages -d | grep '$apk_to_install')"
    if [ $STATUS ]; then
        pm enable $apk_to_install
    fi
fi

if [ -e  "$MODPATH/upgrade" ]; then
    rm $MODPATH/upgrade
fi
