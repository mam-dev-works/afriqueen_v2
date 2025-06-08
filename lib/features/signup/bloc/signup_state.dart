// signup_state.dart

import 'package:equatable/equatable.dart';

///----------------------- Base SignupState class that holds common form fields----------------------
class SignupState extends Equatable {
  final bool isPasswordHidden;
  final bool isChecked;

  const SignupState({required this.isPasswordHidden, required this.isChecked});

  ///------------------ Initial state with empty email/password and default visibility/checkbox-------------------
  factory SignupState.initial() {
    return const SignupState(isPasswordHidden: true, isChecked: false);
  }

  ///---------------- Clone the current state with optional new values--------------------------
  SignupState copyWith({bool? isPasswordHidden, bool? isChecked}) {
    return SignupState(
      isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  List<Object?> get props => [isPasswordHidden, isChecked];
}

///---------------------------State representing the initial form state-------------------------
final class SignupInitial extends SignupState {
  const SignupInitial() : super(isPasswordHidden: true, isChecked: false);
}

///--------------------------- State representing the signup loading state -----------------------
final class Loading extends SignupState {
  Loading.fromState(SignupState state)
    : super(
        isPasswordHidden: state.isPasswordHidden,
        isChecked: state.isChecked,
      );
}

///--------------------------- State representing successful signup ------------------------------
final class Success extends SignupState {
  Success.fromState(SignupState state)
    : super(
        isPasswordHidden: state.isPasswordHidden,
        isChecked: state.isChecked,
      );
}

///--------------------------- State representing successful Google sign-in ------------------------------
final class GoogleSignInSuccess extends SignupState {
  GoogleSignInSuccess.fromState(SignupState state)
    : super(
        isPasswordHidden: state.isPasswordHidden,
        isChecked: state.isChecked,
      );
}

///--------------------------- State representing existing user Google sign-in ------------------------------
final class GoogleSignInExistingUser extends SignupState {
  const GoogleSignInExistingUser({
    super.isPasswordHidden = true,
    super.isChecked = false,
  });

  factory GoogleSignInExistingUser.fromState(SignupState state) {
    return GoogleSignInExistingUser(
      isPasswordHidden: state.isPasswordHidden,
      isChecked: state.isChecked,
    );
  }

  @override
  List<Object?> get props => [isPasswordHidden, isChecked];
}

/// --------------------------- State representing a failed signup attempt with an error message -------------------------
final class SignUpfail extends SignupState {
  final String error;

  SignUpfail.fromState(SignupState state, {required this.error})
    : super(
        isPasswordHidden: state.isPasswordHidden,
        isChecked: state.isChecked,
      );
}
