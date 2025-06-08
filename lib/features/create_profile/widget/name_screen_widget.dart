import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/utils/validators.dart';
import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:afriqueen/common/widgets/common_textfield.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_event.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

// -----------------------------Name screen components-----------------------------------

//----------------Text Regarding name description--------------------------
class NameDescription extends StatelessWidget {
  const NameDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.nameDescription.name.tr,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

//----------------Text Regarding name Title--------------------------
class NameTitle extends StatelessWidget {
  const NameTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.nameTitle.name.tr,

      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

//----------------- User input for pseudo---------
class PseudoTextField extends StatelessWidget {
  PseudoTextField({super.key});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      labelText: EnumLocale.nameHintText.name.tr,
      controller: controller,
      validator: AppValidator.validatePseudo,
      obscureText: false,
      onChanged: (value) => context.read<CreateProfileBloc>().add(
        PseudoChanged(pseudo: value.trim()),
      ),
    );
  }
}

//------------------------Next Button ----------------------------------
class NameNextButton extends StatelessWidget {
  NameNextButton({super.key, required this.formKey});
  final GlobalKey<FormState> formKey;
  final AppGetStorage app = AppGetStorage();

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          app.setPageNumber(3);
          Get.toNamed(AppRoutes.gender);
        }
      },
      buttonText: EnumLocale.next.name.tr,
    );
  }
}
