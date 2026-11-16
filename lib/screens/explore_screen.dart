import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../state/load_state.dart';
import '../state/recipes_controller.dart';
import '../widgets/recipe_card.dart';
import '../widgets/status_views.dart';
import 'navigation.dart';

/// RF01 e RF02: identidade do app, acesso à pesquisa e listagem de receitas.
///
/// O carregamento é iniciado uma única vez em `main()`; esta tela só mostra
/// o estado atual do [RecipesController].
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleNavigation {
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  /// Abre a tela de pesquisa. Com texto, já pesquisa; sem texto, abre o
  /// formulário vazio para o usuário digitar lá.
  void _openSearch() {
    final recipes = AppScope.of(context).recipes;
    final query = _field.text.trim();
    if (query.isEmpty) {
      recipes.clearSearch();
    } else {
      recipes.searchByName(query);
    }
    FocusScope.of(context).unfocus();
    openSearch();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = AppScope.of(context).recipes;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BrandHeader(),
            Expanded(
              child: ListenableBuilder(
                listenable: recipes,
                builder: (context, _) => _buildBody(recipes),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(RecipesController recipes) {
    const padding = EdgeInsets.fromLTRB(20, 24, 20, 24);

    return switch (recipes.catalog) {
      LoadIdle() || LoadInProgress() => ListView(
          padding: padding,
          children: const [
            SectionTitle('Explorar receitas', large: true),
            SizedBox(height: 28),
            LoadingSkeleton(message: 'Carregando receitas…', showSearchBar: true),
          ],
        ),
      LoadFailure(:final error) => ListView(
          padding: padding,
          children: [
            ErrorMessage(
              title: 'Não foi possível carregar as receitas.',
              error: error,
              onRetry: () => recipes.loadCatalog(force: true),
            ),
          ],
        ),
      LoadSuccess(recipes: final list) => ListView.builder(
          key: const PageStorageKey('explore'),
          padding: padding,
          itemCount: list.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _header(isEmpty: list.isEmpty, onReload: recipes.retry);
            final recipe = list[index - 1];
            return RecipeCard(
              key: ValueKey(recipe.id),
              recipe: recipe,
              onTap: () => openDetail(recipe),
            );
          },
        ),
    };
  }

  Widget _header({required bool isEmpty, required VoidCallback onReload}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Receitas', subtitle: 'Pesquise uma receita pelo nome.', large: true),
        const SizedBox(height: 22),
        TextField(
          controller: _field,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _openSearch(),
          decoration: const InputDecoration(
            hintText: 'Buscar pelo nome',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _openSearch, child: const Text('Buscar receitas')),
        const SizedBox(height: 32),
        if (isEmpty)
          StatusMessage(
            icon: const Icon(Icons.menu_book_outlined, size: 40),
            title: 'Nenhuma receita disponível',
            message: 'O servidor não enviou receitas desta vez.',
            actionLabel: 'Tentar novamente',
            onAction: onReload,
          )
        else ...[
          const SectionTitle(
            'Receitas disponíveis',
            subtitle: 'Selecione uma receita para ver o preparo.',
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
