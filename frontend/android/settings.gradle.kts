pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localProperties = java.io.File(rootDir, "local.properties")
        if (localProperties.exists()) {
            localProperties.inputStream().use { properties.load(it) }
        }
        properties.getProperty("flutter.sdk")
            ?: System.getenv("FLUTTER_SDK")
            ?: System.getenv("FLUTTER_HOME")
            ?: error("flutter.sdk not set in local.properties")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
