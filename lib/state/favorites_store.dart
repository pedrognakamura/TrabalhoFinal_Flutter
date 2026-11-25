import 'package:flutter/foundation.dart';

import '../models/recipe.dart';

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

  bool toggle(Recipe recipe) {
    if (contains(recipe.id)) {
      remove(recipe.id);
      return false;
    }
    add(recipe);
    return true;
  }
}
