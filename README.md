# Lotus Connect

A production-ready Flutter communication platform featuring clean architecture, reactive state management, and multi-engine LLM capabilities.

## Tech Stack
- **Flutter** (Latest Stable)
- **State Management & Dependency Injection**: Riverpod 3.x
- **Local Database**: Drift (SQLite)
- **Networking**: Dio
- **Routing**: GoRouter
- **Functional Programming**: fpdart
- **Model Generation**: Freezed, json_serializable

## Getting Started
1. Run `flutter pub get` to download dependencies.
2. Run `dart run build_runner build --delete-conflicting-outputs` to generate Drift schemas and Riverpod notifier bindings.
3. Run `flutter run` to launch the application.
