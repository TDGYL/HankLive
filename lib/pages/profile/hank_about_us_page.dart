import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';

/// HankAboutUsPage: 关于我们页面
/// 功能：展示App Logo、版本号、服务协议、隐私政策、官网入口
/// 差异化：浅紫+白色主题，圆形渐变Logo，白色圆角卡片列表
/// 参照 ZogoLive about_us_page.dart 的功能和数据
class HankAboutUsPage extends StatefulWidget {
  const HankAboutUsPage({Key? key}) : super(key: key);

  @override
  State<HankAboutUsPage> createState() => _HankAboutUsPageState();
}

class _HankAboutUsPageState extends State<HankAboutUsPage> {
  /// 应用版本号
  static const String _appVersion = 'v1.0.0';

  /// 服务协议URL
  static const String _userAgreementUrl =
      'https://www.livespeeds.com/user-agreement?platform=IOS';

  /// 隐私政策URL
  static const String _privacyAgreementUrl =
      'https://www.livespeeds.com/privacy-agreement?platform=IOS';

  /// 官网地址
  static const String _officialWebsite = 'https://www.livespeeds.com';

  /// 跳转WebView加载协议页面
  /// [title] 页面标题，[url] 加载地址
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

  /// 复制官网地址到剪贴板
  Future<void> _copyWebsite() async {
    await Clipboard.setData(const ClipboardData(text: _officialWebsite));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制'), duration: Duration(seconds: 1)),
      );
    }
  }

  /// 构建列表项
  /// [icon] 图标，[iconColor] 图标颜色，[title] 标题
  /// [trailing] 右侧内容，[onTap] 点击回调
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
        title: const Text('关于我们',
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
          // Logo（渐变圆形 + 足球图标）
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
          // 应用名称
          const Center(
            child: Text('HankLive',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.slate800)),
          ),
          const SizedBox(height: 4),
          // 版本号
          const Center(
            child: Text(_appVersion,
                style: TextStyle(
                    color: AppColors.slate500, fontSize: 12)),
          ),
          const SizedBox(height: 32),
          // 功能列表
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
                  Icons.description, AppColors.violet600, '服务协议',
                  trailing: const Icon(Icons.chevron_right, size: 14,
                      color: AppColors.slate400),
                  onTap: () => _pushToWebView(
                      title: '服务协议', url: _userAgreementUrl),
                ),
                Divider(height: 1, color: AppColors.violet100),
                _buildListItem(
                  Icons.privacy_tip, AppColors.violet500, '隐私政策',
                  trailing: const Icon(Icons.chevron_right, size: 14,
                      color: AppColors.slate400),
                  onTap: () => _pushToWebView(
                      title: '隐私政策', url: _privacyAgreementUrl),
                ),
                Divider(height: 1, color: AppColors.violet100),
                _buildListItem(
                  Icons.language, AppColors.violet400, '官网',
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

/// _HankSimpleWebViewPage: 简单WebView页面
/// 用于加载协议、政策等外部网页
class _HankSimpleWebViewPage extends StatefulWidget {
  /// 页面标题
  final String pageTitle;

  /// 网页URL
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