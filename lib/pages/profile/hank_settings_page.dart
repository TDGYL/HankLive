import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/hank_auth_manager.dart';
import '../../utils/hank_network_manager.dart';

/// HankSettingsPage: 设置页面
/// 功能：展示当前登录邮箱，退出登录，注销账号
/// 差异化：浅紫+白色主题，白色圆角卡片
/// 参照 ZogoLive settings_page.dart + profile_page.dart 退出登录逻辑
/// 接口：POST /api/livespeed/member/cancel
class HankSettingsPage extends StatefulWidget {
  const HankSettingsPage({Key? key}) : super(key: key);

  @override
  State<HankSettingsPage> createState() => _HankSettingsPageState();
}

class _HankSettingsPageState extends State<HankSettingsPage> {
  /// 是否正在注销
  bool _isCancelling = false;

  /// 显示退出登录二次确认弹窗
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('提示',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.slate800)),
          content: const Text('确定要退出登录吗？',
              style: TextStyle(fontSize: 13, color: AppColors.slate600)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消',
                  style: TextStyle(color: AppColors.slate500)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performLogout();
              },
              child: const Text('确定',
                  style: TextStyle(color: AppColors.rose500)),
            ),
          ],
        );
      },
    );
  }

  /// 执行退出登录
  /// 清除本地用户信息后返回个人中心
  Future<void> _performLogout() async {
    await HankAuthManager().logout();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('已退出登录'),
            duration: Duration(seconds: 1)),
      );
      Navigator.of(context).pop();
    }
  }

  /// 显示注销账号二次确认弹窗
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('提示',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.slate800)),
          content: const Text('确定要注销此账号吗？此操作不可撤销',
              style: TextStyle(fontSize: 13, color: AppColors.slate600)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消',
                  style: TextStyle(color: AppColors.slate500)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _cancelAccount();
              },
              child: const Text('注销',
                  style: TextStyle(color: AppColors.rose500)),
            ),
          ],
        );
      },
    );
  }

  /// 注销账号
  /// 接口：POST /api/livespeed/member/cancel（无入参）
  /// 成功后清除本地用户信息并返回个人中心
  Future<void> _cancelAccount() async {
    if (_isCancelling) return;
    setState(() {
      _isCancelling = true;
    });

    var success = false;
    try {
      final response = await HankNetworkManager()
          .postRequest('/api/livespeed/member/cancel');
      success = response.isSuccess;
    } catch (e) {
      success = false;
    }

    if (!mounted) return;
    setState(() {
      _isCancelling = false;
    });

    if (success) {
      await HankAuthManager().logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('账号已注销'),
            duration: Duration(seconds: 1)),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('操作失败，请重试'),
            duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = HankAuthManager().currentUser;

    return Scaffold(
      backgroundColor: AppColors.violet50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('设置',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18,
              color: AppColors.slate600),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 邮箱信息卡片
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0F8B5CF6),
                    blurRadius: 8,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.violet100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.email,
                            color: AppColors.violet600, size: 14),
                      ),
                      const SizedBox(width: 12),
                      const Text('邮箱',
                          style: TextStyle(
                              color: AppColors.slate800, fontSize: 13)),
                      const Spacer(),
                      Flexible(
                        flex: 2,
                        child: Text(
                          (user?.email?.isNotEmpty ?? false)
                              ? user!.email!
                              : (user?.account ?? '--'),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: AppColors.slate500, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 退出登录
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0F8B5CF6),
                    blurRadius: 8,
                    offset: Offset(0, 2)),
              ],
            ),
            child: InkWell(
              onTap: _showLogoutDialog,
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0x1AF43F5E),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Icon(Icons.logout,
                            color: AppColors.rose500, size: 14),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('退出登录',
                        style: TextStyle(
                            color: AppColors.rose500, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 注销账号
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0F8B5CF6),
                    blurRadius: 8,
                    offset: Offset(0, 2)),
              ],
            ),
            child: InkWell(
              onTap: _showDeleteAccountDialog,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.rose500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_off,
                          color: AppColors.rose500, size: 14),
                    ),
                    const SizedBox(width: 12),
                    const Text('注销账号',
                        style: TextStyle(
                            color: AppColors.rose500, fontSize: 13)),
                    const Spacer(),
                    if (_isCancelling)
                      const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.rose500),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}