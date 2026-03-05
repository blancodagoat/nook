import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nook/core/constants/app_colors.dart';
import 'package:nook/core/theme/app_theme.dart';
import 'package:nook/features/dashboard/dashboard_screen.dart';
import 'package:nook/features/history/history_screen.dart';
import 'package:nook/features/summary/summary_screen.dart';
import 'package:nook/shared/widgets/app_bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/summary',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SummaryScreen(),
          ),
        ),
      ],
    ),
  ],
);

class LedgerApp extends StatelessWidget {
  const LedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}

class MainShell extends StatefulWidget {

  const MainShell({required this.child, super.key});
  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          widget.child,
          AppBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              switch (index) {
                case 0:
                  context.go('/');
                case 1:
                  context.go('/history');
                case 2:
                  context.go('/summary');
              }
            },
          ),
        ],
      ),
    );
  }
}
