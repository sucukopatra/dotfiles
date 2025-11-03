#!/bin/bash
packages=(
  com.mi.globalminusscreen
  com.amazon.mShop.android.shopping
  com.miui.calculator
  com.xiaomi.calendar
  com.miui.compass
  com.miui.notes
  com.miui.cleaner
  com.android.providers.downloads.ui
  com.google.android.apps.docs
  com.preff.kb.xm
  com.facebook.katana
  com.mi.android.globalFileexplorer
  com.miui.fm
  com.xiaomi.glgm
  com.xiaomi.mipicks
  com.google.android.gm
  com.google.android.videos
  com.linkedin.android
  com.google.android.apps.tachyon
  com.android.mms
  com.mi.globalbrowser
  com.xiaomi.payment
  cn.wps.xiaomi.abroad.lite
  com.xiaomi.smarthome
  com.duokan.phone.remotecontroller
  com.mi.global.shop
  com.miui.videoplayer
  com.getmidas.app
  com.miui.player
  com.netflix.mediaclient
  com.google.android.apps.photos
  com.android.soundrecorder
  com.xiaomi.scanner
  com.miui.screenrecorder
  com.miui.miservice
  com.xiaomi.midrop
  com.android.stk
  com.snapchat.android
  com.zhiliaoapp.musically
  com.miui.weather2
  cn.wps.moffice_eng
  com.mi.global.bbs
  com.google.android.youtube
  com.google.android.apps.youtube.music
  com.android.chrome
  com.android.thememanager
  com.badambiz.okeyYuzbir
  com.king.candycrushsaga
  com.block.juggle
  com.vitastudio.mahjong
  com.mintgames.wordtrip
  com.fugo.wow
  com.mintgames.fancycolorpro
  com.google.android.apps.safetyhub
)

echo "Removing Bloatware"
for pkg in "${packages[@]}"; do
  echo ">>> $pkg trying to uninstall..."
  adb shell pm uninstall "$pkg"
  if [ $? -ne 0 ]; then
    echo ">>> Cannot Uninstall, disabling..."
    adb shell pm disable-user --user 0 "$pkg"
  fi
done

echo "Proccess completed, restart your phone."
