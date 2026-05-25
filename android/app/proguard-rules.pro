# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Drift (SQLite)
-keep class androidx.sqlite.** { *; }
-keep class sqlite3.** { *; }

# Hive CE
-keep class hive_ce.** { *; }

# Dio
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Play Core (not used, but referenced by Flutter engine)
-dontwarn com.google.android.play.core.**

# General
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
