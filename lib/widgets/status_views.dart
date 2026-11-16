import 'package:flutter/material.dart';

import '../services/api_exception.dart';
import '../theme/app_theme.dart';

/// Cabeçalho "Saborê" com divisória, usado nas abas.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Saborê',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          SizedBox(height: 14),
          Divider(),
        ],
      ),
    );
  }
}

/// Título de seção com subtítulo opcional.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.large = false});

  final String title;
  final String? subtitle;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: large ? 26 : 19,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        ],
      ],
    );
  }
}

/// Estado vazio ou de erro: ícone num círculo, título, texto e ações.
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final Widget icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 36),
        Center(
          child: Container(
            width: 108,
            height: 108,
            decoration: const BoxDecoration(
              color: AppColors.softGreen,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: icon,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        const SizedBox(height: 20),
        Text(message, style: const TextStyle(fontSize: 14, color: AppColors.muted, height: 1.4)),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 40),
          FilledButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
        ],
      ],
    );
  }
}

/// Erro de API com botão "Tentar novamente".
class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    super.key,
    required this.title,
    required this.error,
    required this.onRetry,
  });

  final String title;
  final ApiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return StatusMessage(
      icon: const Text(
        '!',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.green),
      ),
      title: title,
      message: error.message,
      actionLabel: 'Tentar novamente',
      onAction: onRetry,
    );
  }
}

/// Cards cinza no lugar da lista enquanto os dados carregam.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, required this.message, this.showSearchBar = false});

  final String message;
  final bool showSearchBar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showSearchBar) ...[
            const _Bone(height: 48),
            const SizedBox(height: 20),
          ],
          const _SkeletonCard(),
          const SizedBox(height: 12),
          const _SkeletonCard(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(message, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bone(width: 96, height: 102),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                _Bone(height: 12),
                SizedBox(height: 12),
                FractionallySizedBox(widthFactor: 0.7, child: _Bone(height: 12)),
                SizedBox(height: 26),
                FractionallySizedBox(widthFactor: 0.45, child: _Bone(height: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.skeleton,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
