import 'package:flutter_test/flutter_test.dart';
import 'package:trabalho_final/models/recipe.dart';

void main() {
  group('Recipe.tryParse', () {
    test('lê uma receita completa', () {
      final recipe = Recipe.tryParse({
        'id': 1,
        'name': 'Classic Margherita Pizza',
        'ingredients': ['Pizza dough', 'Tomato sauce'],
        'instructions': ['Preheat', 'Bake'],
        'image': 'https://cdn.dummyjson.com/recipe-images/1.webp',
        'prepTimeMinutes': 20,
        'cookTimeMinutes': 15,
        'servings': 4,
        'rating': 4.6,
        'mealType': ['Dinner'],
      })!;

      expect(recipe.id, 1);
      expect(recipe.ingredients, ['Pizza dough', 'Tomato sauce']);
      expect(recipe.instructions, ['Preheat', 'Bake']);
      expect(recipe.totalTimeMinutes, 35);
      expect(recipe.servings, 4);
      expect(recipe.rating, 4.6);
      expect(recipe.mealType, ['Dinner']);
    });

    test('rejeita item sem id válido', () {
      expect(Recipe.tryParse({'name': 'Sem id'}), isNull);
      expect(Recipe.tryParse({'id': 'abc'}), isNull);
      expect(Recipe.tryParse('não é objeto'), isNull);
    });

    test('trata campos ausentes sem trocar por zero', () {
      final recipe = Recipe.tryParse({'id': 7, 'prepTimeMinutes': 10})!;

      expect(recipe.name, Recipe.fallbackName);
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
      expect(recipe.image, isNull);
      expect(recipe.cookTimeMinutes, isNull);
      expect(recipe.totalTimeMinutes, isNull);
      expect(recipe.servings, isNull);
      expect(recipe.rating, isNull);
    });

    test('aceita rating int, mealType String e tempo em double inteiro', () {
      final recipe = Recipe.tryParse({
        'id': 2,
        'rating': 5,
        'mealType': 'Lunch',
        'prepTimeMinutes': 15.0,
        'cookTimeMinutes': '5',
        'servings': 0,
      })!;

      expect(recipe.rating, 5);
      expect(recipe.mealType, ['Lunch']);
      expect(recipe.totalTimeMinutes, 20);
      expect(recipe.servings, isNull, reason: '0 porções não é utilizável');
    });

    test('ignora itens inválidos nas listas e imagem que não é URL', () {
      final recipe = Recipe.tryParse({
        'id': 3,
        'ingredients': ['Salt', null, '  ', 42, ' Pepper '],
        'image': 'not a url',
      })!;

      expect(recipe.ingredients, ['Salt', 'Pepper']);
      expect(recipe.image, isNull);
    });
  });
}
