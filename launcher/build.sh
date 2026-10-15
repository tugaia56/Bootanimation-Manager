#!/bin/sh
# Builds BootanimManager.apk (no Gradle): aapt2 + javac + d8 + apksigner. Needs the Android SDK (build-tools, platform) and a JDK.
SDK="${ANDROID_HOME:-$HOME/AppData/Local/Android/Sdk}"
BT=$(ls -d "$SDK"/build-tools/*/ | tail -1); PL=$(ls -d "$SDK"/platforms/android-*/ | tail -1)
JBR="${JAVA_HOME:-/c/Program Files/Android/Android Studio/jbr}"
HERE=$(cd "$(dirname "$0")" && pwd); OUT="$HERE/build"; rm -rf "$OUT"; mkdir -p "$OUT/res" "$OUT/cls"
"$BT/aapt2.exe" compile --dir "$HERE/res" -o "$OUT/res" || exit 1
"$BT/aapt2.exe" link -o "$OUT/base.apk" -I "$PL/android.jar" --manifest "$HERE/AndroidManifest.xml" --min-sdk-version 26 --target-sdk-version 34 "$OUT"/res/*.flat || exit 1
"$JBR/bin/javac" -source 8 -target 8 -cp "$PL/android.jar" -d "$OUT/cls" $(find "$HERE/src" -name '*.java') || exit 1
JAVA_HOME="$JBR" "$BT/d8.bat" --min-api 26 --lib "$PL/android.jar" --output "$OUT" $(find "$OUT/cls" -name '*.class') || exit 1
cd "$OUT" && cp base.apk unsigned.apk && "$JBR/bin/jar" uf unsigned.apk classes.dex 2>/dev/null || (cd "$OUT" && zip -q -u unsigned.apk classes.dex)
"$BT/zipalign.exe" -f 4 "$OUT/unsigned.apk" "$OUT/aligned.apk" || exit 1
JAVA_HOME="$JBR" "$BT/apksigner.bat" sign --ks "$HOME/.android/debug.keystore" --ks-pass pass:android --key-pass pass:android --out "$HERE/BootanimManager.apk" "$OUT/aligned.apk" || exit 1
echo built "$HERE/BootanimManager.apk"
