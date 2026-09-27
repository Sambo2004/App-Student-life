# Student Life Hub

Student Life Hub is an offline-first Flutter productivity app for students. It brings classes, tasks, events, expenses, and personal routine insights into one simple workspace.

## What It Includes

- Four-page onboarding experience for first-time users
- Home dashboard with a personalized greeting, profile image, useful summaries, and routine chart
- Class schedule with subject, day, start time, end time, room, instructor, and notes
- Task management for assignments and exams with due dates, categories, priorities, notes, completion, filters, delete, and undo
- Events with date, time, location, organizer, and description
- Expense tracking with amount, date, category, payment method, notes, and spending total
- Profile settings for display name, profile image, text size, font family, text color, and light/dark/system theme
- About Us and Sponsors & Partners pages
- Responsive navigation: side navigation on wide screens and bottom navigation on small screens
- Custom app logo and bundled images
- Local persistence so data remains available after closing the app

## User Flow

On a new installation, the app opens with the welcome pages. Select **Get started** once to enter the app. After onboarding is complete, future launches open the Home page instead of showing welcome again.

Use Profile to change personal appearance settings or reset local app data. Use the add buttons on Schedule, Tasks, Events, and Expenses to enter your own information using date pickers, time pickers, dropdowns, and optional details.

## Technology

- Flutter and Dart
- Material 3 UI
- GetX controllers for app and store state
- SharedPreferences for local settings and student data
- Image Picker for profile images
- Custom Flutter widgets and painting for charts and visual backgrounds

The app is intentionally offline-only. It has no backend, account system, cloud sync, online database, or required network connection. It stores data in the device or browser's local storage and should remain useful with Wi-Fi and mobile data disabled.

## Project Structure

```text
lib/
  main.dart                 App startup, theme, and routing
  data/                     Settings, models, and local student store
  routes/                   Application route definitions
  screens/                  Welcome, home, schedule, tasks, events, expenses, profile, and info pages
  widgets/                  Shared shell, headers, backgrounds, charts, and UI components
assets/                     Welcome animation and app image assets
web/                        Web title, favicon, manifest, and entry page
android/                    Android project and launcher branding
deploy.bat                  Windows Flutter web build and SCP deployment script
```

## Run Locally

Install the Flutter SDK and make sure `flutter` is available in your terminal.

```bash
flutter doctor
flutter pub get
flutter run
```

To check the project before committing changes:

```bash
flutter analyze
flutter test
```

The application entry point is `lib/main.dart`. The `.widget_preview` directory is only preview tooling and is not the main application entry point.

## Build For Web

Create a production web build with:

```bash
flutter pub get
flutter build web --release --no-pub
```

The compiled files are generated in `build/web`.

## Deploy To AWS Linux

`deploy.bat` builds the release version, verifies the app image and Material Icons assets, uploads `build/web` using SCP, and makes the files readable by the web server.

Before using it, confirm that:

- OpenSSH `scp` and `ssh` are installed on Windows
- The SSH user, server address, and Nginx directory in `deploy.bat` are correct
- The SSH key or authentication method works without an interactive password prompt
- Nginx serves `/usr/share/nginx/html`

Run it from the project directory:

```bat
deploy.bat
```

After deployment, use `Ctrl+Shift+R` in the browser. If the old icon or image is still visible, clear the browser cache or service worker and reload the site.

## Asset Notes

The app image and logo are declared in `pubspec.yaml` and must be included in the Flutter build. Do not reference local Windows paths such as `C:\Users\...` from Dart code. Use Flutter asset paths such as:

```dart
Image.asset('assets/start_page.gif')
Image.asset('assets/app_logo.webp')
```

Linux paths are case-sensitive, so asset names must match their filenames exactly.

## Resetting Local Data

Open **Profile** and choose the reset option to clear locally saved settings and student records. This returns the app to a clean first-install state and shows onboarding again.

## About The Project

- Founder: Sum Sambo
- Email: sumsambo8899@gmail.com
- Education: Computer Science
- Team: Sao Sreynet, Srun Darasthya, and Kun Korn

## Future Production Improvements

For a larger real-world release, the next useful additions would be user authentication, encrypted cloud sync, database backup, push notifications, automated tests for data persistence, and a production privacy policy.
