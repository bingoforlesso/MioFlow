abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String phone;
  final String password;

  LoginEvent({
    required this.phone,
    required this.password,
  });
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String password;
  final String email;

  RegisterEvent({
    required this.username,
    required this.password,
    required this.email,
  });
}

class LogoutEvent extends AuthEvent {}
