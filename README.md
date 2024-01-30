# app_linkster

A versatile utility to facilitate launching deep links for popular social media platforms. With `app_linkster`, effortlessly convert standard web URLs to platform-specific deep links and launch them seamlessly on both iOS and Android.

## Features

- **Support for Multiple Platforms**: Currently supports Facebook, Twitter, Instagram, TikTok, YouTube, and LinkedIn.
- **Automatic Platform Detection**: It intelligently detects the platform (iOS/Android) and launches the deep link accordingly.
- **Easy Integration**: Designed to be a drop-in solution for projects with minimal setup.
- **Custom Deep Link Parsing**: Uses `DeeplinkCreator` for flexible deep link generation based on given URL patterns.

## Supported Apps

- Facebook
- (X) Twitter
- Instagram
- TikTok
- YouTube
- LinkedIn
- More coming soon!


## Getting Started

### Prerequisites
- Dart SDK: version >=3.0.5 <4.0.0
- Flutter: version >=3.0.0

### Installation
1. Add `app_linkster` to your `pubspec.yaml` file:
```yaml
dependencies:
  app_linkster: ^latest_version
```
2. Install the package:
```bash
$ flutter pub get
```
3. Add query schemes:
  - For iOS, add the following to your `Info.plist` file:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fb</string>
    <string>instagram</string>
    <string>snssdk1233</string>
    <string>twitter</string>
    <string>youtube</string>
    <string>linkedin</string>
</array>
```

- For Android, add the following to your `AndroidManifest.xml` file:

```xml
    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="fb" />
        </intent>
 
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="snssdk1233" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
    </queries>
```

## Usage

1. Import the library:
```dart
import 'package:app_linkster/app_linkster.dart';
```

2. Create an instance of `AppLinksterLauncher` and call `launchThisGuy`:
```dart
final launcher = AppLinksterLauncher();
await launcher.launchThisGuy('https://www.facebook.com/yourProfile');
```
change fallback launch mode:
```dart
final launcher = AppLinksterLauncher();
await launcher.launchThisGuy('https://www.facebook.com/yourProfile', 
    fallbackLaunchMode: LaunchMode.externalApplication);
```

## Additional Information

- **Documentation**: For detailed documentation, WIP.
- **Contributions**: We welcome contributions!.
- **Issues**: If you encounter any problems, please file an issue along with a detailed description.
- **Feedback**: All feedback is welcome! Reach out to us at [mohn93@gmail.com].
