import 'package:afriqueen/features/login/bloc/login_event.dart';
import 'package:afriqueen/features/login/bloc/login_state.dart';
import 'package:afriqueen/features/login/models/login_model.dart';
import 'package:afriqueen/features/login/repository/login_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository _repository;
  bool _isPasswordHidden = true;
  LoginModel _loginModel = LoginModel(email: '', password: '');

  LoginBloc({
    LoginRepository? repository,
  }) : _repository = repository ?? LoginRepository(),
    super(LoginInitial()) {
    //---------------------password visibility-----------------------------
    on<LoginPasswordVisibility>((
        LoginPasswordVisibility event,
        Emitter<LoginState> emit,
        ) {
      _isPasswordHidden = !_isPasswordHidden;
      emit(state.copyWith(isLoginPasswordVisible: _isPasswordHidden));
    });
    //------------------------track user input for email--------------------------
    on<LoginEmailChanged>((event, emit) {
      _loginModel = _loginModel.copyWith(email: event.email);
    });
    //------------------------track user input for password--------------------------
    on<LoginPasswordChanged>((event, emit) {
      _loginModel = _loginModel.copyWith(password: event.password);
    });

    //------------------------User pressed LoginButton--------------------------
    on<LoginSubmit>((event, emit) async {
      try {
        emit(LoginLoading.fromState(state));
        UserCredential? userCredential = await _repository.loginWithEmail(
          _loginModel,
        );

        if (userCredential != null && userCredential.user != null) {
          if (_repository.isExistingUser) {
            emit(LoginSuccess.fromState(state));
          } else {
            emit(GoogleLoginNewUser.fromState(state));
          }
        } else {
          emit(LoginError.fromState(state, error: _repository.error ?? 'Authentication failed'));
        }
      } catch (e) {
        debugPrint('Login error: $e');
        emit(LoginError.fromState(state, error: _repository.error ?? 'Something went wrong'));
      }
    });
    // -------------------google signing--------------------------------------
    on<GoogleSignInButtonClicked>((event, emit) async {
      emit(LoginLoading.fromState(state));
      UserCredential? userCredential = await _repository.loginWithGoogle();

      if (userCredential != null) {
        if (_repository.isExistingUser) {
          emit(LoginSuccess.fromState(state));
        } else {
          emit(GoogleLoginNewUser.fromState(state));
        }
      } else {
        emit(
          GoogleLoginError.fromState(state, error: _repository.error!.tr),
        );
      }
    });
  }
}
