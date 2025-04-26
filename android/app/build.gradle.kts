import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.advancedmobile.aichatbot"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
        // Skip metadata version checks to allow older/newer library metadata
        freeCompilerArgs += listOf("-Xskip-metadata-version-check")
    }

    defaultConfig {
        applicationId = "com.advancedmobile.aichatbot"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Add a signing config for release builds loading credentials from key.properties
    signingConfigs {
        create("release") {
            // Load release keystore properties
            val props = Properties().apply { load(rootProject.file("key.properties").inputStream()) }
             keyAlias = props["keyAlias"] as String
             keyPassword = props["keyPassword"] as String
             storeFile = file(props["storeFile"] as String)
             storePassword = props["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // Use the release signing config
            signingConfig = signingConfigs.getByName("release")
            // Enable code shrinking and obfuscation
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
