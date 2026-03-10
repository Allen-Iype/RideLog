# RideLog App Icon Guide

This directory contains the app launcher icons for the RideLog mobile application.

## Required Icon Files

To generate platform-specific launcher icons, you need to provide:

### 1. Main App Icon (`app_icon.png`)
- **Size:** 1024x1024 pixels (will be scaled down for different platforms)
- **Format:** PNG with transparency
- **Purpose:** Used for iOS and older Android versions

### 2. Adaptive Icon Foreground (`app_icon_foreground.png`)
- **Size:** 1024x1024 pixels
- **Format:** PNG with transparency
- **Purpose:** Android adaptive icons (API 26+)
- **Design:** Icon should fit within safe zone (432x432px centered)

## Design Guidelines

### RideLog Icon Concept

The RideLog app is for motorcycle riders to track their journeys. The icon should:

1. **Be Instantly Recognizable** - Simple, bold design that stands out
2. **Represent Motion/Journey** - Convey the idea of riding and tracking
3. **Use Brand Colors** - Primary blue (#1976D2) from the app theme

### Suggested Design Elements

Choose one or combine:
- **Motorcycle silhouette** - Side view of a motorcycle (minimalist)
- **Route/Path** - Curved road or GPS route line
- **Location pin** - Combined with motorcycle or road imagery
- **Speedometer** - Circular gauge with needle
- **Rider icon** - Stylized motorcycle rider from above/behind

### Design Specifications

#### Color Palette
- **Primary Blue:** #1976D2 (Material Blue 700)
- **Accent:** #FFC107 (Amber for highlights)
- **Dark:** #0D47A1 (Material Blue 900)
- **White:** #FFFFFF (for contrast)

#### Style Guidelines
- **Flat Design:** Modern, flat icons work best on mobile
- **Single Focal Point:** One clear element, not cluttered
- **High Contrast:** Ensure visibility on all backgrounds
- **No Text:** Avoid text in the icon (too small on home screens)
- **Safe Margins:** Keep important elements 20% from edges

## Icon Examples (Inspiration)

### Simple Concepts:
1. **Minimalist Motorcycle**
   - White motorcycle silhouette on blue gradient background
   - Side view with clean lines

2. **Route Tracker**
   - Blue background with white route line forming an "R"
   - Location pins at start/end

3. **Rider Badge**
   - Circular badge design
   - Motorcycle viewed from above/top-down
   - GPS-style concentric circles in background

4. **Speed & Motion**
   - Speedometer dial with needle pointing right
   - Motion lines suggesting speed

## Creating Your Icon

### Option 1: Design Tools
- **Figma** (free): https://figma.com
- **Canva** (free): https://canva.com
- **Adobe Illustrator** (paid)
- **Inkscape** (free, open source)

### Option 2: Icon Generators
- **AppIcon.co**: https://appicon.co
- **MakeAppIcon**: https://makeappicon.com
- **Icon Kitchen**: https://icon.kitchen

### Option 3: Hire a Designer
- **Fiverr**: Search for "app icon design"
- **99designs**: Run an icon design contest
- **Dribbble**: Hire from portfolio

## Generating Platform Icons

Once you have your icon files, generate platform-specific icons:

```bash
cd /Users/allen/Personal/RideLog/mobile

# Install dependencies (if not already done)
flutter pub get

# Generate launcher icons
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for:
- **Android**: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi
- **iOS**: All required AppIcon sizes
- **Android Adaptive Icons**: Foreground + background combination

## Testing Your Icon

### Android
1. Build and install: `flutter run -d android`
2. Check home screen, app drawer, settings
3. Test on different Android versions (API 21+ and 26+)

### iOS
1. Build and install: `flutter run -d ios`
2. Check home screen, app switcher
3. Test on different iOS versions and screen sizes

## Current Status

**⚠️ Using Default Flutter Icon**

The app currently uses Flutter's default launcher icon. To create a professional production app:

1. Design or commission a custom RideLog icon
2. Save it as `app_icon.png` (1024x1024px) in this directory
3. Create `app_icon_foreground.png` for Android adaptive icons
4. Run `flutter pub run flutter_launcher_icons` to generate all sizes
5. Rebuild the app to see your new icon

## Quick Start with Placeholder

For quick testing, you can create a simple placeholder:

1. Create a 1024x1024px PNG with:
   - Blue (#1976D2) background
   - White text "RL" in the center (large, bold font)
   - Or use a motorcycle emoji/icon

2. Save as `app_icon.png` in this directory

3. Copy the same file to `app_icon_foreground.png`

4. Run:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

5. Rebuild your app:
   ```bash
   flutter clean
   flutter run
   ```

## Resources

- [Material Design Icons](https://material.io/design/iconography)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Android Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)

---

**Note:** This is currently set up but waiting for icon design. The configuration in `pubspec.yaml` is ready - just add your icon files and run the generator!
