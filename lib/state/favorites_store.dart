import 'package:flutter/foundation.dart';

import '../models/recipe.dart';

/// Favoritos da sessão, guardados em memória.
///
/// É a única fonte de verdade entre as telas: a lista, os detalhes e a tela
/// de favoritos leem e alteram esta mesma instância. As receitas são
/// indexadas pelo `id`, o que impede duplicatas. A ordem é a de inclusão.
class FavoritesStore extends ChangeNotifier {
  final Map<int, Recipe> _byId = {};

  List<Recipe> get items => List.unmodifiable(_byId.values);

  int get count => _byId.length;

  bool get isEmpty => _byId.isEmpty;

  bool contains(int recipeId) => _byId.containsKey(recipeId);

  void add(Recipe recipe) {
    if (_byId.containsKey(recipe.id)) return;
    _byId[recipe.id] = recipe;
    notifyListeners();
  }

  void remove(int recipeId) {
    if (_byId.remove(recipeId) != null) notifyListeners();
  }

  /// Adiciona ou remove. Retorna `true` se a receita ficou favoritada.
  bool toggle(Recipe recipe) {
    if (contains(recipe.id)) {
      remove(recipe.id);
      return false;
    }
    add(recipe);
    return true;
  }
}
