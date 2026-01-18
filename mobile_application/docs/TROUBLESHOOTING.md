# Troubleshooting Guide

## Common Issues and Solutions

### Build Issues

#### Issue: "Gradle build failed"

**Solution:**

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### Issue: "CocoaPods installation failed"

**Solution:**

```bash
cd ios
pod deintegrate
pod cache clean --all
pod install
cd ..
flutter clean
flutter run
```

#### Issue: "Version conflict in dependencies"

**Solution:**

```bash
flutter pub upgrade --major-versions
flutter pub get
```

### Authentication Issues

#### Issue: "Supabase initialization failed"

**Cause:** Missing or incorrect environment variables

**Solution:**

1. Verify `.env` file exists
2. Check `SUPABASE_URL` and `SUPABASE_ANON_KEY` are correct
3. Restart the app

#### Issue: "OTP not received"

**Possible causes:**

- Phone number format incorrect (should include country code)
- Supabase auth settings not configured
- Network connectivity issues

**Solution:**

1. Ensure phone number includes country code: `+911234567890`
2. Check Supabase dashboard for auth settings
3. Verify network connection

### Runtime Errors

#### Issue: "LateInitializationError: Field has not been initialized"

**Cause:** Accessing Supabase before initialization

**Solution:**

```dart
// Ensure Supabase is initialized before use
await SupabaseService.initialize();
final supabase = Supabase.instance.client;
```

#### Issue: "setState() called after dispose()"

**Solution:**

```dart
if (mounted) {
  setState(() {
    // Update state
  });
}
```

### UI Issues

#### Issue: "Keyboard overlapping text fields"

**Solution:**

```dart
Scaffold(
  resizeToAvoidBottomInset: true,
  body: SingleChildScrollView(
    child: // Your content
  ),
)
```

#### Issue: "Bottom overflow by X pixels"

**Solution:**

- Wrap content in `SingleChildScrollView`
- Use `Expanded` or `Flexible` for flexible layouts
- Check for hardcoded heights

### Performance Issues

#### Issue: "App is laggy/slow"

**Solutions:**

1. Use `const` constructors where possible
2. Avoid rebuilding entire tree
3. Use `RepaintBoundary` for complex widgets
4. Profile with DevTools: `flutter run --profile`

#### Issue: "Large app size"

**Solutions:**

```bash
# Remove unused resources
flutter clean

# Build with --split-per-abi for Android
flutter build apk --split-per-abi

# Analyze app size
flutter build apk --analyze-size
```

### State Management Issues

#### Issue: "Provider not found"

**Cause:** Provider not declared in ancestor

**Solution:**

```dart
// Ensure provider is declared in ProviderScope
runApp(
  ProviderScope(
    child: MyApp(),
  ),
);
```

#### Issue: "State not updating"

**Solution:**

- Verify you're using `StateNotifier` correctly
- Check if you're calling `state = newState`
- Use `ref.watch()` instead of `ref.read()` in build methods

### Database Issues

#### Issue: "Failed to fetch data from Supabase"

**Solutions:**

1. Check network connectivity
2. Verify Supabase URL is correct
3. Check Row Level Security (RLS) policies
4. Verify user is authenticated

#### Issue: "Permission denied"

**Cause:** Row Level Security (RLS) blocking access

**Solution:**

- Review RLS policies in Supabase dashboard
- Ensure policies allow authenticated users
- Check user authentication status

### Development Issues

#### Issue: "Hot reload not working"

**Solutions:**

```bash
# Restart app
r (in terminal)

# Full restart
R (in terminal)

# If still not working
flutter clean
flutter run
```

#### Issue: "VS Code not detecting Flutter SDK"

**Solution:**

1. Open Command Palette (Ctrl/Cmd + Shift + P)
2. Type "Flutter: Change SDK"
3. Select your Flutter SDK path

## Debugging Tips

### Enable verbose logging

```bash
flutter run -v
```

### View Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Check Flutter doctor

```bash
flutter doctor -v
```

### Clear all caches

```bash
flutter clean
flutter pub cache repair
rm -rf ~/.pub-cache
flutter pub get
```

## Getting Help

If your issue isn't listed here:

1. Check [Flutter documentation](https://flutter.dev/docs)
2. Search [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
3. Check [Supabase documentation](https://supabase.com/docs)
4. Open an issue on GitHub with:
   - Error message
   - Steps to reproduce
   - Device/OS information
   - Flutter doctor output
