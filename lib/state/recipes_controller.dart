import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../services/api_exception.dart';
import '../services/recipe_api.dart';
import 'load_state.dart';

class RecipesController extends ChangeNotifier {
  RecipesController(this._api);

  final RecipeApi _api;

  LoadState _catalog = const LoadIdle();
  LoadState _search = const LoadIdle();
  String? _activeQuery;
  int _searchGeneration = 0;

  LoadState get catalog => _catalog;

  LoadState get search => _search;

  String? get activeQuery => _activeQuery;

  bool get isSearching => _activeQuery != null;

  LoadState get visible => isSearching ? _search : _catalog;

  bool get isBusy => visible is LoadInProgress;

  Future<void> loadCatalog({bool force = false}) async {
    if (_catalog is LoadInProgress) return;
    if (_catalog is LoadSuccess && !force) return;

    _catalog = const LoadInProgress();
    notifyListeners();
    _catalog = await _run(_api.fetchRecipes);
    notifyListeners();
  }

  bool searchByName(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return false;
    if (query == _activeQuery && _search is LoadInProgress) return true;

    _runSearch(query);
    return true;
  }

  Future<void> retry() async {
    final query = _activeQuery;
    if (query != null) {
      await _runSearch(query);
    } else {
      await loadCatalog(force: true);
    }
  }

  void clearSearch() {
    _searchGeneration++;
    _activeQuery = null;
    _search = const LoadIdle();
    notifyListeners();
  }

  Future<void> _runSearch(String query) async {
    final generation = ++_searchGeneration;
    _activeQuery = query;
    _search = const LoadInProgress();
    notifyListeners();

    final result = await _run(() => _api.searchRecipes(query));
    if (generation != _searchGeneration) return;

    _search = result;
    notifyListeners();
  }

  Future<LoadState> _run(Future<List<Recipe>> Function() request) async {
    try {
      return LoadSuccess(await request());
    } on ApiException catch (error) {
      return LoadFailure(error);
    } catch (error, stack) {
      debugPrint('Erro inesperado ao buscar receitas: $error\n$stack');
      return const LoadFailure(InvalidResponseException());
    }
  }
}
