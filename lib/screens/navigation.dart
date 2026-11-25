import 'package:flutter/material.dart';

import '../models/recipe.dart';
import 'recipe_detail_screen.dart';
import 'search_screen.dart';

mixin SingleNavigation<T extends StatefulWidget> on State<T> {
  bool _navigating = false;

  Future<void> pushOnce(Widget Function() builder, {bool rootNavigator = false}) async {
    if (_navigating) return;
    _navigating = true;
    try {
      await Navigator.of(context, rootNavigator: rootNavigator)
          .push(MaterialPageRoute<void>(builder: (_) => builder()));
    } finally {
      _navigating = false;
    }
  }

  Future<void> openDetail(Recipe recipe) =>
      pushOnce(() => RecipeDetailScreen(recipe: recipe), rootNavigator: true);

  Future<void> openSearch() => pushOnce(() => const SearchScreen());
}
