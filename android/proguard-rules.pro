# Proguard rules for Flutter app

# Preserve Flutter classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Preserve Dart classes
-keep class com.example.crux.** { *; }
-dontwarn com.example.crux.**

# Preserve Agora classes
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# Preserve Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Preserve application classes
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.view.View
-keep public class * extends android.app.Fragment
-keep public class * extends androidx.fragment.app.Fragment

# Preserve annotation classes
-keepattributes *Annotation*
-keepattributes SourceFile
-keepattributes LineNumberTable
-renamesourcefileattribute SourceFile

# Preserve native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Preserve Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Preserve R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Preserve BuildConfig
-keep class **.BuildConfig { *; }