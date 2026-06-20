plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

apply(plugin = "com.google.gms.google-services")

val localProperties = java.util.Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "com.example.crux"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    signingConfigs {
        create("release") {
            storeFile = file("crux.keystore")
            storePassword = "crux2024!"
            keyAlias = "crux_key"
            keyPassword = "crux2024!"
        }
    }

    defaultConfig {
        applicationId = "com.example.crux"
        minSdk = 24
        targetSdk = 35
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            signingConfig = signingConfigs.getByName("release")
            isDebuggable = true
        }
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }
}

flutter {
    source = "../.."
}

// Add Flutter plugin subprojects as compile dependencies.
// These projects are included in settings.gradle.kts from .flutter-plugins.
val flutterPluginsFile = File(rootProject.projectDir.parentFile, ".flutter-plugins")
if (flutterPluginsFile.exists()) {
    val pluginProps = java.util.Properties()
    flutterPluginsFile.inputStream().use { pluginProps.load(it) }
    pluginProps.forEach { (pluginName, _) ->
        if (findProject(":$pluginName") != null) {
            dependencies.add("implementation", project(":$pluginName"))
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.core:core:1.12.0")
}
