/// FILE: lib/services/auth_service.dart
class AuthService {
  static String? _registeredEmail;
  static String? _registeredPassword;

  static bool _isLoggedIn = false;
  static bool _onboardingCompleted = false;

  static String? get registeredEmail => _registeredEmail;
  static bool get isLoggedIn => _isLoggedIn;
  static bool get isRegistered => _registeredEmail != null;
  static bool get onboardingCompleted => _onboardingCompleted;

  static void register(String email, String password) {
    _registeredEmail = email.trim();
    _registeredPassword = password;
  }

  static void markLoggedIn() {
    _isLoggedIn = true;
  }

  static bool login(String email, String password) {
    if (_registeredEmail == null || _registeredPassword == null) {
      return false;
    }
    final ok = _registeredEmail == email.trim() &&
        _registeredPassword == password;
    _isLoggedIn = ok;
    return ok;
  }

  static void logout() {
    _isLoggedIn = false;
  }

  static void completeOnboarding() {
    _onboardingCompleted = true;
  }
}
