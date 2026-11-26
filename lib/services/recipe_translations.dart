import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/recipe.dart';

/// Tradução para português das receitas da DummyJSON, que só vêm em inglês.
///
/// Nome, ingredientes e modo de preparo ficam no arquivo
/// `assets/translations/receitas_pt.json`, indexados pelo `id` da receita.
/// Culinária e tipo de refeição são traduzidos pelas tabelas abaixo.
/// Receitas sem tradução continuam no idioma original.
class RecipeTranslations {
  const RecipeTranslations(this._byId);

  const RecipeTranslations.empty() : _byId = const {};

  static const assetPath = 'assets/translations/receitas_pt.json';

  final Map<int, _Entry> _byId;

  int get length => _byId.length;

  static Future<RecipeTranslations> load({AssetBundle? bundle}) async {
    try {
      final text = await (bundle ?? rootBundle).loadString(assetPath);
      return RecipeTranslations.fromJson(jsonDecode(text));
    } catch (error) {
      debugPrint('Não foi possível carregar as traduções: $error');
      return const RecipeTranslations.empty();
    }
  }

  factory RecipeTranslations.fromJson(Object? json) {
    if (json is! Map) return const RecipeTranslations.empty();
    final entries = <int, _Entry>{};
    for (final MapEntry(:key, :value) in json.entries) {
      final id = int.tryParse('$key');
      final entry = _Entry.tryParse(value);
      if (id != null && entry != null) entries[id] = entry;
    }
    return RecipeTranslations(entries);
  }

  Recipe translate(Recipe recipe) {
    final entry = _byId[recipe.id];

    // Só troca as listas quando o tamanho confere, para nunca misturar passos
    // de uma versão da receita com a tradução de outra.
    final ingredients = entry != null &&
            entry.ingredients.length == recipe.ingredients.length
        ? entry.ingredients
        : recipe.ingredients;
    final instructions = entry != null &&
            entry.instructions.length == recipe.instructions.length
        ? entry.instructions
        : recipe.instructions;

    return recipe.copyWith(
      name: entry?.name ?? recipe.name,
      originalName: entry != null && entry.name != recipe.name ? recipe.name : null,
      ingredients: ingredients,
      instructions: instructions,
      cuisine: _cuisines[recipe.cuisine] ?? recipe.cuisine,
      originalCuisine: _cuisines.containsKey(recipe.cuisine) ? recipe.cuisine : null,
      mealType: [for (final meal in recipe.mealType) _mealTypes[meal] ?? meal],
    );
  }

  static const _cuisines = {
    'American': 'Americana',
    'Asian': 'Asiática',
    'Brazilian': 'Brasileira',
    'Cocktail': 'Coquetel',
    'Greek': 'Grega',
    'Hawaiian': 'Havaiana',
    'Indian': 'Indiana',
    'Italian': 'Italiana',
    'Japanese': 'Japonesa',
    'Korean': 'Coreana',
    'Lebanese': 'Libanesa',
    'Mediterranean': 'Mediterrânea',
    'Mexican': 'Mexicana',
    'Moroccan': 'Marroquina',
    'Pakistani': 'Paquistanesa',
    'Russian': 'Russa',
    'Smoothie': 'Smoothie',
    'Spanish': 'Espanhola',
    'Thai': 'Tailandesa',
    'Turkish': 'Turca',
    'Vietnamese': 'Vietnamita',
  };

  static const _mealTypes = {
    'Appetizer': 'Entrada',
    'Beverage': 'Bebida',
    'Breakfast': 'Café da manhã',
    'Dessert': 'Sobremesa',
    'Dinner': 'Jantar',
    'Lunch': 'Almoço',
    'Side Dish': 'Acompanhamento',
    'Snack': 'Lanche',
    'Snacks': 'Lanche',
  };
}

class _Entry {
  const _Entry({
    required this.name,
    required this.ingredients,
    required this.instructions,
  });

  final String name;
  final List<String> ingredients;
  final List<String> instructions;

  static _Entry? tryParse(Object? json) {
    if (json is! Map) return null;
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) return null;
    return _Entry(
      name: name.trim(),
      ingredients: _strings(json['ingredients']),
      instructions: _strings(json['instructions']),
    );
  }

  static List<String> _strings(Object? value) =>
      value is List ? List.unmodifiable(value.whereType<String>()) : const [];
}
