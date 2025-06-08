import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/repository/create_profile_repository.dart';
import 'package:afriqueen/features/create_profile/screen/name_screen.dart';

class CreateProfileFlow extends StatelessWidget {
  const CreateProfileFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => CreateProfileRepository(),
      child: BlocProvider(
        create: (context) => CreateProfileBloc(
          repository: context.read<CreateProfileRepository>(),
        ),
        child:  NameScreen(),
      ),
    );
  }
}
