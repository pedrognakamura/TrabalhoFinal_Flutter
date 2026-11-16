import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/favorite_button.dart';
import '../widgets/recipe_image.dart';

/// RF04: detalhes da receita selecionada.
///
/// Decisão: a tela reaproveita o objeto [Recipe] que veio na listagem ou na
/// pesquisa, em vez de chamar `/recipes/{id}`. As respostas de `/recipes` e
/// `/recipes/search` já trazem a receita completa (ingredientes, instruções,
/// tempos etc.), então uma segunda requisição só traria os mesmos dados,
/// com mais espera e mais um ponto de falha.
class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final rating = recipe.rating;
    final meta = [
      ?recipe.cuisine,
      if (recipe.difficulty case final difficulty?) formatDifficulty(difficulty),
      if (rating != null) formatRating(rating),
    ].join('  •  ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receita'),
        actions: [FavoriteButton(recipe: recipe), const SizedBox(width: 8)],
      ),
      body: Scrollbar(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            32 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: RecipeImage(url: recipe.image, iconSize: 64),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              recipe.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1.25,
              ),
            ),
            if (meta.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(meta, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
            const SizedBox(height: 20),
            _StatTiles(recipe: recipe),
            const SizedBox(height: 14),
            _TimesAndMeals(recipe: recipe),
            const SizedBox(height: 28),
            const _Heading('Ingredientes'),
            if (recipe.ingredients.isEmpty)
              const _Missing('Ingredientes não informados para esta receita.')
            else
              for (final ingredient in recipe.ingredients) _Bullet(ingredient),
            const SizedBox(height: 28),
            const _Heading('Modo de preparo'),
            if (recipe.instructions.isEmpty)
              const _Missing('Instruções não informadas para esta receita.')
            else
              for (final (index, step) in recipe.instructions.indexed)
                _Step(number: index + 1, text: step),
          ],
        ),
      ),
    );
  }
}

/// Blocos: tempo total, porções (se utilizável) e situação nos favoritos.
class _StatTiles extends StatelessWidget {
  const _StatTiles({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).favorites;
    final total = recipe.totalTimeMinutes;
    final servings = recipe.servings;

    return ListenableBuilder(
      listenable: favorites,
      builder: (context, _) {
        final saved = favorites.contains(recipe.id);
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Tile(
                  value: total == null ? '—' : formatMinutes(total),
                  label: total == null ? 'tempo total não informado' : 'tempo total',
                ),
              ),
              if (servings != null) ...[
                const SizedBox(width: 10),
                Expanded(child: _Tile(value: '$servings', label: 'porções')),
              ],
              const SizedBox(width: 10),
              Expanded(
                child: _Tile(
                  value: saved ? 'Salva' : 'Não salva',
                  label: 'nos favoritos',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.green),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}

/// Tempos separados (ausente aparece como "não informado", nunca 0),
/// calorias e tipos de refeição.
class _TimesAndMeals extends StatelessWidget {
  const _TimesAndMeals({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5);
    final calories = recipe.caloriesPerServing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preparo: ${formatOptionalMinutes(recipe.prepTimeMinutes)}  •  '
          'Cozimento: ${formatOptionalMinutes(recipe.cookTimeMinutes)}',
          style: style,
        ),
        if (calories != null) Text('Calorias por porção: $calories kcal', style: style),
        if (recipe.mealType.isNotEmpty)
          Text('Refeição: ${recipe.mealType.join(', ')}', style: style),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7, right: 12),
            child: Icon(Icons.circle, size: 6, color: AppColors.green),
          ),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.35))),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppColors.green,
            child: Text(
              '$number',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Missing extends StatelessWidget {
  const _Missing(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.muted),
    );
  }
}
