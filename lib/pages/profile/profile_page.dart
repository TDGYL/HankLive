import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/user_profile_model.dart';
import '../../services/mock_data_service.dart';

/// ProfilePage: 个人中心页面
/// 包含渐变头部（头像、签名、统计数据）和功能列表（编辑信息、关于我们、客服、设置）
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// 用户信息
  late UserProfileModel _user;

  @override
  void initState() {
    super.initState();
    _user = MockDataService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildFunctionList(),
            ],
          ),
        ),
      ),
    );
  }

  /// 头部渐变Banner：头像、昵称、签名、统计
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.profileHeaderGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x335B21B6),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserRow(),
              const SizedBox(height: 20),
              _buildStatsBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow() {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.violet300,
              child: ClipOval(
                child: _user.avatarUrl != null
                    ? Image.network(
                        _user.avatarUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
            if (_user.isPro)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.amber400,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _user.nickname,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('展示个人名片'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.qr_code,
                            size: 12,
                            color: Color(0xFFC4B5FD),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '名片',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFC4B5FD),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _user.signature,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFC4B5FD),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.violet400, AppColors.violet600],
        ),
      ),
      child: Text(
        _user.nickname.isNotEmpty ? _user.nickname.characters.first : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0x4D8B5CF6), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            value: '${_user.followingCount}',
            label: '关注',
          ),
          _buildStatItem(
            value: _user.followerDisplay,
            label: '粉丝',
          ),
          _buildStatItem(
            value: '${_user.postCount}',
            label: '帖子',
          ),
          _buildStatItem(
            value: '${_user.predictWinRate}%',
            label: '预测胜率',
            valueColor: AppColors.amber400,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: valueColor ?? Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFC4B5FD),
            ),
          ),
        ],
      ),
    );
  }

  /// 功能列表卡片
  Widget _buildFunctionList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.violet100),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A7C3AED),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildFunctionItem(
              icon: Icons.edit,
              iconBgColor: AppColors.violet100,
              iconColor: AppColors.violet700,
              title: '编辑个人信息',
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.violet100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '完善度${_user.profileCompletion}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.violet700,
                  ),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('打开编辑个人信息界面'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildFunctionItem(
              icon: Icons.info_outline,
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF9333EA),
              title: '关于我们',
              trailingText: 'v3.2.0',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('紫极足球 v3.2.0 (Build 2026)'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildFunctionItem(
              icon: Icons.headset_mic_outlined,
              iconBgColor: const Color(0xFFD1FAE5),
              iconColor: const Color(0xFF059669),
              title: '在线客服',
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '24h 在线',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('连接在线客服中...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildFunctionItem(
              icon: Icons.settings_outlined,
              iconBgColor: const Color(0xFFF1F5F9),
              iconColor: const Color(0xFF334155),
              title: '设置',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('打开系统设置'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: Color(0xCCDDD6FE),
      indent: 14,
      endIndent: 14,
    );
  }

  Widget _buildFunctionItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? trailingText,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                ),
              ),
            if (trailing != null) trailing,
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 14,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
