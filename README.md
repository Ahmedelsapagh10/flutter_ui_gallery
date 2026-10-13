# Flutter UI Gallery 🎨

<p align="center">
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  </a>
  <a href="https://dart.dev">
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  </a>
  <a href="https://github.com/Ahmedelsapagh10/flutter_ui_gallery/blob/master/LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License">
  </a>
  <a href="https://github.com/Ahmedelsapagh10/flutter_ui_gallery/pulls">
    <img src="https://img.shields.io/badge/PRs-Welcome-brightgreen.svg?style=for-the-badge" alt="PRs Welcome">
  </a>
</p>

<p align="center">
  A curated collection of modern, responsive, and reusable Flutter UI components, animations, and screen templates designed to accelerate Flutter development.
</p>

---

## 🚀 Overview

**Flutter UI Gallery** is an all-in-one showcase and component library built with Flutter. It provides pre-crafted, production-ready widgets and screens adhering to the latest design trends and Material 3 / iOS Cupertino guidelines.

Whether you're building an MVP or scaling an enterprise app, copy-paste or import beautiful UI blocks with ease.

---

## ✨ Features

- 🧩 **Modular Components**: Cleanly decoupled widgets (Buttons, Cards, Inputs, Dialogs, Navbars, Drawers, Badges).
- 📱 **Full Screen Templates**: Auth (Login/Register), Onboarding, Dashboard, Profile, Settings, E-commerce, and more.
- 🎨 **Theme Ready**: Seamless Light and Dark mode support with dynamic color schemes.
- 💫 **Smooth Animations**: Interactive micro-interactions and transitions using Flutter animation primitives.
- 📐 **Fully Responsive**: Optimized for Mobile (iOS & Android), Tablet, Web, and Desktop screen sizes.
- ⚡ **Clean Architecture**: Follows best practices and clean Dart/Flutter code conventions.

---

## 🛠️ Getting Started

### Prerequisites

Ensure you have Flutter installed on your machine:
```bash
flutter --version
```

### Installation

Add `flutter_ui_gallery` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_ui_gallery:
    git:
      url: https://github.com/Ahmedelsapagh10/flutter_ui_gallery.git
```

Or install it directly via the terminal:

```bash
flutter pub add flutter_ui_gallery
```

Then fetch dependencies:

```bash
flutter pub get
```

---

## 💡 Usage

Import the package where needed:

```dart
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
```

Example widget usage:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter UI Gallery Example'),
      ),
      body: Center(
        child: Text(
          'Explore custom UI components and templates!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
```

---

## 📁 Project Structure

```text
flutter_ui_gallery/
├── lib/
│   ├── flutter_ui_gallery.dart    # Main package export
│   └── src/                       # Widgets, themes, and screens
├── example/                       # Showcase demo application
├── test/                          # Unit and widget tests
└── pubspec.yaml                   # Package dependencies & configuration
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## 👨💻 Author

<p align="center">
  <img src="https://raw.githubusercontent.com/Ahmedelsapagh10/waapi_flutter/main/assets/me3.webp" width="120" style="border-radius: 50%;" alt="Eng Ahmed Mohamed Elsapagh">
</p>

<p align="center">
  <strong>Eng Ahmed Mohamed Elsapagh</strong>
</p>

- 🌐 **Portfolio**: [elsapagh.octopusteam.net](https://elsapagh.octopusteam.net/)
- 💼 **Role**: Co-founder & Mobile Lead at [Octopus Team](https://octopusteam.net)

### 📬 Contact Us
- 📧 **Email**: [ahmedelsapagh@gmail.com](mailto:ahmedelsapagh@gmail.com)
- 💬 **WhatsApp**: [+201201709414](https://wa.me/201201709414)
