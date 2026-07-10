# Velixra Knowledge Hub

Velixra Knowledge Hub is a Flutter frontend for a role-based document and chat platform.
It supports Owner, Manager, and Employee user roles with login, document upload, invite flows, analytics, and document-aware chat.

## Key Features

- Role-based navigation and session persistence
- Login and invitation acceptance flow
- Owner dashboard with document and query analytics
- Manager panel for uploading documents, inviting employees, and managing active files
- Employee chat interface with history drawer and question answering
- Secure storage for auth tokens and role data

## Architecture

- Flutter + Riverpod state management
- `go_router` for routing
- `dio` for networking
- `flutter_secure_storage` for token storage
- Local backend configuration in `lib/core/constants/api_constants.dart`

## Project Structure

- `lib/main.dart` — app entrypoint and startup logic
- `lib/router/` — route definitions and initial route selection
- `lib/presentation/` — UI screens by feature and role
- `lib/providers/` — state providers and business logic
- `lib/data/` — data sources, repositories, and models
- `lib/core/` — theme, constants, storage, and utilities

## Setup

1. Install Flutter and configure your environment:
   - https://flutter.dev/docs/get-started/install
2. Open the project folder:
   - `frontend_velixra`
3. Fetch dependencies:
   - `flutter pub get`

## Running the App

### Mobile / Desktop

- Android/Emulator: `flutter run`
- iOS/Simulator: `flutter run`
- Web: `flutter run -d chrome`
- Windows/macOS/Linux: `flutter run -d windows` (or the corresponding desktop target)

### Notes

- The backend base URL is set in `lib/core/constants/api_constants.dart`.
- For Android emulators, use `10.0.2.2` to access a local machine backend.
- The current package is configured with `publish_to: 'none'` in `pubspec.yaml`.

## Dependencies

- `flutter_riverpod`
- `go_router`
- `dio`
- `pretty_dio_logger`
- `flutter_secure_storage`
- `google_fonts`
- `file_picker`
- `intl`

## Development Tips

- Use the login screen to authenticate and navigate to role-specific screens.
- Managers can upload documents and invite employees from the Manager Panel.
- Owners can review analytics and document summaries in the Owner Dashboard.
- Employees interact with documents and questions through the chat UI.

## License

This project is currently private and not configured for `pub.dev` publishing.
