import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';

/// HankAboutUsPage: About Uspage
/// feature：displayApp Logo、Version、serviceagreement、Privacy Policy、official website entry
/// differentiated：light purple+whitecolorhometheme，circlegradientLogo，whitecolorroundedcardlist
/// reference ZogoLive about_us_page.dart featureandData
class HankAboutUsPage extends StatefulWidget {
  const HankAboutUsPage({Key? key}) : super(key: key);

  @override
  State<HankAboutUsPage> createState() => _HankAboutUsPageState();
}

class _HankAboutUsPageState extends State<HankAboutUsPage> {
  /// shoulduseVersion
  static const String _appVersion = 'v1.0.0';

  /// serviceagreementURL
  static const String _userAgreementUrl =
      'https://www.livespeeds.com/user-agreement?platform=IOS';

  /// Privacy PolicyURL
  static const String _privacyAgreementUrl =
      'https://www.livespeeds.com/privacy-agreement?platform=IOS';

  /// officialwebaddress
  static const String _officialWebsite = 'https://www.livespeeds.com';

  /// navWebViewloadagreementpage
  /// [title] pagetitle，[url] loadaddress
  void _pushToWebView({required String title, required String url}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _HankSimpleWebViewPage(
          pageTitle: title,
          webUrl: url,
        ),
      ),
    );
  }

  /// copyofficialwebaddresstoclipboardboard
  Future<void> _copyWebsite() async {
    await Clipboard.setData(const ClipboardData(text: _officialWebsite));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
      );
    }
  }

  /// buildlistitem
  /// [icon] icon，[iconColor] iconcolor，[title] title
  /// [trailing] right content，[onTap] tapcallback
  Widget _buildListItem(
    IconData icon,
    Color iconColor,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: AppColors.slate800, fontSize: 13)),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('About Us',
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
          const SizedBox(height: 40),
          // Logo（gradient circle + Footballicon）
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.violet400, AppColors.violet600],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x338B5CF6),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.sports_soccer,
                  color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          // shouldusename
          const Center(
            child: Text('HankLive',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.slate800)),
          ),
          const SizedBox(height: 4),
          // Version
          const Center(
            child: Text(_appVersion,
                style: TextStyle(
                    color: AppColors.slate500, fontSize: 12)),
          ),
          const SizedBox(height: 32),
          // featurelist
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
                _buildListItem(
                  Icons.description, AppColors.violet600, 'serviceagreement',
                  trailing: const Icon(Icons.chevron_right, size: 14,
                      color: AppColors.slate400),
                  onTap: () => _pushToWebView(
                      title: 'serviceagreement', url: _userAgreementUrl),
                ),
                Divider(height: 1, color: AppColors.violet100),
                _buildListItem(
                  Icons.privacy_tip, AppColors.violet500, 'Privacy Policy',
                  trailing: const Icon(Icons.chevron_right, size: 14,
                      color: AppColors.slate400),
                  onTap: () => _pushToWebView(
                      title: 'Privacy Policy', url: _privacyAgreementUrl),
                ),
                Divider(height: 1, color: AppColors.violet100),
                _buildListItem(
                  Icons.language, AppColors.violet400, 'officialweb',
                  trailing: const Text(_officialWebsite,
                      style: TextStyle(
                          color: AppColors.slate500, fontSize: 10)),
                  onTap: _copyWebsite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// _HankSimpleWebViewPage: simpleWebViewpage
/// useloadagreement、policyetcoutersectionwebpage
class _HankSimpleWebViewPage extends StatefulWidget {
  /// pagetitle
  final String pageTitle;

  /// webpageURL
  final String webUrl;

  const _HankSimpleWebViewPage({
    required this.pageTitle,
    required this.webUrl,
  });

  @override
  State<_HankSimpleWebViewPage> createState() =>
      _HankSimpleWebViewPageState();
}

class _HankSimpleWebViewPageState extends State<_HankSimpleWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.webUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.pageTitle,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18,
              color: AppColors.slate600),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}