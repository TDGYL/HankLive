/// HankUserModel: 用户信息模型
/// 对应 /api/livespeed/member 返回的用户数据
class HankUserModel {
  /// 用户ID - int类型，用户唯一标识
  final int? id;

  /// 账号 - String类型，用户登录账号
  final String? account;

  /// 邮箱 - String类型，用户绑定邮箱
  final String? email;

  /// 昵称 - String类型，用户展示名称
  final String? nickname;

  /// 头像URL - String类型，用户头像图片地址
  final String? avatar;

  /// 个性签名 - String类型，用户个人简介
  final String? signature;

  /// 手机号 - String类型，用户绑定手机号
  final String? mobile;

  /// 注册时间 - String类型，用户注册时间
  final String? regTime;

  /// 用户状态 - int类型，0=正常 1=禁用
  final int? status;

  /// 登录平台 - String类型，用户登录平台标识
  final String? platforms;

  /// 最后登录时间 - String类型，用户最近一次登录时间
  final String? lastLoginTime;

  /// 是否首登 - bool类型，true表示首次登录
  final bool? isDebut;

  /// 金币余额 - int类型，用户金币数量
  final int? kMoney;

  /// 优惠券数量 - int类型，用户优惠券数量
  final int? kCoupon;

  /// 关注数 - int类型，用户关注的人数
  final int? followers;

  /// 粉丝数 - int类型，用户的粉丝数量
  final int? fansCount;

  /// 性别 - int类型，0=未知 1=男 2=女
  final int? sex;

  HankUserModel({
    this.id,
    this.account,
    this.email,
    this.nickname,
    this.avatar,
    this.signature,
    this.mobile,
    this.regTime,
    this.status,
    this.platforms,
    this.lastLoginTime,
    this.isDebut,
    this.kMoney,
    this.kCoupon,
    this.followers,
    this.fansCount,
    this.sex,
  });

  /// 从JSON映射（snake_case → camelCase）
  factory HankUserModel.fromJson(Map<String, dynamic> json) {
    return HankUserModel(
      id: json['id'] as int?,
      account: json['account'] as String?,
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      signature: json['signature'] as String?,
      mobile: json['mobile'] as String?,
      regTime: json['reg_time'] as String?,
      status: json['status'] as int?,
      platforms: json['platforms'] as String?,
      lastLoginTime: json['last_login_time'] as String?,
      isDebut: json['is_debut'] as bool?,
      kMoney: json['k_money'] as int?,
      kCoupon: json['k_coupon'] as int?,
      followers: json['followers'] as int?,
      fansCount: json['fans_count'] as int?,
      sex: json['sex'] as int?,
    );
  }

  /// 转为JSON（camelCase → snake_case）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'email': email,
      'nickname': nickname,
      'avatar': avatar,
      'signature': signature,
      'mobile': mobile,
      'reg_time': regTime,
      'status': status,
      'platforms': platforms,
      'last_login_time': lastLoginTime,
      'is_debut': isDebut,
      'k_money': kMoney,
      'k_coupon': kCoupon,
      'followers': followers,
      'fans_count': fansCount,
      'sex': sex,
    };
  }
}
