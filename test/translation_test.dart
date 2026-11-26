import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trabalho_final/models/recipe.dart';
import 'package:trabalho_final/services/recipe_api.dart';
import 'package:trabalho_final/services/recipe_translations.dart';
import 'package:trabalho_final/utils/text_search.dart';

const _pizzaJson = {
  'id': 1,
  'name': 'Classic Margherita Pizza',
  'ingredients': ['Pizza dough', 'Olive oil'],
  'instructions': ['Bake it'],
  'cuisine': 'Italian',
  'mealType': ['Dinner'],
};

const _translations = {
  '1': {
    'name': 'Pizza Margherita Clássica',
    'ingredients': ['Massa de pizza', 'Azeite de oliva'],
    'instructions': ['Asse.'],
  },
};

RecipeApi _api({Object? translations = _translations}) => RecipeApi(
      translations: RecipeTranslations.fromJson(translations),
      client: MockClient((_) async => http.Response.bytes(
            utf8.encode(jsonEncode({'recipes': [_pizzaJson]})),
            200,
          )),
    );

void main() {
  group('normalizeForSearch', () {
    test('ignora maiúsculas e acentos', () {
      expect(normalizeForSearch('  Muçarela PÃO Café '), 'mucarela pao cafe');
    });

    test('matchesAllWords exige todas as palavras', () {
      expect(matchesAllWords('Pizza Margherita Clássica', 'classica pizza'), isTrue);
      expect(matchesAllWords('Pizza Margherita Clássica', 'pizza bolo'), isFalse);
      expect(matchesAllWords('Pizza', '   '), isFalse);
    });
  });

  group('RecipeTranslations', () {
    test('traduz nome, ingredientes, passos, culinária e refeição', () async {
      final recipe = (await _api().fetchRecipes()).single;

      expect(recipe.name, 'Pizza Margherita Clássica');
      expect(recipe.originalName, 'Classic Margherita Pizza');
      expect(recipe.ingredients, ['Massa de pizza', 'Azeite de oliva']);
      expect(recipe.instructions, ['Asse.']);
      expect(recipe.cuisine, 'Italiana');
      expect(recipe.mealType, ['Jantar']);
    });

    test('mantém o original quando a receita não tem tradução', () async {
      final recipe = (await _api(translations: {}).fetchRecipes()).single;

      expect(recipe.name, 'Classic Margherita Pizza');
      expect(recipe.ingredients, ['Pizza dough', 'Olive oil']);
      expect(recipe.cuisine, 'Italiana');
    });

    test('não troca a lista quando o tamanho não confere', () async {
      final recipe = (await _api(translations: {
        '1': {
          'name': 'Pizza Margherita Clássica',
          'ingredients': ['Só um item'],
          'instructions': ['Asse.'],
        },
      }).fetchRecipes())
          .single;

      expect(recipe.name, 'Pizza Margherita Clássica');
      expect(recipe.ingredients, ['Pizza dough', 'Olive oil']);
      expect(recipe.instructions, ['Asse.']);
    });

    test('a pesquisa acha pelo nome em português, sem acento e em inglês', () async {
      final api = _api();

      for (final query in ['clássica', 'CLASSICA', 'margherita pizza', 'classic', 'italiana']) {
        expect(await api.searchRecipes(query), hasLength(1), reason: query);
      }
      expect(await api.searchRecipes('bolo'), isEmpty);
    });
  });

  group('arquivo de traduções do app', () {
    final file = File(RecipeTranslations.assetPath);

    test('cobre as 50 receitas, sem texto vazio nem restos de inglês óbvios', () {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      expect(json.length, 50);

      final translations = RecipeTranslations.fromJson(json);
      expect(translations.length, 50);

      for (final MapEntry(:key, :value) in json.entries) {
        final entry = value as Map<String, dynamic>;
        expect(entry['name'], isNotEmpty, reason: 'receita $key');
        expect(entry['ingredients'], isNotEmpty, reason: 'receita $key');
        expect(entry['instructions'], isNotEmpty, reason: 'receita $key');
        for (final text in [...entry['ingredients'], ...entry['instructions']]) {
          expect(text, isNot(isEmpty), reason: 'receita $key');
          expect(text, isNot(contains('Preheat')), reason: 'receita $key');
        }
      }
    });

    testWidgets('o asset declarado no pubspec carrega pelo rootBundle', (tester) async {
      final translations = await tester.runAsync(RecipeTranslations.load);
      expect(translations!.length, 50);
    });

    test('traduz uma receita completa e mantém o número de itens', () {
      final translations = RecipeTranslations.fromJson(
        jsonDecode(file.readAsStringSync()),
      );
      const original = Recipe(
        id: 1,
        name: 'Classic Margherita Pizza',
        ingredients: ['a', 'b', 'c', 'd', 'e', 'f'],
        instructions: ['1', '2', '3', '4', '5', '6'],
        cuisine: 'Italian',
      );

      final translated = translations.translate(original);

      expect(translated.name, 'Pizza Margherita Clássica');
      expect(translated.ingredients.first, 'Massa de pizza');
      expect(translated.instructions.first, startsWith('Preaqueça'));
    });
  });
}
