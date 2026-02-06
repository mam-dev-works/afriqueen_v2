import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/report_profile/repository/report_profile_repository.dart';
import 'package:afriqueen/features/report_profile/widgets/report_profile_user_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ReportProfileSubmitScreen extends StatefulWidget {
  const ReportProfileSubmitScreen({
    super.key,
    required this.user,
    required this.selectedReason,
  });

  final HomeModel user;
  final EnumLocale selectedReason;

  @override
  State<ReportProfileSubmitScreen> createState() => _ReportProfileSubmitScreenState();
}

class _ReportProfileSubmitScreenState extends State<ReportProfileSubmitScreen> {
  static const int _maxCharacters = 1000;
  final TextEditingController _controller = TextEditingController();
  final ReportProfileRepository _repository = ReportProfileRepository();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _remainingChars {
    final remaining = _maxCharacters - _controller.text.length;
    return remaining.clamp(0, _maxCharacters);
  }

  Future<void> _handleSubmit({required bool alsoBlock}) async {
    final text = _controller.text.trim();
    if (text.length < 20) {
      snackBarMessage(
        context,
        EnumLocale.reportDescriptionMinChars.name.tr,
        Theme.of(context),
      );
      return;
    }

    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await _repository.submitProfileReport(
        reportedUserId: widget.user.id,
        categoryKey: widget.selectedReason.name,
        description: text,
        blockUser: alsoBlock,
      );

      if (!mounted) return;
      snackBarMessage(
        context,
        EnumLocale.userReportedSuccess.name.tr,
        Theme.of(context),
      );
      Get.close(2);
    } on ReportAlreadySubmittedException {
      snackBarMessage(
        context,
        EnumLocale.alreadyReportedUser.name.tr,
        Theme.of(context),
      );
    } catch (e) {
      snackBarMessage(
        context,
        EnumLocale.errorWithMessage.name.trParams({'msg': e.toString()}),
        Theme.of(context),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(EnumLocale.reportProfileTitle.name.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReportProfileUserHeader(user: widget.user),
                    SizedBox(height: 16.h),
                    Text(
                      EnumLocale.reportDescriptionTitle.name.tr,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 16.h),
                    _buildReasonChip(context),
                    SizedBox(height: 12.h),
                    _buildInputField(context),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        EnumLocale.reportDescriptionMinChars.name.tr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      EnumLocale.reportDescriptionCharsRemaining.name
                          .trParams({'count': _remainingChars.toString()}),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    _buildActionsRow(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReasonChip(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppColors.lightOrange.withOpacity(0.2),
      ),
      child: Text(
        widget.selectedReason.name.tr,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TextField(
          controller: _controller,
          maxLength: _maxCharacters,
          maxLines: null,
          expands: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: EnumLocale.reportDescriptionPlaceholder.name.tr,
            counterText: '',
          ),
        ),
      ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => _handleSubmit(alsoBlock: false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primaryColor),
              foregroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: 18.r,
                    width: 18.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(EnumLocale.reportSubmitButton.name.tr),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => _handleSubmit(alsoBlock: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: 18.r,
                    width: 18.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    EnumLocale.reportSubmitBlockButton.name.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}

