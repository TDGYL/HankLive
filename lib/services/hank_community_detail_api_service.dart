import '../utils/hank_network_manager.dart';
import '../models/hank_post_api_model.dart';
import '../models/hank_comment_model.dart';

/// HankCommunityDetailApiService: 社区详情接口服务
/// 封装帖子详情、评论列表、评论发布、点赞、删除、关注等接口
class HankCommunityDetailApiService {
  /// 单例实例
  static final HankCommunityDetailApiService _instance =
      HankCommunityDetailApiService._internal();

  /// 工厂构造，返回单例
  factory HankCommunityDetailApiService() => _instance;

  /// 私有构造
  HankCommunityDetailApiService._internal();

  /// 请求帖子详情
  /// 接口：GET /api/livespeed/community/detail
  /// [postId] - 帖子ID
  /// 返回：HankPostItem 帖子详情
  Future<HankPostItem?> fetchPostDetail({required int postId}) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/community/detail',
      queryParameters: {'id': postId},
    );

    if (response.isSuccess && response.data != null) {
      return HankPostItem.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }

  /// 请求评论列表
  /// 接口：GET /api/livespeed/community/comment/list
  /// [objectId] - 帖子ID
  /// 返回：HankCommentData 评论列表数据
  Future<HankCommentData?> fetchComments({required String objectId}) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/community/comment/list',
      queryParameters: {'object_id': objectId},
    );

    if (response.isSuccess && response.data != null) {
      return HankCommentData.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }

  /// 发表评论/回复
  /// 接口：POST /api/livespeed/community/comment/add
  /// [objectId] - 帖子ID
  /// [words] - 评论内容
  /// [commentId] - 回复时的一级评论ID，直接评论帖子时为null
  /// 返回：HankCommentItem? 新评论数据
  Future<HankCommentItem?> addComment({
    required int objectId,
    required String words,
    int? commentId,
  }) async {
    final params = <String, dynamic>{
      'object_id': objectId,
      'words': words,
    };
    if (commentId != null) {
      params['comment_id'] = commentId;
    }

    final response = await HankNetworkManager().postRequest(
      '/api/livespeed/community/comment/add',
      data: params,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final commentJson = data['comment'] as Map<String, dynamic>?;
      if (commentJson != null) {
        return HankCommentItem.fromJson(commentJson);
      }
    }
    return null;
  }

  /// 评论点赞/取消点赞
  /// 接口：POST /api/livespeed/support
  /// [objectId] - 评论ID
  /// [isSupport] - true=点赞 false=取消
  /// 返回：bool 是否成功
  Future<bool> supportComment({
    required int objectId,
    required bool isSupport,
  }) async {
    final response = await HankNetworkManager().postRequest(
      '/api/livespeed/support',
      data: {
        'object_id': objectId,
        'object_type': 3,
        'is_support': isSupport,
      },
    );

    return response.isSuccess;
  }

  /// 帖子点赞/取消点赞
  /// 接口：POST /api/livespeed/community/like
  /// [postId] - 帖子ID
  /// [type] - 1=点赞 2=取消
  /// 返回：bool 是否成功
  Future<bool> likePost({required int postId, required int type}) async {
    final response = await HankNetworkManager().postRequest(
      '/api/livespeed/community/like',
      data: {
        'post_id': postId,
        'type': type,
      },
    );

    return response.isSuccess;
  }

  /// 删除帖子
  /// 接口：POST /api/livespeed/community/delete
  /// [postId] - 帖子ID
  /// 返回：bool 是否成功
  Future<bool> deletePost({required int postId}) async {
    final response = await HankNetworkManager().postRequest(
      '/api/livespeed/community/delete',
      data: {'id': postId},
    );

    return response.isSuccess;
  }

  /// 关注/取消关注帖子作者
  /// 接口：POST /api/livespeed/imchat/subscribe
  /// [targetId] - 作者用户ID
  /// [type] - 1=关注 2=取消
  /// 返回：bool 是否成功
  Future<bool> toggleFollowAuthor({
    required int targetId,
    required int type,
  }) async {
    final response = await HankNetworkManager().postRequest(
      '/api/livespeed/imchat/subscribe',
      data: {
        'target_id': targetId,
        'type': type,
      },
    );

    return response.isSuccess;
  }
}