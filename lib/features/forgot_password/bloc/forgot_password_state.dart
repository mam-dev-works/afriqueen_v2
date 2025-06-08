

import 'package:equatable/equatable.dart';
//-------------------------------State--------------------------------------
sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
  
  @override
  List<Object> get props => [];
}

final class ForgotPasswordInitial extends ForgotPasswordState {}

final class ForgotPasswordSuccess extends ForgotPasswordState {}


