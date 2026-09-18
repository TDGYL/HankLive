import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../utils/hank_auth_manager.dart';

/// HankEditProfilePage: Edit Profilepage
/// feature：modifyavatar、nickname、gender
/// differentiated：light purple+whitecolorhometheme，roundedcardtablesingle，gradientSavebutton
/// reference ZogoLive edit_profile_page.dart featureandData
class HankEditProfilePage extends StatefulWidget {
  const HankEditProfilePage({Key? key}) : super(key: key);

  @override
  State<HankEditProfilePage> createState() => _HankEditProfilePageState();
}

class _HankEditProfilePageState extends State<HankEditProfilePage> {
  /// nicknameinputcontroller
  final TextEditingController _nicknameController = TextEditingController();

  /// useaccountavatarURL（networkaddressorlocalfilepath）
  String? _avatar;

  /// whetherislocalselectedimagefile
  bool _isLocalAvatar = false;

  /// gender（1=male 2=female，null=notSettings）
  int? _sex;

  @override
  void initState() {
    super.initState();
    final user = HankAuthManager().currentUser;
    _nicknameController.text = user?.nickname ?? '';
    _avatar = user?.avatar;
    _sex = user?.sex;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  /// Saveeachpersondata
  /// SubmitafterToasthint"Submitted, pending review"，notrequestAPI
  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Submitted, pending review'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  /// tapmorechangeavatar，fromphaseregisterselectimage
  /// useuseimage_pickerinsertitem，selectafterlocaldisplay，SubmitwhennotrequestupuploadAPI
  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _avatar = pickedFile.path;
          _isLocalAvatar = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image, please retry'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// displaygenderselectpopup
  void _showSexPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildSexOption(sheetContext, 1, 'male', Icons.male),
              Divider(height: 1, color: AppColors.violet100),
              _buildSexOption(sheetContext, 2, 'female', Icons.female),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// buildgenderselectitemrow
  /// [value] gendervalue，[label] displaytext，[icon] icon
  Widget _buildSexOption(
      BuildContext sheetContext, int value, String label, IconData icon) {
    final selected = _sex == value;
    return InkWell(
      onTap: () {
        Navigator.of(sheetContext).pop();
        setState(() {
          _sex = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.violet600 : AppColors.slate500,
                size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    color: AppColors.slate800, fontSize: 14),
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: AppColors.violet600, size: 18),
          ],
        ),
      ),
    );
  }

  /// gendertext
  String get _sexText {
    switch (_sex) {
      case 1:
        return 'male';
      case 2:
        return 'female';
      default:
        return 'notSettings';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.slate800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18,
              color: AppColors.slate600),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // avatararea
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.violet200, AppColors.violet100],
                        ),
                        border: Border.all(
                            color: AppColors.violet300, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (_avatar != null && _avatar!.isNotEmpty)
                          ? _isLocalAvatar
                              ? Image.file(File(_avatar!),
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover)
                              : Image.network(_avatar!,
                                  width: 84, height: 84, fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(
                                      Icons.person, size: 40,
                                      color: AppColors.violet400))
                          : const Icon(Icons.person, size: 40,
                              color: AppColors.violet400),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'tapmorechangeavatar',
                    style: TextStyle(
                        color: AppColors.slate500, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // tablesinglecard
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F8B5CF6),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // nickname
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 64,
                          child: Text('nickname',
                              style: TextStyle(
                                  color: AppColors.slate500, fontSize: 13)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _nicknameController,
                            style: const TextStyle(
                                color: AppColors.slate800, fontSize: 14),
                            maxLength: 20,
                            decoration: const InputDecoration(
                              hintText: 'Please enternickname',
                              hintStyle: TextStyle(
                                  color: AppColors.slate400, fontSize: 13),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: AppColors.violet100),
                  // gender
                  InkWell(
                    onTap: _showSexPicker,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 64,
                            child: Text('gender',
                                style: TextStyle(
                                    color: AppColors.slate500,
                                    fontSize: 13)),
                          ),
                          Expanded(
                            child: Text(_sexText,
                                style: const TextStyle(
                                    color: AppColors.slate800,
                                    fontSize: 14)),
                          ),
                          const Icon(Icons.chevron_right, size: 16,
                              color: AppColors.slate400),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Savebutton
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}