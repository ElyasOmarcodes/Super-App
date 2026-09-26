import java.security.MessageDigest

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("io.github.takahirom.roborazzi")
}

// The entry code is fixed at build time. Set the APP_PASSCODE secret in GitHub
// (Settings → Secrets → Actions) to change it; only its hash ends up in the APK.
val passcode: String = System.getenv("APP_PASSCODE")?.takeIf { it.isNotBlank() } ?: "1234"
require(passcode.all { it.isDigit() } && passcode.length in 4..8) {
    "APP_PASSCODE must be 4-8 digits"
}
val passcodeHash: String = MessageDigest.getInstance("SHA-256")
    .digest("tamarkuz:$passcode".toByteArray())
    .joinToString("") { "%02x".format(it) }

val ciVersionCode = System.getenv("VERSION_CODE")?.toIntOrNull() ?: 1

android {
    namespace = "com.elyas.tamarkuz"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.elyas.tamarkuz"
        minSdk = 29
        targetSdk = 36
        versionCode = ciVersionCode
        versionName = "1.0.$ciVersionCode"

        buildConfigField("String", "PASSCODE_SHA256", "\"$passcodeHash\"")
        buildConfigField("int", "PASSCODE_LENGTH", passcode.length.toString())
    }

    signingConfigs {
        create("release") {
            val ksFile = System.getenv("KEYSTORE_FILE")
            storeFile = if (ksFile != null) file(ksFile) else file("signing/tamarkuz.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "tamarkuz-store"
            keyAlias = System.getenv("KEY_ALIAS") ?: "tamarkuz"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "tamarkuz-store"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
        }
    }

    packaging {
        resources.excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2025.07.00")
    implementation(composeBom)
    implementation("androidx.core:core-ktx:1.16.0")
    implementation("androidx.activity:activity-compose:1.10.1")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.9.1")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")

    testImplementation(composeBom)
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.robolectric:robolectric:4.16")
    testImplementation("androidx.compose.ui:ui-test-junit4")
    testImplementation("io.github.takahirom.roborazzi:roborazzi:1.75.0")
    testImplementation("io.github.takahirom.roborazzi:roborazzi-compose:1.75.0")
    testImplementation("io.github.takahirom.roborazzi:roborazzi-junit-rule:1.75.0")
}
