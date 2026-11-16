/// Ex.: `formatMinutes(75)` → `1 h 15 min`.
String formatMinutes(int minutes) {
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours h' : '$hours h $rest min';
}

/// Tempo que pode não ter sido informado pela API.
String formatOptionalMinutes(int? minutes) =>
    minutes == null ? 'não informado' : formatMinutes(minutes);

/// `4.6` → `4,6 / 5`. Funciona para `int` e `double`.
String formatRating(num rating) =>
    '${rating.toStringAsFixed(1).replaceAll('.', ',')} / 5';

/// Traduz as dificuldades conhecidas da API; outros valores ficam como vieram.
String formatDifficulty(String difficulty) =>
    switch (difficulty.toLowerCase()) {
      'easy' => 'Fácil',
      'medium' => 'Médio',
      'hard' => 'Difícil',
      _ => difficulty,
    };
