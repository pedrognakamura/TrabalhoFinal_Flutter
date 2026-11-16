import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trabalho_final/models/recipe.dart';
import 'package:trabalho_final/services/recipe_api.dart';
import 'package:trabalho_final/state/favorites_store.dart';
import 'package:trabalho_final/state/load_state.dart';
import 'package:trabalho_final/state/recipes_controller.dart';

http.Response _recipes(List<String> names) => http.Response.bytes(
      utf8.encode(jsonEncode({
        'recipes': [
          for (final (i, name) in names.indexed) {'id': i + 1, 'name': name},
        ],
      })),
      200,
    );

void main() {
  group('FavoritesStore', () {
    test('não duplica e remove pelo id', () {
      final store = FavoritesStore();
      const pizza = Recipe(id: 1, name: 'Pizza');

      store.add(pizza);
      store.add(const Recipe(id: 1, name: 'Pizza (cópia)'));
      expect(store.count, 1);

      expect(store.toggle(pizza), isFalse);
      expect(store.isEmpty, isTrue);
    });
  });

  group('RecipesController', () {
    test('não repete o carregamento da listagem em andamento', () async {
      var calls = 0;
      final controller = RecipesController(RecipeApi(
        client: MockClient((_) async {
          calls++;
          return _recipes(['Pizza']);
        }),
      ));

      await Future.wait([controller.loadCatalog(), controller.loadCatalog()]);
      await controller.loadCatalog();

      expect(calls, 1);
      expect(controller.catalog, isA<LoadSuccess>());
    });

    test('recusa pesquisa vazia', () {
      final controller = RecipesController(RecipeApi(
        client: MockClient((_) async => _recipes([])),
      ));

      expect(controller.searchByName('   '), isFalse);
      expect(controller.isSearching, isFalse);
    });

    test('descarta a resposta de uma pesquisa antiga', () async {
      final slow = Completer<http.Response>();
      final controller = RecipesController(RecipeApi(
        client: MockClient((request) {
          final q = request.url.queryParameters['q'];
          return q == 'lenta' ? slow.future : Future.value(_recipes(['Rápida']));
        }),
      ));

      controller.searchByName('lenta');
      controller.searchByName('rápida');
      await pumpEventQueue();
      slow.complete(_recipes(['Lenta']));
      await pumpEventQueue();

      expect(controller.activeQuery, 'rápida');
      final state = controller.search as LoadSuccess;
      expect(state.recipes.single.name, 'Rápida');
    });

    test('limpar a pesquisa volta para a listagem', () async {
      final controller = RecipesController(RecipeApi(
        client: MockClient((_) async => _recipes(['Pizza'])),
      ));
      await controller.loadCatalog();

      controller.searchByName('pizza');
      await pumpEventQueue();
      controller.clearSearch();

      expect(controller.isSearching, isFalse);
      expect(controller.visible, same(controller.catalog));
    });
  });
}
