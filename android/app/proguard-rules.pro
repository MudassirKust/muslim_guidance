# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Keep old plugin embedding for compatibility
-keep class io.flutter.plugin.common.PluginRegistry { *; }
-keep class io.flutter.plugin.common.PluginRegistry$Registrar { *; }
-keep class io.flutter.plugin.common.PluginRegistry$ViewRegistrar { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R classes
-keep class **.R$* {
    public static <fields>;
}

# Keep WebView
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep audio players
-keep class com.ryanheise.audioplayers.** { *; }

# Keep geolocator
-keep class com.baseflow.geolocator.** { *; }

# Keep notifications
-keep class com.dexterous.** { *; }

# Keep timezone
-keep class net.time4j.** { *; }

# Keep shared preferences
-keep class androidx.preference.** { *; }

# Keep connectivity
-keep class androidx.work.** { *; }

# Keep multidex
-keep class androidx.multidex.** { *; }

# Keep AndroidX components
-keep class androidx.core.** { *; }
-keep class androidx.appcompat.** { *; }
-keep class androidx.fragment.** { *; }

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }

# Keep location services
-keep class com.google.android.gms.location.** { *; }

# Keep permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep vibration
-keep class com.dexterous.** { *; }

# Keep sensors
-keep class io.flutter.plugins.sensors.** { *; }

# Keep compass
-keep class io.flutter.plugins.compass.** { *; }

# Keep HTTP
-keep class io.flutter.plugins.connectivity.** { *; }

# Keep package info
-keep class io.flutter.plugins.packageinfo.** { *; }

# Keep local notifications
-keep class com.dexterous.** { *; }

# Keep battery optimization
-keep class com.baseflow.batteryoptimization.** { *; }

# Keep additional plugin classes
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.view.** { *; }

# Keep Google Play Core classes
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
