// lib/widgets/skeleton_loader.dart
// Skeleton loaders avec shimmer — zéro dépendance externe
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer de base (glissement de lumière gauche → droite)
// ─────────────────────────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF252535) : const Color(0xFFE8E8EE);
    final highlight = isDark ? const Color(0xFF363650) : const Color(0xFFF5F5FA);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [base, highlight, base],
          stops: [
            (_anim.value - 1).clamp(0.0, 1.0),
            _anim.value.clamp(0.0, 1.0),
            (_anim.value + 1).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bloc rectangulaire de base â€" brique de construction principale
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({super.key, this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252535) : const Color(0xFFE8E8EE),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte de post social (Feed)
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.deepSlate : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SkeletonBox(width: 42, height: 42, radius: 21),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SkeletonBox(width: 130, height: 12, radius: 6),
            const SizedBox(height: 6),
            SkeletonBox(width: 85, height: 10, radius: 5),
          ])),
        ]),
        const SizedBox(height: 14),
        SkeletonBox(height: 12, radius: 6),
        const SizedBox(height: 7),
        SkeletonBox(height: 12, radius: 6),
        const SizedBox(height: 7),
        SkeletonBox(width: 200, height: 12, radius: 6),
        const SizedBox(height: 14),
        SkeletonBox(height: 180, radius: 12),
        const SizedBox(height: 14),
        Row(children: [
          SkeletonBox(width: 64, height: 30, radius: 15),
          const SizedBox(width: 10),
          SkeletonBox(width: 64, height: 30, radius: 15),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ligne utilisateur (User Management admin)
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonUserTile extends StatelessWidget {
  const SkeletonUserTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.deepSlate : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        SkeletonBox(width: 44, height: 44, radius: 22),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SkeletonBox(width: 130, height: 13, radius: 6),
          const SizedBox(height: 7),
          SkeletonBox(width: 190, height: 10, radius: 5),
        ])),
        const SizedBox(width: 10),
        SkeletonBox(width: 56, height: 24, radius: 12),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rangée de 4 KPI cards (banners admin)
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonKpiRow extends StatelessWidget {
  final int count;
  const SkeletonKpiRow({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: List.generate(count, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.deepSlate : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SkeletonBox(width: 28, height: 28, radius: 14),
            const SizedBox(height: 10),
            SkeletonBox(height: 20),
            const SizedBox(height: 6),
            SkeletonBox(width: 50, height: 10, radius: 5),
          ]),
        ),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification skeleton
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonNotifTile extends StatelessWidget {
  const SkeletonNotifTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.deepSlate : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        SkeletonBox(width: 40, height: 40, radius: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SkeletonBox(height: 12, radius: 6),
          const SizedBox(height: 7),
          SkeletonBox(width: 100, height: 10, radius: 5),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper : liste répétée de N skeletons identiques
// Exemple : SkeletonList(count: 6, builder: (_) => const SkeletonPostCard())
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonList extends StatelessWidget {
  final int count;
  final Widget Function(int i) builder;
  const SkeletonList({super.key, this.count = 5, required this.builder});

  @override
  Widget build(BuildContext context) =>
      Column(children: List.generate(count, builder));
}
