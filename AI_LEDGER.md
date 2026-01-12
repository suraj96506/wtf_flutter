# AI Ledger

## Entry 1: Initial Project Scaffolding
- **Prompt #:** User instruction to "lets do that" (create project structure).
- **Tool:** Gemini CLI Agent
- **Intent:** Create the initial project directory structure and essential markdown files as specified in the assessment PDF. This includes `token_server/`, `shared/` with its subdirectories (`models`, `services`, `widgets`, `utils`), `guru_app/` and `trainer_app/` with their respective `lib/`, `test/` directories, and placeholder `pubspec.yaml` files. Also, `AI_LEDGER.md`, `ARCHITECTURE.md`, `DECISIONS.md`.
- **Output snippet:** Successfully created directories and files: `AI_LEDGER.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `token_server`, `shared/`, `shared/models`, `shared/services`, `shared/widgets`, `shared/utils`, `guru_app/`, `guru_app/lib`, `guru_app/test`, `guru_app/pubspec.yaml`, `trainer_app/`, `trainer_app/lib`, `trainer_app/test`, `trainer_app/pubspec.yaml`.

## Entry 2: Populating pubspec.yaml for Guru and Trainer Apps
- **Prompt #:** Internal decision to populate `pubspec.yaml` files after initial scaffolding.
- **Tool:** Gemini CLI Agent
- **Intent:** Add core Flutter dependencies, `flutter_lints` for code quality, `flutter_riverpod` for state management, and `hmssdk_flutter` for 100ms video call integration to both `guru_app/pubspec.yaml` and `trainer_app/pubspec.yaml`.
- **Output snippet:** Successfully wrote content to `guru_app/pubspec.yaml` and `trainer_app/pubspec.yaml`.

## Entry 3: Running flutter pub get for Dependencies
- **Prompt #:** Internal decision to fetch dependencies after updating `pubspec.yaml` files.
- **Tool:** Gemini CLI Agent
- **Intent:** Execute `flutter pub get` in both `guru_app/` and `trainer_app/` directories to download and resolve specified package dependencies.
- **Output snippet:** `flutter pub get` executed successfully for both `guru_app` and `trainer_app`, downloading packages including `flutter_riverpod` and `hmssdk_flutter`.

## Entry 4: Creating Initial main.dart Files
- **Prompt #:** Internal decision to create minimal entry points for both applications.
- **Tool:** Gemini CLI Agent
- **Intent:** Create basic `main.dart` files in `guru_app/lib/` and `trainer_app/lib/` to allow each application to run as a minimal Flutter app, displaying a simple "Welcome" message.
- **Output snippet:** Successfully created `guru_app/lib/main.dart` and `trainer_app/lib/main.dart`.
