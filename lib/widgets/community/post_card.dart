import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/post_model.dart';
import '../match/embedded_match_card.dart';

/// PostCard: 社区帖子卡片
/// 含用户信息、话题标签、正文、内嵌比赛卡片、点赞/评论/分享交互条
class PostCard extends StatefulWidget {
  /// 帖子数据
  final PostModel post;

  /// 点赞状态变更回调
  final ValueChanged<bool>? onLikeChanged;

  /// 点击评论回调
  final VoidCallback? onCommentTap;

  /// 点击分享回调
  final VoidCallback? onShareTap;

  /// 点击用户/关注回调
  final VoidCallback? onFollowTap;

  /// 点击帖子正文回调
  final VoidCallback? onTap;

  PostCard({
    Key? key,
    required this.post,
    this.onLikeChanged,
    this.onCommentTap,
    this.onShareTap,
    this.onFollowTap,
    this.onTap,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount = _likeCount > 0 ? _likeCount - 1 : 0;
      } else {
        _isLiked = true;
        _likeCount = _likeCount + 1;
      }
      widget.post.isLiked = _isLiked;
      widget.post.likeCount = _likeCount;
      widget.onLikeChanged?.call(_isLiked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.violet100, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A7C3AED),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 10),
            if (widget.post.hashtags.isNotEmpty) ...[
              _buildHashtagWrap(),
              const SizedBox(height: 8),
            ],
            _buildContentText(),
            if (widget.post.embeddedMatch != null) ...[
              const SizedBox(height: 10),
              EmbeddedMatchCard(
                match: widget.post.embeddedMatch!,
                onViewLiveTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('切换至直播界面'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 10),
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.violet100,
          child: ClipOval(
            child: widget.post.userAvatarUrl != null
                ? Image.network(
                    widget.post.userAvatarUrl!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildDefaultAvatar(widget.post.userName),
                  )
                : _buildDefaultAvatar(widget.post.userName),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.post.userName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800,
                    ),
                  ),
                  if (widget.post.userBadge != null &&
                      widget.post.userBadge!.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Color(widget.post.userBadgeBgColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.post.userBadge!,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(widget.post.userBadgeTextColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.post.publishTime}${widget.post.location != null ? ' · ${widget.post.location!}' : ''}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: widget.onFollowTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.violet300),
            ),
            child: const Text(
              '+ 关注',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.violet600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name.characters.first : '?';
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.violet400, AppColors.violet600],
        ),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 话题标签Wrap布局（参考ZogoLive，独立标签容器展示在比赛上方）
  Widget _buildHashtagWrap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxTagWidth = constraints.maxWidth * 0.75;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.post.hashtags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.violet100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.violet300.withOpacity(0.3)),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxTagWidth),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: AppColors.violet600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// 正文内容（纯文本）
  Widget _buildContentText() {
    return Text(
      widget.post.content,
      style: const TextStyle(
        fontSize: 12,
        height: 1.6,
        color: AppColors.slate700,
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xCCEDE9FE), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.comment_outlined,
            label: '${widget.post.commentCount}',
            activeColor: AppColors.violet600,
            onTap: widget.onCommentTap,
          ),
          _buildActionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            label: '$_likeCount',
            isActive: _isLiked,
            activeColor: AppColors.rose500,
            onTap: _toggleLike,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color activeColor = AppColors.violet600,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final Color color = isActive ? activeColor : const Color(0xFF94A3B8);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
