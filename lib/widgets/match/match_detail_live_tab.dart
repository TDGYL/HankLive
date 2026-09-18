import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_process_model.dart';

/// MatchDetailLiveTab: Articlematch eventsTabcomponent
/// displaymatchmatchitemTimeline，useAPI /api/livespeed/football/match/process  incidents Data
/// UIrestore football_match_details.html Articlematch eventslayoutmatch：
///   left event icon dot + rightwhitecolorcardcontainer（titlerow + descriptiontext + extrainfo）
///   eacheacheventusewhitecolorbackgroundroundedcardcirclestartto
/// filtertagrootbased oneventtypedynamicgeneratecomplete，selectedwhenfilterdisplaymaps toevent
class MatchDetailLiveTab extends StatefulWidget {
  /// match event list（fromAPIincidents）
  final List<HankIncidentItem> incidents;

  MatchDetailLiveTab({
    required this.incidents,
    Key? key,
  }) : super(key: key);

  @override
  State<MatchDetailLiveTab> createState() => _MatchDetailLiveTabState();
}

class _MatchDetailLiveTabState extends State<MatchDetailLiveTab> {
  /// randomgeneratecompletetempdepth（10-30depth）
  late final int _temperature;

  /// whenbeforeselectedfiltertype（null = All）
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // randomgeneratecomplete10-30depthtempdepth
    _temperature = 10 + Random().nextInt(21);
  }

  /// getfiltertaglist（rootbased onincidentsinentityactualstoreineventtypedynamicgeneratecomplete）
  /// Backorderorder：All、Goals、redYellow Cards、substitution（onlycontainshasDatatype）
  /// unknowneventnotstatsinstats
  List<String> _buildFilterLabels() {
    final labels = <String>['All'];

    // filterremoveunknownevent
    final knownIncidents = widget.incidents.where((incident) {
      return incident.custTypeName != 'unknownevent';
    }).toList();

    // statseventtype
    bool hasGoal = false;
    bool hasCard = false;
    bool hasSub = false;

    for (final incident in knownIncidents) {
      final type = incident.type ?? 0;
      // Goalstype：1=Goals, 8=PENGoals, 17=own goalgoal, 29=PENGoals
      if (type == 1 || type == 8 || type == 17 || type == 29) {
        hasGoal = true;
      }
      // redYellow Cardstype：3=Yellow Cards, 4=Red Cards, 15=twoyellow tored
      if (type == 3 || type == 4 || type == 15) {
        hasCard = true;
      }
      // substitutiontype：9=substitution
      if (type == 9) {
        hasSub = true;
      }
    }

    if (hasGoal) labels.add('Goals');
    if (hasCard) labels.add('redYellow Cards');
    if (hasSub) labels.add('substitution');

    return labels;
  }

  /// rootbased onwhenbeforefilteritemitemfiltereventlist（filterremoveunknownevent）
  List<HankIncidentItem> _getFilteredIncidents() {
    // firstfilterremoveunknownevent
    final knownIncidents = widget.incidents.where((incident) {
      return incident.custTypeName != 'unknownevent';
    }).toList();

    if (_selectedFilter == null || _selectedFilter == 'All') {
      return knownIncidents;
    }

    return knownIncidents.where((incident) {
      final type = incident.type ?? 0;
      switch (_selectedFilter) {
        case 'Goals':
          return type == 1 || type == 8 || type == 17 || type == 29;
        case 'redYellow Cards':
          return type == 3 || type == 4 || type == 15;
        case 'substitution':
          return type == 9;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.incidents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            'Nomatch eventsData',
            style: TextStyle(fontSize: 14, color: AppColors.slate500),
          ),
        ),
      );
    }

    final filterLabels = _buildFilterLabels();
    final filteredIncidents = _getFilteredIncidents();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterPills(filterLabels),
          const SizedBox(height: 16),
          _buildTimeline(filteredIncidents),
        ],
      ),
    );
  }

  /// matchstatusbanner（weather + animationLive）
  /// tempdepthrandomgeneratecomplete（10-30depth）
  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F8B5CF6),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.thermostat, size: 14, color: AppColors.amber500),
              const SizedBox(width: 8),
              Text(
                'weather: $_temperature°C sunny · matchvenueexcellent',
                style: const TextStyle(fontSize: 12, color: AppColors.slate700),
              ),
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  /// eventfiltertag（dynamicgeneratecomplete，rootbased oneventstats）
  Widget _buildFilterPills(List<String> labels) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('filter:', style: TextStyle(fontSize: 11, color: AppColors.slate500)),
        ...labels.map((label) {
          final isActive = (_selectedFilter ?? 'All') == label;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = label == 'All' ? null : label;
              });
            },
            child: _buildPill(label, isActive),
          );
        }),
      ],
    );
  }

  /// filtertag
  Widget _buildPill(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.violet100
            : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive
              ? AppColors.violet300
              : AppColors.violet200.withOpacity(0.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isActive ? AppColors.violet700 : AppColors.slate500,
        ),
      ),
    );
  }

  /// Timelineeventflow
  /// leftverticalline + eacheachevent：leftdoticon + rightwhitecolorcard
  Widget _buildTimeline(List<HankIncidentItem> incidents) {
    if (incidents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'thistypeNoevent',
            style: TextStyle(fontSize: 13, color: AppColors.slate500),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // leftverticalline
        Positioned(
          left: 10,
          top: 8,
          bottom: 8,
          child: Container(
            width: 2,
            color: AppColors.violet200,
          ),
        ),
        // eventlist
        Column(
          children: incidents.map((incident) {
            return _buildEventItem(incident);
          }).toList(),
        ),
      ],
    );
  }

  /// singleeacheventitem
  /// left：eventicondot（inverticallineup）
  /// right：whitecolorroundedcard，containstitlerow（Time + teamname/score）+ description
  Widget _buildEventItem(HankIncidentItem incident) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left：eventicondot
          _buildEventIcon(incident),
          const SizedBox(width: 12),
          // right：whitecoloreventcard
          Expanded(
            child: _buildEventCard(incident),
          ),
        ],
      ),
    );
  }

  /// eventicondot（left）
  Widget _buildEventIcon(HankIncidentItem incident) {
    final iconColor = incident.iconColor;
    final isGoal = incident.type == 1 || incident.type == 8 || incident.type == 17;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isGoal ? iconColor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor,
          width: 2,
        ),
        boxShadow: isGoal
            ? [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        incident.iconData,
        size: 10,
        color: isGoal ? Colors.white : iconColor,
      ),
    );
  }

  /// eventcard（rightwhitecolorcontainer）
  Widget _buildEventCard(HankIncidentItem incident) {
    final iconColor = incident.iconColor;
    final isGoal = incident.type == 1 || incident.type == 8 || incident.type == 17;

    // buildtitle：Time + eventtypename
    final titleText = "${incident.time ?? 0}' - ${incident.custTypeName}";

    // buildrightinfo：Teamname or score
    String rightText;
    if (incident.homeScore != null && incident.awayScore != null) {
      rightText = '${incident.homeScore} - ${incident.awayScore}';
    } else {
      rightText = incident.position == 1 ? 'Home' : 'Away';
    }

    // builddescriptiontext
    final playerName = incident.custPlayerName;
    final typeName = incident.custTypeName;
    String description;
    if (incident.type == 9) {
      // substitution：appearancePlayer → entermatchPlayer
      description = 'substitutioncalloverall：${incident.outPlayerName ?? ''} replace ${incident.inPlayerName ?? ''} onmatch。';
    } else if (playerName.isNotEmpty) {
      description = '$playerName - $typeName';
    } else {
      description = typeName;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGoal
              ? iconColor.withOpacity(0.4)
              : AppColors.violet200.withOpacity(0.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F8B5CF6),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // titlerow：left Time+typename | right Team/score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  titleText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 4,
                ),
                child: Text(
                  rightText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: incident.position == 1
                        ? AppColors.rose500
                        : AppColors.blue500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // descriptiontext
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.slate700,
            ),
          ),
          // score changerow（e.g.has）
          if (incident.homeScore != null && incident.awayScore != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.violet100),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.sports_soccer, size: 10, color: iconColor),
                  const SizedBox(width: 4),
                  Text(
                    'score: ${incident.homeScore} - ${incident.awayScore}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
