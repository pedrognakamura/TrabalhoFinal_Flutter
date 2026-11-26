import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trabalho_final/main.dart';
import 'package:trabalho_final/services/recipe_api.dart';
import 'package:trabalho_final/state/favorites_store.dart';
import 'package:trabalho_final/state/recipes_controller.dart';

const _pizza = {
  'id': 1,
  'name': 'Classic Margherita Pizza',
  'ingredients': ['Pizza dough'],
  'instructions': ['Bake it'],
  'prepTimeMinutes': 20,
  'difficulty': 'Easy',
  'rating': 4.6,
};

http.Response _body(List<Object> recipes) =>
    http.Response.bytes(utf8.encode(jsonEncode({'recipes': recipes})), 200);

Future<FavoritesStore> _startApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final api = RecipeApi(
    client: MockClient((request) async => _body([_pizza])),
  );
  final recipes = RecipesController(api)..loadCatalog();
  final favorites = FavoritesStore();

  await tester.pumpWidget(SaboreApp(recipes: recipes, favorites: favorites));
  await tester.pumpAndSettle();
  return favorites;
}

void main() {
  testWidgets('Explorar → detalhes → favoritar → aba Favoritos', (tester) async {
    final favorites = await _startApp(tester);

    expect(find.text('Saborê'), findsOneWidget);
    expect(find.text('Receitas disponíveis'), findsOneWidget);
    expect(find.text('4,6 / 5'), findsOneWidget);

    await tester.tap(find.text('Classic Margherita Pizza'));
    await tester.pumpAndSettle();
    expect(find.text('Pizza dough'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.textContaining('Cozimento: não informado'), findsOneWidget);
    expect(find.text('Não salva'), findsOneWidget);

    await tester.tap(find.byTooltip('Adicionar aos favoritos'));
    await tester.pump();
    expect(favorites.contains(1), isTrue);
    expect(find.text('Salva'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Receitas salvas nesta sessão.'), findsOneWidget);
  });

  testWidgets('Pesquisa: vazia, com resultado e sem resultado', (tester) async {
    await _startApp(tester);

    await tester.tap(find.text('Buscar receitas'));
    await tester.pumpAndSettle();
    expect(find.text('Qual receita você procura?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Pesquisar'));
    await tester.pumpAndSettle();
    expect(find.text('Digite um nome para pesquisar.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  pizza ');
    await tester.tap(find.text('Pesquisar'));
    await tester.pumpAndSettle();
    expect(find.text('Resultados para “pizza”'), findsOneWidget);
    expect(find.text('Limpar pesquisa'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzz987');
    await tester.tap(find.text('Pesquisar'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum resultado'), findsOneWidget);

    await tester.ensureVisible(find.text('Ver todas as receitas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver todas as receitas'));
    await tester.pumpAndSettle();
    expect(find.text('Receitas disponíveis'), findsOneWidget);
  });

  testWidgets('Favoritos vazio leva de volta para Explorar', (tester) async {
    await _startApp(tester);

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum favorito'), findsOneWidget);

    await tester.tap(find.text('Explorar receitas'));
    await tester.pumpAndSettle();
    expect(find.text('Receitas disponíveis'), findsOneWidget);
  });
}
