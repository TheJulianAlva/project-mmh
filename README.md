<p align="center">
  <img src="../lib/assets/klinik-icon.png" alt="Klinik Logo" width="120" height="120" />
</p>

<h1 align="center">Klinik</h1>

<p align="center">
  <strong>A smart, offline-first dental academic assistant for dentistry students.</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#project-structure">Project Structure</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38.1-02569B?logo=flutter" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Dart-3.7.2+-0175C2?logo=dart" alt="Dart Version" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen" alt="Platform" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20%2B%20Feature--First-blueviolet" alt="Architecture" />
  <img src="https://img.shields.io/badge/License-Proprietary-lightgrey" alt="License" />
</p>

---

## Overview

**Klinik** is a cross-platform mobile application built with Flutter, designed specifically for **dentistry students** to manage their clinical academic workflow entirely offline. It consolidates patient records, dental charting (odontogram), appointment scheduling, treatment tracking, and academic goal management into a single, elegant, and private tool — all without requiring an internet connection.

Data is stored locally on-device using **SQLite**, ensuring patient information never leaves the student's phone.

---

## Features

### 🏠 Dashboard
- At-a-glance view of academic progress with dynamic statistics.
- Filter data by **semester** (period) and **clinic**.
- Quick-action buttons for creating new patients and treatments.
- Visual progress indicators for clinical goals.

### 📅 Agenda & Scheduling
- Full-featured calendar with **monthly, bi-weekly,** and **weekly** views powered by `table_calendar`.
- Create, edit, and manage appointment **sessions** linked to treatments.
- Session status tracking: *Scheduled*, *Completed*, *No-Show*.
- Cupertino-style date & time pickers with Spanish locale support.

### 🦷 Patient Management
- Complete patient records with file number, demographics, and medical history.
- Attach and manage **clinical photographs** via the device camera or gallery.
- Built-in search and filtering for quick patient lookup.


### 🔬 Interactive Odontogram
- Full **universal dental chart** (ISO numbering system) for adult and pediatric dentitions.
- Tap-to-edit interaction for both **global tooth states** (absent, extraction-indicated, erupting, fixed prosthesis/bridge) and **surface-level conditions** (caries, restoration, sealant, fracture).
- Visual bridge grouping with multi-tooth selection logic.
- Color-coded rendering: red for pathology, blue for restorations.
- Live state persistence — every change is saved immediately to the local database.

### 📋 Treatment Tracking
- Create and manage treatments linked to patients, clinics, and academic goals.
- Multi-session treatment workflow with status transitions (*Planned → Completed*).
- Goal-linked treatments automatically update academic progress counters when marked as completed.

### 🎯 Clinics & Academic Goals
- Define **semesters** (periods), **clinics**, and per-clinic **treatment goals** (e.g., "10 Endodontics for Integral Clinic I").
- Track real-time progress with `current / target` counters.
- Color-coded clinic identification throughout the app.

### 🔔 Local Notifications & Reminders
- Daily agenda reminders with configurable time.
- All-configurable reminders.

### ⚙️ Settings
- **Dark / Light mode** toggle.
- Reminder configuration screen.
- Clinic & Goal management access.

### 🎨 Design & UX
- Modern **iOS/Cupertino-inspired** UI.
- Polished color palette.
- Smooth micro-animations and transitions throughout.
- Full **Spanish (es_ES) localization** for dates, calendars, and UI text.

---

## Screenshots

> _Coming soon — screenshots will be added in a future release._

<!--
| Dashboard | Agenda | Odontogram |
|:---------:|:------:|:----------:|
| ![Dashboard](docs/screenshots/dashboard.png) | ![Agenda](docs/screenshots/agenda.png) | ![Odontogram](docs/screenshots/odontogram.png) |

| Patients | Treatments | Settings |
|:--------:|:----------:|:--------:|
| ![Patients](docs/screenshots/patients.png) | ![Treatments](docs/screenshots/treatments.png) | ![Settings](docs/screenshots/settings.png) |
-->

---

## Architecture

Klinik follows a **Feature-First Clean Architecture** pattern, combining modular feature isolation with a clear separation of concerns across layers:

```
┌─────────────────────────────────────────────────┐
│                  Presentation                   │
│         (Screens, Widgets, Providers)           │
│              Riverpod + GoRouter                │
├─────────────────────────────────────────────────┤
│                    Domain                       │
│          (Entities, Models – Freezed)           │
├─────────────────────────────────────────────────┤
│                     Data                        │
│         (Repositories, SQLite Access)           │
├─────────────────────────────────────────────────┤
│                     Core                        │
│      (Database, Theme, Router, Services)        │
└─────────────────────────────────────────────────┘
```

**Data flow per entity:**

1. **Entity (Domain)** — Immutable data class annotated with `@freezed` + `@JsonSerializable`.
2. **DatabaseHelper (Core)** — Raw SQL operations against SQLite via `sqflite`.
3. **Repository (Data)** — Abstraction layer over database access.
4. **Provider (Presentation)** — `AutoDisposeAsyncNotifier` from Riverpod, exposing `AsyncValue` state to the UI.

---

## Tech Stack

| Category | Technology |
|:---------|:-----------|
| **Framework** | [Flutter](https://flutter.dev) 3.38.1 |
| **Language** | Dart 3.7.2+ |
| **State Management** | [Riverpod](https://riverpod.dev) (`flutter_riverpod`) |
| **Navigation** | [GoRouter](https://pub.dev/packages/go_router) |
| **Local Database** | [sqflite](https://pub.dev/packages/sqflite) + `path` |
| **Models & Immutability** | [Freezed](https://pub.dev/packages/freezed) + `json_serializable` |
| **Forms** | [Flutter Form Builder](https://pub.dev/packages/flutter_form_builder) + Validators |
| **Calendar** | [Table Calendar](https://pub.dev/packages/table_calendar) |
| **Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| **Typography** | [Google Fonts](https://pub.dev/packages/google_fonts) (Outfit) |
| **Image Picker** | [image_picker](https://pub.dev/packages/image_picker) |
| **Preferences** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **Icons** | [Font Awesome Flutter](https://pub.dev/packages/font_awesome_flutter) + Material Icons |
| **SVG Rendering** | [flutter_svg](https://pub.dev/packages/flutter_svg) |
| **Splash & Icons** | `flutter_native_splash` + `flutter_launcher_icons` |
| **Version Manager** | [FVM](https://fvm.app) |

---

## Getting Started

### Prerequisites

- **Flutter SDK** 3.38.1 or later (managed via [FVM](https://fvm.app) recommended)
- **Dart SDK** 3.7.2+
- **Android Studio** or **Xcode** (for emulator/simulator)
- **Git**

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/TheJulianAlva/project-mmh.git
   cd project-mmh/code/project_mmh
   ```

2. **Install Flutter version (if using FVM):**

   ```bash
   fvm install
   fvm use
   ```

3. **Install dependencies:**

   ```bash
   flutter pub get
   ```

4. **Generate model code:**

   Freezed and JSON serializable classes require code generation:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Generate localization files:**

   ```bash
   flutter gen-l10n
   ```

6. **Run the app:**

   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android

- **Minimum SDK:** 21 (Android 5.0 Lollipop)
- Permissions required: `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `POST_NOTIFICATIONS`, `USE_FULL_SCREEN_INTENT` (configured in `AndroidManifest.xml`).

#### iOS

- **Minimum Deployment Target:** iOS 12.0
- Camera and photo library usage descriptions are pre-configured in `Info.plist`.

---

## Project Structure

```
├──code/project_mmh/
├── android/                    # Android platform project
├── ios/                        # iOS platform project
├── lib/
│   ├── assets/                 # App icons, splash, and branding assets
│   ├── core/
│   │   ├── database/           # SQLite DatabaseHelper (schema + migrations)
│   │   ├── router/             # GoRouter configuration (app_router.dart)
│   │   ├── services/           # NotificationService and other core services
│   │   └── theme/              # AppTheme (light & dark) + clinic palette
│   ├── features/
│   │   ├── agenda/             # Calendar, sessions, and appointment logic
│   │   │   ├── data/           # Repositories
│   │   │   ├── domain/         # Entities (Treatment, Session)
│   │   │   └── presentation/   # Screens, widgets, providers
│   │   ├── clinicas_metas/     # Clinic & academic goal management
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── dashboard/          # Main dashboard with stats & quick actions
│   │   │   └── presentation/
│   │   ├── diagnosis/          # AI-assisted diagnostic wizard
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── odontograma/        # Interactive dental chart
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── pacientes/          # Patient CRUD and records
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── settings/           # App settings (theme, reminders)
│   │   │   └── presentation/
│   │   └── core/               # Shared feature utilities (preferences, theme providers)
│   │       └── presentation/
│   ├── shared/                 # Shared widgets (e.g., ScaffoldWithNavBar)
│   └── main.dart               # App entry point
├── docs/                       # Project documentation
├── pubspec.yaml                # Dependencies and project metadata
└── README.md                   # ← You are here
```

---

## Medical Disclaimer

This application is an **auxiliary and educational tool**. By using it, you acknowledge that:

- Suggestions and data are algorithmic. Professional judgment and faculty supervision are the final authority.
- It should not be the sole basis for clinical decisions or patient interventions.
- Accuracy depends entirely on the data entered by the user.
- The developers are not responsible for erroneous diagnoses or treatments derived from the use of this tool.

**By using this app, you confirm that you understand these limitations and assume full responsibility for your clinical decisions.**

---

## Contributing

Contributions are welcome! To get started:

1. **Fork** the repository.
2. Create a **feature branch:** `git checkout -b feature/my-feature`
3. **Commit** your changes: `git commit -m 'feat: add my feature'`
4. **Push** to the branch: `git push origin feature/my-feature`
5. Open a **Pull Request**.

Please ensure all contributions:
- Follow the existing **Feature-First** architecture pattern.
- Include code generation output (`build_runner build`) if models are modified.
- Pass `flutter analyze` with no new issues.

---

## Acknowledgments

- Built with [Flutter](https://flutter.dev) by Google.
- Calendar powered by [Table Calendar](https://pub.dev/packages/table_calendar).
- State management by [Riverpod](https://riverpod.dev).

---

<p align="center">
   <i>Klinik, your essential companion for dental life.</i>
   <i>Made with ❤️ for dentistry students everywhere.</i>
</p>
