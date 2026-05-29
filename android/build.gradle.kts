// This file is the basis of the build system for all sub-projects/modules.
//
// The allprojects/repositories block is where you can declare any
// repositories for your dependencies.
// Currently defined here because New project wizard puts all dependencies
// here. Change this (and enable project-specific repositories) for each
// project/module as appropriate.

plugins {
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}