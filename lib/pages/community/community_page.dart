import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/post_model.dart';
import '../../services/hank_community_api_service.dart';
import '../../utils/hank_auth_manager.dart';
import '../../utils/hank_network_manager.dart';
import '../../widgets/community/post_card.dart';
import 'community_detail_page.dart';
import 'post_community_page.dart';
import '../login/login_page.dart';

/// CommunitySubTab: CommunitylistsecondlevelTabenum
/// maps to API type paramcount：Featured=1，recent=2，Follow=3
enum CommunitySubTab {
  /// Featured type=1
  recommend,

  /// recent type=2
  recent,

  /// Follow type=3
  follow,
}

/// CommunityPage: goalfanCommunitypage
/// contains3eachsecondlevelTab：Featured/recent/Follow
/// Datapasspass HankCommunityApiService requestAPIget
/// Postcardcontainstopictag（imagefield）inmatchinfoupside
/// supportPull to refresh + uppullloadMore
class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  /// whenbeforeselectedchildTab
  CommunitySubTab _currentSubTab = CommunitySubTab.recommend;

  /// PostDatalist
  List<PostModel> _posts = [];

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
  final HankCommunityApiService _apiService = HankCommunityApiService();

  /// scrollcontroller（useuppullloadlisten）
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

  /// scroll listener：toreachedbottomtriggerloadMore
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoading && !_isRefreshing && !_hasNoMore) {
        _fetchPosts(isRefresh: false);
      }
    }
  }

  /// will CommunitySubTab convert toAPImaps to HankCommunityTab
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

  /// requestCommunityPostlistData
  /// [isRefresh] - true=refresh（resetpage=1），false=loadMore
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

  /// blockPost（secondtimeConfirmpopup + APIrequest）
  /// [post] - byblockPostmodel
  /// API：POST /api/livespeed/community/block_post
  Future<void> _blockPost(PostModel post) async {
    if (!HankAuthManager().isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HankLoginPage()),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('blockPost',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text(
            'OKneedblockthis postPost?？blockafterwillnotagaindisplaythisPost。',
            style: TextStyle(fontSize: 13, color: AppColors.slate600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.slate500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('block', style: TextStyle(color: AppColors.rose500)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final postId = int.tryParse(post.postId) ?? 0;
    final response = await HankNetworkManager().postRequest(
      '/api/livespeed/community/block_post',
      data: {
        'post_id': postId,
        'type': 1,
      },
    );

    if (response.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('alreadyblock'), duration: Duration(seconds: 1)),
      );
      // fromlistinfilterremovebyblockPost
      setState(() {
        _posts.removeWhere((p) => int.tryParse(p.postId) == postId);
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'blockfailed，please retry'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
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

  /// header：title + New Postbutton + secondlevelTab
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
                  'Community',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet900,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (!HankAuthManager().isLoggedIn) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HankLoginPage(),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HankPostCommunityPage(),
                      ),
                    ).then((published) {
                      if (published == true) {
                        _fetchPosts(isRefresh: true);
                      }
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          'New Post',
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

  /// secondlevelTab：Featured / recent / Follow
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
          _buildSubTabButton(CommunitySubTab.recommend, 'Featured'),
          _buildSubTabButton(CommunitySubTab.recent, 'recent'),
          _buildSubTabButton(CommunitySubTab.follow, 'Follow'),
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

  /// contentarea
  Widget _buildContent() {
    // firsttimeLoading
    if (_isRefreshing && _posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    // emptyData
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
              'NoPostData',
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
          // bottomload/nohasMoreindicator
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
                      _posts.removeWhere(
                        (p) => int.tryParse(p.postId) == postId,
                      );
                    });
                    _fetchPosts(isRefresh: true);
                  }
                });
              },
              onBlockTap: () => _blockPost(_posts[index]),
              onCommentTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('CommentareaExpand'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onShareTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sharesuccess'),
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
}
