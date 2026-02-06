import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/features/event/model/event_model.dart';
import 'package:afriqueen/features/event/repository/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  
  // Date controllers for separate day/month/year fields
  final TextEditingController _dayCtrl = TextEditingController();
  final TextEditingController _monthCtrl = TextEditingController();
  final TextEditingController _yearCtrl = TextEditingController();
  
  String _eventWith = ''; // Will be initialized with localized string
  String _eventFor = ''; // Will be initialized with localized string
  String _costCovered = ''; // Will be initialized with localized string
  bool _saving = false;
  String? _imageUrl;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize date fields with current date
    final now = DateTime.now();
    _dayCtrl.text = now.day.toString().padLeft(2, '0');
    _monthCtrl.text = now.month.toString().padLeft(2, '0');
    _yearCtrl.text = now.year.toString();
    
    // Initialize localized strings
    _eventWith = EnumLocale.createEventWithOption1.name.tr;
    _eventFor = EnumLocale.createEventForOption1.name.tr;
    _costCovered = EnumLocale.createEventCostOption1.name.tr;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate required fields
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(EnumLocale.createEventValidationTitleRequired.name.tr)),
      );
      return;
    }
    
    if (_locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(EnumLocale.createEventValidationLocationRequired.name.tr)),
      );
      return;
    }
    
    // Validate date fields
    final day = int.tryParse(_dayCtrl.text);
    final month = int.tryParse(_monthCtrl.text);
    final year = int.tryParse(_yearCtrl.text);
    
    if (day == null || month == null || year == null || 
        day < 1 || day > 31 || month < 1 || month > 12 || year < 2024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(EnumLocale.createEventValidationDateRequired.name.tr)),
      );
      return;
    }
    
    setState(() => _saving = true);
    
    try {
      final eventDate = DateTime(year, month, day);
    final model = EventModel(
      id: '',
      title: _titleCtrl.text.trim(),
        date: eventDate,
      location: _locationCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
        status: _eventWith == EnumLocale.createEventWithOption1.name.tr ? EventStatus.DUO : EventStatus.GROUP,
      creatorId: FirebaseAuth.instance.currentUser?.uid ?? '',
      imageUrl: _imageUrl,
        costCovered: _costCovered == EnumLocale.createEventCostOption1.name.tr,
        maxParticipants: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
      
      await EventRepository().createEvent(model);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${EnumLocale.createEventErrorCreate.name.tr} $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      final cloudinary = CloudinaryPublic(AppStrings.cloudName, AppStrings.uploadPreset);
      final res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          picked.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'afriqueen/events',
          publicId: 'event_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      setState(() => _imageUrl = res.secureUrl);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${EnumLocale.createEventErrorImageUpload.name.tr} $e')),
      );
    }
  }

  Widget _buildFormField({
    required String label,
    required Widget child,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        child,
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.red,
            ),
          ),
        ],
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Container(
      height: maxLines != null ? null : 48.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          EnumLocale.createEventTitle.name.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de l'évènement
              _buildFormField(
                label: EnumLocale.createEventTitleLabel.name.tr,
                child: _buildInputField(
                  controller: _titleCtrl,
                  hintText: EnumLocale.createEventTitleHint.name.tr,
                ),
              ),

              // Évènement à faire avec
              _buildFormField(
                label: EnumLocale.createEventWithLabel.name.tr,
                child: _buildDropdown(
                  value: _eventWith,
                  items: [EnumLocale.createEventWithOption1.name.tr, EnumLocale.createEventWithOption2.name.tr],
                  onChanged: (value) => setState(() => _eventWith = value ?? EnumLocale.createEventWithOption1.name.tr),
                ),
              ),

              // Cet évènement s'adresse
              _buildFormField(
                label: EnumLocale.createEventForLabel.name.tr,
                child: _buildDropdown(
                  value: _eventFor,
                  items: [
                    EnumLocale.createEventForOption1.name.tr, 
                    EnumLocale.createEventForOption2.name.tr, 
                    EnumLocale.createEventForOption3.name.tr
                  ],
                  onChanged: (value) => setState(() => _eventFor = value ?? EnumLocale.createEventForOption1.name.tr),
                ),
              ),

              // Date
              _buildFormField(
                label: EnumLocale.createEventDateLabel.name.tr,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _dayCtrl,
                        hintText: EnumLocale.createEventDateDayHint.name.tr,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildInputField(
                        controller: _monthCtrl,
                        hintText: EnumLocale.createEventDateMonthHint.name.tr,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildInputField(
                        controller: _yearCtrl,
                        hintText: EnumLocale.createEventDateYearHint.name.tr,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),

              // Lieu
              _buildFormField(
                label: EnumLocale.createEventLocationLabel.name.tr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    _buildInputField(
                      controller: _locationCtrl,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      EnumLocale.createEventLocationRequired.name.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // Image Upload
            GestureDetector(
              onTap: _saving ? null : _pickAndUploadImage,
                child: Container(
                  height: 120.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey[300]!),
                    image: _imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageUrl == null
                      ? Center(
                          child: Text(
                            EnumLocale.createEventImageHint.name.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(height: 16.h),

              // Description
              _buildFormField(
                label: EnumLocale.createEventDescriptionLabel.name.tr,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: EnumLocale.createEventDescriptionHint.name.tr,
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // Frais de sortie
              _buildFormField(
                label: EnumLocale.createEventCostLabel.name.tr,
                child: _buildDropdown(
                  value: _costCovered,
                  items: [EnumLocale.createEventCostOption1.name.tr, EnumLocale.createEventCostOption2.name.tr],
                  onChanged: (value) => setState(() => _costCovered = value ?? EnumLocale.createEventCostOption1.name.tr),
                ),
              ),

              SizedBox(height: 40.h),

              // Retour Button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        EnumLocale.createEventBack.name.tr,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B6FB2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                child: _saving
                          ? SizedBox(
                              height: 18.h,
                              width: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              EnumLocale.createEventCreate.name.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
              ),
            ),
          ],
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}


