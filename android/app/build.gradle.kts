plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "et.medimind.medimind"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17

            isCoreLibraryDesugaringEnabled = true
        }

    dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    }

    defaultConfig {
        applicationId = "et.medimind.medimind"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // agora_rtm 2.x and agora_rtc_engine 6.x both ship libaosl.so. Pick the first
    // copy at merge time to avoid a mergeDebugNativeLibs failure — the two files
    // are byte-identical so either is fine.
    packaging {
        jniLibs {
            pickFirsts += setOf(
                "lib/arm64-v8a/libaosl.so",
                "lib/armeabi-v7a/libaosl.so",
                "lib/x86/libaosl.so",
                "lib/x86_64/libaosl.so",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

// Disable Crashlytics mapping upload — not needed for local dev builds
tasks.configureEach {
    if (name.contains("uploadCrashlyticsMappingFile")) {
        enabled = false
    }
}
