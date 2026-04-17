plugins {
    kotlin("jvm") version "1.6.20"
    id("application")
    id("java")
    id("idea")

    // This is used to create a GraalVM native image
    id("org.graalvm.buildtools.native") version "0.9.11"

    // This creates a fat JAR
    id("com.github.johnrengelman.shadow") version "7.1.2"
}

group = "com.ido"
description = "HelloWorld"

// Version is read from gradle.properties (appVersion=x.y.z)
// The CI pipeline automatically bumps the patch number before each build.
version = project.property("appVersion") as String

application.mainClass.set("com.ido.HelloWorld")

repositories {
    mavenCentral()
}

// Give the shadow (fat) JAR a clean, version-stamped name
tasks.shadowJar {
    archiveBaseName.set("gradle-hello-world")
    archiveClassifier.set("")
    archiveVersion.set(version.toString())
}

graalvmNative {
    binaries {
        named("main") {
            imageName.set("helloworld")
            mainClass.set("com.ido.HelloWorld")
            fallback.set(false)
            sharedLibrary.set(false)
            useFatJar.set(true)
            javaLauncher.set(javaToolchains.launcherFor {
                languageVersion.set(JavaLanguageVersion.of(17))
                vendor.set(JvmVendorSpec.matching("GraalVM Community"))
            })
        }
    }
}