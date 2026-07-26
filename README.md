# Lotus Connect

A production-ready Flutter communication platform featuring clean architecture, reactive state management, and multi-engine LLM capabilities.

## Chatbot Demo
Introduce Lotus Connect Chatbot capabilities, featuring smooth SSE streaming, optimistic UI bubble updates, and multi-engine AI support (live Gemini models & local Ollama models).

<video src="https://devblocks.tech/wp-content/uploads/2026/07/lotus_connect_chatbot_demo.mov" controls width="100%"></video>

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
