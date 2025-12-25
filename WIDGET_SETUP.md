# Home Screen Widget Setup

I've implemented the logic for the Home Screen widget. Here's how to complete the setup for Android and iOS:

## Android (Completed)
The Android implementation is fully integrated. You should be able to see the "Today's Habits" widget in your device's widget list after a full rebuild.

- **Files created/modified:**
  - `pubspec.yaml`: added `home_widget`
  - `AndroidManifest.xml`: registered `HabitWidgetProvider`
  - `res/xml/habit_widget_info.xml`: widget configuration
  - `res/layout/habit_widget_layout.xml`: widget UI
  - `res/drawable/widget_background.xml`: widget styling
  - `MainActivity.kt`: (no changes needed for basic support)
  - `HabitWidgetProvider.kt`: Kotlin logic for updating the widget

## iOS (Manual Steps Required)
iOS widgets require a "Widget Extension" target which must be created in Xcode.

1. **Open your project in Xcode:** `ios/Runner.xcworkspace`
2. **Add App Group:**
   - Select the `Runner` target.
   - Go to `Signing & Capabilities`.
   - Click `+ Capability` and add `App Groups`.
   - Add a new group named `group.com.example.habit`.
3. **Add Widget Extension:**
   - Go to `File > New > Target...`
   - Select `Widget Extension`.
   - Name it `HabitWidgetExtension`.
   - Uncheck "Include Configuration Intent".
   - Activate the new scheme if prompted.
4. **Configure Widget Extension:**
   - Select the new `HabitWidgetExtension` target.
   - Go to `Signing & Capabilities`.
   - Add the same `App Group` (`group.com.example.habit`).
5. **Copy Code:**
   - Replace the contents of the generated `HabitWidget.swift` (in the `HabitWidgetExtension` folder) with the code I've provided in `ios/Runner/HabitWidget.swift`.

## Flutter Logic
The app is now configured to update the widget:
- When the app starts.
- Whenever a habit is added, updated, deleted, or toggled.

The widget will display Today's habits with a ✅ or ⭕ status.
