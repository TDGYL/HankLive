import 'match_model.dart';

/// PostModel: CommunityPostmodel
/// containsPostuseaccountinfo、topictag、content、embeddedmatchcard、interactionData
class PostModel {
  /// PostuniqueID
  final String postId;

  /// PostuseaccountID
  final String userId;

  /// Postuseaccountnickname
  final String userName;

  /// useaccountavatarURL
  final String? userAvatarUrl;

  /// useaccountetcleveltag（e.g. LV.8 / VIP）
  final String? userBadge;

  /// useaccountetcleveltagbackgroundcolor
  final int userBadgeBgColor;

  /// useaccountetcleveltagtextcolor
  final int userBadgeTextColor;

  /// PostTimedescription（e.g. 15minbefore）
  final String publishTime;

  /// sourcePosition（e.g. from Madrid）
  final String? location;

  /// topictagcountgroup（e.g. #UCL semiFinal）
  final List<String> hashtags;

  /// contentcontent（richtextas plaintextsidestylestore，simplified processing）
  final String content;

  /// embedded matchlinkedmatch（core innovation mechanism），canisempty
  final MatchModel? embeddedMatch;

  /// whetheralreadyLike
  bool isLiked;

  /// Likecount
  int likeCount;

  /// Commentcount
  final int commentCount;

  /// Sharecount
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

  /// fromJSONparse
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
