import 'package:flutter/widgets.dart';

import 'favorites_store.dart';
import 'recipes_controller.dart';

/// Disponibiliza os objetos de estado do app para toda a árvore de widgets.
///
/// Os objetos são criados uma única vez em `main` e nunca trocados, então
/// este widget não precisa notificar dependentes. Para reagir a mudanças, as
/// telas usam `ListenableBuilder` diretamente sobre cada objeto.
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
