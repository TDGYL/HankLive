import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/post_model.dart';
import '../../services/hank_community_api_service.dart';
import '../../widgets/community/post_card.dart';

/// CommunitySubTab: 社区列表二级Tab枚举
/// 对应接口 type 参数：推荐=1，最近=2，关注=3
enum CommunitySubTab {
  /// 推荐 type=1
  recommend,
  /// 最近 type=2
  recent,
  /// 关注 type=3
  follow,
}

/// CommunityPage: 球友社区页面
/// 含3个二级Tab：推荐/最近/关注
/// 数据通过 HankCommunityApiService 请求接口获取
/// 帖子卡片含话题标签（image字段）在比赛信息上方
/// 支持下拉刷新 + 上拉加载更多
class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  /// 当前选中的子Tab
  CommunitySubTab _currentSubTab = CommunitySubTab.recommend;

  /// 帖子数据列表
  List<PostModel> _posts = [];

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
  final HankCommunityApiService _apiService = HankCommunityApiService();

  /// 滚动控制器（用于上拉加载监听）
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchPosts(isRefresh: true);
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
        _fetchPosts(isRefresh: false);
      }
    }
  }

  /// 将 CommunitySubTab 转换为接口对应的 HankCommunityTab
  HankCommunityTab _getApiTab(CommunitySubTab tab) {
    switch (tab) {
      case CommunitySubTab.recommend:
        return HankCommunityTab.recommend;
      case CommunitySubTab.recent:
        return HankCommunityTab.recent;
      case CommunitySubTab.follow:
        return HankCommunityTab.follow;
    }
  }

  /// 请求社区帖子列表数据
  /// [isRefresh] - true=刷新（重置page=1），false=加载更多
  Future<void> _fetchPosts({required bool isRefresh}) async {
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

    final result = await _apiService.fetchPostModels(
      tab: _getApiTab(_currentSubTab),
      page: requestPage,
      size: _size,
    );

    if (mounted) {
      setState(() {
        if (isRefresh) {
          _posts = result;
          _page = 1;
          _isRefreshing = false;
        } else {
          _posts.addAll(result);
          _page = requestPage;
          _isLoading = false;
        }
        if (result.length < _size) {
          _hasNoMore = true;
        }
      });
    }
  }

  void _switchSubTab(CommunitySubTab tab) {
    setState(() {
      _currentSubTab = tab;
      _posts = [];
      _hasNoMore = false;
    });
    _fetchPosts(isRefresh: true);
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

  /// 头部：标题 + 发帖按钮 + 二级Tab
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.violet100.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x80DDD6FE), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  '球友社区',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet900,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('打开发帖编辑器'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.violet600,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x307C3AED),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.add, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          '发帖',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSubTabs(),
          ],
        ),
      ),
    );
  }

  /// 二级Tab：推荐 / 最近 / 关注
  Widget _buildSubTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0x99DDD6FE),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSubTabButton(CommunitySubTab.recommend, '推荐'),
          _buildSubTabButton(CommunitySubTab.recent, '最近'),
          _buildSubTabButton(CommunitySubTab.follow, '关注'),
        ],
      ),
    );
  }

  Widget _buildSubTabButton(CommunitySubTab tab, String label) {
    final isSelected = _currentSubTab == tab;
    return GestureDetector(
      onTap: () => _switchSubTab(tab),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 14 : 10,
                vertical: isSelected ? 4 : 6,
              ),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.violet200.withOpacity(0.5),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A0F172A),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    )
                  : null,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.violet700 : AppColors.slate500,
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                left: 0,
                right: 0,
                bottom: -8,
                child: Center(
                  child: Container(
                    width: 16,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.violet600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
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
    if (_isRefreshing && _posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    // 空数据
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.violet300,
            ),
            SizedBox(height: 12),
            Text(
              '暂无帖子数据',
              style: TextStyle(color: AppColors.slate500, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.violet600,
      onRefresh: () => _fetchPosts(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: _posts.length + 1, // +1 for footer
        itemBuilder: (ctx, index) {
          // 底部加载/没有更多指示器
          if (index == _posts.length) {
            return _buildFooter();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PostCard(
              post: _posts[index],
              onFollowTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已关注该球友: ${_posts[index].userName}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              onCommentTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('评论区展开'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onShareTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('分享成功'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
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
}
