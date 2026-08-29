# R8 runs over the Java and Kotlin shim around the Dart engine. Everything the
# platform reaches by reflection has to survive it by name.

# The Flutter embedding, reached from native code.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# flutter_local_notifications deserialises its scheduled notifications from
# JSON with Gson, so the model classes must keep their field names or every
# alarm that survives a reboot comes back empty.
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-dontwarn com.dexterous.**

# Gson's own reflection.
-keep class com.google.gson.** { *; }
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-dontwarn sun.misc.**

# Desugared java.time, used by the notification scheduler.
-dontwarn java.time.**
-dontwarn javax.annotation.**
