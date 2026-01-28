# BlitzTap ⚡

A professional chess clock timer app built with Flutter, designed for competitive chess players who need precise time management during their games.

## Features

### 🎯 Core Functionality
- **Split-screen timer** - Two-player interface with independent timers
- **Time controls** - Preset categories (Bullet, Blitz, Rapid) and custom time settings
- **Increment support** - Add time after each move (e.g., 3+2, 5+1)
- **Custom presets** - Save and reuse your favorite time controls
- **Player customization** - Edit player names and randomize starting player

### 🎮 Game Controls
- **Turn switching** - Tap the active player's side to switch turns
- **End game actions** - Checkmate, Stalemate, and Forfeit buttons with confirmation dialogs
- **Pause functionality** - Request pause (requires both players to confirm)
- **Swap orientation** - Rotate the board view for both players
- **Low-time warning** - Visual and audio alerts when time drops below 10 seconds

### 🎨 User Experience
- **Modern UI** - Clean, intuitive design with smooth animations
- **Full-screen mode** - Immersive gameplay experience
- **Haptic feedback** - Tactile responses for all button interactions
- **3-2-1 countdown** - Animated countdown before game starts
- **Precision timing** - Millisecond accuracy when time is critical (< 10 seconds)

### 🔒 Security
- **App signing** - Properly configured for release builds
- **Keystore protection** - Secure signing keys (never committed to repository)

## Screenshots

The app features:
- **Homepage** - Time control selection with preset categories
- **Timer Screen** - Split-screen view with inverted top half for player 2
- **Confirmation Overlays** - Safety dialogs for critical game-ending actions
- **End Game Screen** - Results display with new game option

## Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / Xcode (for mobile development)
- Dart SDK (included with Flutter)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Bennie09/blitztap.git
   cd blitztap
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Building for Release

### Android APK

1. **Ensure keystore is configured**
   - The keystore file (`blitztap-keystore.jks`) should be in the project root
   - Update `android/key.properties` with your keystore credentials

2. **Build the release APK**
   ```bash
   flutter build apk --release
   ```

3. **Find your APK**
   - Location: `build/app/outputs/flutter-apk/app-release.apk`

### iOS (Coming Soon)
```bash
flutter build ios --release
```

## Project Structure

```
blitztap/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── game_state.dart      # Game status enums
│   │   ├── player.dart          # Player model
│   │   └── time_preset.dart     # Time preset model
│   ├── providers/
│   │   └── game_provider.dart   # Game state management
│   ├── screens/
│   │   ├── settings_screen.dart  # Homepage/settings
│   │   └── game_screen.dart      # Timer screen
│   ├── utils/
│   │   └── app_colors.dart      # Color palette
│   └── widgets/                  # Reusable UI components
│       ├── action_buttons.dart
│       ├── confirmation_overlay.dart
│       ├── countdown_overlay.dart
│       ├── end_game_overlay.dart
│       ├── pause_overlay.dart
│       ├── player_half.dart
│       ├── swap_button.dart
│       └── timer_display.dart
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
└── assets/                       # Images and icons
```

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Fonts**: Google Fonts (Public Sans)

## Time Control Presets

### Bullet
- 1 minute
- 1 + 1 (1 minute with 1 second increment)
- 2 + 1

### Blitz
- 3 minutes
- 3 + 2
- 5 minutes

### Rapid
- 10 minutes
- 15 + 10
- 30 minutes

### Custom
- Set your own time and increment
- Save multiple custom presets
- Delete saved presets with long-press

## Development

### Key Features Implementation
- **Timer Logic**: Uses `Timer.periodic` for precise 100ms updates
- **State Management**: Provider pattern for reactive UI updates
- **Animations**: Custom animations for countdown and transitions
- **Full Screen**: System UI mode management for immersive experience
- **Signing**: Proper Android app signing configuration

## Security Notes

⚠️ **Important**: 
- Never commit keystore files (`.jks`, `.keystore`) to version control
- Never commit `key.properties` file
- Keep your keystore password secure
- Back up your keystore file in a secure location

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available for public use.

## Author

Developed with ❤️ for chess enthusiasts

## Security Note

This repository is public, but the app signing keys are **never** committed to the repository. The keystore files (`.jks`, `.keystore`) and `key.properties` are excluded via `.gitignore`. 

If you want to build and publish your own version:
1. Create your own keystore using the instructions in the "Building for Release" section
2. Update `android/key.properties` with your own credentials
3. Build and sign your own APK

**Important**: Each developer needs their own keystore to publish to Google Play Store. You cannot update someone else's published app without their keystore. by Benjamin Oguntade

---

**Note**: This app is designed for competitive chess play. Always ensure fair play and sportsmanship when using timing features.
