import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';
import 'api_exception.dart';

class RecipeApi {
  RecipeApi({http.Client? client, Uri? baseUri, this.timeout = const Duration(seconds: 15)})
      : _client = client ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('https://dummyjson.com');

  final http.Client _client;
  final Uri _baseUri;
  final Duration timeout;

  Future<List<Recipe>> fetchRecipes() {
    return _getRecipeList(
      _baseUri.replace(path: '/recipes', queryParameters: {'limit': '0'}),
    );
  }

  Future<List<Recipe>> searchRecipes(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(query, 'query', 'A pesquisa não pode ser vazia');
    }
    return _getRecipeList(
      _baseUri.replace(
        path: '/recipes/search',
        queryParameters: {'q': trimmed, 'limit': '0'},
      ),
    );
  }

  Future<List<Recipe>> _getRecipeList(Uri uri) async {
    final decoded = await _getJson(uri);
    if (decoded is! Map) throw const InvalidResponseException();

    final items = decoded['recipes'];
    if (items is! List) throw const InvalidResponseException();

    final recipes = items.map(Recipe.tryParse).whereType<Recipe>().toList();
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
