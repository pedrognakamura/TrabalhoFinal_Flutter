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

  static const fallbackName = 'Receita sem nome';

  final int id;
  final String name;
  final List<String> ingredients;

  final List<String> instructions;
  final String? image;

  final int? prepTimeMinutes;

  final int? cookTimeMinutes;

  final int? servings;

  final num? rating;
  final List<String> mealType;
  final String? cuisine;
  final String? difficulty;
  final int? caloriesPerServing;
  final List<String> tags;

  int? get totalTimeMinutes {
    final prep = prepTimeMinutes;
    final cook = cookTimeMinutes;
    if (prep == null || cook == null) return null;
    return prep + cook;
  }

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
    return number == number.truncateToDouble() ? number.toInt() : null;
  }

  static int? _asNonNegativeInt(Object? value) {
    final number = _asInt(value);
    return (number != null && number >= 0) ? number : null;
  }

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
