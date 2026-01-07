
# Timelog App Flutter

A robust Flutter application designed for time logging and session management, optimized for kiosk and terminal environments.

## Features

- **Authentication Methods**: Supports multiple ways to log in/out, including:
  - **RFID**: Integration via USB NFC Reader.
  - **QR Code**: Scanning capabilities using `mobile_scanner`.
  - **PIN**: Secure PIN-based entry.
- **Session Management**: Comprehensive tracking of user sessions, active contracts, and event handling.
- **Kiosk Mode**: Built-in support for dedicated hardware setups using `kiosk_mode` and `wakelock_plus`.
- **Weather Integration**: Displays real-time weather information.
- **Advanced Logging**: Integrated with `Talker` for detailed runtime logging and `Dio` interception.
- **Responsive UI**: Features a custom theme, busy overlays, and error handling banners.

## Project Structure

The project follows a feature-first architectural pattern:

- `lib/core`: Shared configurations, HTTP clients (Dio), location services, and storage.
- `lib/features`:
  - `admin`: Administrative controls and settings.
  - `session`: Core business logic for time tracking and user sessions.
  - `rfid` / `qr` / `pin`: Input-specific modules.
  - `logging`: Diagnostic tools and logger UI.
  - `home`: Main dashboard and screen orchestration.
- `plugins`: Contains custom local plugins like `usbnfcreader`.

## Tech Stack

- **State Management**: [Riverpod](https://riverpod.dev/)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Code Generation**: [Freezed](https://pub.dev/packages/freezed) & [JSON Serializable](https://pub.dev/packages/json_serializable)
- **Database/Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences)

## Getting Started

### Prerequisites

- Flutter SDK (see `pubspec.yaml` for version requirements)
- Android/iOS development environment

### Installation

1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```
