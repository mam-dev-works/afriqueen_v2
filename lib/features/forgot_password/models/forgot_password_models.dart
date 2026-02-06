import 'package:equatable/equatable.dart';

//----------------------------------------- Model for forgot password----------------------------------
class ForgotPasswordModel extends Equatable {
  final String email;
  const ForgotPasswordModel({required this.email});

  ForgotPasswordModel copyWith({String? email}) =>
      ForgotPasswordModel(email: email ?? this.email);

  @override
  List<Object?> get props => [email];
}
