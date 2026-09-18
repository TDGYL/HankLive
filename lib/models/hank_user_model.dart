/// HankUserModel: useaccountinfomodel
/// maps to /api/livespeed/member BackuseaccountData
class HankUserModel {
  /// useaccountID - inttype，useaccountuniquebadge
  final int? id;

  /// account - Stringtype，useaccountLoginaccount
  final String? account;

  /// email - Stringtype，useaccountboundemail
  final String? email;

  /// nickname - Stringtype，useaccountdisplayname
  final String? nickname;

  /// avatarURL - Stringtype，useaccountavatarimageaddress
  final String? avatar;

  /// bio - Stringtype，useaccounteachpersonbio
  final String? signature;

  /// phone - Stringtype，useaccountboundphone
  final String? mobile;

  /// RegisterTime - Stringtype，useaccountRegisterTime
  final String? regTime;

  /// user status - inttype，0=normal 1=banneduse
  final int? status;

  /// LoginDplatform - Stringtype，useaccountLoginDplatformbadge
  final String? platforms;

  /// lastLoginTime - Stringtype，useaccountrecentatimeLoginTime
  final String? lastLoginTime;

  /// is first login - booltype，truemeansfirsttimeLogin
  final bool? isDebut;

  /// gold balance - inttype，useaccountgoldcountcount
  final int? kMoney;

  /// couponscountcount - inttype，useaccountcouponscountcount
  final int? kCoupon;

  /// Followcount - inttype，useaccountFollowpersoncount
  final int? followers;

  /// followerscount - inttype，useaccountfollowerscountcount
  final int? fansCount;

  /// gender - inttype，0=unknown 1=male 2=female
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

  /// fromJSONmapping（snake_case → camelCase）
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

  /// convert toJSON（camelCase → snake_case）
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
