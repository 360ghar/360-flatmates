allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
    // Fix duplicate BuildConfig.class in plugin full JARs (e.g. url_launcher_android
    // ships its own BuildConfig while AGP also generates one).
    tasks.withType<Jar>().configureEach {
        duplicatesStrategy = DuplicatesStrategy.EXCLUDE
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
