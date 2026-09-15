import 'match_model.dart';

/// PostModel: 社区帖子模型
/// 包含发布用户信息、话题标签、正文、内嵌比赛卡片、交互数据
class PostModel {
  /// 帖子唯一ID
  final String postId;

  /// 发布用户ID
  final String userId;

  /// 发布用户昵称
  final String userName;

  /// 用户头像URL
  final String? userAvatarUrl;

  /// 用户等级标签（如 LV.8 / VIP）
  final String? userBadge;

  /// 用户等级标签背景颜色
  final int userBadgeBgColor;

  /// 用户等级标签文字颜色
  final int userBadgeTextColor;

  /// 发布时间描述（如 15分钟前）
  final String publishTime;

  /// 来源位置（如 来自马德里）
  final String? location;

  /// 话题标签数组（如 #欧冠半决赛）
  final List<String> hashtags;

  /// 正文内容（富文本以纯文本方式存储，简化处理）
  final String content;

  /// 内嵌关联比赛（核心创新机制），可为空
  final MatchModel? embeddedMatch;

  /// 是否已点赞
  bool isLiked;

  /// 点赞数
  int likeCount;

  /// 评论数
  final int commentCount;

  /// 分享数
  final int shareCount;

  PostModel({
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.userBadge,
    this.userBadgeBgColor = 0xFFEDE9FE,
    this.userBadgeTextColor = 0xFF7C3AED,
    required this.publishTime,
    this.location,
    this.hashtags = const [],
    required this.content,
    this.embeddedMatch,
    this.isLiked = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
  });

  /// 从JSON解析
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatarUrl: json['userAvatarUrl'],
      userBadge: json['userBadge'],
      userBadgeBgColor: json['userBadgeBgColor'] ?? 0xFFEDE9FE,
      userBadgeTextColor: json['userBadgeTextColor'] ?? 0xFF7C3AED,
      publishTime: json['publishTime'] ?? '',
      location: json['location'],
      hashtags: (json['hashtags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      content: json['content'] ?? '',
      embeddedMatch: json['embeddedMatch'] == null
          ? null
          : MatchModel.fromJson(json['embeddedMatch']),
      isLiked: json['isLiked'] ?? false,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'userBadge': userBadge,
      'userBadgeBgColor': userBadgeBgColor,
      'userBadgeTextColor': userBadgeTextColor,
      'publishTime': publishTime,
      'location': location,
      'hashtags': hashtags,
      'content': content,
      'embeddedMatch': embeddedMatch?.toJson(),
      'isLiked': isLiked,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
    };
  }
}
