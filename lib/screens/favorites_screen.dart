import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import '../widgets/status_views.dart';
import 'navigation.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.onExplore});

  final VoidCallback onExplore;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleNavigation {
  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).favorites;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BrandHeader(),
            Expanded(
              child: ListenableBuilder(
                listenable: favorites,
                builder: (context, _) {
                  final items = favorites.items;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    children: items.isEmpty
                        ? [
                            StatusMessage(
                              icon: const Icon(Icons.favorite_border, size: 44, color: AppColors.ink),
                              title: 'Nenhum favorito',
                              message: 'Marque uma receita como favorita para encontrá-la aqui.',
                              actionLabel: 'Explorar receitas',
                              onAction: widget.onExplore,
                            ),
                          ]
                        : [
                            const SectionTitle(
                              'Favoritos',
                              subtitle: 'Receitas salvas nesta sessão.',
                              large: true,
                            ),
                            const SizedBox(height: 24),
                            for (final recipe in items)
                              RecipeCard(
                                key: ValueKey(recipe.id),
                                recipe: recipe,
                                onTap: () => openDetail(recipe),
                              ),
                            const SizedBox(height: 32),
                            const Text(
                              'Toque no coração para remover.',
                              style: TextStyle(fontSize: 13, color: AppColors.muted),
                            ),
                          ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
