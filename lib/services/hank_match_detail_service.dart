import 'dart:math';
import '../models/hank_match_detail_model.dart';

/// HankMatchDetailService: 比赛详情Mock数据服务
/// 提供图文赛况、首发阵容、技术统计、指数分析的模拟数据
/// 技术统计中的比赛主导率数据使用本地随机生成
class HankMatchDetailService {
  /// 单例实例
  static final HankMatchDetailService _instance = HankMatchDetailService._internal();

  /// 工厂构造，返回单例
  factory HankMatchDetailService() {
    return _instance;
  }

  /// 私有构造
  HankMatchDetailService._internal();

  /// 随机数生成器（用于比赛主导率数据）
  final Random _random = Random();

  /// 获取图文赛况事件列表
  /// 返回按时间倒序排列的事件列表
  List<HankMatchEvent> getMatchEvents() {
    return [
      HankMatchEvent(
        id: 'evt_1',
        type: HankMatchEventType.substitution,
        minute: 65,
        title: "65' - 换人调整",
        description: '阿森纳做出人员调整：19-特罗萨德 替换 11-马丁内利 登场，加强左路进攻与防守跑动。',
        teamName: '阿森纳',
      ),
      HankMatchEvent(
        id: 'evt_2',
        type: HankMatchEventType.goal,
        minute: 58,
        title: "58' - GOAL! 进球得分!",
        description: '精彩的世界波！马丁内利左路内切后在禁区前沿起脚劲射，皮球划出弧线直挂球门死角！守门员扑救不及！',
        teamName: '阿森纳',
        scoreChange: '阿森纳 2 - 1 曼城',
        extraInfo: '助攻: 厄德高 · 期望进球值 xG: 0.08',
      ),
      HankMatchEvent(
        id: 'evt_3',
        type: HankMatchEventType.penaltyGoal,
        minute: 51,
        title: "51' - 点球破门",
        description: '哈兰德操刀主罚点球，冷静骗过门将将球送入球门右下角，曼城扳平比分！',
        teamName: '曼城',
        scoreChange: '阿森纳 1 - 1 曼城',
      ),
      HankMatchEvent(
        id: 'evt_4',
        type: HankMatchEventType.yellowCard,
        minute: 42,
        title: "42' - 黄牌警告",
        description: '罗德里在中场拉拽萨卡阻止防守反击，主裁判向其出示黄牌。',
        teamName: '曼城',
      ),
      HankMatchEvent(
        id: 'evt_5',
        type: HankMatchEventType.goal,
        minute: 24,
        title: "24' - 首开纪录",
        description: '萨卡禁区右侧接队友直塞，扣过防守球员后左脚推射近角得手！阿森纳取得领先！',
        teamName: '阿森纳',
        scoreChange: '阿森纳 1 - 0 曼城',
      ),
    ];
  }

  /// 获取主队首发阵型与球员
  HankMatchLineupFormation getHomeLineup() {
    return HankMatchLineupFormation(
      teamName: '阿森纳',
      formation: '4-3-3',
      teamColor: 0xFFEF4444,
      playerRows: [
        // 门将
        [
          HankMatchPlayer(name: '拉亚', number: '22', position: '门将', rating: '7.6'),
        ],
        // 中场
        [
          HankMatchPlayer(name: '赖斯', number: '41', position: '中场', rating: '8.0'),
          HankMatchPlayer(name: '厄德高', number: '8', position: '前腰', rating: '8.5', isStar: true),
          HankMatchPlayer(name: '哈弗茨', number: '29', position: '中场', rating: '7.3'),
        ],
        // 前锋
        [
          HankMatchPlayer(name: '马丁内利', number: '11', position: '左锋', rating: '8.3', hasGoal: true),
          HankMatchPlayer(name: '热苏斯', number: '9', position: '中锋', rating: '7.2'),
          HankMatchPlayer(name: '萨卡', number: '7', position: '右锋', rating: '8.6', isStar: true, hasGoal: true),
        ],
      ],
    );
  }

  /// 获取客队首发阵型与球员
  HankMatchLineupFormation getAwayLineup() {
    return HankMatchLineupFormation(
      teamName: '曼城',
      formation: '4-2-3-1',
      teamColor: 0xFF3B82F6,
      playerRows: [
        // 前锋
        [
          HankMatchPlayer(name: '哈兰德', number: '9', position: '中锋', rating: '8.2', isStar: true, hasGoal: true),
        ],
        // 攻击中场
        [
          HankMatchPlayer(name: '格拉利什', number: '10', position: '左边锋', rating: '7.1'),
          HankMatchPlayer(name: '德布劳内', number: '17', position: '前腰', rating: '7.8', isStar: true),
          HankMatchPlayer(name: '福登', number: '47', position: '右边锋', rating: '7.4'),
        ],
        // 后腰
        [
          HankMatchPlayer(name: '罗德里', number: '16', position: '后腰', rating: '6.9', hasYellowCard: true),
          HankMatchPlayer(name: '科瓦契奇', number: '8', position: '后腰', rating: '7.0'),
        ],
        // 门将
        [
          HankMatchPlayer(name: '埃德森', number: '31', position: '门将', rating: '6.8'),
        ],
      ],
    );
  }

  /// 获取替补席球员列表
  List<HankMatchBenchPlayer> getBenchPlayers() {
    return [
      HankMatchBenchPlayer(name: '19-特罗萨德', teamName: '阿森纳', isPlayed: true, playedMinute: "65'"),
      HankMatchBenchPlayer(name: '19-阿尔瓦雷斯', teamName: '曼城'),
      HankMatchBenchPlayer(name: '10-史密斯·罗', teamName: '阿森纳'),
      HankMatchBenchPlayer(name: '25-阿坎吉', teamName: '曼城'),
    ];
  }

  /// 获取技术统计数据
  /// 比赛主导率的柱状图数据使用本地随机生成
  List<int> getMomentumData() {
    // 随机生成9个柱状图高度（20-100）
    return List.generate(9, (_) => 20 + _random.nextInt(81));
  }

  /// 获取技术统计对比项
  List<HankMatchStatItem> getMatchStats() {
    return [
      HankMatchStatItem(label: '控球率', homeValue: '54%', awayValue: '46%', homePercent: 54, awayPercent: 46),
      HankMatchStatItem(label: '射门次数', homeValue: '14', awayValue: '9', homePercent: 61, awayPercent: 39),
      HankMatchStatItem(label: '射正次数', homeValue: '6', awayValue: '3', homePercent: 66, awayPercent: 34),
      HankMatchStatItem(label: '危险进攻', homeValue: '48', awayValue: '35', homePercent: 58, awayPercent: 42),
      HankMatchStatItem(label: '角球', homeValue: '7', awayValue: '4', homePercent: 63, awayPercent: 37),
      HankMatchStatItem(label: '传球成功率', homeValue: '88%', awayValue: '85%', homePercent: 51, awayPercent: 49),
      HankMatchStatItem(label: '黄牌', homeValue: '1', awayValue: '2', homePercent: 33, awayPercent: 67),
    ];
  }

  /// 获取亚盘让球指数数据
  List<HankMatchOddsRow> getAsianHandicapOdds() {
    return [
      HankMatchOddsRow(
        stage: '即盘',
        homeOdds: '1.85',
        middleOdds: '主让 0.25',
        awayOdds: '2.05',
        homeTrend: 'down',
        awayTrend: 'up',
      ),
      HankMatchOddsRow(
        stage: '初盘',
        homeOdds: '2.10',
        middleOdds: '平手盘',
        awayOdds: '1.80',
      ),
    ];
  }

  /// 获取欧赔指数数据
  List<HankMatchOddsRow> getEuropeanOdds() {
    return [
      HankMatchOddsRow(
        stage: '即时',
        homeOdds: '1.45',
        middleOdds: '4.20',
        awayOdds: '6.50',
      ),
      HankMatchOddsRow(
        stage: '初盘',
        homeOdds: '2.35',
        middleOdds: '3.40',
        awayOdds: '2.80',
      ),
    ];
  }

  /// 获取大小球数据
  Map<String, String> getOverUnderOdds() {
    return {
      'line': '3.5',
      'over': '1.92',
      'under': '1.88',
      'currentGoals': '3',
    };
  }
}
