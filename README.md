# 📖 Audio Bible - AI-Enhanced KJV Bible App

A modern, feature-rich Bible application with audio playback and AI-powered semantic search, built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.8+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

### 📚 Bible Reading
- **Complete KJV Text** - Full King James Version Bible with 66 books
- **Beautiful Typography** - Lora font for comfortable reading
- **Customizable Font Size** - Adjust text size to your preference
- **Dark/Light Theme** - Automatic theme switching based on system

### 🎧 Audio Playback
- **Full Audio Bible** - Professional narration for all 1,194 chapters
- **Background Playback** - Continue listening while using other apps
- **Playback Controls** - Play, pause, skip, rewind/forward 10s
- **Speed Control** - 0.5x to 2x playback speed
- **Sleep Timer** - Auto-stop after set duration

### 🔍 Search
- **Keyword Search** - Find verses containing specific words
- **AI Semantic Search** - Ask questions in natural language (powered by Google Gemini)
- **Highlighted Results** - See search terms highlighted in results

### 📱 User Experience
- **Modern UI** - Clean, intuitive design with smooth animations
- **Fast Navigation** - Quick access to any book and chapter
- **Verse Highlighting** - Follow along as audio plays
- **Offline Mode** - Read and listen without internet connection

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8+
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ayomide-16/Audio-Bible.git
   cd Audio-Bible
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── constants/               # App-wide constants
│   └── theme/                   # Theme configuration
├── data/
│   ├── models/                  # Data models (Bible, Book, Chapter, Verse)
│   └── repositories/            # Data access layer
├── features/
│   ├── home/                    # Home screen with book grid
│   ├── reader/                  # Bible reading screen
│   ├── audio_player/            # Audio playback widget
│   ├── search/                  # Keyword search
│   └── ai_search/               # AI semantic search
└── shared/
    └── widgets/                 # Reusable UI components
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.8+
- **State Management**: Riverpod
- **Audio**: just_audio, audio_service
- **Storage**: Hive, SharedPreferences
- **AI**: Google Generative AI (Gemini)
- **Fonts**: Google Fonts (Lora, Inter)

## 📊 Data Sources

- **Bible Text**: Structured JSON with 31,102 verses
- **Audio Files**: 1,194 MP3 files (~830MB)
- **Search Index**: Pre-indexed verse data for fast search

## 🔧 Configuration

### Gemini API Setup (for AI Search)

1. Get an API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Add to your environment:
   ```dart
   // In lib/core/constants/api_keys.dart (create this file)
   const String geminiApiKey = 'YOUR_API_KEY';
   ```

## 📱 Screenshots

*Coming soon*

## 🗺️ Roadmap

- [x] Core Bible reading functionality
- [x] Audio playback with controls
- [x] Keyword search
- [ ] Complete AI semantic search integration
- [ ] Verse bookmarks and highlights
- [ ] Reading plans
- [ ] Cross-references
- [ ] Share verses as images
- [ ] iOS release

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting a pull request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- King James Version Bible text - Public Domain
- Audio recordings from the original Audio Bible app

---

**Built with ❤️ for the glory of God**
