import java.util.Properties

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use {
        localProperties.load(it)
    }
}

val flutterRoot = localProperties.getProperty("flutter.sdk")
    ?: throw GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0.0"

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

apply(from = "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle")

android {
    namespace = "com.crux.app"
    compileSdk = 34
    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.crux.app"
        minSdk = 23
        targetSdk = 34
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        
        // WebRTC configuration
        ndk {
            abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a"))
        }

        // Multidex support pour les apps avec beaucoup de dépendances
        multiDexEnabled = true

        // Compression for WebRTC assets
        vectorDrawables.useSupportLibrary = true
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.4.0"
    }

    buildTypes {
        debug {
            debuggable = true
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }

        release {
            debuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug") // À remplacer en production
        }
    }

    packagingOptions {
        exclude("META-INF/DEPENDENCIES")
        exclude("META-INF/LICENSE")
        exclude("META-INF/LICENSE.txt")
        exclude("META-INF/NOTICE")
    }

    lint {
        disable.addAll(listOf("MissingDimensionBaseline"))
        checkReleaseBuilds = false
        abortOnError = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core Android
    implementation("androidx.core:core:1.10.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.multidex:multidex:2.0.1")

    // Material Design 3
    implementation("com.google.android.material:material:1.10.0")

    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.20")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.1")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.1")

    // Jetpack Compose (pour UI optionnelle)
    val composeBom = platform("androidx.compose:compose-bom:2023.10.00")
    implementation(composeBom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.6.2")

    // Firebase (BOM pour synchroniser les versions)
    implementation(platform("com.google.firebase:firebase-bom:32.6.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-crashlytics")
    implementation("com.google.firebase:firebase-remote-config")

    // WebRTC pour vidéoconférence
    implementation("org.webrtc:google-webrtc:1.0.32006")
    implementation("io.flutter.plugins.webrtc:flutter_webrtc:0.9.45")

    // Networking & HTTP
    implementation("com.squareup.okhttp3:okhttp:4.11.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.11.0")
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")

    // JSON Serialization
    implementation("com.google.code.gson:gson:2.10.1")

    // State Management & Reactive
    implementation("io.reactivex.rxjava3:rxjava:3.1.7")
    implementation("io.reactivex.rxjava3:rxandroid:3.0.0")

    // Local Storage
    implementation("androidx.datastore:datastore-preferences:1.0.0")
    implementation("androidx.security:security-crypto:1.1.0-alpha06")

    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito:mockito-core:5.5.0")
    testImplementation("org.mockito.kotlin:mockito-kotlin:5.1.0")
    
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")

    // Logging
    implementation("com.jakewharton.timber:timber:5.0.1")

    // Permission handling
    implementation("com.google.android.gms:play-services-location:21.0.1")
    implementation("com.google.android.gms:play-services-tasks:18.0.2")
}

apply(plugin = "com.google.gms.google-services")
apply(plugin = "com.google.firebase.crashlytics")
