import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.recipe, this.compact = false});

  final Recipe recipe;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).favorites;
    return ListenableBuilder(
      listenable: favorites,
      builder: (context, _) {
        final isFavorite = favorites.contains(recipe.id);
        return IconButton(
          tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
          isSelected: isFavorite,
          visualDensity: compact ? VisualDensity.compact : null,
          icon: const Icon(Icons.favorite_border, color: AppColors.ink),
          selectedIcon: const Icon(Icons.favorite, color: AppColors.accent),
          onPressed: () => favorites.toggle(recipe),
        );
      },
    );
  }
}
