/// HankPostData: CommunityPostlistAPIresponseDatabody
/// containstotalcountandPostitem list
class HankPostData {
  /// Datatotalcount
  final int? total;

  /// Postitem list
  final List<HankPostItem> results;

  HankPostData({this.total, this.results = const []});

  /// fromJSONparse
  factory HankPostData.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List?;
    List<HankPostItem> items = [];
    if (list != null) {
      items = list.map((e) => HankPostItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return HankPostData(
      total: json['total'] as int?,
      results: items,
    );
  }
}

/// HankPostItem: singlePostDataitem
/// mappingAPIBack snake_case field is camelCase property
class HankPostItem {
  /// PostuniqueID
  final int? id;

  /// Postcontentcontent
  final String? content;

  /// topictag（commacategoryseparatedstring，maycontains com/ beforesuffix）
  final String? image;

  /// image list
  final List<String>? images;

  /// Likecount
  final int? likeCount;

  /// Commentcount
  final int? commentCount;

  /// createdTimetimestamp（seconds）
  final int? createTime;

  /// authorinfo
  final HankPostAuthor? author;

  /// linkedmatchinfo
  final HankPostMatch? match;

  /// whetheralreadyLike
  final bool? isLike;

  HankPostItem({
    this.id,
    this.content,
    this.image,
    this.images,
    this.likeCount,
    this.commentCount,
    this.createTime,
    this.author,
    this.match,
    this.isLike,
  });

  /// fromJSONparse（snake_case → camelCase）
  factory HankPostItem.fromJson(Map<String, dynamic> json) {
    return HankPostItem(
      id: json['id'] as int?,
      content: json['content'] as String?,
      image: json['image'] as String?,
      images: (json['images'] as List?)?.map((e) => e as String).toList(),
      likeCount: json['like_count'] as int?,
      commentCount: json['comment_count'] as int?,
      createTime: json['create_time'] as int?,
      author: json['author'] != null ? HankPostAuthor.fromJson(json['author']) : null,
      match: json['match'] != null ? HankPostMatch.fromJson(json['match']) : null,
      isLike: json['is_like'] as bool?,
    );
  }
}

/// HankPostAuthor: Postauthorinfo
class HankPostAuthor {
  /// authorID
  final int? id;

  /// author nickname
  final String? name;

  /// whetheralreadyFollow
  final bool? isSubscribe;

  /// authoravatarURL
  final String? avatar;

  /// memberID
  final int? memberId;

  HankPostAuthor({
    this.id,
    this.name,
    this.isSubscribe,
    this.avatar,
    this.memberId,
  });

  /// fromJSONparse
  factory HankPostAuthor.fromJson(Map<String, dynamic> json) {
    return HankPostAuthor(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isSubscribe: json['is_subscribe'] as bool?,
      avatar: json['avatar'] as String?,
      memberId: json['member_id'] as int?,
    );
  }
}

/// HankPostMatch: Postlinkedmatchinfo
class HankPostMatch {
  /// matchtype
  final int? matchType;

  /// matchID
  final int? matchId;

  /// matchID
  final int? competitionId;

  /// SeasonID
  final int? seasonId;

  /// startTimetimestamp（seconds）
  final int? startTime;

  /// statusID
  final int? statusId;

  /// statusname
  final String? statusName;

  /// matchname
  final String? competitionName;

  /// HomeID
  final int? homeTeamId;

  /// Homename
  final String? homeTeamName;

  /// HomeLogo URL
  final String? homeTeamLogo;

  /// AwayID
  final int? awayTeamId;

  /// Awayname
  final String? awayTeamName;

  /// AwayLogo URL
  final String? awayTeamLogo;

  /// Homescore
  final int? homeScore;

  /// Awayscore
  final int? awayScore;

  HankPostMatch({
    this.matchType,
    this.matchId,
    this.competitionId,
    this.seasonId,
    this.startTime,
    this.statusId,
    this.statusName,
    this.competitionName,
    this.homeTeamId,
    this.homeTeamName,
    this.homeTeamLogo,
    this.awayTeamId,
    this.awayTeamName,
    this.awayTeamLogo,
    this.homeScore,
    this.awayScore,
  });

  /// fromJSONparse
  factory HankPostMatch.fromJson(Map<String, dynamic> json) {
    return HankPostMatch(
      matchType: json['match_type'] as int?,
      matchId: json['match_id'] as int?,
      competitionId: json['competition_id'] as int?,
      seasonId: json['season_id'] as int?,
      startTime: json['start_time'] as int?,
      statusId: json['status_id'] as int?,
      statusName: json['status_name'] as String?,
      competitionName: json['competition_name'] as String?,
      homeTeamId: json['home_team_id'] as int?,
      homeTeamName: json['home_team_name'] as String?,
      homeTeamLogo: json['home_team_logo'] as String?,
      awayTeamId: json['away_team_id'] as int?,
      awayTeamName: json['away_team_name'] as String?,
      awayTeamLogo: json['away_team_logo'] as String?,
      homeScore: json['home_score'] as int?,
      awayScore: json['away_score'] as int?,
    );
  }
}
