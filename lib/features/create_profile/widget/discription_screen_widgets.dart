import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/utils/validators.dart';
import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_event.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

//--------------- Discription screen componets---------------------

//----------------Text Regarding name discription--------------------------
class DiscriptionBody extends StatelessWidget {
  const DiscriptionBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.descriptionBody.name.tr,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

//----------------Text Regarding name Title--------------------------
class DiscriptionTitle extends StatelessWidget {
  const DiscriptionTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.descriptionTitle.name.tr,

      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

//------------------------Textfield for user input for discription------------------------
class TextFieldForDiscription extends StatefulWidget {
  const TextFieldForDiscription({super.key});

  @override
  State<TextFieldForDiscription> createState() =>
      _TextFieldForDiscriptionState();
}

class _TextFieldForDiscriptionState extends State<TextFieldForDiscription> {
  final discriptionController = TextEditingController();

  @override
  void dispose() {
    discriptionController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: TextFormField(
        scrollPadding: EdgeInsets.zero,
        expands: true, // Fills available vertical space
        maxLines: null, // Must be null when expands is true
        minLines: null,
        keyboardType: TextInputType.text,
        onChanged:
            (value) => context.read<CreateProfileBloc>().add(
              DiscriptionChanged(discription: value.trim()),
            ),
        cursorColor: AppColors.black,
        style: TextStyle(fontSize: 16),
        validator: AppValidator.validateDiscription,
        controller: discriptionController,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
          errorMaxLines: 3,
          labelText: EnumLocale.descriptionLabelText.name.tr,
          labelStyle: Theme.of(context).textTheme.bodySmall,
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(width: 2.w, color: AppColors.red),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(width: 1.w, color: AppColors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(width: 1.w, color: AppColors.blue),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(width: 2.w, color: AppColors.red),
          ),

          border: InputBorder.none,
        ),
      ),
    );
  }
}

//------------------------Next Button ----------------------------------

class DiscriptionNextButton extends StatelessWidget {
  DiscriptionNextButton({super.key, required this.formKey});
  final GlobalKey<FormState> formKey;
  final AppGetStorage app = AppGetStorage();

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          app.setPageNumber(9);
          Get.offAllNamed(AppRoutes.upload);
        }
      },
      buttonText: EnumLocale.next.name.tr,
    );
  }
}
