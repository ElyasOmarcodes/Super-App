import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.elyasomar.arabic.qamus"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications schedules with java.time, which only
        // exists from API 26 up; desugaring back-fills it for older phones.
        isCoreLibraryDesugaringEnabled = true
    }

    androidResources {
        // The corpus is LZMA2-compressed and then sealed, so its bytes are
        // indistinguishable from noise. Letting the packager deflate them
        // again costs build time, grows the APK, and forces an inflate on
        // every read; storing them verbatim avoids all three.
        noCompress += listOf("sealed")
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.elyasomar.arabic.qamus"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Google Play will not accept a debug-signed bundle. When an upload key
    // is present — android/key.properties, which CI writes from repository
    // secrets and which is never committed — the release build is signed with
    // it. Without one the build still succeeds, signed with the debug key, so
    // that `flutter run --release` and every CI run keep working; only the
    // Play upload needs the real thing.
    val keyProperties = Properties().apply {
        val file = rootProject.file("key.properties")
        if (file.exists()) file.inputStream().use { load(it) }
    }
    val hasUploadKey = keyProperties.getProperty("storeFile") != null

    // Set by CI for the Play bundle only. A bundle that is going to be signed
    // by hand must leave here with *no* signature at all: signing a
    // debug-signed bundle again leaves both signatures in META-INF, and Play
    // rejects that. The APKs are still debug-signed, because an unsigned APK
    // cannot be installed and those are the ones people sideload.
    val buildUnsigned = System.getenv("QAMUS_UNSIGNED") == "1"

    signingConfigs {
        if (hasUploadKey) {
            create("upload") {
                storeFile = rootProject.file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                hasUploadKey -> signingConfigs.getByName("upload")
                buildUnsigned -> null
                else -> signingConfigs.getByName("debug")
            }

            // The Dart half is already AOT machine code with its symbols
            // stripped by --obfuscate. R8 does the same for the thin Java and
            // Kotlin shim around it: names go, dead code goes, and what is
            // left does not read as source in a decompiler.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
