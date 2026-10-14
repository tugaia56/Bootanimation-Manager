#!/system/bin/sh
# Bootanimation Manager helper. Called by the WebUI: sh bam.sh <command> [args]
MODS=/data/adb/modules
UPD=/data/adb/modules_update
KSUD=/data/adb/ksu/bin/ksud
TMP=/data/local/tmp/oxybam
T=/my_product/media/bootanimation/bootanimation.zip

# path of the bootanimation file of module $1 (installed or pending)
bafile() {
  for b in "$MODS/$1" "$UPD/$1"; do
    for f in "$b/my_product/media/bootanimation/bootanimation.zip" "$b/system/product/media/bootanimation.zip" "$b/system/media/bootanimation.zip"; do
      if [ -f "$f" ]; then echo "$f"; return; fi
    done
  done
}

cmd=$1
shift

case "$cmd" in
list)
  { ls "$MODS" 2>/dev/null; ls "$UPD" 2>/dev/null; } | sort -u | while read -r id; do
    [ -z "$id" ] && continue
    [ -d "$MODS/$id" ] || [ -d "$UPD/$id" ] || continue
    f=$(bafile "$id")
    [ -z "$f" ] && continue
    p="$MODS/$id/module.prop"; [ -f "$p" ] || p="$UPD/$id/module.prop"
    name=$(sed -n 's/^name=//p' "$p" 2>/dev/null | head -1 | tr -d '\r' | tr '|' '/')
    st=on
    [ -f "$MODS/$id/disable" ] && st=off
    [ -f "$MODS/$id/remove" ] && st=rm
    pend=0
    [ -f "$MODS/$id/update" ] && pend=1
    echo "$id|$st|$pend|$name"
  done
  ;;
play)
  id=$1; d=${2:-10}
  f=$(bafile "$id")
  [ -z "$f" ] && { echo "no-file"; exit 1; }
  bs=$(wm size | sed -n 's/Override size: //p'); bd=$(wm density | sed -n 's/Override density: //p')
  chcon u:object_r:system_file:s0 "$f" 2>/dev/null
  nsenter -t 1 -m -- mount --bind "$f" "$T" </dev/null || { echo "mount-failed"; exit 1; }
  setprop service.bootanim.exit 0
  setprop ctl.start bootanim
  sleep "$d"
  setprop service.bootanim.exit 1
  setprop ctl.stop bootanim
  nsenter -t 1 -m -- umount "$T" </dev/null
  # after the preview the screen can stay drawn in a corner (stale projection): re-apply the display override exactly as it was
  for i in 1 2; do
    sleep 1
    wm size reset; wm density reset
    [ -n "$bs" ] && wm size "$bs"
    [ -n "$bd" ] && wm density "$bd"
  done
  echo ok
  ;;
use)
  id=$1
  [ -d "$MODS/$id" ] || { echo "not-installed-yet"; exit 1; }
  for d in "$MODS"/*/; do
    i=${d%/}; i=${i##*/}
    [ -n "$(bafile "$i")" ] || continue
    touch "$MODS/$i/disable"
  done
  rm -f "$MODS/$id/disable"
  echo ok
  ;;
none)
  for d in "$MODS"/*/; do
    i=${d%/}; i=${i##*/}
    [ -n "$(bafile "$i")" ] || continue
    touch "$MODS/$i/disable"
  done
  echo ok
  ;;
remove)
  "$KSUD" module uninstall "$1" </dev/null 2>&1 | tail -1
  ;;
api)
  curl -s -m 25 "https://api.pcloud.com/getpublinkdownload?code=$1" </dev/null
  ;;
dl)
  mkdir -p "$TMP"
  rm -f "$TMP/$2"
  if curl -L -s --fail -m 3000 -o "$TMP/$2" "$1" </dev/null; then
    s=$(stat -c %s "$TMP/$2" 2>/dev/null)
    [ "${s:-0}" -gt 1000 ] && echo "ok $s" || echo "fail empty"
  else
    echo "fail curl"
  fi
  ;;
scan)
  dir=$1
  for z in "$dir"/*.zip; do
    [ -f "$z" ] || continue
    unzip -l "$z" 2>/dev/null | grep -q "bootanimation.zip" || continue
    name=$(unzip -p "$z" module.prop 2>/dev/null | sed -n 's/^name=//p' | head -1 | tr -d '\r' | tr '|' '/')
    echo "$z|$(stat -c %s "$z")|$name"
  done
  ;;
install)
  z=$1
  id=$(unzip -p "$z" module.prop 2>/dev/null | sed -n 's/^id=//p' | head -1 | tr -d '\r')
  [ -z "$id" ] && { echo "bad-zip"; exit 1; }
  out=$("$KSUD" module install "$z" </dev/null 2>&1)
  echo "$out" | tail -2
  touch "$MODS/$id/disable"
  echo "id=$id (installed, turned off)"
  ;;
clean)
  rm -rf "$TMP"
  echo ok
  ;;
selfver)
  # version of the installed manager (no argument) or of a downloaded manager zip ($1)
  if [ -n "$1" ]; then p=$(unzip -p "$1" module.prop 2>/dev/null); else p=$(cat "$MODS/oxybootanim/module.prop" 2>/dev/null); fi
  echo "$p" | tr -d '\r' | grep -E '^(id|version|versionCode)='
  ;;
selfapply)
  # update the manager in place from a downloaded manager zip: no reboot needed
  z=$1
  id=$(unzip -p "$z" module.prop 2>/dev/null | tr -d '\r' | sed -n 's/^id=//p' | head -1)
  [ "$id" = "oxybootanim" ] || { echo "bad-zip"; exit 1; }
  S=$TMP/self; D=$MODS/oxybootanim
  rm -rf "$S"; mkdir -p "$S"
  unzip -oq "$z" 'webroot/*' module.prop bam.sh uninstall.sh -d "$S" </dev/null || { echo "unzip-failed"; exit 1; }
  [ -s "$S/bam.sh" ] && [ -s "$S/webroot/index.html" ] && [ -s "$S/module.prop" ] || { echo "incomplete"; exit 1; }
  sed -i 's/\r$//' "$S/bam.sh" "$S/module.prop" "$S/uninstall.sh"
  mkdir -p "$D/webroot"
  cp -rf "$S/webroot/." "$D/webroot/"
  cp -f "$S/module.prop" "$D/module.prop"
  cp -f "$S/uninstall.sh" "$D/uninstall.sh"
  # the running script is replaced last, through a new file, so the shell keeps reading the old one
  cp -f "$S/bam.sh" "$D/bam.sh.new" && chmod 755 "$D/bam.sh.new" && mv -f "$D/bam.sh.new" "$D/bam.sh"
  rm -rf "$S"
  echo ok
  ;;
*)
  echo "unknown command"
  exit 1
  ;;
esac
exit 0
