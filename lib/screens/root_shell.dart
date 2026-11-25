import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import 'explore_screen.dart';
import 'favorites_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final _exploreNavigator = GlobalKey<NavigatorState>();
  int _index = 0;

  void _select(int index) {
    if (index == 0 && _index == 0) {
      _exploreNavigator.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() => _index = index);
  }

  void _handleBack(bool didPop, Object? result) {
    if (didPop) return;
    if (_index != 0) {
      setState(() => _index = 0);
      return;
    }
    final explore = _exploreNavigator.currentState;
    if (explore != null && explore.canPop()) {
      explore.maybePop();
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).favorites;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleBack,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            Navigator(
              key: _exploreNavigator,
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => const ExploreScreen(),
              ),
            ),
            FavoritesScreen(onExplore: () => _select(0)),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: ListenableBuilder(
            listenable: favorites,
            builder: (context, _) => NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.search),
                  label: 'Explorar',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: !favorites.isEmpty,
                    backgroundColor: AppColors.accent,
                    label: Text('${favorites.count}'),
                    child: const Icon(Icons.favorite_border),
                  ),
                  selectedIcon: const Icon(Icons.favorite, color: AppColors.accent),
                  label: 'Favoritos',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
