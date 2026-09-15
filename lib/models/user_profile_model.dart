/// UserProfileModel: 个人中心用户信息模型
/// 包含头像、昵称、签名、关注/粉丝/帖子/预测胜率等数据
class UserProfileModel {
  /// 用户唯一ID
  final String userId;

  /// 昵称
  final String nickname;

  /// 头像URL
  final String? avatarUrl;

  /// 是否是PRO会员
  final bool isPro;

  /// 个人签名
  final String signature;

  /// 关注数
  final int followingCount;

  /// 粉丝数
  final int followerCount;

  /// 帖子数
  final int postCount;

  /// 预测胜率 0-100
  final int predictWinRate;

  /// 个人资料完善度 0-100
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

  /// 从JSON解析
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

  /// 粉丝数格式化显示（如 2.4k）
  String get followerDisplay {
    if (followerCount >= 10000) {
      return '${(followerCount / 10000).toStringAsFixed(1)}w';
    } else if (followerCount >= 1000) {
      return '${(followerCount / 1000).toStringAsFixed(1)}k';
    }
    return followerCount.toString();
  }
}
