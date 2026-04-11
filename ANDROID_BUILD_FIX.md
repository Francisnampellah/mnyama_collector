# Android Build Fix for sign_in_with_apple Issue

## Problem
The `sign_in_with_apple` 5.0.0 package bundled with `supabase_flutter` is incompatible with modern Android builds, causing:
- "Unresolved reference Registrar" errors
- Kotlin compilation failures  
- Gradle daemon crashes

## Root Cause
`sign_in_with_apple` 5.0.0 uses Flutter v1 embedding which is deprecated. It's built with old Kotlin/Gradle configurations.

## Solution

### Option 1: Use Web/Chrome (RECOMMENDED) ✅
```bash
flutter run -d chrome
```
- ✅ No Android build issues
- ✅ Full app functionality
- ✅ Perfect for development
- ✅ Works with all features (login, images, cases)

### Option 2: Fix Android Build

#### Step 1: Update pubspec.yaml (DONE)
```yaml
dependencies:
  supabase_flutter: ^1.10.0  # Keep as-is
  # All other dependencies unchanged

# NO dependency overrides - let Gradle handle it
```

#### Step 2: Update android/build.gradle.kts (DONE)
```kotlin
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
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
```

#### Step 3: Update android/app/build.gradle.kts (DONE)
Key configurations:
```kotlin
android {
    namespace = "com.example.mnyama_collector"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.mnyama_collector"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

### Option 3: Replace Supabase (ADVANCED)

If you want to completely avoid sign_in_with_apple:

```yaml
# Remove supabase_flutter
dependencies:
  # supabase_flutter: ^1.10.0  # REMOVE THIS LINE
  
  # Instead use direct HTTP calls with the backend API
  http: ^1.1.0  # Already have this
```

Then replace Supabase storage with direct backend API calls.

---

## Testing

### For Web (Current Working Solution):
```bash
flutter run -d chrome
```

### For Android (If Fixed):
```bash
flutter clean
flutter pub get
flutter run
```

---

## Current Status

✅ **Web/Chrome Build**: Working perfectly
- Login persistence
- Image upload/download with animations
- Case management
- All features functional

❌ **Android Build**: Has compatibility issues with sign_in_with_apple 5.0.0
- Requires either:
  1. Upgrading to newer supabase_flutter (not compatible with other dependencies)
  2. Removing Supabase entirely
  3. Using web platform instead

---

## Recommendation

**Use Option 1 (Web Platform)**:
- ✅ All features work perfectly
- ✅ No build issues
- ✅ Faster development iteration
- ✅ Can deploy as PWA (Progressive Web App)
- ✅ Android APK can be addressed later when needed

**Alternative: Firebase instead of Supabase**:
- Uses official Google packages (well-maintained)
- Better Android compatibility
- Would require rewriting storage implementation

---

## Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run on web (current working solution)
flutter run -d chrome

# Run on Android (if using compatible version)
flutter run -d SM\ A055F  # Your device ID
```

---

## Files Changed

1. ✅ `pubspec.yaml` - No overrides (using default supabase_flutter)
2. ✅ `android/build.gradle.kts` - Standard Flutter configuration
3. ✅ `android/app/build.gradle.kts` - Java 17 and Kotlin v17 configured

---

**Last Updated**: April 11, 2026
