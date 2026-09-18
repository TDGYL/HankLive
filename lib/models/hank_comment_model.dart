/// HankCommentData: CommunityCommentlistresponseDatabody
/// containsCommenttotalcountandCommentitem list
class HankCommentData {
  /// Commenttotalcount - inttype，meansCommenttotalcountcount
  final int? total;

  /// Commentitemcountgroup - List<HankCommentItem>type，containsthehasCommentitem
  final List<HankCommentItem> results;

  HankCommentData({this.total, this.results = const []});

  /// fromJSONmapping
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

/// HankCommentItem: singleComment/ReplyDataitem
/// CommentandReplyshareusesameastructure，passpass parent_id and is_reply_child areacategorylevellevel
class HankCommentItem {
  /// CommentID - inttype，uniquebadgethisitemComment
  int? id;

  /// linkedobjectID - inttype，Commentbelongs toPostID
  int? objectId;

  /// linkedobjecttype - inttype，meansCommentbelongs toobjecttype（e.g.Post=3）
  int? objectType;

  /// CommentuseaccountID - inttype，post thisCommentuseaccountID
  int? userId;

  /// parentCommentID - inttype，alevelCommentis0，Replythenmaps toalevelCommentID
  int? parentId;

  /// ReplyitemmarkuseaccountID - inttype，ReplysomeuseaccountwhenthisuseaccountID
  int? replyToUser;

  /// ReplyitemmarkCommentID - inttype，ReplysomeCommentwhenthisCommentID
  int? replyToComment;

  /// Commentcontent - Stringtype，Commenttextcontent
  String? words;

  /// Likecount - inttype，thisCommentgetgotLikecount
  int? support;

  /// whetherischildReply - inttype，0=alevelComment 1=secondlevelReply
  int? isReplyChild;

  /// CommentTime - inttype，UnixTimetimestamp（seconds）
  int? commentTime;

  /// DeleteTime - String?type，notDeleteisnull
  String? deletedAt;

  /// useaccountavatarURL - Stringtype，Commentuseaccountavatarimageaddress
  String? userPic;

  /// useaccountname - Stringtype，Commentuseaccountnickname
  String? userName;

  /// whetheralreadyLike - booltype，truemeanswhenbeforeuseaccountalreadyLike
  bool? isSupport;

  /// remainingchildCommentcountcount - inttype，notdisplayReplycountcount
  int? remainChildCommentCount;

  /// displaychildCommentlist - List<HankCommentItem>?type，thisCommentdownReplylist
  List<HankCommentItem>? showChildComments;

  /// Replyitemmarkuseaccountname - Stringtype，Replysomeuseaccountwhenthisuseaccountnickname
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

  /// fromJSONmapping（snake_case → camelCase）
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