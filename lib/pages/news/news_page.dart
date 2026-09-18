import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/news_model.dart';
import '../../services/hank_news_api_service.dart';
import '../../widgets/news/feature_news_card.dart';
import '../../widgets/news/compact_news_card.dart';

import 'news_detail_page.dart';

/// NewsPage: football pitchnewspage
/// topBanner（1item）+ inbetweenlistcard + bottomBanner（4item）
/// Datapasspass HankNewsApiService requestAPIget
/// supportPull to refresh + uppullloadMore
class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  /// newsDatalist
  List<NewsModel> _newsList = [];

  /// whetheractiveinPull to refresh
  bool _isRefreshing = false;

  /// whetheractiveinuppullload
  bool _isLoading = false;

  /// whethernohasMoreData
  bool _hasNoMore = false;

  /// categorypagepagecode
  int _page = 1;

  /// eachpageitemcount
  final int _size = 10;

  /// APIservice instance
  final HankNewsApiService _apiService = HankNewsApiService();

  /// scrollcontroller（useuppullloadlisten）
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

  /// scroll listener：toreachedbottomtriggerloadMore
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoading && !_isRefreshing && !_hasNoMore) {
        _fetchNews(isRefresh: false);
      }
    }
  }

  /// requestnewslistData
  /// [isRefresh] - true=refresh（resetpage=1），false=loadMore
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

  /// topBannerData（before3item）
  List<NewsModel> get _bannerList {
    if (_newsList.isEmpty) return [];
    final count = _newsList.length < 3 ? _newsList.length : 3;
    return _newsList.sublist(0, count);
  }

  /// inbetweenlistData（4itemwithafter）
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

  /// header：onlykeeptitle，removedarkdepthtactical/news categoryTab
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
              'News',
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

  /// contentarea
  Widget _buildContent() {
    // firsttimeLoading
    if (_isRefreshing && _newsList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    // emptyData
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
              'NonewsData',
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
          // tophorizontalslideanimationBanner
          if (index == 0 && _bannerList.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildHorizontalBanner(),
            );
          }

          // inbetweenlistcard
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

          // bottomloadindicator
          return _buildFooter();
        },
      ),
    );
  }

  /// horizontalslideanimationBanner（before3itemData）
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

  /// calculatelisttotalitemcount：horizontalBanner + inbetweenlist + footer
  int _buildItemCount() {
    int count = 0;
    if (_bannerList.isNotEmpty) count++; // horizontalBanner
    count += _middleList.length; // inbetweenlist
    if (!_hasNoMore || _isLoading) count++; // footer
    return count;
  }

  /// listbottomindicator（Loading / nohasMore）
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
                'nohasMore',
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

  /// tapnewscallback：pushtonewsDetailspage
  void _onNewsTap(NewsModel news) {
    final newsId = int.tryParse(news.newsId) ?? 0;
    if (newsId == 0) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HankNewsDetailPage(
          newsId: newsId,
          newsTitle: news.title,
        ),
      ),
    );
  }
}
