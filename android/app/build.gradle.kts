plugins {
    id("com.android.application")
    id("kotlin-android")
}

android {
    namespace = "com.example.crux"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.crux"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            minifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
}
