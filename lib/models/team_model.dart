/// TeamModel: 球队信息模型
/// 存储球队的ID、名称、简称、队色、Logo等基础信息
class TeamModel {
  /// 球队唯一ID
  final String teamId;

  /// 球队中文全称
  final String teamName;

  /// 球队英文缩写（如 ARS / CHE）
  final String teamShort;

  /// 队徽图片URL（可空，使用首字母占位）
  final String? logoUrl;

  /// 队主色（用于首字母占位背景）
  final int primaryColor;

  /// 队文字颜色（用于首字母占位文字）
  final int textColor;

  TeamModel({
    required this.teamId,
    required this.teamName,
    required this.teamShort,
    this.logoUrl,
    this.primaryColor = 0xFFF3E8FF,
    this.textColor = 0xFF7C3AED,
  });

  /// 从JSON解析
  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      teamId: json['teamId'] ?? '',
      teamName: json['teamName'] ?? '',
      teamShort: json['teamShort'] ?? '',
      logoUrl: json['logoUrl'],
      primaryColor: json['primaryColor'] ?? 0xFFF3E8FF,
      textColor: json['textColor'] ?? 0xFF7C3AED,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'teamShort': teamShort,
      'logoUrl': logoUrl,
      'primaryColor': primaryColor,
      'textColor': textColor,
    };
  }
}
