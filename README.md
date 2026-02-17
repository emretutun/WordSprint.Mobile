# WordSprint Mobile (Flutter)

WordSprint is a vocabulary learning app. This repository contains the Flutter mobile client.

## Features (v1)
- Auth: Register, Login, Forgot Password, Reset Password (manual token), Change Password
- Home: Profile card + Stats
- Learn New Words: assign random words + learning list
- Quiz: 4 modes
  - TR → EN (Typing)
  - EN → TR (Typing)
  - TR → EN (Multiple Choice)
  - EN → TR (Multiple Choice)
- Repeat: learned words list + repeat quiz
- Profile: view/edit + photo upload

## Tech
- Flutter
- JWT auth (token stored locally)
- REST API (WordSprint.Api)

## Setup
1. Configure API base url in `lib/core/network/api.dart`
2. Run:
   ```bash
   flutter pub get
   flutter run




