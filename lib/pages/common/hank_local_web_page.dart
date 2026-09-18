import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';

/// HankLocalWebPage: 本地HTML文件加载页面
/// 从assets加载HTML文件并展示，用于服务条款、隐私政策等
class HankLocalWebPage extends StatefulWidget {
  /// HTML文件路径（assets路径，如 assets/htmlSource/user-agreement.html）
  final String assetPath;

  /// 页面标题
  final String title;

  /// 构造函数
  const HankLocalWebPage({
    required this.assetPath,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  State<HankLocalWebPage> createState() => _HankLocalWebPageState();
}

class _HankLocalWebPageState extends State<HankLocalWebPage> {
  /// WebView控制器
  late final WebViewController _controller;

  /// 是否正在加载
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadFlutterAsset(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.slate800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18,
              color: AppColors.slate600),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.violet600,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }
}
