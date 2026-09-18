import '../utils/hank_network_manager.dart';
import '../models/hank_post_api_model.dart';
import '../models/hank_comment_model.dart';

/// HankCommunityDetailApiService: CommunityDetailsAPI service
/// wrapPostDetails、Commentlist、CommentPost、Like、Delete、FollowetcAPI
class HankCommunityDetailApiService {
  /// singleton instance
  static final HankCommunityDetailApiService _instance =
      HankCommunityDetailApiService._internal();

  /// factoryconstructor，Backsingleton
  factory HankCommunityDetailApiService() => _instance;

  /// private constructor
  HankCommunityDetailApiService._internal();

  /// requestPostDetails
  /// API：GET /api/livespeed/community/detail
  /// [postId] - PostID
  /// Back：HankPostItem PostDetails
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

  /// requestCommentlist
  /// API：GET /api/livespeed/community/comment/list
  /// [objectId] - PostID
  /// Back：HankCommentData CommentlistData
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

  /// posttableComment/Reply
  /// API：POST /api/livespeed/community/comment/add
  /// [objectId] - PostID
  /// [words] - Commentcontent
  /// [commentId] - ReplywhenalevelCommentID，directlyCommentPostwhennull
  /// Back：HankCommentItem? newCommentData
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

  /// CommentLike/CancelLike
  /// API：POST /api/livespeed/support
  /// [objectId] - CommentID
  /// [isSupport] - true=Like false=Cancel
  /// Back：bool whethersuccess
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

  /// PostLike/CancelLike
  /// API：POST /api/livespeed/community/like
  /// [postId] - PostID
  /// [type] - 1=Like 2=Cancel
  /// Back：bool whethersuccess
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

  /// DeletePost
  /// API：POST /api/livespeed/community/delete
  /// [postId] - PostID
  /// Back：bool whethersuccess
  Future<bool> deletePost({required int postId}) async {
    final response = await HankNetworkManager().postRequest(
      '/api/livespeed/community/delete',
      data: {'id': postId},
    );

    return response.isSuccess;
  }

  /// Follow/CancelFollowPostauthor
  /// API：POST /api/livespeed/imchat/subscribe
  /// [targetId] - authoruseaccountID
  /// [type] - 1=Follow 2=Cancel
  /// Back：bool whethersuccess
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