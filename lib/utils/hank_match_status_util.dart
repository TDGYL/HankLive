/// HankMatchStatusUtil: 比赛状态工具类
/// 将接口返回的中文/长状态名统一转换为常规英文缩写展示
/// 足球常用缩写：NS未开赛 / 1H上半场 / HT中场 / 2H下半场 / FT完场 / PEN点球 / CANC取消 / POST推迟
class HankMatchStatusUtil {
  /// 状态缩写映射表 - 中文状态名到英文缩写
  static const Map<String, String> _statusMap = {
    '未开赛': 'NS',
    '未开始': 'NS',
    '赛前': 'NS',
    '上半场': '1H',
    '中场': 'HT',
    '中场休息': 'HT',
    '下半场': '2H',
    '进行中': 'LIVE',
    '完场': 'FT',
    '已完场': 'FT',
    '结束': 'FT',
    '加时': 'ET',
    '点球': 'PEN',
    '点球大战': 'PEN',
    '取消': 'CANC',
    '推迟': 'POST',
    '中断': 'INT',
    '待定': 'TBD',
    '腰斩': 'ABD',
  };

  /// 获取状态缩写
  /// 优先按状态名映射为缩写；已是英文则原样返回
  /// [statusName] - 接口返回的状态名
  /// [statusId] - 状态ID，状态名为空时兜底映射
  /// 返回：状态缩写字符串
  static String abbreviate(String? statusName, {int? statusId}) {
    final name = statusName?.trim() ?? '';

    if (_statusMap.containsKey(name)) {
      return _statusMap[name]!;
    }

    if (name.isEmpty && statusId != null) {
      switch (statusId) {
        case 0:
        case 1:
          return 'NS';
        case 2:
        case 3:
          return 'LIVE';
        case 8:
          return 'FT';
      }
    }

    return name;
  }

  /// 是否为进行中的比赛
  /// [statusId] - 状态ID
  /// 返回：true表示进行中
  static bool isLive(int? statusId) {
    return statusId == 2 || statusId == 3 || statusId == 4;
  }

  /// 是否为已完场
  /// [statusId] - 状态ID
  /// 返回：true表示已完场
  static bool isFinished(int? statusId) {
    return statusId == 8 || statusId == 9;
  }

  /// 是否为未开赛
  /// [statusId] - 状态ID
  /// 返回：true表示未开赛
  static bool isUpcoming(int? statusId) {
    return statusId == 0 || statusId == 1;
  }
}
