// ignore_for_file: avoid_dynamic_calls
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';
import '../../widgets/safe_network_image.dart';
import '../../widgets/auth_prompt_dialog.dart';
import 'section_impact.dart';
import '../client/feed_tab.dart';
import '../client/rewards_tab.dart';
import '../client/map_tab.dart';
import '../../services/auth_service.dart';

class MobileMarketingLandingScreen extends StatefulWidget {
  const MobileMarketingLandingScreen({super.key});

  @override
  State<MobileMarketingLandingScreen> createState() => _MobileMarketingLandingScreenState();
}

class _MobileMarketingLandingScreenState extends State<MobileMarketingLandingScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _bgAnimationController;
  
  String _impactSubtitle = '...';
  List<Map<String, dynamic>> _testimonials = [];
  bool _loadingTestimonials = true;

  @override
  void initState() {
    super.initState();
    // Animation controller for the scroll down indicator
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _loadStats();
    _loadTestimonialsForLanding();
  }

  void _loadStats() async {
    try {
      final stats = await AuthService().fetchPlatformStats();
      if (mounted && stats.isNotEmpty) {
        setState(() {
          final members = (stats['total_users'] ?? 0).toInt();
          _impactSubtitle = '$members membres actifs';
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget page, {bool requiresAuth = false}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            requiresAuth ? AuthPromptWrapper(child: page) : page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildMobileHero()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 20, left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explorez',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.deepNavy,
                          letterSpacing: -1,
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),
                      const SizedBox(height: 8),
                      Text(
                        'Découvrez tout l\'univers EcoRewind inspiré par vous.',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppTheme.textMuted,
                          height: 1.4,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildPinterestGrid()),
              SliverToBoxAdapter(child: _buildTestimonialsInline()),
              const SliverToBoxAdapter(child: SizedBox(height: 140)), // Padding for bottom bar
            ],
          ),

          // Sticky Bottom Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHero() {
    final height = MediaQuery.of(context).size.height; // Full height hero
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fond avec image illustrative login_hero_new.png et zoom lent
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_bgAnimationController.value * 0.04),
                child: child,
              );
            },
            child: Image.asset(
              'assets/images/login_hero_new.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F2D1F),
                      Color(0xFF0A1628),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          
          // Gradient Overlay (plus clair, lumineux et naturel)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF042F2E).withOpacity(0.2),
                  const Color(0xFF064E3B).withOpacity(0.8),
                  const Color(0xFF022C22).withOpacity(0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 0.75, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Title
                    Text(
                      'Triez.\nGagnez.\nChangez le monde.',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -1.5,
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'Transformez chaque geste de tri en récompenses réelles. Rejoignez la communauté.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 30),

                    // Scroll Down Indicator
                    Center(
                      child: AnimatedBuilder(
                        animation: _bgAnimationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _bgAnimationController.value * 15),
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
                            Text('Découvrir', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                            const SizedBox(height: 8),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 28),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 1000.ms),
                    
                    SizedBox(height: MediaQuery.of(context).size.height < 600 ? 20 : (MediaQuery.of(context).size.height < 700 ? 50 : 100)), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTestimonialsForLanding() async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/testimonials/landing?limit=10'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _testimonials = data.cast<Map<String, dynamic>>();
            _loadingTestimonials = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingTestimonials = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingTestimonials = false);
    }
  }

  Widget _buildTestimonialsInline() {
    if (_loadingTestimonials) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF1A6B3C))),
      );
    }
    if (_testimonials.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 32, 0, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FAF4), Color(0xFFE8F5E9)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          // ── Titre ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6B3C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ce que disent nos citoyens',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A2B1E),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ── Carousel ──
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _testimonials.length,
              itemBuilder: (context, index) {
                final t = _testimonials[index];
                final int rating = (t['rating'] ?? 5) as int;
                final String itemContent = (t['content'] ?? '').toString();
                final String name = (t['user_name'] ?? 'Anonyme').toString();
                final bool featured = t['is_featured'] == true;
                // Couleur de fond alternée
                final List<Color> bgColors = [
                  Colors.white,
                  const Color(0xFFF8FFFE),
                  const Color(0xFFFFFDF5),
                ];
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 14, bottom: 8, top: 4),
                  decoration: BoxDecoration(
                    color: bgColors[index % bgColors.length],
                    borderRadius: BorderRadius.circular(24),
                    border: featured
                        ? Border.all(color: const Color(0xFF1A6B3C).withOpacity(0.5), width: 1.5)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A6B3C).withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header : avatar + nom + badge
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1A6B3C), Color(0xFF34A85A)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'A',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: const Color(0xFF1A2B1E),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: List.generate(5, (i) => Padding(
                                      padding: const EdgeInsets.only(right: 1),
                                      child: Icon(
                                        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                        size: 13,
                                        color: i < rating
                                            ? const Color(0xFFF59E0B)
                                            : Colors.grey.shade300,
                                      ),
                                    )),
                                  ),
                                ],
                              ),
                            ),
                            if (featured)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A6B3C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '\u2605',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF1A6B3C),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Guillemets décoratifs
                        Text(
                          '\u201c',
                          style: GoogleFonts.merriweather(
                            fontSize: 32,
                            color: const Color(0xFF1A6B3C).withOpacity(0.25),
                            height: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            itemContent,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF3D5A45),
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildPinterestGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildPinCard(
                  title: 'Impact Reel',
                  subtitle: _impactSubtitle,
                  assetImage: 'assets/images/card_impact.png',
                  fallbackGrad: const [Color(0xFF064E3B), Color(0xFF0D9488)],
                  fallbackIcon: Icons.bar_chart_rounded,
                  height: 260,
                  page: const SectionImpact(),
                  isAuthRequired: true,
                  delay: 100,
                ),
                const SizedBox(height: 16),
                _buildPinCard(
                  title: 'Recompenses',
                  subtitle: 'Cadeaux exclusifs',
                  assetImage: 'assets/images/card_rewards.png',
                  fallbackGrad: const [Color(0xFF3B0764), Color(0xFF7C3AED)],
                  fallbackIcon: Icons.card_giftcard_rounded,
                  height: 320,
                  page: const RewardsTab(),
                  isAuthRequired: true,
                  delay: 200,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildPinCard(
                  title: 'Communaute',
                  subtitle: "Rejoignez le mouv'",
                  assetImage: 'assets/images/card_community.png',
                  fallbackGrad: const [Color(0xFF1E1B4B), Color(0xFF2563EB)],
                  fallbackIcon: Icons.groups_rounded,
                  height: 300,
                  page: const FeedTab(),
                  isAuthRequired: true,
                  delay: 300,
                ),
                const SizedBox(height: 16),
                _buildPinCard(
                  title: 'Carte',
                  subtitle: 'Trouvez les bornes',
                  assetImage: 'assets/images/card_map.png',
                  fallbackGrad: const [Color(0xFF052E16), Color(0xFF059669)],
                  fallbackIcon: Icons.map_rounded,
                  height: 240,
                  page: const MapTab(),
                  isAuthRequired: true,
                  delay: 400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinCard({
    required String title,
    required String subtitle,
    required String assetImage,
    required List<Color> fallbackGrad,
    required IconData fallbackIcon,
    required double height,
    required Widget page,
    bool isAuthRequired = false,
    required int delay,
  }) {
    return GestureDetector(
      onTap: () => _navigateTo(page, requiresAuth: isAuthRequired),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image illustrative de la fonctionnalite
              Image.asset(
                assetImage,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: fallbackGrad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(child: Icon(fallbackIcon, color: Colors.white54, size: 48)),
                ),
              ),
              // Overlay sombre pour lisibilite
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 16, right: 16, bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: delay.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildStickyBottomBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.deepNavy,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'CONNEXION',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'S\'INSCRIRE',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 1.0, end: 0);
  }
}

class _ContinuousKenBurns extends StatefulWidget {
  final List<String> imageUrls;
  const _ContinuousKenBurns({required this.imageUrls});

  @override
  State<_ContinuousKenBurns> createState() => _ContinuousKenBurnsState();
}

class _ContinuousKenBurnsState extends State<_ContinuousKenBurns> with TickerProviderStateMixin {
  int _index = 0;
  late Timer _timer;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..forward();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % widget.imageUrls.length;
        });
        _scaleController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: AnimatedBuilder(
        key: ValueKey<int>(_index),
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_scaleController.value * 0.15),
            child: child,
          );
        },
        child: SafeNetworkImage(
          widget.imageUrls[_index],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
