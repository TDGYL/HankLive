import 'dart:math';
import '../models/hank_match_detail_model.dart';

/// HankMatchDetailService: matchDetailsMockDataservice
/// provideArticlematch events、starterLineup、technicalstats、OddsmodesimulateData
/// technicalstatsinmatchhomenavrateDatauseuselocalrandomgeneratecomplete
class HankMatchDetailService {
  /// singleton instance
  static final HankMatchDetailService _instance = HankMatchDetailService._internal();

  /// factoryconstructor，Backsingleton
  factory HankMatchDetailService() {
    return _instance;
  }

  /// private constructor
  HankMatchDetailService._internal();

  /// randomcountgeneratecompleteindicator（usematchhomenavrateData）
  final Random _random = Random();

  /// getArticlematch event list
  /// BackbyTimefallorderarrangeeventlist
  List<HankMatchEvent> getMatchEvents() {
    return [
      HankMatchEvent(
        id: 'evt_1',
        type: HankMatchEventType.substitution,
        minute: 65,
        title: "65' - substitutioncalloverall",
        description: 'Arsenaldooutpersonplayercalloverall：19-Trossard replace 11-MartinelliinnerLi onmatch，strengthenleftroadAttackswithdefensedefendrunanimation。',
        teamName: 'Arsenal',
      ),
      HankMatchEvent(
        id: 'evt_2',
        type: HankMatchEventType.goal,
        minute: 58,
        title: "58' - GOAL! Goalsgotcategory!",
        description: 'brilliantworld！MartinelliinnerLileftroadinnertoggleafterinbannedareabeforealongstartfootpowerful shot，goaloutcurvelinedirecthanggoalgoaldeadcorner！defendgoalkeeper savesnotand！',
        teamName: 'Arsenal',
        scoreChange: 'Arsenal 2 - 1 Man City',
        extraInfo: 'assists: Odegaard · expiryexpectGoalsvalue xG: 0.08',
      ),
      HankMatchEvent(
        id: 'evt_3',
        type: HankMatchEventType.penaltyGoal,
        minute: 51,
        title: "51' - PENgoal",
        description: 'HaalanddefendtakeshomepenaltyPEN，calmpassgoalkeeperwillgoalpassingoalgoalrightdowncorner，Man CityDscore！',
        teamName: 'Man City',
        scoreChange: 'Arsenal 1 - 1 Man City',
      ),
      HankMatchEvent(
        id: 'evt_4',
        type: HankMatchEventType.yellowCard,
        minute: 42,
        title: "42' - Yellow Cardswarning",
        description: 'RodriinhalftimepullpullSakacardblockdefensedefendcounter，homeRefereedirectionitsshowYellow Cards。',
        teamName: 'Man City',
      ),
      HankMatchEvent(
        id: 'evt_5',
        type: HankMatchEventType.goal,
        minute: 24,
        title: "24' - firstopenminutein",
        description: 'Sakacardbannedarearightreceiveteamfandirectpass，bucklepassdefensedefendPlayerafterleftfootshotnearcornergothand！Arsenal took the lead！',
        teamName: 'Arsenal',
        scoreChange: 'Arsenal 1 - 0 Man City',
      ),
    ];
  }

  /// getHomestarterformation andPlayer
  HankMatchLineupFormation getHomeLineup() {
    return HankMatchLineupFormation(
      teamName: 'Arsenal',
      formation: '4-3-3',
      teamColor: 0xFFEF4444,
      playerRows: [
        // goalkeeper
        [
          HankMatchPlayer(name: 'pullAsia', number: '22', position: 'goalkeeper', rating: '7.6'),
        ],
        // halftime
        [
          HankMatchPlayer(name: 'Rice', number: '41', position: 'halftime', rating: '8.0'),
          HankMatchPlayer(name: 'Odegaard', number: '8', position: 'beforewaist', rating: '8.5', isStar: true),
          HankMatchPlayer(name: 'Havertz', number: '29', position: 'halftime', rating: '7.3'),
        ],
        // before
        [
          HankMatchPlayer(name: 'MartinelliinnerLi', number: '11', position: 'left', rating: '8.3', hasGoal: true),
          HankMatchPlayer(name: 'Jesus', number: '9', position: 'striker', rating: '7.2'),
          HankMatchPlayer(name: 'Sakacard', number: '7', position: 'right', rating: '8.6', isStar: true, hasGoal: true),
        ],
      ],
    );
  }

  /// getAwaystarterformation andPlayer
  HankMatchLineupFormation getAwayLineup() {
    return HankMatchLineupFormation(
      teamName: 'Man City',
      formation: '4-2-3-1',
      teamColor: 0xFF3B82F6,
      playerRows: [
        // before
        [
          HankMatchPlayer(name: 'Haalanddefend', number: '9', position: 'striker', rating: '8.2', isStar: true, hasGoal: true),
        ],
        // attackhalftime
        [
          HankMatchPlayer(name: 'GepullSmith', number: '10', position: 'left winger', rating: '7.1'),
          HankMatchPlayer(name: 'defendlayoutMartinezinner', number: '17', position: 'beforewaist', rating: '7.8', isStar: true),
          HankMatchPlayer(name: 'Foden', number: '47', position: 'rightborder', rating: '7.4'),
        ],
        // afterwaist
        [
          HankMatchPlayer(name: 'Rodri', number: '16', position: 'afterwaist', rating: '6.9', hasYellowCard: true),
          HankMatchPlayer(name: 'Kovacic', number: '8', position: 'afterwaist', rating: '7.0'),
        ],
        // goalkeeper
        [
          HankMatchPlayer(name: 'Ederson', number: '31', position: 'goalkeeper', rating: '6.8'),
        ],
      ],
    );
  }

  /// getbenchPlayerlist
  List<HankMatchBenchPlayer> getBenchPlayers() {
    return [
      HankMatchBenchPlayer(name: '19-Trossard', teamName: 'Arsenal', isPlayed: true, playedMinute: "65'"),
      HankMatchBenchPlayer(name: '19-Alvarez', teamName: 'Man City'),
      HankMatchBenchPlayer(name: '10-·Rodri', teamName: 'Arsenal'),
      HankMatchBenchPlayer(name: '25-Akanji', teamName: 'Man City'),
    ];
  }

  /// gettechnicalstatsData
  /// matchhomenavratebarstatusimageDatauseuselocalrandomgeneratecomplete
  List<int> getMomentumData() {
    // randomgeneratecomplete9eachbarstatusimageheight（20-100）
    return List.generate(9, (_) => 20 + _random.nextInt(81));
  }

  /// gettechnicalstatsmatchmatchitem
  List<HankMatchStatItem> getMatchStats() {
    return [
      HankMatchStatItem(label: 'Possession', homeValue: '54%', awayValue: '46%', homePercent: 54, awayPercent: 46),
      HankMatchStatItem(label: 'Shotstimecount', homeValue: '14', awayValue: '9', homePercent: 61, awayPercent: 39),
      HankMatchStatItem(label: 'On Targettimecount', homeValue: '6', awayValue: '3', homePercent: 66, awayPercent: 34),
      HankMatchStatItem(label: 'DangerousAttacks', homeValue: '48', awayValue: '35', homePercent: 58, awayPercent: 42),
      HankMatchStatItem(label: 'Corners', homeValue: '7', awayValue: '4', homePercent: 63, awayPercent: 37),
      HankMatchStatItem(label: 'Passessuccessrate', homeValue: '88%', awayValue: '85%', homePercent: 51, awayPercent: 49),
      HankMatchStatItem(label: 'Yellow Cards', homeValue: '1', awayValue: '2', homePercent: 33, awayPercent: 67),
    ];
  }

  /// getAHhandicapgoaloddscountData
  List<HankMatchOddsRow> getAsianHandicapOdds() {
    return [
      HankMatchOddsRow(
        stage: 'ishandicap',
        homeOdds: '1.85',
        middleOdds: 'homehandicap 0.25',
        awayOdds: '2.05',
        homeTrend: 'down',
        awayTrend: 'up',
      ),
      HankMatchOddsRow(
        stage: 'Opening',
        homeOdds: '2.10',
        middleOdds: 'Dhandhandicap',
        awayOdds: '1.80',
      ),
    ];
  }

  /// get1X2oddscountData
  List<HankMatchOddsRow> getEuropeanOdds() {
    return [
      HankMatchOddsRow(
        stage: 'Live',
        homeOdds: '1.45',
        middleOdds: '4.20',
        awayOdds: '6.50',
      ),
      HankMatchOddsRow(
        stage: 'Opening',
        homeOdds: '2.35',
        middleOdds: '3.40',
        awayOdds: '2.80',
      ),
    ];
  }

  /// getO/UgoalData
  Map<String, String> getOverUnderOdds() {
    return {
      'line': '3.5',
      'over': '1.92',
      'under': '1.88',
      'currentGoals': '3',
    };
  }
}
