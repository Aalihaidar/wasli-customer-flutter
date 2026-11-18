import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Signing keys are read from android/key.<environment>.properties when the file exists (CI writes it from the
// environment secrets). Without it a flavor signs with the debug key, so a fresh clone and pull requests still build.
fun loadKeyProperties(fileName: String): Properties? {
    val file = rootProject.file(fileName)
    if (!file.exists()) return null
    return Properties().also { properties ->
        FileInputStream(file).use { properties.load(it) }
    }
}

val stagingKeyProperties = loadKeyProperties("key.staging.properties")
val productionKeyProperties = loadKeyProperties("key.production.properties")

android {
    namespace = "com.alihaidar.wasli_customer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.alihaidar.wasli.customer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        stagingKeyProperties?.let { keys ->
            create("staging") {
                keyAlias = keys.getProperty("keyAlias")
                keyPassword = keys.getProperty("keyPassword")
                storeFile = keys.getProperty("storeFile")?.let { file(it) }
                storePassword = keys.getProperty("storePassword")
            }
        }
        productionKeyProperties?.let { keys ->
            create("production") {
                keyAlias = keys.getProperty("keyAlias")
                keyPassword = keys.getProperty("keyPassword")
                storeFile = keys.getProperty("storeFile")?.let { file(it) }
                storePassword = keys.getProperty("storePassword")
            }
        }
    }

    // The flavor names are the environment names (build.yml uses them as the Gradle flavor, the GitHub environment
    // and the APP_ENV value). Production keeps the plain application ID, because that is the ID in the stores.
    flavorDimensions += "default"
    productFlavors {
        create("staging") {
            dimension = "default"
            applicationIdSuffix = ".staging"
            signingConfig =
                signingConfigs.findByName("staging") ?: signingConfigs.getByName("debug")
        }
        create("production") {
            dimension = "default"
            signingConfig =
                signingConfigs.findByName("production") ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
