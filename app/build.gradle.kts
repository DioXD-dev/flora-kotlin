plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace   = "com.dioxd.floramusic"
    compileSdk  = 34

    defaultConfig {
        applicationId = "com.dioxd.floramusic"
        minSdk        = 26
        targetSdk     = 34
        versionCode   = 1
        versionName   = "1.0"
    }

    buildTypes {
        release { isMinifyEnabled = false }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions { jvmTarget = "17" }

    buildFeatures { compose = true }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.14"
    }
}

dependencies {
    // Compose BOM — versi dikunci, semua lib konsisten
    val bom = platform("androidx.compose:compose-bom:2024.09.00")
    implementation(bom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.compose.animation:animation")
    implementation("androidx.compose.foundation:foundation")
    debugImplementation("androidx.compose.ui:ui-tooling")

    // AndroidX
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.activity:activity-compose:1.9.2")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.5")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.5")
    implementation("androidx.navigation:navigation-compose:2.8.1")

    // Image loading
    implementation("io.coil-kt:coil-compose:2.7.0")

    // Palette — extract warna dari album art
    implementation("androidx.palette:palette-ktx:1.0.0")

    // Blur
    implementation("jp.wasabeef:blurry:4.0.1")
}
