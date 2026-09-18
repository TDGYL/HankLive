import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/hank_auth_manager.dart';
import '../../utils/hank_network_manager.dart';

/// HankSettingsPage: Settingspage
/// feature：displaywhenbeforeLoginemail，ExitLogin，deleteaccount
/// differentiated：light purple+whitecolorhometheme，whitecolorroundedcard
/// reference ZogoLive settings_page.dart + profile_page.dart ExitLoginlogic
/// API：POST /api/livespeed/member/cancel
class HankSettingsPage extends StatefulWidget {
  const HankSettingsPage({Key? key}) : super(key: key);

  @override
  State<HankSettingsPage> createState() => _HankSettingsPageState();
}

class _HankSettingsPageState extends State<HankSettingsPage> {
  /// whetheractiveindelete
  bool _isCancelling = false;

  /// displayExitLoginsecondtimeConfirmpopup
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('hint',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.slate800)),
          content: const Text('OKneedExitLogin?？',
              style: TextStyle(fontSize: 13, color: AppColors.slate600)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.slate500)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performLogout();
              },
              child: const Text('OK',
                  style: TextStyle(color: AppColors.rose500)),
            ),
          ],
        );
      },
    );
  }

  /// runrowExitLogin
  /// clearlocaluseaccountinfoafterBackprofile
  Future<void> _performLogout() async {
    await HankAuthManager().logout();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('alreadyExitLogin'),
            duration: Duration(seconds: 1)),
      );
      Navigator.of(context).pop();
    }
  }

  /// displaydeleteaccountsecondtimeConfirmpopup
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('hint',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.slate800)),
          content: const Text('OKneeddeletethisaccount?？thisactionnotcanundo',
              style: TextStyle(fontSize: 13, color: AppColors.slate600)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.slate500)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _cancelAccount();
              },
              child: const Text('delete',
                  style: TextStyle(color: AppColors.rose500)),
            ),
          ],
        );
      },
    );
  }

  /// deleteaccount
  /// API：POST /api/livespeed/member/cancel（noneinparam）
  /// successafterclearlocaluseaccountinfoandBackprofile
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
            content: Text('accountalreadydelete'),
            duration: Duration(seconds: 1)),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed，please retry'),
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
        title: const Text('Settings',
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
          // emailinfocard
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
                      const Text('email',
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
          // ExitLogin
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
                    Text('ExitLogin',
                        style: TextStyle(
                            color: AppColors.rose500, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // deleteaccount
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
                    const Text('deleteaccount',
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