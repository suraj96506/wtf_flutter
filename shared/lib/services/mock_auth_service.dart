import 'dart:async';
import 'package:hive/hive.dart';
import 'package:shared/models/user.dart';
import 'package:shared/services/auth_service.dart';

// Key for storing the logged-in user ID in Hive
const _loggedInUserIdKey = 'loggedInUserId';
// Key for storing the first run status
const _isFirstRunKey = 'isFirstRun';

class MockAuthService implements AuthService {
  late final Future<void> ready;

  // Pre-seeded users as per assessment
  final _dkMember = User(
    id: 'dk_member_id',
    role: 'member',
    name: 'DK',
    email: 'dk@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=1', // Placeholder avatar
    assignedTrainerId: 'aarav_trainer_id',
  );

  final _aaravTrainer = User(
    id: 'aarav_trainer_id',
    role: 'trainer',
    name: 'Aarav (Lead Trainer)',
    email: 'aarav@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=2', // Placeholder avatar
  );

  User? _currentUser;
  late final StreamController<User?> _currentUserController;
  late Box<String> _authBox; // Hive box for authentication data
  bool _isFirstRun = true; // Default to true

  MockAuthService() {
    _currentUserController = StreamController<User?>.broadcast(
      onListen: () {
        // Always emit the latest value to new listeners to avoid indefinite spinners.
        _currentUserController.add(_currentUser);
      },
    );
    // Emit an initial null so listeners exit the loading state immediately.
    _currentUserController.add(null);
    ready = _initHiveAndAuth()
        .timeout(const Duration(seconds: 2), onTimeout: () async {
      // Fallback: continue without persistence if Hive is slow/unavailable.
      _isFirstRun = false;
      _currentUserController.add(_currentUser);
    });
  }

  Future<void> _initHiveAndAuth() async {
    try {
      _authBox = await Hive.openBox<String>('authBox');
      _isFirstRun = _authBox.get(_isFirstRunKey, defaultValue: 'true') == 'true';

      // Attempt to auto-login if a user ID is stored
      final storedUserId = _authBox.get(_loggedInUserIdKey);
      if (storedUserId != null) {
        if (storedUserId == _dkMember.id) {
          _currentUser = _dkMember;
        } else if (storedUserId == _aaravTrainer.id) {
          _currentUser = _aaravTrainer;
        }
      }
      _currentUserController.add(_currentUser);
    } catch (_) {
      // Fallback: disable first run and continue without persistence.
      _isFirstRun = false;
      _currentUserController.add(_currentUser);
    }
  }

  // Helper to expose the current user synchronously to other mocks.
  User? get currentUserSync => _currentUser;

  // New method to check if it's the first run
  @override
  bool get isFirstRun => _isFirstRun;

  // New method to mark onboarding as complete
  @override
  Future<void> completeOnboarding() async {
    _isFirstRun = false;
    await _authBox.put(_isFirstRunKey, 'false'); // Store as string for consistency with _loggedInUserIdKey
  }

  @override
  Future<User?> login(String email, String password) async {
    // Simple mock login logic
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    User? authenticatedUser;
    if (email == _dkMember.email && password == 'password') {
      authenticatedUser = _dkMember;
    } else if (email == _aaravTrainer.email && password == 'password') {
      authenticatedUser = _aaravTrainer;
    } else {
      authenticatedUser = null;
    }

    _currentUser = authenticatedUser;
    _currentUserController.add(_currentUser);

    // Persist user ID if login is successful
    if (_currentUser != null) {
      await _authBox.put(_loggedInUserIdKey, _currentUser!.id);
      // Logging in counts as completed onboarding.
      _isFirstRun = false;
      await _authBox.put(_isFirstRunKey, 'false');
    } else {
      await _authBox.delete(_loggedInUserIdKey);
    }
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    _currentUser = null;
    _currentUserController.add(null);
    await _authBox.delete(_loggedInUserIdKey); // Clear persisted user ID
  }

  @override
  Stream<User?> get currentUser => _currentUserController.stream;

  void dispose() {
    _currentUserController.close();
  }
}
