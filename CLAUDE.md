# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Klinik** is an offline-first dental academic assistant for dentistry students. All data is stored locally via SQLite — there are no network dependencies. The Flutter app targets Android and iOS, using Spanish (es_ES) exclusively.

Flutter version is pinned via FVM at `3.38.1`. The project root is `code/project_mmh/`.

## Commands

Run these from `code/project_mmh/`:

```bash
# Install dependencies
flutter pub get

# Code generation (Freezed models, JSON serializable — required after model changes)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Lint
flutter analyze --no-fatal-infos

# Run all tests
flutter test --no-pub

# Run a single test file
flutter test test/path/to/test_file.dart --no-pub
```

## Architecture

Feature-first Clean Architecture with two layers per feature: `data/` (repos + data sources) and `presentation/` (providers + screens). There is no explicit `domain/` usecase layer — notifiers call repositories directly. Freezed models live under each feature root (e.g., `features/agenda/domain/`).

```
lib/
  core/
    database/     # DatabaseHelper — schema, migrations, FK enforcement
    router/       # GoRouter (app_router.dart)
    services/     # NotificationService, ImageService
    theme/        # AppTheme (light/dark)
    presentation/widgets/  # AppEntityCard, AppFilterChip, etc.
  features/
    agenda/       # Calendar, treatment list, session scheduling
    clinicas_metas/  # Periods, clinics, per-clinic treatment goals
    dashboard/    # Stats with period/clinic filters
    diagnosis/    # AI-assisted diagnostic wizard
    odontograma/  # Interactive ISO dental chart
    pacientes/    # Patient CRUD, photos, soft-delete
    settings/     # Theme toggle, reminders, clinic management
    core/         # SharedPreferences providers (theme, last-viewed period)
  shared/widgets/ # ScaffoldWithNavBar
  main.dart
```

## State Management: Riverpod

**Data flow:** `ConsumerWidget` → `AsyncNotifierProvider` → `Repository` → `DatabaseHelper` → SQLite

Provider types in use:
- `AsyncNotifierProvider` — mutable lists with CRUD (e.g., `patientsProvider` / `PatientsNotifier`)
- `FutureProvider` / `FutureProvider.family` — read-only async fetches (e.g., `patientByIdProvider`, `objetivosByClinicaProvider(id)`)
- `StateProvider` — local UI state (e.g., `selectedDateProvider`, `statusFilterProvider`)
- `StateNotifierProvider` — persisted settings via SharedPreferences (e.g., `reminderSettingsProvider`, `themeModeProvider`)
- `Provider` — singleton repositories (e.g., `patientRepositoryProvider`, `agendaRepositoryProvider`)

**Cross-feature invalidation:** `clinicasUpdateSignalProvider` is a `StateProvider<int>` that is incremented whenever clinics/periods change. Dependent providers (like `allTratamientosRichProvider`) watch it to know when to refetch.

Screens handle async states with `.when(data: ..., loading: ..., error: ...)`. No `Result<T,E>` type — raw exceptions are thrown and caught by Riverpod's error channel.

## Navigation: GoRouter

Router config: `lib/core/router/app_router.dart`. Initial location: `/dashboard`.

**StatefulShellRoute (bottom nav):**

| Path | Screen |
|------|--------|
| `/dashboard` | `DashboardScreen` |
| `/agenda` | `AgendaScreen` |
| `/tratamientos` | `TreatmentsScreen` (query param: `?patientId`) |
| `/tratamientos/:id` | `TreatmentDetailScreen` |
| `/pacientes` | `PatientsScreen` |
| `/pacientes/:id` | `PatientDetailScreen` |
| `/pacientes/:id/edit` | `EditPatientScreen` (extra: `Patient` object) |
| `/settings` | `SettingsScreen` |
| `/settings/clinicas-metas` | `ClinicasMetasScreen` |
| `/settings/recordatorios` | `RemindersSettingsScreen` |

**Full-screen routes (no nav bar):**

| Path | Screen |
|------|--------|
| `/treatment-create` | `AppointmentCreateScreen` |
| `/patient-create` | `AddPatientScreen` |
| `/patient-odontograma/:id` | `OdontogramaScreen` |
| `/diagnosis` | `DiagnosisWizardScreen` |

## Database

SQLite via `sqflite`. Schema and migrations live in `lib/core/database/database_helper.dart`. Current version: **2**.

**Tables:**
- `periodos` — academic periods
- `clinicas` — clinics (FK → periodos); color stored as hex string
- `objetivos` — treatment goals per clinic; `cantidad_actual` manually incremented on treatment finalization
- `pacientes` — patients; `id_expediente` is a string PK (not AUTOINCREMENT); `imagenes_paths` stores pipe-delimited file paths
- `tratamientos` — treatments (FK → clinicas, pacientes, objetivos ON DELETE SET NULL)
- `sesiones` — sessions (FK → tratamientos ON DELETE CASCADE)
- `odontogramas` — one per patient
- `piezas_dentales` — individual teeth in odontogram

**Rules:**
- Foreign keys enforced via `PRAGMA foreign_keys = ON` in `_onConfigure`
- Patients use soft-delete (`deleted_at TEXT`); all patient queries filter `WHERE deleted_at IS NULL`
- If a patient has treatments, deletion soft-deletes the patient and hard-deletes the odontogram. If no treatments exist, the patient is hard-deleted.
- `updatePatientId()` uses `db.transaction()` to atomically cascade the ID change across `tratamientos` and `odontogramas`
- Add schema changes in `_onUpgrade()` and bump the DB version constant

## Freezed Models

All domain entities use `@freezed` with `json_serializable`. Key conventions:
- `@JsonKey(name: 'snake_case_column')` maps SQLite columns to camelCase fields
- `@Default(value)` for optional fields (e.g., `@Default(0) int cantidadActual`)
- Custom field converters declared as top-level functions and referenced via `@JsonKey(fromJson: ..., toJson: ...)`

**Rich models** (`TratamientoRichModel`, `SesionRichModel`) are plain Dart classes (not Freezed) that combine a base entity with joined fields (patient name, clinic color, next session date). They are populated inside repository methods via multiple queries or raw SQL joins — not via separate providers.

## App Bootstrap (main.dart)

1. `initializeDateFormatting('es_ES')` — Spanish locale for `intl`
2. `NotificationService.instance.init(...)` — registers notification tap handler (routes to `/agenda`)
3. `SharedPreferences.getInstance()` — loaded once, injected via `sharedPreferencesProvider` override
4. `reminderSettingsProvider.notifier.refreshNotifications()` — reschedules pending reminders at startup
5. `UncontrolledProviderScope` wraps the app with the pre-configured `ProviderContainer`

## Key Dependencies

```yaml
flutter_riverpod: ^2.6.1
go_router: ^17.0.0
sqflite: ^2.4.2
freezed_annotation: ^3.1.0
json_annotation: ^4.9.0
shared_preferences: ^2.5.3
flutter_local_notifications: ^19.5.0
table_calendar: ^3.2.0
intl: ^0.20.2
image_picker: ^1.2.1
uuid: ^4.5.2
flutter_form_builder: ^10.0.1
form_builder_validators: ^11.2.0
google_fonts: ^7.0.2
flutter_svg: ^2.2.2
modal_bottom_sheet: ^3.0.0
```
