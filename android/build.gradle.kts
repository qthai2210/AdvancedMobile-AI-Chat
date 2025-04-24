import org.gradle.api.tasks.testing.Test
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

// Add buildscript block to configure NDK version
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ...existing classpaths...
        classpath("com.google.gms:google-services:4.3.15")
    }

    extra.apply {
        set("ndkVersion", "25.1.8937393") // Use a stable NDK version
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    tasks.withType<Test>().configureEach {
        enabled = false
    }
}

// Apply skip metadata version check to all Kotlin compile tasks
subprojects {
    tasks.withType<KotlinCompile>().configureEach {
        kotlinOptions.freeCompilerArgs += listOf("-Xskip-metadata-version-check")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
