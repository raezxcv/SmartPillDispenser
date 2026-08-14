# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase & Google Play Services
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**

# Keep Lottie & Image Pickers
-keep class com.airbnb.lottie.** { *; }

# Suppress harmless warnings
-dontwarn io.flutter.embedding.**
-dontwarn androidx.**
