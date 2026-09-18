/// HankMatchStatusUtil: matchstatusutilitytype
/// convert APIBackChinese/convert long status names to standard English abbreviations
/// Footballcommon abbreviations：NSnot started / 1HupHT / HThalftime / 2HdownHT / FTFT / PENPEN / CANCCancel / POSTdelayed
class HankMatchStatusUtil {
  /// statusabbrevwritemapping table - ChinesestatusnametoEnglish abbreviation
  static const Map<String, String> _statusMap = {
    'not started': 'NS',
    'Not Started': 'NS',
    'matchbefore': 'NS',
    'upHT': '1H',
    'halftime': 'HT',
    'halftimebreak': 'HT',
    'downHT': '2H',
    'In Progress': 'LIVE',
    'FT': 'FT',
    'alreadyFT': 'FT',
    'ended': 'FT',
    'overtime': 'ET',
    'PEN': 'PEN',
    'PENderby': 'PEN',
    'Cancel': 'CANC',
    'delayed': 'POST',
    'Interrupted': 'INT',
    'TBD': 'TBD',
    'abandoned': 'ABD',
  };

  /// get status abbreviation
  /// preferbystatusnamemappingisabbrevwrite；alreadyisEnglishthenas-isBack
  /// [statusName] - APIBackstatusname
  /// [statusId] - statusID，statusnameisemptywhenfallbackmapping
  /// Back：statusabbrevwritestring
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

  /// whetherisIn Progressmatch
  /// [statusId] - statusID
  /// Back：truemeansIn Progress
  static bool isLive(int? statusId) {
    return statusId == 2 || statusId == 3 || statusId == 4;
  }

  /// is finishedFT
  /// [statusId] - statusID
  /// Back：truemeansalreadyFT
  static bool isFinished(int? statusId) {
    return statusId == 8 || statusId == 9;
  }

  /// whetherisnot started
  /// [statusId] - statusID
  /// Back：truemeans not started
  static bool isUpcoming(int? statusId) {
    return statusId == 0 || statusId == 1;
  }
}
