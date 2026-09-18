import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_post_api_model.dart';
import '../../models/hank_comment_model.dart';
import '../../models/match_model.dart';
import '../../models/team_model.dart';
import '../../services/hank_community_detail_api_service.dart';
import '../../utils/hank_auth_manager.dart';
import '../match/match_detail_page.dart';

/// HankCommunityDetailPage: CommunityPostDetailspage
/// receivePostID，requestDetailsandCommentData
/// differentiatedlayoutmatch：lightpurple+whitecolorhometheme，cardstyleauthorinfo，horizontaltagscroll，roundedCommentcard
/// feature：Like、Comment、Reply、Followauthor、DeletePost
class HankCommunityDetailPage extends StatefulWidget {
  /// PostID - inttype，fromCommunitylistpassed in
  final int postId;

  /// PostData（optional） - HankPostItem?type，fromlistprepassed inreducefewfirstscreenetcwait
  final HankPostItem? initialPost;

  HankCommunityDetailPage({
    Key? key,
    required this.postId,
    this.initialPost,
  }) : super(key: key);

  @override
  _HankCommunityDetailPageState createState() =>
      _HankCommunityDetailPageState();
}

class _HankCommunityDetailPageState extends State<HankCommunityDetailPage> {
  /// API serviceinstance
  final HankCommunityDetailApiService _apiService =
      HankCommunityDetailApiService();

  /// PostDetailsData - HankPostItem?type，lazy load
  HankPostItem? _post;

  /// CommentlistData - List<HankCommentItem>type
  List<HankCommentItem> _comments = [];

  /// Commenttotalcount - inttype
  int _commentTotal = 0;

  /// whetherLoadingDetails
  bool _isLoadingDetail = false;

  /// whetherLoadingComment
  bool _isLoadingComments = false;

  /// whetheralreadyLike - booltype，localcachestatus
  bool _isLiked = false;

  /// Likecount - inttype，localcache
  int _likeCount = 0;

  /// whetheralreadyFollowauthor - booltype
  bool _isFollowing = false;

  /// inputfieldcontroller
  final TextEditingController _inputController = TextEditingController();

  /// inputfieldfocus
  final FocusNode _inputFocusNode = FocusNode();

  /// whenbeforeReplyComment - HankCommentItem?type，nullmeansdirectlyCommentPost
  HankCommentItem? _replyingTo;

  /// scrollcontroller
  final ScrollController _scrollController = ScrollController();

  /// whetherisownPost - booltype，usedisplayDeletebutton
  bool _isOwnPost = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// initData：preferuseusepassed inPostData，againrequestDetailsandComment
  void _initData() {
    if (widget.initialPost != null) {
      _post = widget.initialPost;
      _isLiked = widget.initialPost!.isLike ?? false;
      _likeCount = widget.initialPost!.likeCount ?? 0;
      _isFollowing = widget.initialPost!.author?.isSubscribe ?? false;
      _checkOwnPost();
      setState(() {});
    }
    _fetchPostDetail();
    _fetchComments();
  }

  /// checksearchwhetherisownPost
  void _checkOwnPost() {
    final currentUserId = HankAuthManager().currentUser?.id;
    final authorId = _post?.author?.id;
    if (currentUserId != null && authorId != null) {
      _isOwnPost = currentUserId == authorId;
    }
  }

  /// requestPostDetails
  /// API：GET /api/livespeed/community/detail
  Future<void> _fetchPostDetail() async {
    setState(() {
      _isLoadingDetail = true;
    });

    final result = await _apiService.fetchPostDetail(postId: widget.postId);

    if (mounted) {
      setState(() {
        if (result != null) {
          _post = result;
          _isLiked = result.isLike ?? false;
          _likeCount = result.likeCount ?? 0;
          _isFollowing = result.author?.isSubscribe ?? false;
          _checkOwnPost();
        }
        _isLoadingDetail = false;
      });
    }
  }

  /// requestCommentlist
  /// API：GET /api/livespeed/community/comment/list
  Future<void> _fetchComments() async {
    setState(() {
      _isLoadingComments = true;
    });

    final result = await _apiService.fetchComments(
      objectId: widget.postId.toString(),
    );

    if (mounted) {
      setState(() {
        if (result != null) {
          _comments = result.results;
          _commentTotal = result.total ?? result.results.length;
        }
        _isLoadingComments = false;
      });
    }
  }

  /// PostLike/CancelLike
  /// API：POST /api/livespeed/community/like
  Future<void> _toggleLike() async {
    if (!HankAuthManager().isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    final newIsLiked = !_isLiked;
    final newLikeCount =
        newIsLiked ? _likeCount + 1 : (_likeCount > 0 ? _likeCount - 1 : 0);

    setState(() {
      _isLiked = newIsLiked;
      _likeCount = newLikeCount;
    });

    final success = await _apiService.likePost(
      postId: widget.postId,
      type: newIsLiked ? 1 : 2,
    );

    if (!success && mounted) {
      setState(() {
        _isLiked = !newIsLiked;
        _likeCount = newIsLiked ? newLikeCount - 1 : newLikeCount + 1;
      });
      _showToast('Failed，please retry');
    }
  }

  /// CommentLike/CancelLike
  /// [comment] - byactionComment
  /// API：POST /api/livespeed/support
  Future<void> _toggleCommentSupport(HankCommentItem comment) async {
    if (!HankAuthManager().isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    final newIsSupport = !(comment.isSupport ?? false);
    final newSupportCount = newIsSupport
        ? (comment.support ?? 0) + 1
        : (comment.support ?? 0) > 0
            ? (comment.support ?? 0) - 1
            : 0;

    setState(() {
      comment.isSupport = newIsSupport;
      comment.support = newSupportCount;
    });

    final success = await _apiService.supportComment(
      objectId: comment.id ?? 0,
      isSupport: newIsSupport,
    );

    if (!success && mounted) {
      setState(() {
        comment.isSupport = !newIsSupport;
        comment.support =
            newIsSupport ? newSupportCount - 1 : newSupportCount + 1;
      });
      _showToast('Failed，please retry');
    }
  }

  /// Follow/CancelFollowauthor
  /// API：POST /api/livespeed/imchat/subscribe
  Future<void> _toggleFollowAuthor() async {
    if (!HankAuthManager().isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    final authorId = _post?.author?.id;
    if (authorId == null) return;

    final newFollowing = !_isFollowing;

    setState(() {
      _isFollowing = newFollowing;
    });

    final success = await _apiService.toggleFollowAuthor(
      targetId: authorId,
      type: newFollowing ? 1 : 2,
    );

    if (!success && mounted) {
      setState(() {
        _isFollowing = !newFollowing;
      });
      _showToast('Failed，please retry');
    } else if (mounted) {
      _showToast(newFollowing ? 'alreadyFollow' : 'alreadyCancelFollow');
    }
  }

  /// DeletePost
  /// API：POST /api/livespeed/community/delete
  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('DeletePost',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('OKneedDeletethis postPost?？',
            style: TextStyle(fontSize: 13, color: AppColors.slate600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.slate500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.rose500)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _apiService.deletePost(postId: widget.postId);

    if (success && mounted) {
      _showToast('PostalreadyDelete');
      Navigator.pop(context, true);
    } else if (mounted) {
      _showToast('Deletefailed，please retry');
    }
  }

  /// startReplysomeitemComment
  /// [comment] - byReplyComment
  void _startReply(HankCommentItem comment) {
    if (!HankAuthManager().isLoggedIn) {
      _showLoginPrompt();
      return;
    }
    setState(() {
      _replyingTo = comment;
    });
    FocusScope.of(context).requestFocus(_inputFocusNode);
  }

  /// CancelReplymodestyle
  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      _inputController.clear();
    });
    _inputFocusNode.unfocus();
  }

  /// SubmitCommentorReply
  /// directlyCommentPost：commentId = null
  /// ReplyComment：commentId = alevelCommentID
  /// API：POST /api/livespeed/community/comment/add
  Future<void> _submitComment() async {
    final words = _inputController.text.trim();
    if (words.isEmpty) return;

    if (!HankAuthManager().isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    int? commentId;
    if (_replyingTo != null) {
      // ReplyalevelCommentwhenuse parent_id，e.g.ifReplyischildCommentthenuseparentCommentID
      commentId = _replyingTo!.parentId != null && _replyingTo!.parentId != 0
          ? _replyingTo!.parentId
          : _replyingTo!.id;
    }

    final newComment = await _apiService.addComment(
      objectId: widget.postId,
      words: words,
      commentId: commentId,
    );

    if (newComment != null && mounted) {
      _insertComment(newComment, commentId);
      setState(() {
        _commentTotal++;
        _inputController.clear();
        _replyingTo = null;
      });
      _inputFocusNode.unfocus();
    } else if (mounted) {
      _showToast('Commentfailed，please retry');
    }
  }

  /// newCommentinsertinlist
  /// [newComment] - newCommentData
  /// [commentId] - nonnullmeansReply，insertintomaps toalevelComment showChildComments
  void _insertComment(HankCommentItem newComment, int? commentId) {
    if (commentId == null) {
      // directlyCommentPost，insertintolistheader
      _comments.insert(0, newComment);
    } else {
      // ReplyComment，findtomaps toalevelComment
      for (final parent in _comments) {
        if (parent.id == commentId) {
          parent.showChildComments ??= [];
          parent.showChildComments!.add(newComment);
          parent.remainChildCommentCount =
              (parent.remainChildCommentCount ?? 0) + 1;
          break;
        }
      }
    }
  }

  /// Loginhintpopup
  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('hint',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('please firstLoginafteragainaction',
            style: TextStyle(fontSize: 13, color: AppColors.slate600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.slate500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('goLogin',
                style: TextStyle(color: AppColors.violet600)),
          ),
        ],
      ),
    );
  }

  /// displayToastmessage
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// formatTimetimestampiscanreadstring
  /// [timestamp] - secondslevelTimetimestamp
  /// Back：e.g."2underwhenbefore"、"3daybefore"
  String _formatTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}minbefore';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}underwhenbefore';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}daybefore';
    } else {
      return '${date.month}-${date.day}';
    }
  }

  /// navigate tomatchDetails
  /// [match] - PostlinkedmatchData
  void _pushToMatchDetail(HankPostMatch match) {
    final matchModel = MatchModel(
      matchId: match.matchId?.toString() ?? '',
      leagueName: match.competitionName ?? '',
      leagueColor: 0xFF7C3AED,
      homeTeam: TeamModel(
        teamId: match.homeTeamId?.toString() ?? '',
        teamName: match.homeTeamName ?? '',
        teamShort: '',
        logoUrl: match.homeTeamLogo,
      ),
      awayTeam: TeamModel(
        teamId: match.awayTeamId?.toString() ?? '',
        teamName: match.awayTeamName ?? '',
        teamShort: '',
        logoUrl: match.awayTeamLogo,
      ),
      homeScore: match.homeScore,
      awayScore: match.awayScore,
      matchTime: _formatMatchTime(match.startTime),
      status:
          match.homeScore != null ? MatchStatus.finished : MatchStatus.upcoming,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MatchDetailPage(match: matchModel)),
    );
  }

  /// parsetopictag
  /// [rawImage] - API image field
  /// Back：tagcountgroup
  List<String> _parseHashtags(String? rawImage) {
    if (rawImage == null || rawImage.isEmpty) return [];
    String raw = rawImage;
    if (raw.contains('com/')) {
      raw = raw.substring(raw.indexOf('com/') + 4);
    }
    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
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
            _buildAppBar(),
            Expanded(
              child: _buildBody(),
            ),
            _buildBottomInputBar(),
          ],
        ),
      ),
    );
  }

  /// topnavbar：Back + title + Deletebutton（onlyownPost）
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.violet100.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x80DDD6FE), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AppColors.violet800,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'PostDetails',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet900,
                  ),
                ),
              ),
              if (_isOwnPost)
                GestureDetector(
                  onTap: _deletePost,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.rose500,
                    ),
                  ),
                )
              else
                const SizedBox(width: 34),
            ],
          ),
        ),
      ),
    );
  }

  /// homebodycontent：CustomScrollView
  Widget _buildBody() {
    if (_isLoadingDetail && _post == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    if (_post == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.error_outline, size: 48, color: AppColors.violet300),
            SizedBox(height: 12),
            Text('Failed to load',
                style: TextStyle(color: AppColors.slate500, fontSize: 12)),
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(child: _buildAuthorCard()),
        SliverToBoxAdapter(child: _buildContentSection()),
        SliverToBoxAdapter(child: _buildTagsSection()),
        if (_post!.match != null)
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => _pushToMatchDetail(_post!.match!),
              child: _buildMatchCard(),
            ),
          ),
        SliverToBoxAdapter(child: _buildStatsRow()),
        SliverToBoxAdapter(child: _buildCommentsHeader()),
        _buildCommentsList(),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  /// authorinfocard：avatar + nickname + PostTime + Followbutton
  Widget _buildAuthorCard() {
    final author = _post!.author;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.violet100, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A7C3AED),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(author?.avatar, author?.name ?? 'goalfan', 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author?.name ?? 'anonymousnamegoalfan',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(_post!.createTime),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
          ),
          if (!_isOwnPost) _buildFollowButton(),
        ],
      ),
    );
  }

  /// Follow/alreadyFollowbutton
  Widget _buildFollowButton() {
    return GestureDetector(
      onTap: _toggleFollowAuthor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: _isFollowing
              ? null
              : LinearGradient(
                  colors: [AppColors.violet500, AppColors.violet600],
                ),
          color: _isFollowing ? AppColors.violet100 : null,
          borderRadius: BorderRadius.circular(999),
          border: _isFollowing ? Border.all(color: AppColors.violet200) : null,
        ),
        child: Text(
          _isFollowing ? 'Followed' : '+ Follow',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _isFollowing ? AppColors.violet500 : Colors.white,
          ),
        ),
      ),
    );
  }

  /// Postcontentarea
  Widget _buildContentSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.violet100, width: 1),
      ),
      child: Text(
        _post!.content ?? '',
        style: const TextStyle(
          fontSize: 14,
          height: 1.7,
          color: AppColors.slate700,
        ),
      ),
    );
  }

  /// imagegallery（gridlayoutmatch）
  /// imagegalleryalreadyremove，imagesfieldaeachDatausetopictagcategorysplit

  /// topictagarea（horizontal scroll）
  /// preferget images aeachstringcategorysplit，fallbackuse image field
  Widget _buildTagsSection() {
    final tags = _parseHashtags(
      (_post!.images != null && _post!.images!.isNotEmpty)
          ? _post!.images!.first
          : _post!.image,
    );
    if (tags.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.violet50, AppColors.violet100],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.violet200.withOpacity(0.5)),
            ),
            child: Text(
              '#${tags[index]}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.violet600,
              ),
            ),
          );
        },
      ),
    );
  }

  /// linkedmatchcard（lightpurplestyle，areaotherZogoLivedarkcolorcard）
  Widget _buildMatchCard() {
    final match = _post!.match!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.violet50, AppColors.violet100],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.violet200.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          // matchname
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 14, color: AppColors.violet500),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  match.competitionName ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.violet700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // two sides
          Row(
            children: [
              Expanded(
                child: _buildTeamSide(
                  match.homeTeamName,
                  match.homeTeamLogo,
                  align: CrossAxisAlignment.start,
                ),
              ),
              _buildScoreBox(match.homeScore, match.awayScore),
              Expanded(
                child: _buildTeamSide(
                  match.awayTeamName,
                  match.awayTeamLogo,
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // matchstatus
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              match.statusName ?? _formatMatchTime(match.startTime),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.violet600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// matchcardinTeaminfo
  Widget _buildTeamSide(
    String? name,
    String? logo, {
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        _buildTeamLogo(logo, 40),
        const SizedBox(height: 8),
        Text(
          name ?? '',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.slate700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// scoreboxchild
  Widget _buildScoreBox(int? homeScore, int? awayScore) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x147C3AED),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${homeScore ?? 0} : ${awayScore ?? 0}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.violet700,
        ),
      ),
    );
  }

  /// interactanimationDatarow：Likecount + Commentcount
  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.violet100, width: 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleLike,
            behavior: HitTestBehavior.opaque,
            child: _buildStatItem(
              icon: _isLiked ? Icons.favorite : Icons.favorite_border,
              label: '$_likeCount',
              isActive: _isLiked,
              activeColor: AppColors.rose500,
            ),
          ),
          const SizedBox(width: 24),
          _buildStatItem(
            icon: Icons.chat_bubble_outline,
            label: '$_commentTotal',
            activeColor: AppColors.violet600,
          ),
          const Spacer(),
          // matchTime
          if (_post!.match?.startTime != null)
            Text(
              _formatMatchTime(_post!.match!.startTime),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.slate400,
              ),
            ),
        ],
      ),
    );
  }

  /// stat item
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    Color activeColor = AppColors.violet600,
  }) {
    final color = isActive ? activeColor : AppColors.slate400;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  /// Commentareaheader
  Widget _buildCommentsHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.violet600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AllComment $_commentTotal item',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.slate800,
            ),
          ),
        ],
      ),
    );
  }

  /// Commentlist SliverList
  Widget _buildCommentsList() {
    if (_isLoadingComments && _comments.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
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
        ),
      );
    }

    if (_comments.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'NoComment，come quickComment~',
              style: TextStyle(fontSize: 12, color: AppColors.slate400),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) => _buildCommentCard(_comments[index]),
        childCount: _comments.length,
      ),
    );
  }

  /// singleCommentcard
  Widget _buildCommentCard(HankCommentItem comment) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.violet100.withOpacity(0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentHeader(comment),
          const SizedBox(height: 8),
          _buildCommentContent(comment),
          if (comment.showChildComments != null &&
              comment.showChildComments!.isNotEmpty)
            ...comment.showChildComments!
                .map((child) => _buildChildComment(child, comment)),
          _buildCommentFooter(comment),
        ],
      ),
    );
  }

  /// Commentheader：avatar + nickname + Time
  Widget _buildCommentHeader(HankCommentItem comment) {
    return Row(
      children: [
        _buildAvatar(comment.userPic, comment.userName ?? 'goalfan', 28),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.userName ?? 'anonymousnamegoalfan',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(comment.commentTime),
                style: const TextStyle(fontSize: 10, color: AppColors.slate400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Commentcontentcontent
  Widget _buildCommentContent(HankCommentItem comment) {
    if (comment.deletedAt != null) {
      return const Text(
        'thisCommentalreadyDelete',
        style: TextStyle(
            fontSize: 12,
            color: AppColors.slate400,
            fontStyle: FontStyle.italic),
      );
    }
    return Text(
      comment.words ?? '',
      style: const TextStyle(
        fontSize: 13,
        height: 1.5,
        color: AppColors.slate700,
      ),
    );
  }

  /// childComment（Reply）
  Widget _buildChildComment(HankCommentItem child, HankCommentItem parent) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 36),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.violet50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: child.userName ?? 'goalfan',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.violet600,
                  ),
                ),
                if (child.replyToUserName != null &&
                    child.replyToUserName!.isNotEmpty) ...[
                  const TextSpan(
                    text: ' Reply ',
                    style: TextStyle(fontSize: 12, color: AppColors.slate400),
                  ),
                  TextSpan(
                    text: child.replyToUserName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.violet600,
                    ),
                  ),
                ],
                TextSpan(
                  text: '：${child.words ?? ''}',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.slate700),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(child.commentTime),
                style: const TextStyle(fontSize: 10, color: AppColors.slate400),
              ),
              GestureDetector(
                onTap: () => _startReply(child),
                child: const Text(
                  'Reply',
                  style: TextStyle(fontSize: 10, color: AppColors.violet500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Commentbottom：Like + Reply
  Widget _buildCommentFooter(HankCommentItem comment) {
    final isSupport = comment.isSupport ?? false;
    final supportCount = comment.support ?? 0;
    final supportColor = isSupport ? AppColors.rose500 : AppColors.slate400;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleCommentSupport(comment),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSupport ? Icons.favorite : Icons.favorite_border,
                  size: 13,
                  color: supportColor,
                ),
                const SizedBox(width: 3),
                Text(
                  '$supportCount',
                  style: TextStyle(fontSize: 11, color: supportColor),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _startReply(comment),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.reply, size: 13, color: AppColors.slate400),
                SizedBox(width: 3),
                Text('Reply',
                    style: TextStyle(fontSize: 11, color: AppColors.slate400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// bottominputbar（containsReplymodestylehint）
  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingTo != null) _buildReplyModeBar(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.violet50,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: TextField(
                      controller: _inputController,
                      focusNode: _inputFocusNode,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slate700,
                      ),
                      decoration: InputDecoration(
                        hintText: _replyingTo != null
                            ? 'Reply ${_replyingTo!.userName ?? ''}'
                            : 'writeComment...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.slate400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _submitComment,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.violet500, AppColors.violet600],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x307C3AED),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Replymodestylehintbar
  Widget _buildReplyModeBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.violet50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 14, color: AppColors.violet500),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Reply ${_replyingTo!.userName ?? ''}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.violet600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _cancelReply,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: AppColors.slate400),
            ),
          ),
        ],
      ),
    );
  }

  /// buildavatarcomponent
  /// [url] - avatarURL
  /// [name] - nickname（usegeneratecompletedefaultavatar）
  /// [size] - avatarsize
  Widget _buildAvatar(String? url, String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.violet300, AppColors.violet500],
        ),
      ),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(name, size),
              )
            : _buildDefaultAvatar(name, size),
      ),
    );
  }

  /// defaultavatar（initial）
  Widget _buildDefaultAvatar(String name, double size) {
    final initial = name.isNotEmpty ? name.characters.first : '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.violet400, AppColors.violet600],
        ),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// TeamLogo
  Widget _buildTeamLogo(String? url, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.violet50,
      ),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shield,
                  size: size * 0.5,
                  color: AppColors.violet300,
                ),
              )
            : Icon(
                Icons.shield,
                size: size * 0.5,
                color: AppColors.violet300,
              ),
      ),
    );
  }

  /// formatmatchTime
  String _formatMatchTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
