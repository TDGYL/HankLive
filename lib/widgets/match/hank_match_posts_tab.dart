import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/post_model.dart';
import '../../services/hank_community_api_service.dart';
import '../../utils/hank_auth_manager.dart';
import '../community/post_card.dart';
import '../../pages/community/community_detail_page.dart';

/// HankMatchPostsTab: 比赛详情-帖子列表Tab
/// 请求 /api/livespeed/community/list 接口，type=1 固定推荐
/// 布局与 community_page 一致：下拉刷新 + 上拉加载 + PostCard 列表
class HankMatchPostsTab extends StatefulWidget {
  /// 比赛ID - int类型，用于传递给帖子详情页
  final int matchId;

  HankMatchPostsTab({
    Key? key,
    required this.matchId,
  }) : super(key: key);

  @override
  _HankMatchPostsTabState createState() => _HankMatchPostsTabState();
}

class _HankMatchPostsTabState extends State<HankMatchPostsTab> {
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

  /// 滚动控制器
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

  /// 请求社区帖子列表数据
  /// 接口：GET /api/livespeed/community/list
  /// 参数：type=1（固定推荐），match_type=1
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
      tab: HankCommunityTab.recommend,
      page: requestPage,
      size: _size,
      matchType: 1,
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

  /// 拉黑帖子
  /// [post] - 被拉黑的帖子模型
  Future<void> _blockPost(PostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('拉黑帖子',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('确定要拉黑这篇帖子吗？拉黑后将不再显示该帖子。',
            style: TextStyle(fontSize: 13, color: AppColors.slate600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消', style: TextStyle(color: AppColors.slate500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('拉黑', style: TextStyle(color: AppColors.rose500)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!HankAuthManager().isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录'), duration: Duration(seconds: 1)),
      );
      return;
    }

    final postId = int.tryParse(post.postId) ?? 0;
    if (!mounted) return;
    setState(() {
      _posts.removeWhere((p) => int.tryParse(p.postId) == postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRefreshing && _posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.violet300),
            SizedBox(height: 12),
            Text('暂无帖子数据', style: TextStyle(color: AppColors.slate500, fontSize: 12)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.violet600,
      onRefresh: () => _fetchPosts(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
        itemCount: _posts.length + 1,
        itemBuilder: (ctx, index) {
          if (index == _posts.length) {
            return _buildFooter();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PostCard(
              post: _posts[index],
              onTap: () {
                final postId = int.tryParse(_posts[index].postId) ?? 0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HankCommunityDetailPage(postId: postId),
                  ),
                ).then((deleted) {
                  if (deleted == true) {
                    setState(() {
                      _posts.removeWhere((p) => int.tryParse(p.postId) == postId);
                    });
                    _fetchPosts(isRefresh: true);
                  }
                });
              },
              onBlockTap: () => _blockPost(_posts[index]),
            ),
          );
        },
      ),
    );
  }

  /// 列表底部指示器
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
              const Text('没有更多了',
                  style: TextStyle(fontSize: 11, color: AppColors.slate500)),
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
