import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.iconSize = 32,
  });

  final String? url;
  final double? width;
  final double? height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) return _placeholder(Icons.restaurant);

    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      semanticLabel: 'Foto da receita',
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(null),
      errorBuilder: (context, error, stackTrace) =>
          _placeholder(Icons.no_photography_outlined),
    );
  }

  Widget _placeholder(IconData? icon) {
    return Container(
      width: width,
      height: height,
      color: AppColors.imageBackground,
      alignment: Alignment.center,
      child: icon == null
          ? SizedBox.square(
              dimension: iconSize * 0.6,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: iconSize, color: AppColors.muted),
    );
  }
}
