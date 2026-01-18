# Deployment Guide

## Android Deployment

### Prerequisites

- Android Studio installed
- Java Development Kit (JDK) configured
- Android device or emulator

### Build APK

```bash
flutter build apk --release
```

### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### Debug Build

```bash
flutter build apk --debug
```

## iOS Deployment

### Prerequisites

- Xcode installed (macOS only)
- Apple Developer account
- iOS device or simulator

### Build iOS App

```bash
flutter build ios --release
```

### Archive for App Store

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Product" > "Archive"
3. Follow App Store Connect upload process

## Web Deployment

### Build Web App

```bash
flutter build web --release
```

### Deploy to Firebase Hosting

```bash
firebase deploy --only hosting
```

### Deploy to Netlify

1. Build the web app
2. Deploy the `build/web` directory

## Environment Configuration

### Production Environment

Create `.env.production`:

```
SUPABASE_URL=your_production_url
SUPABASE_ANON_KEY=your_production_key
```

### Staging Environment

Create `.env.staging`:

```
SUPABASE_URL=your_staging_url
SUPABASE_ANON_KEY=your_staging_key
```

## Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update CHANGELOG.md
- [ ] Run tests: `flutter test`
- [ ] Build and test on multiple devices
- [ ] Update environment variables
- [ ] Create git tag: `git tag v1.0.0`
- [ ] Push to repository: `git push origin --tags`
- [ ] Build release version
- [ ] Submit to store

## Version Management

Follow semantic versioning: `MAJOR.MINOR.PATCH`

Update in `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

- First number: version name
- Second number: build number

## App Signing

### Android

1. Generate keystore:

```bash
keytool -genkey -v -keystore lifemonk-release.keystore -alias lifemonk -keyalg RSA -keysize 2048 -validity 10000
```

2. Configure in `android/key.properties`
3. Reference in `android/app/build.gradle`

### iOS

1. Configure signing in Xcode
2. Use automatic signing or manual provisioning profiles

## Continuous Integration

Consider setting up CI/CD with:

- GitHub Actions
- Codemagic
- Bitrise
