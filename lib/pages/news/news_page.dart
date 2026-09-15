import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/news_model.dart';
import '../../services/hank_news_api_service.dart';
import '../../widgets/news/feature_news_card.dart';
import '../../widgets/news/compact_news_card.dart';

/// NewsPage: 绿荫资讯页面
/// 顶部Banner（第1条）+ 中间列表卡片 + 底部Banner（第4条）
/// 数据通过 HankNewsApiService 请求接口获取
/// 支持下拉刷新 + 上拉加载更多
class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  /// 资讯数据列表
  List<NewsModel> _newsList = [];

  /// 是否正在下拉刷新
  bool _isRefreshing = false;

  /// 是否正在上拉加载
  bool _isLoading = false;

  /// 是否没有更多数据
  bool _hasNoMore = false;

  /// 分页页码
  int _page = 1;

  /// 每页条数
  final int _size = 10;

  /// API服务实例
  final HankNewsApiService _apiService = HankNewsApiService();

  /// 滚动控制器（用于上拉加载监听）
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchNews(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听：到达底部触发加载更多
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoading && !_isRefreshing && !_hasNoMore) {
        _fetchNews(isRefresh: false);
      }
    }
  }

  /// 请求资讯列表数据
  /// [isRefresh] - true=刷新（重置page=1），false=加载更多
  Future<void> _fetchNews({required bool isRefresh}) async {
    if (_isLoading || _isRefreshing) return;

    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
        _page = 1;
        _hasNoMore = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    final requestPage = isRefresh ? 1 : _page + 1;

    final result = await _apiService.fetchNewsModels(
      page: requestPage,
      size: _size,
    );

    if (mounted) {
      setState(() {
        if (isRefresh) {
          _newsList = result;
          _page = 1;
          _isRefreshing = false;
        } else {
          _newsList.addAll(result);
          _page = requestPage;
          _isLoading = false;
        }
        if (result.length < _size) {
          _hasNoMore = true;
        }
      });
    }
  }

  /// 顶部Banner数据（前3条）
  List<NewsModel> get _bannerList {
    if (_newsList.isEmpty) return [];
    final count = _newsList.length < 3 ? _newsList.length : 3;
    return _newsList.sublist(0, count);
  }

  /// 中间列表数据（第4条以后）
  List<NewsModel> get _middleList {
    if (_newsList.length <= 3) return [];
    return _newsList.sublist(3);
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
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// 头部：仅保留标题，去掉深度战术/快讯分类Tab
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.violet100.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x80DDD6FE), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: const [
            Text(
              '绿荫资讯',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.violet900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 内容区域
  Widget _buildContent() {
    // 首次加载中
    if (_isRefreshing && _newsList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    // 空数据
    if (_newsList.isEmpty) {
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
              '暂无资讯数据',
              style: TextStyle(color: AppColors.slate500, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.violet600,
      onRefresh: () => _fetchNews(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 88),
        itemCount: _buildItemCount(),
        itemBuilder: (ctx, index) {
          // 顶部横向滑动Banner
          if (index == 0 && _bannerList.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildHorizontalBanner(),
            );
          }

          // 中间列表卡片
          final middleIndex = index - 1;
          if (middleIndex < _middleList.length) {
            final news = _middleList[middleIndex];
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: CompactNewsCard(
                news: news,
                onTap: () => _onNewsTap(news),
              ),
            );
          }

          // 底部加载指示器
          return _buildFooter();
        },
      ),
    );
  }

  /// 横向滑动Banner（前3条数据）
  Widget _buildHorizontalBanner() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: _bannerList.length,
        itemBuilder: (ctx, index) {
          final news = _bannerList[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            child: FeatureNewsCard(
              news: news,
              onTap: () => _onNewsTap(news),
            ),
          );
        },
      ),
    );
  }

  /// 计算列表总条数：横向Banner + 中间列表 + footer
  int _buildItemCount() {
    int count = 0;
    if (_bannerList.isNotEmpty) count++; // 横向Banner
    count += _middleList.length; // 中间列表
    if (!_hasNoMore || _isLoading) count++; // footer
    return count;
  }

  /// 列表底部指示器（加载中 / 没有更多）
  Widget _buildFooter() {
    if (_hasNoMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 24, height: 1, color: AppColors.violet200),
              const SizedBox(width: 8),
              const Text(
                '没有更多了',
                style: TextStyle(fontSize: 11, color: AppColors.slate500),
              ),
              const SizedBox(width: 8),
              Container(width: 24, height: 1, color: AppColors.violet200),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.violet600,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 点击资讯回调
  void _onNewsTap(NewsModel news) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('阅读资讯：${news.title.substring(0, news.title.length > 10 ? 10 : news.title.length)}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
