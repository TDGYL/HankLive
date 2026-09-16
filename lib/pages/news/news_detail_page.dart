import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_news_api_model.dart';
import '../../services/hank_news_api_service.dart';

/// HankNewsDetailPage: 资讯详情页面
/// 使用 WebView 加载资讯内容（HTML富文本）
/// 接口：GET /api/livespeed/info/detail
/// 主题：浅紫色 + 白色
class HankNewsDetailPage extends StatefulWidget {
  /// 资讯ID
  final int newsId;

  /// 资讯标题（传入用于导航栏展示，接口返回前使用）
  final String? newsTitle;

  const HankNewsDetailPage({
    required this.newsId,
    this.newsTitle,
    Key? key,
  }) : super(key: key);

  @override
  State<HankNewsDetailPage> createState() => _HankNewsDetailPageState();
}

class _HankNewsDetailPageState extends State<HankNewsDetailPage> {
  /// WebView控制器
  late final WebViewController _controller;

  /// 是否正在加载
  bool _isLoading = true;

  /// 资讯详情数据
  HankNewsItem? _newsDetail;

  /// 资讯接口服务
  final HankNewsApiService _apiService = HankNewsApiService();

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF5F3FF));

    _fetchNewsDetail();
  }

  /// 请求资讯详情数据
  /// 接口：GET /api/livespeed/info/detail
  Future<void> _fetchNewsDetail() async {
    final data = await _apiService.fetchNewsDetail(id: widget.newsId);

    if (mounted) {
      setState(() {
        _newsDetail = data;
        _isLoading = false;
      });
      _loadHtmlContent();
    }
  }

  /// 加载HTML内容到WebView
  void _loadHtmlContent() {
    if (_newsDetail == null) return;

    final title = _newsDetail!.title ?? '';
    final author = _newsDetail!.author ?? '官方';
    final time = _formatTime(_newsDetail!.createdAt);
    final content = _newsDetail!.content ?? '';

    final htmlString = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <style>
          body {
            padding: 16px;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: #FFFFFF;
            color: #1E293B;
            line-height: 1.6;
            margin: 0;
          }
          .title {
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 12px;
            color: #1E293B;
            line-height: 1.4;
          }
          .meta {
            font-size: 12px;
            color: #94A3B8;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
          }
          .content {
            font-size: 15px;
            color: #475569;
            overflow-wrap: break-word;
            word-wrap: break-word;
          }
          .content img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            margin: 10px 0;
            display: block;
          }
          .content p {
            margin: 0 0 12px 0;
          }
          a {
            color: #7C3AED;
            text-decoration: none;
          }
        </style>
      </head>
      <body>
        <div class="title">$title</div>
        <div class="meta">
          <span>$author</span>
          <span>$time</span>
        </div>
        <div class="content">
          $content
        </div>
      </body>
      </html>
    ''';

    _controller.loadHtmlString(htmlString);
  }

  /// 格式化时间为 yyyy-MM-dd HH:mm
  /// [timestamp] - 时间戳（秒）
  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet50,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  /// 顶部导航栏
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.violet200, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // 返回按钮
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.violet100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  size: 16,
                  color: AppColors.violet700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _newsDetail?.title ?? widget.newsTitle ?? '资讯详情',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 页面主体
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    if (_newsDetail == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.newspaper_outlined,
              size: 48,
              color: AppColors.violet300,
            ),
            SizedBox(height: 12),
            Text(
              '暂无资讯内容',
              style: TextStyle(fontSize: 14, color: AppColors.slate500),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: WebViewWidget(controller: _controller),
    );
  }
}