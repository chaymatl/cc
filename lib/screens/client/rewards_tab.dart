import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../widgets/safe_network_image.dart';

class RewardsTab extends StatelessWidget {
  const RewardsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreCard(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Niveaux & Avantages'),
                  const SizedBox(height: 16),
                  _buildLevelCarousel(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Vos Badges'),
                  const SizedBox(height: 16),
                  _buildBadgesGrid(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Récompenses Exclusives'),
                  const SizedBox(height: 16),
                  _buildRewardsGrid(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          'Récompenses',
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.deepNavy,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withOpacity(0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.accentTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Éco-Citoyen',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Solde Actuel',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '1,250',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'pts',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppTheme.deepNavy,
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05);
  }

  Widget _buildLevelCarousel() {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          _buildMobileLevelCard('Éco-Citoyen', 'Niveau Actuel', Icons.eco_rounded, const Color(0xFF10B981), true),
          const SizedBox(width: 16),
          _buildMobileLevelCard('Champion Vert', '2000 pts', Icons.emoji_events_rounded, const Color(0xFFF59E0B), false),
          const SizedBox(width: 16),
          _buildMobileLevelCard('Légende Éco', '5000 pts', Icons.workspace_premium_rounded, const Color(0xFF8B5CF6), false),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1);
  }

  Widget _buildMobileLevelCard(String title, String subtitle, IconData icon, Color color, bool isCurrent) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCurrent ? color : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: isCurrent ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: isCurrent ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isCurrent ? Colors.white : color, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? Colors.white : AppTheme.deepNavy,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isCurrent ? Colors.white.withOpacity(0.8) : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context) {
    final badges = [
      {'icon': Icons.recycling_rounded, 'color': const Color(0xFF3B82F6), 'title': 'Premier Tri'},
      {'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFF59E0B), 'title': 'Série 7J'},
      {'icon': Icons.quiz_rounded, 'color': const Color(0xFF8B5CF6), 'title': 'Expert Quiz'},
      {'icon': Icons.groups_rounded, 'color': Colors.grey.shade300, 'title': 'Communauté', 'locked': true},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: badges.map((b) {
        final isLocked = b['locked'] == true;
        final color = isLocked ? Colors.grey.shade400 : b['color'] as Color;
        return Container(
          width: (MediaQuery.of(context).size.width - 40 - 16) / 2, // 2 columns
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey.shade50 : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isLocked ? Colors.grey.shade200 : color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade200 : color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(b['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  b['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isLocked ? Colors.grey.shade500 : AppTheme.deepNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildRewardsGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildRewardCard(
                title: 'Bon d\'achat 10 DT',
                points: '1000 pts',
                imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&q=80',
                height: 220,
              ),
              const SizedBox(height: 16),
              _buildRewardCard(
                title: 'Sac en toile bio',
                points: '1500 pts',
                imageUrl: 'https://images.unsplash.com/photo-1597348989645-46b190ce4918?w=400&q=80',
                height: 260,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildRewardCard(
                title: 'Gourde écologique',
                points: '2500 pts',
                imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&q=80',
                height: 260,
              ),
              const SizedBox(height: 16),
              _buildRewardCard(
                title: 'Plantation d\'arbre',
                points: '3000 pts',
                imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400&q=80',
                height: 220,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildRewardCard({
    required String title,
    required String points,
    required String imageUrl,
    required double height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeNetworkImage(
              imageUrl,
              fit: BoxFit.cover,
              placeholder: Container(color: Colors.grey.shade200),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  points,
                  style: GoogleFonts.outfit(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
