import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/hank_auth_manager.dart';

/// HankEditProfilePage: 编辑个人信息页面
/// 功能：修改头像、昵称、性别
/// 差异化：浅紫+白色主题，圆角卡片表单，渐变保存按钮
/// 参照 ZogoLive edit_profile_page.dart 的功能和数据
class HankEditProfilePage extends StatefulWidget {
  const HankEditProfilePage({Key? key}) : super(key: key);

  @override
  State<HankEditProfilePage> createState() => _HankEditProfilePageState();
}

class _HankEditProfilePageState extends State<HankEditProfilePage> {
  /// 昵称输入控制器
  final TextEditingController _nicknameController = TextEditingController();

  /// 用户头像URL
  String? _avatar;

  /// 性别（1=男 2=女，null=未设置）
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

  /// 保存个人资料
  /// 提交后Toast提示"已提交审核"
  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已提交审核'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// 点击更换头像（提示功能暂未开放）
  Future<void> _pickAvatar() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('头像更换功能暂未开放'),
          duration: Duration(seconds: 1)),
    );
  }

  /// 显示性别选择弹窗
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
              _buildSexOption(sheetContext, 1, '男', Icons.male),
              Divider(height: 1, color: AppColors.violet100),
              _buildSexOption(sheetContext, 2, '女', Icons.female),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// 构建性别选项行
  /// [value] 性别值，[label] 显示文案，[icon] 图标
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

  /// 性别文案
  String get _sexText {
    switch (_sex) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return '未设置';
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
          '编辑个人信息',
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
            // 头像区域
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
                          ? Image.network(_avatar!,
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
                    '点击更换头像',
                    style: TextStyle(
                        color: AppColors.slate500, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 表单卡片
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
                  // 昵称
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 64,
                          child: Text('昵称',
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
                              hintText: '请输入昵称',
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
                  // 性别
                  InkWell(
                    onTap: _showSexPicker,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 64,
                            child: Text('性别',
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
            // 保存按钮
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
                child: const Text('保存',
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