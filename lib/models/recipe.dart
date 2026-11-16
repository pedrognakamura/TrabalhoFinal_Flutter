/// Receita vinda da API DummyJSON.
///
/// A conversão a partir do JSON é tolerante: campos ausentes ou com tipo
/// inesperado viram `null` (ou lista vazia) em vez de quebrar o app. Só o
/// [id] é obrigatório, pois é a identidade estável usada na seleção e para
/// evitar favoritos duplicados.
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    this.ingredients = const [],
    this.instructions = const [],
    this.image,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    this.rating,
    this.mealType = const [],
    this.cuisine,
    this.difficulty,
    this.caloriesPerServing,
    this.tags = const [],
  });

  /// Nome usado quando a API não envia um nome utilizável.
  static const fallbackName = 'Receita sem nome';

  final int id;
  final String name;
  final List<String> ingredients;

  /// Passos na mesma ordem em que a API os envia.
  final List<String> instructions;
  final String? image;

  /// `null` significa "não informado", e não zero.
  final int? prepTimeMinutes;

  /// `null` significa "não informado", e não zero.
  final int? cookTimeMinutes;

  /// Só tem valor quando é um número positivo, ou seja, utilizável.
  final int? servings;

  /// Mantido como [num]: a API pode mandar `4.6` ou `5`.
  final num? rating;
  final List<String> mealType;
  final String? cuisine;
  final String? difficulty;
  final int? caloriesPerServing;
  final List<String> tags;

  /// Tempo total, calculado só quando os dois tempos foram informados.
  int? get totalTimeMinutes {
    final prep = prepTimeMinutes;
    final cook = cookTimeMinutes;
    if (prep == null || cook == null) return null;
    return prep + cook;
  }

  /// Converte um item JSON. Retorna `null` quando o item não é um objeto ou
  /// não tem um `id` válido, para que um item ruim não derrube a lista toda.
  static Recipe? tryParse(Object? json) {
    if (json is! Map) return null;
    final id = _asInt(json['id']);
    if (id == null) return null;

    final servings = _asInt(json['servings']);

    return Recipe(
      id: id,
      name: _asString(json['name']) ?? fallbackName,
      ingredients: _asStringList(json['ingredients']),
      instructions: _asStringList(json['instructions']),
      image: _asUrl(json['image']),
      prepTimeMinutes: _asNonNegativeInt(json['prepTimeMinutes']),
      cookTimeMinutes: _asNonNegativeInt(json['cookTimeMinutes']),
      servings: (servings != null && servings > 0) ? servings : null,
      rating: _asNum(json['rating']),
      mealType: _asStringList(json['mealType']),
      cuisine: _asString(json['cuisine']),
      difficulty: _asString(json['difficulty']),
      caloriesPerServing: _asNonNegativeInt(json['caloriesPerServing']),
      tags: _asStringList(json['tags']),
    );
  }

  static String? _asString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _asUrl(Object? value) {
    final text = _asString(value);
    if (text == null) return null;
    final uri = Uri.tryParse(text);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    return text;
  }

  static num? _asNum(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.trim());
    return null;
  }

  static int? _asInt(Object? value) {
    final number = _asNum(value);
    if (number == null || !number.isFinite) return null;
    if (number is int) return number;
    // Aceita 15.0, mas rejeita 15.5 em vez de arredondar silenciosamente.
    return number == number.truncateToDouble() ? number.toInt() : null;
  }

  static int? _asNonNegativeInt(Object? value) {
    final number = _asInt(value);
    return (number != null && number >= 0) ? number : null;
  }

  /// Aceita uma lista ou uma String solta (ex.: `mealType: "Dinner"`).
  static List<String> _asStringList(Object? value) {
    if (value is String) {
      final single = _asString(value);
      return single == null ? const [] : List.unmodifiable([single]);
    }
    if (value is! List) return const [];
    return List.unmodifiable(
      value.map(_asString).whereType<String>(),
    );
  }
}
