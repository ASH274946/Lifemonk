# 🎓 LifeMonk - Gamified Learning Platform

A gamified EdTech app for kids built with Flutter, designed to make learning fun and engaging through interactive features and personalized learning paths.

[![Flutter](https://img.shields.io/badge/Flutter-3.24-blue.svg)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Tech Stack

- **Flutter** (latest stable)
- **Supabase** (Auth + Database)
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **UI:** Material 3
- **Platform:** Android first

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App-wide constants
│   ├── router/         # GoRouter configuration
│   ├── theme/          # App themes
│   └── utils/          # Utility functions
├── features/
│   ├── auth/           # Authentication feature
│   ├── home/           # Home screen
│   ├── onboarding/     # Onboarding flow
│   └── splash/         # Splash screen
├── shared/
│   ├── services/       # Shared services (Supabase, LocalStorage)
│   └── widgets/        # Reusable widgets
└── main.dart           # App entry point
```

## Setup Instructions

1. **Clone the repository**

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Supabase**

   - Copy `.env.example` to `.env`
   - Replace placeholder values with your Supabase credentials:
     ```
     SUPABASE_URL=your_supabase_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## App Flow

```
Splash → Login → Onboarding → Home
```

- **Splash:** Initial loading screen, checks auth state
- **Login:** Email/Password or Phone OTP authentication
- **Onboarding:** First-time user experience (persisted locally)
- **Home:** Main app dashboard

## State Management

- Auth state is reactive using Riverpod
- Onboarding completion persists locally via SharedPreferences
- App restores correct screen on restart based on auth + onboarding state

## Environment Variables

Never commit `.env` file. Use `.env.example` as a template.
