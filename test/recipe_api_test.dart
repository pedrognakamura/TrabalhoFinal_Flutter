import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trabalho_final/services/api_exception.dart';
import 'package:trabalho_final/services/recipe_api.dart';

RecipeApi _apiReturning(http.Response response, {void Function(Uri)? onRequest}) {
  return RecipeApi(
    client: MockClient((request) async {
      onRequest?.call(request.url);
      return response;
    }),
  );
}

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  test('fetchRecipes chama /recipes e lê a lista', () async {
    Uri? called;
    final api = _apiReturning(
      _json({
        'recipes': [
          {'id': 1, 'name': 'Pizza'},
          {'id': 2, 'name': 'Pão de queijo'},
        ],
      }),
      onRequest: (uri) => called = uri,
    );

    final recipes = await api.fetchRecipes();

    expect(called!.path, '/recipes');
    expect(recipes.map((r) => r.name), ['Pizza', 'Pão de queijo']);
  });

  test('searchRecipes apara a consulta e usa /recipes/search', () async {
    Uri? called;
    final api = _apiReturning(_json({'recipes': []}), onRequest: (uri) => called = uri);

    final recipes = await api.searchRecipes('  pizza  ');

    expect(recipes, isEmpty);
    expect(called!.path, '/recipes/search');
    expect(called!.queryParameters['q'], 'pizza');
  });

  test('searchRecipes recusa consulta vazia sem chamar a rede', () {
    var calls = 0;
    final api = _apiReturning(_json({'recipes': []}), onRequest: (_) => calls++);

    expect(() => api.searchRecipes('   '), throwsArgumentError);
    expect(calls, 0);
  });

  test('status diferente de 200 vira HttpStatusException', () {
    final api = _apiReturning(http.Response('erro', 503));
    expect(
      api.fetchRecipes(),
      throwsA(isA<HttpStatusException>().having((e) => e.statusCode, 'statusCode', 503)),
    );
  });

  test('corpo que não é JSON vira InvalidResponseException', () {
    final api = _apiReturning(http.Response('<html>oops</html>', 200));
    expect(api.fetchRecipes(), throwsA(isA<InvalidResponseException>()));
  });

  test('JSON sem a lista "recipes" vira InvalidResponseException', () {
    final api = _apiReturning(_json({'products': []}));
    expect(api.fetchRecipes(), throwsA(isA<InvalidResponseException>()));
  });

  test('lista só com itens ilegíveis vira InvalidResponseException', () {
    final api = _apiReturning(_json({
      'recipes': [
        {'name': 'sem id'},
      ],
    }));
    expect(api.fetchRecipes(), throwsA(isA<InvalidResponseException>()));
  });

  test('falha de conexão vira NetworkException', () {
    final api = RecipeApi(
      client: MockClient((_) => throw const SocketException('offline')),
    );
    expect(api.fetchRecipes(), throwsA(isA<NetworkException>()));
  });
}
