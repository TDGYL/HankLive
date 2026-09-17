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
  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  // 初始化用户登录状态（恢复本地缓存的Token和用户信息）
  await HankAuthManager().init();
  runApp(const HankLiveApp());
}

/// HankLiveApp: 紫极足球 App 根组件
/// 包含全局主题配置和底部Tab导航容器
class HankLiveApp extends StatelessWidget {
  const HankLiveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '紫极足球',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScaffold(),
    );
  }
}

/// MainScaffold: 主框架
/// 管理底部5个Tab页面切换（比赛/赛事/资讯/社区/我的）
class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  /// 当前选中的Tab索引
  int _currentIndex = 0;

  /// 底部Tab项配置
  final List<AppTabItem> _tabItems = [
    AppTabItem(
      icon: Icons.emoji_events,
      activeColor: AppColors.violet700,
      label: '比赛',
    ),
    AppTabItem(
      icon: Icons.sports_soccer,
      activeColor: AppColors.violet700,
      label: '赛事',
    ),
    AppTabItem(
      icon: Icons.newspaper,
      activeColor: AppColors.violet700,
      label: '资讯',
    ),
    AppTabItem(
      icon: Icons.chat_bubble_outline,
      activeColor: AppColors.violet700,
      label: '社区',
    ),
    AppTabItem(
      icon: Icons.person_outline,
      activeColor: AppColors.violet700,
      label: '我的',
    ),
  ];

  /// 页面列表（懒加载：仅初始化引用，build时按需创建）
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
