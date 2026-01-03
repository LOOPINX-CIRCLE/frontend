plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // preferred modern id
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.text_code"

    compileSdk = 35 // you can keep flutter.compileSdkVersion if dynamic
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.text_code"
        minSdk = 23 
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ Updated Java + Kotlin compatibility
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            // TODO: Replace this with your actual release key when you’re ready to publish
            signingConfig = signingConfigs.getByName("debug")

            // ✅ Optional but recommended for smaller APKs
            isMinifyEnabled = false
            isShrinkResources = false
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
