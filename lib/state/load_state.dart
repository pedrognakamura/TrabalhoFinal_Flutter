import '../models/recipe.dart';
import '../services/api_exception.dart';

/// Estado de uma consulta remota de receitas.
sealed class LoadState {
  const LoadState();
}

class LoadIdle extends LoadState {
  const LoadIdle();
}

class LoadInProgress extends LoadState {
  const LoadInProgress();
}

class LoadSuccess extends LoadState {
  const LoadSuccess(this.recipes);

  final List<Recipe> recipes;
}

class LoadFailure extends LoadState {
  const LoadFailure(this.error);

  final ApiException error;
}
