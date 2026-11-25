import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../state/load_state.dart';
import '../state/recipes_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import '../widgets/status_views.dart';
import 'navigation.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleNavigation {
  late final RecipesController _recipes;
  late final TextEditingController _field;
  final _focus = FocusNode();
  String? _fieldError;

  @override
  void initState() {
    super.initState();
    _recipes = AppScope.of(context).recipes;
    _field = TextEditingController(text: _recipes.activeQuery ?? '');
    if (_recipes.activeQuery == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _busy => _recipes.search is LoadInProgress;

  void _submit() {
    if (_busy) return;

    final query = _field.text.trim();
    if (!_recipes.searchByName(query)) {
      _field.clear();
      setState(() => _fieldError = 'Digite um nome para pesquisar.');
      _focus.requestFocus();
      return;
    }
    _field.text = query;
    setState(() => _fieldError = null);
    _focus.unfocus();
  }

  void _clear() {
    _field.clear();
    setState(() => _fieldError = null);
    _recipes.clearSearch();
    _focus.requestFocus();
  }

  void _changeSearch() {
    _field.selection = TextSelection(baseOffset: 0, extentOffset: _field.text.length);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar receitas'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _recipes,
        builder: (context, _) => ListView(
          key: PageStorageKey('search:${_recipes.activeQuery}'),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: _buildContent(),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    final query = _recipes.activeQuery;
    final state = _recipes.search;

    if (query == null) {
      return [
        const SectionTitle('Qual receita você procura?'),
        const SizedBox(height: 20),
        ..._form(),
        const SizedBox(height: 32),
        const Text(
          'Você pode buscar por parte do nome da receita.',
          style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.4),
        ),
      ];
    }

    return switch (state) {
      LoadSuccess(:final recipes) when recipes.isEmpty => [
          _searchField(),
          StatusMessage(
            icon: const Icon(Icons.search, size: 28, color: AppColors.muted),
            title: 'Nenhum resultado',
            message: 'Não encontramos receitas para esse nome. Tente outro termo.',
            actionLabel: 'Alterar pesquisa',
            onAction: _changeSearch,
            secondaryLabel: 'Ver todas as receitas',
            onSecondary: () => Navigator.of(context).pop(),
          ),
        ],
      LoadSuccess(:final recipes) => [
          ..._form(),
          const SizedBox(height: 28),
          SectionTitle(
            'Resultados para “$query”',
            subtitle: 'Toque na receita para ver o preparo.',
          ),
          const SizedBox(height: 16),
          for (final recipe in recipes)
            RecipeCard(
              key: ValueKey(recipe.id),
              recipe: recipe,
              onTap: () => openDetail(recipe),
            ),
          const SizedBox(height: 20),
          OutlinedButton(onPressed: _clear, child: const Text('Limpar pesquisa')),
        ],
      LoadFailure(:final error) => [
          _searchField(),
          ErrorMessage(
            title: 'Não foi possível pesquisar.',
            error: error,
            onRetry: _recipes.retry,
          ),
        ],
      LoadIdle() || LoadInProgress() => [
          ..._form(),
          const SizedBox(height: 28),
          LoadingSkeleton(message: 'Pesquisando “$query”…'),
        ],
    };
  }

  List<Widget> _form() => [
        const Text(
          'Nome da receita',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        const SizedBox(height: 8),
        _searchField(),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Pesquisar'),
        ),
      ];

  Widget _searchField() {
    return TextField(
      controller: _field,
      focusNode: _focus,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submit(),
      onChanged: (_) {
        if (_fieldError != null) setState(() => _fieldError = null);
      },
      decoration: InputDecoration(
        hintText: 'Buscar pelo nome',
        prefixIcon: const Icon(Icons.search),
        errorText: _fieldError,
      ),
    );
  }
}
