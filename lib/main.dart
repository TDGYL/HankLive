import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/common/app_bottom_nav_bar.dart';
import 'pages/match/match_page.dart';
import 'pages/league/hank_league_page.dart';
import 'pages/news/news_page.dart';
import 'pages/community/community_page.dart';
import 'pages/profile/profile_page.dart';
import 'utils/hank_auth_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Settingsstatus bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  // inituseaccountLoginstatus（restore cachedTokenanduseaccountinfo）
  await HankAuthManager().init();
  runApp(const HankLiveApp());
}

/// HankLiveApp: violetFootball App rootcomponent
/// containsallmatchhomethemeconfigandbottomTabnav container
class HankLiveApp extends StatelessWidget {
  const HankLiveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'violetFootball',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScaffold(),
    );
  }
}

/// MainScaffold: homefieldframework
/// manage bottom5eachTabpagetoggle（match/match/news/Community/Profile）
class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  /// whenbeforeselectedTabindex
  int _currentIndex = 0;

  /// bottomTabitemconfig
  final List<AppTabItem> _tabItems = [
    AppTabItem(
      icon: Icons.emoji_events,
      activeColor: AppColors.violet700,
      label: 'match',
    ),
    AppTabItem(
      icon: Icons.sports_soccer,
      activeColor: AppColors.violet700,
      label: 'data',
    ),
    AppTabItem(
      icon: Icons.newspaper,
      activeColor: AppColors.violet700,
      label: 'news',
    ),
    AppTabItem(
      icon: Icons.chat_bubble_outline,
      activeColor: AppColors.violet700,
      label: 'Community',
    ),
    AppTabItem(
      icon: Icons.person_outline,
      activeColor: AppColors.violet700,
      label: 'Profile',
    ),
  ];

  /// pagelist（lazy load：onlyinitinituse，buildon demandcreated）
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const MatchPage(),
      const HankLeaguePage(),
      const NewsPage(),
      const CommunityPage(),
      const ProfilePage(),
    ];
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        items: _tabItems,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}
