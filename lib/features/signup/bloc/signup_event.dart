import 'package:equatable/equatable.dart' show Equatable;
//-----------------------------Event------------------------
sealed class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

final class EmailChanged extends SignupEvent {
  final String email;
  const EmailChanged({required this.email});
}

final class PasswordChanged extends SignupEvent {
  final String password;
  const PasswordChanged({required this.password});
}

final class Submit extends SignupEvent {}

final class PasswordVisibility extends SignupEvent {}

final class CheckedBox extends SignupEvent {}

final class GoogleSignInButtonClicked extends SignupEvent {}
