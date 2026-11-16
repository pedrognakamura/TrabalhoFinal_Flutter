import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../services/api_exception.dart';
import '../services/recipe_api.dart';
import 'load_state.dart';

/// Fonte única de verdade da listagem e da pesquisa.
///
/// Fica acima de todas as telas (criado em `main`), então a consulta atual e
/// os resultados sobrevivem quando o usuário abre os detalhes e volta.
///
/// Regras de concorrência:
/// * A listagem não é recarregada se já estiver carregando ou carregada
///   (a não ser em "tentar novamente").
/// * Repetir a mesma pesquisa enquanto ela carrega é ignorado.
/// * Uma pesquisa nova substitui a anterior: cada uma recebe um número de
///   geração, e respostas de gerações antigas são descartadas.
class RecipesController extends ChangeNotifier {
  RecipesController(this._api);

  final RecipeApi _api;

  LoadState _catalog = const LoadIdle();
  LoadState _search = const LoadIdle();
  String? _activeQuery;
  int _searchGeneration = 0;

  /// Estado da listagem completa.
  LoadState get catalog => _catalog;

  /// Estado da pesquisa atual (`LoadIdle` quando não há pesquisa).
  LoadState get search => _search;

  /// Termo pesquisado (já aparado), ou `null` quando o usuário está na listagem.
  String? get activeQuery => _activeQuery;

  bool get isSearching => _activeQuery != null;

  /// O que a tela de receitas deve mostrar agora.
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

  /// Inicia uma pesquisa. Retorna `false` (sem fazer nada) quando a consulta,
  /// depois de aparada, fica vazia.
  bool searchByName(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return false;
    if (query == _activeQuery && _search is LoadInProgress) return true;

    _runSearch(query);
    return true;
  }

  /// Repete a consulta atual: a pesquisa, se houver uma, ou a listagem.
  Future<void> retry() async {
    final query = _activeQuery;
    if (query != null) {
      await _runSearch(query);
    } else {
      await loadCatalog(force: true);
    }
  }

  /// Sai da pesquisa e volta para a listagem. Respostas pendentes são ignoradas.
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
    if (generation != _searchGeneration) return; // Resposta antiga: descarta.

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
