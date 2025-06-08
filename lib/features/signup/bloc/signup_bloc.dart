import 'package:afriqueen/features/login/bloc/login_state.dart';
import 'package:afriqueen/features/signup/bloc/signup_event.dart';
import 'package:afriqueen/features/signup/bloc/signup_state.dart';
import 'package:afriqueen/features/signup/models/signup_model.dart';
import 'package:afriqueen/features/signup/repository/signup_repository.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupRepository _repository;
  bool _isBoxChecked = false;
  bool _isPasswordHidden = true;
  final AppGetStorage _appGetStorage = AppGetStorage();
  SignUpModel _signUpModel = SignUpModel(email: '', password: '');

  SignupBloc({required SignupRepository signupRepository})
    : _repository = signupRepository,
      super(SignupInitial()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<Submit>(_onSubmit);
    on<PasswordVisibility>(_onPasswordVisibility);
    on<CheckedBox>(_onCheckedBox);
    on<GoogleSignInButtonClicked>(_onGoogleSignInButtonClicked);
  }
  //------------------------- on Clicking Signup button it  will run-----------------------------
  Future<void> _onSubmit(Submit event, Emitter<SignupState> emit) async {
    emit(Loading.fromState(state));
    UserCredential? userCredential = await _repository.signupWithEmail(
      _signUpModel,
    );

    if (userCredential != null) {
      _appGetStorage.setPageNumber(1);
      emit(Success.fromState(state));
    } else {
      emit(SignUpfail.fromState(state, error: _repository.errorMessge!.tr));
    }
  }

  //------------------------- on Clicking Google Sign In button it will run-----------------------------
  Future<void> _onGoogleSignInButtonClicked(
    GoogleSignInButtonClicked event,
    Emitter<SignupState> emit,
  ) async {
    emit(Loading.fromState(state));
    UserCredential? userCredential = await _repository.signupWithGoogle();

    if (userCredential != null) {
      if (_repository.isExistingUser) {
        emit(GoogleSignInExistingUser.fromState(state));
      } else {
        _appGetStorage.setPageNumber(2);
        emit(GoogleSignInSuccess.fromState(state));
      }
    } else {
      emit(SignUpfail.fromState(state, error: _repository.errorMessge!.tr));
    }
  }

  //------------------------User input for email-------------------------------
  void _onEmailChanged(EmailChanged event, Emitter<SignupState> emit) {
    _signUpModel = _signUpModel.copyWith(email: event.email);
  }

  // ---------------------------- password from user---------------------
  void _onPasswordChanged(PasswordChanged event, Emitter<SignupState> emit) {
    _signUpModel = _signUpModel.copyWith(password: event.password);
  }

  //-----------------------Toggle to show passsword-------------------------
  void _onPasswordVisibility(
    PasswordVisibility event,
    Emitter<SignupState> emit,
  ) {
    _isPasswordHidden = !_isPasswordHidden;
    emit(state.copyWith(isPasswordHidden: _isPasswordHidden));
  }

  //-------------------------------------- privacy and policy checked box----------------------------------
  void _onCheckedBox(CheckedBox event, Emitter<SignupState> emit) {
    _isBoxChecked = !_isBoxChecked;
    emit(state.copyWith(isChecked: _isBoxChecked));
  }
}
