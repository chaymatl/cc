import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';

/// Login web : split-screen, professionnel, sobre, sans animations.
class WebLoginBody extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;
  final VoidCallback onLogin;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onFacebookSignIn;
  final VoidCallback onSignUp;

  const WebLoginBody({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.errorMessage,
    required this.onLogin,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onGoogleSignIn,
    required this.onFacebookSignIn,
    required this.onSignUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Fond gris très subtil
      body: Stack(
        children: [
          // ── Fond décoratif subtil ──
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentTeal.withOpacity(0.03),
              ),
            ),
          ),

          // ── Carte Centrale Premium ──
          Center(
            child: Container(
              width: 1000,
              height: 650,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  // ── Panneau gauche : Illustration Riche ────────────────────────────
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0F172A), // Deep Slate
                            Color(0xFF064E3B), // Dark Emerald
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Orbs
                          Positioned(
                            top: -50,
                            right: -50,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF10B981).withOpacity(0.15),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(48),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/ecorewind_logo.png',
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    'EcoRewind',
                                    style: GoogleFonts.outfit(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'L\'excellence en gestion\néco-citoyenne des déchets.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.7),
                                      height: 1.6,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 48),
                                  // Stats rapides
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: const [
                                      _StatBadge(value: '10K+', label: 'Utilisateurs'),
                                      _StatBadge(value: '99%', label: 'Recyclage'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Panneau droit : Formulaire Épuré ──────────────────────────────
                  Expanded(
                    flex: 6,
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Bienvenue',
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Connectez-vous à votre espace personnel',
                                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 40),

                                // Erreur
                                if (errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFFCA5A5)),
                                    ),
                                    child: Row(children: [
                                      const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(errorMessage!, style: GoogleFonts.inter(color: const Color(0xFFB91C1C), fontSize: 13, fontWeight: FontWeight.w500))),
                                    ]),
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                // Email
                                Text('Email', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    hintText: 'nom@entreprise.com',
                                    hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                                    prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onSubmitted: (_) => onLogin(),
                                ),
                                const SizedBox(height: 20),

                                // Mot de passe
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Mot de passe', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                                    TextButton(
                                      onPressed: onForgotPassword,
                                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                      child: Text('Oublié ?', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), letterSpacing: 2),
                                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                                    suffixIcon: IconButton(
                                      icon: Icon(obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: const Color(0xFF94A3B8)),
                                      onPressed: onTogglePassword,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onSubmitted: (_) => onLogin(),
                                ),

                                const SizedBox(height: 32),

                                // Bouton connexion
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : onLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F172A), // Bouton noir pro (style Vercel/Stripe)
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : Text('Se connecter', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Séparateur
                                Row(children: [
                                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('ou continuer avec', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
                                  ),
                                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                                ]),
                                const SizedBox(height: 24),

                                // Social auth en ligne
                                Row(children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: isLoading ? null : onGoogleSignIn,
                                      icon: const FaIcon(FontAwesomeIcons.google, size: 16, color: Color(0xFF475569)),
                                      label: Text('Google', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569), fontWeight: FontWeight.w600)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ]),

                                const SizedBox(height: 32),

                                // Inscription
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Pas encore de compte ? ', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13)),
                                    TextButton(
                                      onPressed: onSignUp,
                                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                      child: Text("S'inscrire", style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
