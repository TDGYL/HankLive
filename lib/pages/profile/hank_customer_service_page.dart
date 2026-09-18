import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

/// HankCustomerServicePage: onlineSupportpage
/// feature：displaySupportemail，one-click supportcopy
/// differentiated：light purple+whitecolorhometheme，gradient circleemailicon，whitecolorroundedcard
/// reference ZogoLive customer_service_page.dart featureandData
class HankCustomerServicePage extends StatefulWidget {
  const HankCustomerServicePage({Key? key}) : super(key: key);

  @override
  State<HankCustomerServicePage> createState() =>
      _HankCustomerServicePageState();
}

class _HankCustomerServicePageState extends State<HankCustomerServicePage> {
  /// Supportemailaddress
  static const String _serviceEmail = 'LiveSpeedService@outlook.com';

  /// copyemailtoclipboardboard
  Future<void> _copyEmail() async {
    await Clipboard.setData(const ClipboardData(text: _serviceEmail));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Copied'),
            duration: Duration(seconds: 1)),
      );
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
        title: const Text('onlineSupport',
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
          // topdescriptioncard
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.violet100, AppColors.violet50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.violet400, AppColors.violet600],
                    ),
                  ),
                  child: const Icon(Icons.headset_mic,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(height: 12),
                const Text('7x24underwhenonlineservice',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.violet700)),
                const SizedBox(height: 4),
                const Text('hasany questionthemepleasepasspassemailContact Us',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.slate500)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // emailcard
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0F8B5CF6),
                    blurRadius: 8,
                    offset: Offset(0, 2)),
              ]),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.violet100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.email,
                        color: AppColors.violet600, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(_serviceEmail,
                        style: TextStyle(
                            color: AppColors.slate800,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _copyEmail,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.violet400, AppColors.violet600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('copy',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}