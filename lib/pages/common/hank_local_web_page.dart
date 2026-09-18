import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';

/// HankLocalWebPage: localHTMLfileloadpage
/// fromassetsloadHTMLfileanddisplay，useTerms of Service、Privacy Policyetc
class HankLocalWebPage extends StatefulWidget {
  /// HTMLfilepath（assetspath，e.g. assets/htmlSource/user-agreement.html）
  final String assetPath;

  /// pagetitle
  final String title;

  /// constructorfunctioncount
  const HankLocalWebPage({
    required this.assetPath,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  State<HankLocalWebPage> createState() => _HankLocalWebPageState();
}

class _HankLocalWebPageState extends State<HankLocalWebPage> {
  /// WebViewcontroller
  late final WebViewController _controller;

  /// whetherLoading
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
