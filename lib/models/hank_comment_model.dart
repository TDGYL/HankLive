/// HankCommentData: 社区评论列表响应数据体
/// 包含评论总数和评论项列表
class HankCommentData {
  /// 评论总数 - int类型，表示评论的总数量
  final int? total;

  /// 评论项数组 - List<HankCommentItem>类型，包含所有评论项
  final List<HankCommentItem> results;

  HankCommentData({this.total, this.results = const []});

  /// 从JSON映射
  factory HankCommentData.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List?;
    return HankCommentData(
      total: json['total'] as int?,
      results: list
              ?.map((e) => HankCommentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// HankCommentItem: 单条评论/回复数据项
/// 评论和回复共用同一结构，通过 parent_id 和 is_reply_child 区分层级
class HankCommentItem {
  /// 评论ID - int类型，唯一标识该条评论
  int? id;

  /// 关联对象ID - int类型，评论所属帖子的ID
  int? objectId;

  /// 关联对象类型 - int类型，表示评论所属的对象类型（如帖子=3）
  int? objectType;

  /// 评论用户ID - int类型，发表该评论的用户ID
  int? userId;

  /// 父评论ID - int类型，一级评论为0，回复则对应一级评论的ID
  int? parentId;

  /// 回复目标用户ID - int类型，回复某用户时该用户的ID
  int? replyToUser;

  /// 回复目标评论ID - int类型，回复某评论时该评论的ID
  int? replyToComment;

  /// 评论内容 - String类型，评论文字内容
  String? words;

  /// 点赞数 - int类型，该评论获得的点赞数
  int? support;

  /// 是否为子回复 - int类型，0=一级评论 1=二级回复
  int? isReplyChild;

  /// 评论时间 - int类型，Unix时间戳（秒）
  int? commentTime;

  /// 删除时间 - String?类型，未删除为null
  String? deletedAt;

  /// 用户头像URL - String类型，评论用户头像图片地址
  String? userPic;

  /// 用户名 - String类型，评论用户昵称
  String? userName;

  /// 是否已点赞 - bool类型，true表示当前用户已点赞
  bool? isSupport;

  /// 剩余子评论数量 - int类型，未展示的回复数量
  int? remainChildCommentCount;

  /// 展示的子评论列表 - List<HankCommentItem>?类型，该评论下的回复列表
  List<HankCommentItem>? showChildComments;

  /// 回复目标用户名 - String类型，回复某用户时该用户的昵称
  String? replyToUserName;

  HankCommentItem({
    this.id,
    this.objectId,
    this.objectType,
    this.userId,
    this.parentId,
    this.replyToUser,
    this.replyToComment,
    this.words,
    this.support,
    this.isReplyChild,
    this.commentTime,
    this.deletedAt,
    this.userPic,
    this.userName,
    this.isSupport,
    this.remainChildCommentCount,
    this.showChildComments,
    this.replyToUserName,
  });

  /// 从JSON映射（snake_case → camelCase）
  factory HankCommentItem.fromJson(Map<String, dynamic> json) {
    final childList = json['show_child_comments'] as List?;
    return HankCommentItem(
      id: json['id'] as int?,
      objectId: json['object_id'] as int?,
      objectType: json['object_type'] as int?,
      userId: json['user_id'] as int?,
      parentId: json['parent_id'] as int?,
      replyToUser: json['reply_to_user'] as int?,
      replyToComment: json['reply_to_comment'] as int?,
      words: json['words'] as String?,
      support: json['support'] as int?,
      isReplyChild: json['is_reply_child'] as int?,
      commentTime: json['comment_time'] as int?,
      deletedAt: json['deleted_at'] as String?,
      userPic: json['user_pic'] as String?,
      userName: json['user_name'] as String?,
      isSupport: json['is_support'] as bool?,
      remainChildCommentCount: json['remain_child_comment_count'] as int?,
      replyToUserName: json['reply_to_user_name'] as String?,
      showChildComments: childList
          ?.map((e) => HankCommentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}