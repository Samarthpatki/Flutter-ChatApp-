# flutter_chatapp_qualwebs_assignment

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

lib/
│── main.dart
│── core/
│   ├── constants.dart        # App-wide constants
│   ├── helpers.dart          # Utility functions
│   ├── routes.dart           # Named routes for navigation
│── models/
│   ├── chat_message.dart     # Chat message model
│   ├── user.dart             # User model
│── views/
│   ├── chat_screen.dart      # Main chat screen
│   ├── home_screen.dart      # Recent chats screen
│   ├── login_screen.dart     # Authentication screen
│── controllers/
│   ├── chat_controller.dart  # Chat-related logic
│   ├── auth_controller.dart  # Authentication logic
│── services/
│   ├── firebase_service.dart # Firebase interactions
│── widgets/
│   ├── chat_bubble.dart      # Custom chat UI widget
│   ├── custom_button.dart    # Reusable button widget

