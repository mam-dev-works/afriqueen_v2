import 'package:afriqueen/features/login/bloc/login_event.dart';
import 'package:afriqueen/features/login/bloc/login_state.dart';
import 'package:afriqueen/features/login/models/login_model.dart';
import 'package:afriqueen/features/login/repository/login_repository.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository _loginRepository;
  bool _isPasswordHidden = true;
  final _app = AppGetStorage();
  LoginModel _loginModel = LoginModel(email: '', password: '');

  LoginBloc({required LoginRepository loginrepository})
      : _loginRepository = loginrepository,
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
      emit(LoginLoading.fromState(state));
      UserCredential? userCredential = await _loginRepository.loginWithEmail(
        _loginModel,
      );

      if (userCredential != null) {
        if (_loginRepository.isExistingUser) {
          emit(LoginSuccess.fromState(state));
        } else {
          emit(GoogleLoginNewUser.fromState(state));
        }
      } else {
        emit(LoginError.fromState(state, error: _loginRepository.error!.tr));
      }
    });
    // -------------------google signing--------------------------------------
    on<GoogleSignInButtonClicked>((event, emit) async {
      emit(LoginLoading.fromState(state));
      UserCredential? userCredential = await _loginRepository.loginWithGoogle();

      if (userCredential != null) {
        if (_loginRepository.isExistingUser) {
          emit(LoginSuccess.fromState(state));
        } else {
          emit(GoogleLoginNewUser.fromState(state));
        }
      } else {
        emit(
          GoogleLoginError.fromState(state, error: _loginRepository.error!.tr),
        );
      }
    });
  }
}
