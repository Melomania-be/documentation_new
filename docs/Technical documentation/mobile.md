# TD: Mobile App Wrapper

*Edited by Borshon*

The mobile application is a native wrapper built around the Melomania web app using **CapacitorJS**. It embeds the web app directly within native iOS and Android WebView containers.

---

## Codebase Structure

The mobile code is located in the `mobile/` directory at the root of the repository:
```
mobile/
├── android/                 ← Native Android Studio Project
├── ios/                     ← Native Xcode Project
├── www/                     ← Static web assets placeholder (Capacitor target)
├── capacitor.config.ts      ← Capacitor configuration file
├── package.json             ← Node dependencies and build scripts
└── README.md                ← Local build guide
```

---

## Deployment Configuration

The Capacitor app is set up to load the live web platform dynamically instead of embedding static local files. This ensures that any update deployed to the web frontend is immediately loaded by mobile app users without needing to recompile and redistribute the APK/App.

### API & Web Server URL
The target URL is configured in **`mobile/capacitor.config.ts`**:
```typescript
import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'be.melomania.app',
  appName: 'Melomania',
  webDir: 'www',
  server: {
    url: 'https://tool.melomania.be', // Live production URL
    cleartext: true
  }
};

export default config;
```

---

## How to Build the Android APK

If you need to compile a new version of the Android app, run the following steps on a machine with **Android Studio** installed:

### Step 1: Synchronize Configuration
If you modified `capacitor.config.ts`, run Capacitor sync to apply the changes to the native Android and iOS wrapper folders:
```bash
cd mobile
npm run sync # Alias for: npx cap sync
```

### Step 2: Build with Gradle
From the `/mobile/android` folder, run the Gradle compilation. 
* *Note: If Java is not configured in your shell path, define the `JAVA_HOME` pointing to Android Studio's bundled JDK.*

**On macOS:**
```bash
cd mobile/android
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew assembleDebug
```

### Step 3: Retrieve the APK
Once compilation completes successfully (`BUILD SUCCESSFUL`), the output APK file will be located at:
`mobile/android/app/build/outputs/apk/debug/app-debug.apk`

Copy this file, rename it to follow versioning conventions (e.g. `melomania-v1.0.0.apk`), and upload it to the **GitHub Releases** page as a release asset.
