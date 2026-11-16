import 'package:flutter/material.dart';

import 'screens/root_shell.dart';
import 'services/recipe_api.dart';
import 'state/app_scope.dart';
import 'state/favorites_store.dart';
import 'state/recipes_controller.dart';
import 'theme/app_theme.dart';

void main() {
  // O carregamento começa aqui, uma única vez, na abertura do app (RF01),
  // e não a cada reconstrução de tela.
  final recipes = RecipesController(RecipeApi())..loadCatalog();
  final favorites = FavoritesStore();

  runApp(SaboreApp(recipes: recipes, favorites: favorites));
}

class SaboreApp extends StatelessWidget {
  const SaboreApp({super.key, required this.recipes, required this.favorites});

  final RecipesController recipes;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      recipes: recipes,
      favorites: favorites,
      child: MaterialApp(
        title: 'Saborê',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const RootShell(),
      ),
    );
  }
}
