import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/user_profile_model.dart';
import '../../services/mock_data_service.dart';
import '../../utils/hank_auth_manager.dart';
import '../../models/hank_user_model.dart';
import '../login/login_page.dart';
import 'hank_edit_profile_page.dart';
import 'hank_about_us_page.dart';
import 'hank_customer_service_page.dart';
import 'hank_settings_page.dart';

/// ProfilePage: profilepage
/// containsgradientheader（avatar、bio、statsData）andfeaturelist（Editinfo、About Us、Support、Settings）
/// notLoginwhentapavatarpushtoLoginview，Loginafterdisplayuseaccountinfo
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// localMockuseaccountinfo（notLoginwhendisplay）
  late UserProfileModel _user;

  /// whetheralreadyLogin
  bool _isLoggedIn = false;

  /// whenbeforeLoginuseaccountinfo
  HankUserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _user = MockDataService.getUserProfile();
    _refreshLoginState();
  }

  /// refreshLoginstatus
  void _refreshLoginState() {
    setState(() {
      _isLoggedIn = HankAuthManager().isLoggedIn;
      _currentUser = HankAuthManager().currentUser;
    });
  }

  /// tapavatar：notLoginthenpushtoLoginview，Loginsuccessrefresh after
  void _onAvatarTap() {
    if (_isLoggedIn) {
      return;
    }

    // notLogin，pushtoLoginview
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HankLoginPage()),
    ).then((result) {
      // LoginsuccessBackrefresh afterstatus
      if (result == true) {
        _refreshLoginState();
      }
    });
  }

  /// notLoginwhennavigate toLoginview
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HankLoginPage()),
    ).then((result) {
      if (result == true) {
        _refreshLoginState();
      }
    });
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

  /// headergradientBanner：avatar、nickname、bio、stats
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
    // displaynickname：alreadyLoginAPIData，notLogindisplay"Login/Register"
    final displayName = _isLoggedIn
        ? (_currentUser?.nickname ?? 'Unknown user')
        : 'Login/Register';
    // show bio：alreadyLoginAPIData，notLoginuseMock
    final displaySignature = _isLoggedIn
        ? (_currentUser?.signature ?? 'this user is lazy，whatallnothingdown')
        : 'Loginunlock afterMorefeature';

    return Row(
      children: [
        GestureDetector(
          onTap: _onAvatarTap,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor:
                    _isLoggedIn ? AppColors.violet300 : AppColors.slate400,
                child: ClipOval(
                  child: _isLoggedIn && _currentUser?.avatar != null
                      ? Image.network(
                          _currentUser!.avatar!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildDefaultAvatar(displayName),
                        )
                      : _isLoggedIn
                          ? _buildDefaultAvatar(displayName)
                          : _buildGuestAvatar(),
                ),
              ),
              if (_isLoggedIn && _user.isPro)
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
              if (!_isLoggedIn)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.violet600,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
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
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                displaySignature,
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

  Widget _buildDefaultAvatar([String? name]) {
    final displayName = name ?? _user.nickname;
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
        displayName.isNotEmpty ? displayName.characters.first : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// notLoginwhengreycoloravatarplaceholder
  Widget _buildGuestAvatar() {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      color: AppColors.slate400,
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildStatsBar() {
    // alreadyLoginwhenuseAPIData，notLoginuseuseMock
    final following = _isLoggedIn ? '${_currentUser?.followers ?? 0}' : '-';
    final fans = _isLoggedIn ? '${_currentUser?.fansCount ?? 0}' : '-';

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
            value: following,
            label: 'Follow',
          ),
          _buildStatItem(
            value: fans,
            label: 'followers',
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

  /// featurelistcard
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
              title: 'Edit Profile',
              trailing: _isLoggedIn
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.violet100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'finished ${_user.profileCompletion}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.violet700,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                if (!_isLoggedIn) {
                  _navigateToLogin();
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HankEditProfilePage()),
                );
              },
            ),
            _buildDivider(),
            _buildFunctionItem(
              icon: Icons.info_outline,
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF9333EA),
              title: 'About Us',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HankAboutUsPage()),
                );
              },
            ),
            _buildDivider(),
            _buildFunctionItem(
              icon: Icons.headset_mic_outlined,
              iconBgColor: const Color(0xFFD1FAE5),
              iconColor: const Color(0xFF059669),
              title: 'onlineSupport',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '24h online',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HankCustomerServicePage()),
                );
              },
            ),
            _buildDivider(),
            _buildFunctionItem(
              icon: Icons.settings_outlined,
              iconBgColor: const Color(0xFFF1F5F9),
              iconColor: const Color(0xFF334155),
              title: 'Settings',
              onTap: () {
                if (!_isLoggedIn) {
                  _navigateToLogin();
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HankSettingsPage()),
                ).then((_) => _refreshLoginState());
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
