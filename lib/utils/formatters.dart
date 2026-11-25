String formatMinutes(int minutes) {
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours h' : '$hours h $rest min';
}

String formatOptionalMinutes(int? minutes) =>
    minutes == null ? 'não informado' : formatMinutes(minutes);

String formatRating(num rating) =>
    '${rating.toStringAsFixed(1).replaceAll('.', ',')} / 5';

String formatDifficulty(String difficulty) =>
    switch (difficulty.toLowerCase()) {
      'easy' => 'Fácil',
      'medium' => 'Médio',
      'hard' => 'Difícil',
      _ => difficulty,
    };
