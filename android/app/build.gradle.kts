import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load release signing config from android/key.properties if it exists.
// key.properties (and the .jks keystore) are gitignored — never commit them.
// If the file is absent (e.g. a fresh clone or CI without secrets), release
// builds fall back to debug signing so `flutter run --release` still works.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.gautamkumar.recurring"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications to backport java.time APIs.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Real reverse-domain application ID — matches the iOS bundle ID.
        // (Google Play rejects the template's `com.example.*`.)
        applicationId = "com.gautamkumar.recurring"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // versionCode / versionName come from pubspec.yaml (`version: x.y.z+build`)
        // via Flutter — bump them there, not here.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseKeystore) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use the real upload keystore when key.properties is present;
            // otherwise fall back to debug keys so local release runs still work.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // R8 shrinking/obfuscation is left off for parity with the current
            // build. If you enable it later, add Flutter's proguard rules first.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
