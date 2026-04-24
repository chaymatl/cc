import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'safe_network_image.dart';

/// A Pinterest-style card with image background, glassmorphism overlay,
/// optional badge, and hover effects on web.
class PinCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final String imageUrl;
  final double height;
  final VoidCallback? onTap;
  final String? badgeText;

  const PinCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
    this.imageUrl = '',
    this.height = 200.0,
    this.onTap,
    this.badgeText,
  }) : super(key: key);

  @override
  State<PinCard> createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnim;
  late Animation<double> _elevationAnim;
  late Animation<double> _overlayOpacityAnim;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _elevationAnim = Tween<double>(begin: 8, end: 24).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    _overlayOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onEnter() {
    if (!_isHovered) {
      setState(() => _isHovered = true);
      _hoverController.forward();
    }
  }

  void _onExit() {
    if (_isHovered) {
      setState(() => _isHovered = false);
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.18),
                  blurRadius: _elevationAnim.value,
                  offset: Offset(0, _elevationAnim.value * 0.4),
                  spreadRadius: _isHovered ? 2 : 0,
                ),
                if (_isHovered)
                  BoxShadow(
                    color: widget.color.withOpacity(0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  _buildBackground(),

                  // Gradient scrim
                  _buildGradientScrim(),

                  // Decorative circle
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color.withOpacity(
                          _isHovered ? 0.35 : 0.25,
                        ),
                      ),
                    ),
                  ),

                  // Hover blur overlay (web only)
                  if (kIsWeb)
                    Opacity(
                      opacity: _overlayOpacityAnim.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            color: widget.color.withOpacity(0.12),
                          ),
                        ),
                      ),
                    ),

                  // Content at bottom
                  _buildContent(),

                  // Badge (top-left)
                  if (widget.badgeText != null && widget.badgeText!.isNotEmpty)
                    _buildBadge(),

                  // Bookmark button (top-right)
                  _buildBookmark(),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Wrap with mouse region for web hover
    Widget result;
    if (kIsWeb) {
      result = MouseRegion(
        onEnter: (_) => _onEnter(),
        onExit: (_) => _onExit(),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: card,
        ),
      );
    } else {
      result = GestureDetector(
        onTap: widget.onTap,
        child: card,
      );
    }

    return result;
  }

  Widget _buildBackground() {
    if (widget.imageUrl.isNotEmpty) {
      return SafeNetworkImage(
        widget.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(widget.icon, color: Colors.white.withOpacity(0.3), size: 48),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(widget.icon, color: Colors.white.withOpacity(0.3), size: 48),
      ),
    );
  }

  Widget _buildGradientScrim() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.02),
            Colors.black.withOpacity(0.12),
            Colors.black.withOpacity(_isHovered ? 0.72 : 0.62),
          ],
          stops: const [0.0, 0.35, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            widget.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          // Arrow CTA
          AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            offset: _isHovered ? const Offset(0.05, 0) : Offset.zero,
            child: Row(
              children: [
                Text(
                  'Découvrir',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  transform: Matrix4.translationValues(
                    _isHovered ? 4.0 : 0.0, 0, 0,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white.withOpacity(0.85),
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color,
              widget.color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Text(
              widget.badgeText!,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmark() {
    return Positioned(
      top: 12,
      right: 12,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white
              : Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.1),
              blurRadius: _isHovered ? 12 : 8,
            ),
          ],
        ),
        child: Icon(
          _isHovered ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
          size: 16,
          color: widget.color,
        ),
      ),
    );
  }
}
