import 'package:flutter/widgets.dart';

import 'favorites_store.dart';
import 'recipes_controller.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.recipes,
    required this.favorites,
    required super.child,
  });

  final RecipesController recipes;
  final FavoritesStore favorites;

  static AppScope of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore de widgets');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      recipes != oldWidget.recipes || favorites != oldWidget.favorites;
}
