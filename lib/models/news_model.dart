/// NewsType: newstypeenum
/// feature: darkdepthbigimagestyle | compact: left-rightArticlenews flashstyle
enum NewsType { feature, compact }

/// NewsModel: newsarticlemodel
/// containstitle、image、categorytypetag、source、Time、readingcountetc
class NewsModel {
  /// articleuniqueID
  final String newsId;

  /// displaytype（bigimage/underimage）
  final NewsType type;

  /// articletitle
  final String title;

  /// coverbigimageURL（featurestyleuse）
  final String? coverImageUrl;

  /// abbrevthumbnailimageURL（compactstyleuse）
  final String? thumbnailUrl;

  /// categorytypetagtext
  final String categoryTag;

  /// categorytypetagbackgroundcolor
  final int categoryBgColor;

  /// categorytypetagtextcolor
  final int categoryTextColor;

  /// source/author
  final String source;

  /// PostTimedescription（e.g.：2underwhenbefore）
  final String timeDesc;

  /// readingcountdescription（e.g.：1.80k views）
  final String readCountDesc;

  /// Commentcount
  final int commentCount;

  NewsModel({
    required this.newsId,
    required this.type,
    required this.title,
    this.coverImageUrl,
    this.thumbnailUrl,
    required this.categoryTag,
    this.categoryBgColor = 0xFF7C3AED,
    this.categoryTextColor = 0xFFFFFFFF,
    required this.source,
    required this.timeDesc,
    this.readCountDesc = '',
    this.commentCount = 0,
  });

  /// fromJSONparse
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      newsId: json['newsId'] ?? '',
      type: json['type'] == 'compact' ? NewsType.compact : NewsType.feature,
      title: json['title'] ?? '',
      coverImageUrl: json['coverImageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      categoryTag: json['categoryTag'] ?? '',
      categoryBgColor: json['categoryBgColor'] ?? 0xFF7C3AED,
      categoryTextColor: json['categoryTextColor'] ?? 0xFFFFFFFF,
      source: json['source'] ?? '',
      timeDesc: json['timeDesc'] ?? '',
      readCountDesc: json['readCountDesc'] ?? '',
      commentCount: json['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newsId': newsId,
      'type': type.name,
      'title': title,
      'coverImageUrl': coverImageUrl,
      'thumbnailUrl': thumbnailUrl,
      'categoryTag': categoryTag,
      'categoryBgColor': categoryBgColor,
      'categoryTextColor': categoryTextColor,
      'source': source,
      'timeDesc': timeDesc,
      'readCountDesc': readCountDesc,
      'commentCount': commentCount,
    };
  }
}
