#!/system/bin/sh
ui_print "*******************************"
ui_print "*  Bootanimation Manager       *"
ui_print "*******************************"
API=$(getprop ro.build.version.sdk)
[ "$API" -lt 34 ] && abort "Android 14 or newer required / Serve Android 14 o superiore"
set_perm "$MODPATH/bam.sh" 0 0 0755
ui_print "- Open this module from your module manager (WebUI button)"
ui_print "- Apri questo modulo dal gestore moduli (tasto WebUI)"
ui_print "- Changes to the active bootanimation need a reboot / servono un riavvio"
