/// UserProfileModel: profileuseaccountinfomodel
/// containsavatar、nickname、bio、Follow/followers/Post/predictionWrateetcData
class UserProfileModel {
  /// useaccountuniqueID
  final String userId;

  /// nickname
  final String nickname;

  /// avatarURL
  final String? avatarUrl;

  /// isPROmember
  final bool isPro;

  /// eachpersonbio
  final String signature;

  /// Followcount
  final int followingCount;

  /// followerscount
  final int followerCount;

  /// Postcount
  final int postCount;

  /// predictionWrate 0-100
  final int predictWinRate;

  /// profile completeness 0-100
  final int profileCompletion;

  UserProfileModel({
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    this.isPro = false,
    required this.signature,
    required this.followingCount,
    required this.followerCount,
    required this.postCount,
    required this.predictWinRate,
    required this.profileCompletion,
  });

  /// fromJSONparse
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] ?? '',
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'],
      isPro: json['isPro'] ?? false,
      signature: json['signature'] ?? '',
      followingCount: json['followingCount'] ?? 0,
      followerCount: json['followerCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
      predictWinRate: json['predictWinRate'] ?? 0,
      profileCompletion: json['profileCompletion'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'isPro': isPro,
      'signature': signature,
      'followingCount': followingCount,
      'followerCount': followerCount,
      'postCount': postCount,
      'predictWinRate': predictWinRate,
      'profileCompletion': profileCompletion,
    };
  }

  /// followerscountformatdisplay（e.g. 2.4k）
  String get followerDisplay {
    if (followerCount >= 10000) {
      return '${(followerCount / 10000).toStringAsFixed(1)}w';
    } else if (followerCount >= 1000) {
      return '${(followerCount / 1000).toStringAsFixed(1)}k';
    }
    return followerCount.toString();
  }
}
