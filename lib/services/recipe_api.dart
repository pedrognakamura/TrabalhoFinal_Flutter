import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';
import 'api_exception.dart';
import 'recipe_translations.dart';

class RecipeApi {
  RecipeApi({
    http.Client? client,
    Uri? baseUri,
    this.timeout = const Duration(seconds: 15),
    this.translations = const RecipeTranslations.empty(),
  })  : _client = client ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('https://dummyjson.com');

  final http.Client _client;
  final Uri _baseUri;
  final Duration timeout;

  /// Traduz as receitas (a API só responde em inglês). Vazio = sem tradução.
  final RecipeTranslations translations;

  Future<List<Recipe>> fetchRecipes() {
    return _getRecipeList(
      _baseUri.replace(path: '/recipes', queryParameters: {'limit': '0'}),
    );
  }

  /// Pesquisa pelo nome da receita, em português ou em inglês.
  ///
  /// O endpoint `/recipes/search` da API só entende o texto original em
  /// inglês, então o filtro é feito aqui sobre a lista já traduzida.
  Future<List<Recipe>> searchRecipes(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(query, 'query', 'A pesquisa não pode ser vazia');
    }
    final all = await fetchRecipes();
    return all.where((recipe) => recipe.matchesQuery(trimmed)).toList();
  }

  Future<List<Recipe>> _getRecipeList(Uri uri) async {
    final decoded = await _getJson(uri);
    if (decoded is! Map) throw const InvalidResponseException();

    final items = decoded['recipes'];
    if (items is! List) throw const InvalidResponseException();

    final recipes = items
        .map(Recipe.tryParse)
        .whereType<Recipe>()
        .map(translations.translate)
        .toList();
    if (items.isNotEmpty && recipes.isEmpty) {
      throw const InvalidResponseException();
    }
    return recipes;
  }

  Future<Object?> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(timeout);
    } on TimeoutException {
      throw const NetworkException(timedOut: true);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on HandshakeException {
      throw const NetworkException();
    }

    if (response.statusCode != 200) {
      throw HttpStatusException(response.statusCode);
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const InvalidResponseException();
    }
  }

  void close() => _client.close();
}
