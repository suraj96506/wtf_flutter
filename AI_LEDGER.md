# AI Ledger

## Entry 1: Initial Project Scaffolding
- **Prompt #:** User instruction to "lets do that" (create project structure).
- **Tool": Gemini CLI Agent
- **Intent:** Create the initial project directory structure and essential markdown files as specified in the assessment PDF. This includes `token_server/`, `shared/` with its subdirectories (`models`, `services`, `widgets`, `utils`), `guru_app/` and `trainer_app/` with their respective `lib/`, `test/` directories, and placeholder `pubspec.yaml` files. Also, `AI_LEDGER.md`, `ARCHITECTURE.md`, `DECISIONS.md`.
- **Output snippet:** Successfully created directories and files: `AI_LEDGER.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `token_server`, `shared/`, `shared/models`, `shared/services`, `shared/widgets`, `shared/utils`, `guru_app/`, `guru_app/lib`, `guru_app/test`, `guru_app/pubspec.yaml`, `trainer_app/`, `trainer_app/lib`, `trainer_app/test`, `trainer_app/pubspec.yaml`.

## Entry 2: Populating pubspec.yaml for Guru and Trainer Apps
- **Prompt #:** Internal decision to populate `pubspec.yaml` files after initial scaffolding.
- **Tool": Gemini CLI Agent
- **Intent:** Add core Flutter dependencies, `flutter_lints` for code quality, `flutter_riverpod` for state management, and `hmssdk_flutter` for 100ms video call integration to both `guru_app/pubspec.yaml` and `trainer_app/pubspec.yaml`.
- **Output snippet": Successfully wrote content to `guru_app/pubspec.yaml` and `trainer_app/pubspec.yaml`.

## Entry 3: Running flutter pub get for Dependencies
- **Prompt #": Internal decision to fetch dependencies after updating `pubspec.yaml` files.
- **Tool": Gemini CLI Agent
- **Intent": Execute `flutter pub get` in both `guru_app/` and `trainer_app/` directories to download and resolve specified package dependencies.
- **Output snippet": `flutter pub get` executed successfully for both `guru_app` and `trainer_app`, downloading packages including `flutter_riverpod` and `hmssdk_flutter`.

## Entry 4: Creating Initial main.dart Files
- **Prompt #": Internal decision to create minimal entry points for both applications.
- **Tool": Gemini CLI Agent
- **Intent": Create basic `main.dart` files in `guru_app/lib/` and `trainer_app/lib/` to allow each application to run as a minimal Flutter app, displaying a simple "Welcome" message.
- **Output snippet": Successfully created `guru_app/lib/main.dart` and `trainer_app/lib/main.dart`.

## Entry 5: Creating `shared/pubspec.yaml`
- **Prompt #": Internal decision to create `shared/pubspec.yaml` for shared package dependencies.
- **Tool": Gemini CLI Agent
- **Intent": Define `pubspec.yaml` for the `shared` package, including `json_annotation`, `json_serializable`, `build_runner`, and `lints` for model generation.
- **Output snippet": Successfully created `shared/pubspec.yaml`.

## Entry 6: Running `dart pub get` for `shared` package
- **Prompt #": Internal decision to fetch dependencies for the `shared` package.
- **Tool": Gemini CLI Agent
- **Intent": Execute `dart pub get` in the `shared` directory to download and resolve package dependencies for the shared components.
- **Output snippet": `dart pub get` executed successfully for the `shared` package.

## Entry 7: Creating `shared/lib` and restructuring `models`
- **Prompt #": Internal decision to restructure `shared` package by creating `lib/` and moving `models/` into it due to `build_runner` failure.
- **Tool": Gemini CLI Agent
- **Intent": Correct the Dart package structure for `shared` by creating a `lib` directory and moving the `models` directory into `lib` to ensure proper package recognition and build process.
- **Output snippet": Successfully created `shared/lib` and moved `shared/models` to `shared/lib/models`.

## Entry 8: Defining Data Models and Generating `.g.dart` files
- **Prompt #": Internal decision to define data models as per PDF and generate their serialization files.
- **Tool": Gemini CLI Agent
- **Intent": Create Dart classes for `User`, `Message`, `CallRequest`, `SessionLog`, and `RoomMeta` in `shared/lib/models` using `json_annotation` and then run `build_runner` to generate their respective `*.g.dart` files for JSON serialization/deserialization.
- **Output snippet": Successfully created model files (`user.dart`, `message.dart`, `call_request.dart`, `session_log.dart`, `room_meta.dart`) and `build_runner` generated all `*.g.dart` files.

## Entry 9: Defining `AuthService` Interface
- **Prompt #": Internal decision to define `AuthService` for authentication.
- **Tool": Gemini CLI Agent
- **Intent": Create an abstract `AuthService` interface in `shared/lib/services` to define the contract for authentication operations (login, logout, current user stream).
- **Output snippet": Successfully created `shared/lib/services/auth_service.dart`.

## Entry 10: Implementing `MockAuthService`
- **Prompt #": Internal decision to create a mock implementation for `AuthService`.
- **Tool": Gemini CLI Agent
- **Intent": Implement `MockAuthService` in `shared/lib/services` to provide a mock authentication mechanism, including pre-seeded "DK" (member) and "Aarav" (trainer) users, and simulate login/logout functionality.
- **Output snippet": Successfully created `shared/lib/services/mock_auth_service.dart`.

## Entry 11: Defining Riverpod `AuthService` Provider
- **Prompt #": Internal decision to create a Riverpod provider for `AuthService`.
- **Tool": Gemini CLI Agent
- **Intent": Create `authServiceProvider` in `shared/lib/services/service_providers.dart` to make the `MockAuthService` instance available to the application widgets via Riverpod.
- **Output snippet": Successfully created `shared/lib/services/service_providers.dart`.

## Entry 12: Integrating Auth into Guru App `main.dart`
- **Prompt #": Internal decision to integrate authentication into `guru_app`.
- **Tool": Gemini CLI Agent
- **Intent": Refactor `guru_app/lib/main.dart` to use `ProviderScope`, convert `GuruApp` to a `ConsumerWidget`, and implement a conditional UI that displays a login screen or a home screen based on the `AuthService.currentUser` stream, including a basic `LoginScreen`.
- **Output snippet": Successfully modified `guru_app/lib/main.dart`.

## Entry 13: Integrating Auth into Trainer App `main.dart`
- **Prompt #": Internal decision to integrate authentication into `trainer_app`.
- **Tool": Gemini CLI Agent
- **Intent": Refactor `trainer_app/lib/main.dart` to use `ProviderScope`, convert `TrainerApp` to a `ConsumerWidget`, and implement a conditional UI that displays a login screen or a home screen based on the `AuthService.currentUser` stream, including a basic `LoginScreen` pre-filled for the trainer persona.
- **Output snippet": Successfully modified `trainer_app/lib/main.dart`.

## Entry 14: Adding Hive Dependencies to `shared/pubspec.yaml`
- **Prompt #": Internal decision to add Hive for persistent storage.
- **Tool": Gemini CLI Agent
- **Intent": Add `hive` and `hive_flutter` as dependencies and `hive_generator` as a dev dependency to `shared/pubspec.yaml` to enable local persistent storage for authentication.
- **Output snippet": Successfully updated `shared/pubspec.yaml`.

## Entry 15: Running `dart pub get` for `shared` (Hive)
- **Prompt #": Internal decision to fetch new Hive dependencies.
- **Tool": Gemini CLI Agent
- **Intent": Execute `dart pub get` in the `shared` directory to download and resolve the newly added Hive package dependencies.
- **Output snippet": `dart pub get` executed successfully for the `shared` package, fetching Hive dependencies.

## Entry 16: Implementing Persistent Login in `MockAuthService`
- **Prompt #": Internal decision to use Hive in `MockAuthService`.
- **Tool": Gemini CLI Agent
- **Intent": Modify `MockAuthService` to use Hive for persisting the logged-in user's ID, enabling "remembered login" functionality across app restarts. This includes storing the ID on login, clearing it on logout, and attempting auto-login on service initialization.
- **Output snippet": Successfully modified `shared/lib/services/mock_auth_service.dart`.

## Entry 17: Initializing Hive in Guru App `main.dart`
- **Prompt #": Internal decision to initialize Hive in `guru_app`.
- **Tool": Gemini CLI Agent
- **Intent": Modify `guru_app/lib/main.dart` to be `async`, call `WidgetsFlutterBinding.ensureInitialized()`, and `await Hive.initFlutter()` to correctly initialize the Hive database before `runApp()`.
- **Output snippet": Successfully modified `guru_app/lib/main.dart`.

## Entry 18: Initializing Hive in Trainer App `main.dart`
- **Prompt #": Internal decision to initialize Hive in `trainer_app`.
- **Tool": Gemini CLI Agent
- **Intent": Modify `trainer_app/lib/main.dart` to be `async`, call `WidgetsFlutterBinding.ensureInitialized()`, and `await Hive.initFlutter()` to correctly initialize the Hive database before `runApp()`.
- **Output snippet": Successfully modified `trainer_app/lib/main.dart`.

## Entry 19: Implementing First-Run Logic in `MockAuthService`
- **Prompt #": Internal decision to manage "first run" state for onboarding.
- **Tool": Gemini CLI Agent
- **Intent": Modify `MockAuthService` to include an `_isFirstRun` flag, a `_isFirstRunKey` for Hive, and methods (`isFirstRun` getter, `completeOnboarding`) to track and update the app's first-run status persistently using Hive. This enables the Guru App to detect when to show onboarding.
- **Output snippet": Successfully modified `shared/lib/services/mock_auth_service.dart`.

## Entry 20: Creating Guru App `screens` Directory
- **Prompt #": Internal decision to create a `screens` directory for Guru App UI.
- **Tool": Gemini CLI Agent
- **Intent": Create `guru_app/lib/screens` directory to organize UI-related files for the Guru application.
- **Output snippet": Successfully created `guru_app/lib/screens` directory.

## Entry 21: Implementing Guru App `OnboardingScreen`
- **Prompt #": Internal decision to implement the Guru App's onboarding UI.
- **Tool": Gemini CLI Agent
- **Intent": Create `guru_app/lib/screens/onboarding_screen.dart` with a 2-slide `PageView` onboarding flow, including navigation to the profile creation screen.
- **Output snippet": Successfully created `guru_app/lib/screens/onboarding_screen.dart`.

## Entry 22: Implementing Guru App `CreateProfileScreen`
- **Prompt #": Internal decision to implement the Guru App's profile creation UI.
- **Tool": Gemini CLI Agent
- **Intent": Create `guru_app/lib/screens/create_profile_screen.dart` to allow the user to create the "DK" profile (name prefilled), auto-assign the trainer, and mark onboarding as complete upon successful setup and login.
- **Output snippet": Successfully created `guru_app/lib/screens/create_profile_screen.dart`.

## Entry 23: Integrating Onboarding into Guru App `main.dart`
- **Prompt #": Internal decision to integrate the onboarding flow into Guru App's main entry point.
- **Tool": Gemini CLI Agent
- **Intent": Modify `guru_app/lib/main.dart` to conditionally display the `OnboardingScreen` if `authService.isFirstRun` is true, otherwise proceed to the normal authentication/home flow.
- **Output snippet": Successfully modified `guru_app/lib/main.dart`.

## Entry 24: Creating Guru App Home Screen
- **Prompt #": Internal decision to implement the Guru App's home screen.
- **Tool": Gemini CLI Agent
- **Intent": Create `guru_app/lib/screens/guru_home_screen.dart` with a placeholder UI featuring a logout button and three navigation cards as specified in the assessment.
- **Output snippet": Successfully created `guru_app/lib/screens/guru_home_screen.dart`.

## Entry 25: Integrating Guru App Home Screen into `main.dart`
- **Prompt #": Internal decision to integrate Guru App home screen into `main.dart`.
- **Tool": Gemini CLI Agent
- **Intent": Modify `guru_app/lib/main.dart` to display `GuruHomeScreen` when a user is successfully logged in, replacing the previous placeholder content.
- **Output snippet": Successfully modified `guru_app/lib/main.dart`.

## Entry 26: Adding Guru App Home Screen Import to `main.dart`
- **Prompt #": Internal decision to add the necessary import for `GuruHomeScreen`.
- **Tool": Gemini CLI Agent
- **Intent": Add the import statement for `GuruHomeScreen` in `guru_app/lib/main.dart` to resolve compilation errors.
- **Output snippet": Successfully modified `guru_app/lib/main.dart`.

## Entry 27: Creating Trainer App `screens` Directory
- **Prompt #": Internal decision to create a `screens` directory for Trainer App UI.
- **Tool": Gemini CLI Agent
- **Intent": Create `trainer_app/lib/screens` directory to organize UI-related files for the Trainer application.
- **Output snippet": Successfully created `trainer_app/lib/screens` directory.

## Entry 28: Creating Trainer App Home Screen
- **Prompt #": Internal decision to implement the Trainer App's home screen.
- **Tool": Gemini CLI Agent
- **Intent": Create `trainer_app/lib/screens/trainer_home_screen.dart` with a placeholder UI featuring a logout button and four navigation tiles as specified in the assessment.
- **Output snippet": Successfully created `trainer_app/lib/screens/trainer_home_screen.dart`.

## Entry 29: Integrating Trainer App Home Screen into `main.dart`
- **Prompt #": Internal decision to integrate Trainer App home screen into `main.dart`.
- **Tool": Gemini CLI Agent
- **Intent": Modify `trainer_app/lib/main.dart` to display `TrainerHomeScreen` when a user is successfully logged in, replacing the previous placeholder content.
- **Output snippet": Successfully modified `trainer_app/lib/main.dart`.

## Entry 30: Adding Trainer App Home Screen Import to `main.dart`
- **Prompt #": Internal decision to add the necessary import for `TrainerHomeScreen`.
- **Tool": Gemini CLI Agent
- **Intent": Add the import statement for `TrainerHomeScreen` in `trainer_app/lib/main.dart` to resolve compilation errors.
- **Output snippet": Successfully modified `trainer_app/lib/main.dart`.

## Entry 31: Defining `ChatService` Interface
- **Prompt #": Internal decision to define `ChatService` for chat functionality.
- **Tool": Gemini CLI Agent
- **Intent": Create an abstract `ChatService` interface in `shared/lib/services` to define the contract for chat operations (sending messages, getting message streams, typing status, marking as read, getting conversations).
- **Output snippet": Successfully created `shared/lib/services/chat_service.dart`.

## Entry 32: Implementing `MockChatService`
- **Prompt #": Internal decision to create a mock implementation for `ChatService`.
- **Tool": Gemini CLI Agent
- **Intent": Implement `MockChatService` in `shared/lib/services` to provide a mock chat mechanism, including in-memory message storage, stream-based real-time updates, message status management, and simulated typing and responses. It also includes seeding dummy messages for testing.
- **Output snippet": Successfully created `shared/lib/services/mock_chat_service.dart`.

## Entry 33: Renaming and Consolidating Service Providers
- **Prompt #": Internal decision to consolidate service providers and rename the file.
- **Tool": Gemini CLI Agent
- **Intent": Rename `auth_service_provider.dart` to `service_providers.dart`, and add a new `chatServiceProvider` for `ChatService`, making it available via Riverpod alongside the `authServiceProvider`.
- **Output snippet": Deleted `auth_service_provider.dart` and created `service_providers.dart` with the new content.

## Entry 34: Updating `main.dart` Imports
- **Prompt #": Internal decision to update imports after renaming the service provider file.
- **Tool": Gemini CLI Agent
- **Intent": Update the import statements in both `guru_app/lib/main.dart` and `trainer_app/lib/main.dart` to point to the new `service_providers.dart` file.
- **Output snippet": Successfully modified `guru_app/lib/main.dart` and `trainer_app/lib/main.dart`.

## Entry 35: Defining `currentUserStreamProvider`
- **Prompt #": Internal decision to create a dedicated StreamProvider for current user.
- **Tool": Gemini CLI Agent
- **Intent": Add `currentUserStreamProvider` to `shared/lib/services/service_providers.dart` to provide a more idiomatic Riverpod way to consume the current user's authentication state stream.
- **Output snippet": Successfully modified `shared/lib/services/service_providers.dart`.

## Entry 36: Refactoring `ChatListScreen` to use `currentUserStreamProvider`
- **Prompt #": Internal decision to fix and refactor `ChatListScreen`.
- **Tool": Gemini CLI Agent
- **Intent": Refactor `guru_app/lib/screens/chat_list_screen.dart` to remove redundant code and utilize `ref.watch(currentUserStreamProvider).when()` for a cleaner and more efficient handling of the current user's state.
- **Output snippet": Successfully modified `guru_app/lib/screens/chat_list_screen.dart`.

## Entry 37: Refactoring Guru App `main.dart` to use `currentUserStreamProvider`
- **Prompt #": Internal decision to refactor Guru App `main.dart`.
- **Tool": Gemini CLI Agent
- **Intent": Update `guru_app/lib/main.dart` to use `ref.watch(currentUserStreamProvider).when()` for handling the authenticated user's state, making the main app's authentication logic more consistent with Riverpod best practices.
- **Output snippet": Successfully modified `guru_app/lib/main.dart`.

## Entry 38: Refactoring Trainer App `main.dart` to use `currentUserStreamProvider`
- **Prompt #": Internal decision to refactor Trainer App `main.dart`.
- **Tool": Gemini CLI Agent
- **Intent": Update `trainer_app/lib/main.dart` to use `ref.watch(currentUserStreamProvider).when()` for handling the authenticated user's state, making the main app's authentication logic more consistent with Riverpod best practices.
- **Output snippet": Successfully modified `trainer_app/lib/main.dart`.

## Entry 39: Integrating `ChatListScreen` into `GuruHomeScreen`
- **Prompt #": Internal decision to integrate `ChatListScreen` into `GuruHomeScreen`.
- **Tool": Gemini CLI Agent
- **Intent": Modify `guru_app/lib/screens/guru_home_screen.dart` to navigate to `ChatListScreen` when the "Chat with Trainer" card is tapped, and add the necessary import statement.
- **Output snippet": Successfully modified `guru_app/lib/screens/guru_home_screen.dart`.

## Entry 40: Creating `ConversationScreen`
- **Prompt #": Internal decision to implement the chat conversation UI.
- **Tool": Gemini CLI Agent
- **Intent": Create `guru_app/lib/screens/conversation_screen.dart` to display chat bubbles, typing indicators, message status, quick replies, and handle message input. This screen consumes `ChatService` and `AuthService` via Riverpod.
- **Output snippet": Successfully created `guru_app/lib/screens/conversation_screen.dart`.

## Entry 41: Integrating `ConversationScreen` into `ChatListScreen`
- **Prompt #": Internal decision to integrate the `ConversationScreen` into the `ChatListScreen`.
- **Tool": Gemini CLI Agent
- **Intent": Modify `guru_app/lib/screens/chat_list_screen.dart` to navigate to `ConversationScreen` when a chat list item is tapped, passing the relevant `User` object, and add the necessary import.
- **Output snippet": Successfully modified `guru_app/lib/screens/chat_list_screen.dart`.