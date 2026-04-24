import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_prompt_dialog.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({Key? key}) : super(key: key);

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  final TextEditingController _postController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 15;
  int _currentSkip = 0;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _scrollController.addListener(_onScroll);
    _loadPosts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _postController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts() async {
    setState(() { _isLoading = true; _error = null; _currentSkip = 0; _hasMore = true; });
    try {
      final posts = await _authService.fetchPosts(skip: 0, limit: _pageSize);
      if (mounted) {
        setState(() {
          _posts = posts.cast<Map<String, dynamic>>();
          _isLoading = false;
          _currentSkip = posts.length;
          _hasMore = posts.length >= _pageSize;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Impossible de charger les publications'; _isLoading = false; });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final newPosts = await _authService.fetchPosts(skip: _currentSkip, limit: _pageSize);
      if (mounted) {
        setState(() {
          _posts.addAll(newPosts.cast<Map<String, dynamic>>());
          _currentSkip += newPosts.length;
          _hasMore = newPosts.length >= _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try { return timeago.format(DateTime.parse(dateStr), locale: 'fr'); } catch (_) { return ''; }
  }

  void _createNewPost() {
    if (!AuthState.isLoggedIn) { AuthPromptDialog.show(context: context); return; }

    XFile? selectedImage;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Nouvelle publication', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 20),
              TextField(
                controller: _postController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Partagez votre geste éco-responsable...',
                  hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2)),
                ),
              ),
              const SizedBox(height: 16),

              // Image picker area
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) setModalState(() => selectedImage = picked);
                },
                child: Container(
                  height: selectedImage != null ? 200 : 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                    image: selectedImage != null && !kIsWeb
                        ? DecorationImage(image: FileImage(File(selectedImage!.path)), fit: BoxFit.cover)
                        : null,
                  ),
                  child: selectedImage != null
                      ? Stack(children: [
                          if (kIsWeb) Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.check_circle_rounded, size: 40, color: AppTheme.primaryGreen),
                            const SizedBox(height: 8),
                            Text('Image sélectionnée', style: GoogleFonts.inter(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                          ])),
                          Positioned(
                            top: 8, right: 8,
                            child: GestureDetector(
                              onTap: () => setModalState(() => selectedImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ])
                      : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_photo_alternate_rounded, size: 36, color: AppTheme.primaryGreen.withOpacity(0.6)),
                          const SizedBox(height: 8),
                          Text('Ajouter une image', style: GoogleFonts.inter(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('depuis la galerie', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
                        ]),
                ),
              ),

              const Spacer(),

              // Publish button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.accentTeal]),
                  boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: ElevatedButton(
                  onPressed: isUploading ? null : () async {
                    if (_postController.text.isEmpty) return;
                    setModalState(() => isUploading = true);

                    String imageUrl = '';
                    // Upload image if selected
                    if (selectedImage != null) {
                      final uploadedUrl = await _authService.uploadImageFromXFile(selectedImage!);
                      if (uploadedUrl != null) imageUrl = uploadedUrl;
                    }

                    final user = AuthState.currentUser;
                    final result = await _authService.createPost(
                      userName: user?.name ?? 'Anonyme',
                      userAvatarUrl: user?.avatarUrl ?? '',
                      imageUrl: imageUrl,
                      description: _postController.text,
                    );

                    if (result['success'] == true) {
                      _postController.clear();
                      if (context.mounted) Navigator.pop(context);
                      _loadPosts();

                      // ── Cas 1 : Signalé par l'IA → envoyé à l'admin ───────────
                      if (result['ai_flagged'] == true && mounted) {
                        final category = result['rejection_category'] ?? 'offtopic';
                        final title    = result['rejection_title']    ?? 'Publication signalée';
                        final bodyTxt  = result['rejection_body']     ?? 'Votre publication a été transmise à un administrateur.';
                        final tip      = result['rejection_tip']      ?? 'Publiez du contenu lié à l\'écologie.';

                        final Map<String, Color> accentMap = {
                          'nsfw':          Colors.purple.shade700,
                          'toxic':         Colors.red.shade700,
                          'anti_eco':      Colors.green.shade800,
                          'fashion':       Colors.pink.shade600,
                          'sport':         Colors.blue.shade700,
                          'politics':      Colors.indigo.shade700,
                          'economy':       Colors.teal.shade700,
                          'health':        Colors.cyan.shade700,
                          'education':     Colors.amber.shade800,
                          'entertainment': Colors.orange.shade700,
                          'cooking':       Colors.brown.shade600,
                          'travel':        Colors.lightBlue.shade700,
                          'technology':    Colors.blueGrey.shade700,
                          'news':          Colors.grey.shade700,
                          'offtopic_image':Colors.deepOrange.shade700,
                        };
                        final Map<String, Color> bgMap = {
                          'nsfw':          Colors.purple.shade50,
                          'toxic':         Colors.red.shade50,
                          'anti_eco':      Colors.green.shade50,
                          'fashion':       Colors.pink.shade50,
                          'sport':         Colors.blue.shade50,
                          'politics':      Colors.indigo.shade50,
                          'economy':       Colors.teal.shade50,
                          'health':        Colors.cyan.shade50,
                          'education':     Colors.amber.shade50,
                          'entertainment': Colors.orange.shade50,
                          'cooking':       Colors.brown.shade50,
                          'travel':        Colors.lightBlue.shade50,
                          'technology':    Colors.blueGrey.shade50,
                          'news':          Colors.grey.shade100,
                          'offtopic_image':Colors.deepOrange.shade50,
                        };
                        final Map<String, IconData> iconMap = {
                          'nsfw':          Icons.block_rounded,
                          'toxic':         Icons.sentiment_very_dissatisfied_rounded,
                          'anti_eco':      Icons.eco,
                          'fashion':       Icons.checkroom_rounded,
                          'sport':         Icons.sports_soccer_rounded,
                          'politics':      Icons.how_to_vote_rounded,
                          'economy':       Icons.trending_up_rounded,
                          'health':        Icons.local_hospital_rounded,
                          'education':     Icons.school_rounded,
                          'entertainment': Icons.movie_rounded,
                          'cooking':       Icons.restaurant_rounded,
                          'travel':        Icons.flight_rounded,
                          'technology':    Icons.devices_rounded,
                          'news':          Icons.newspaper_rounded,
                          'offtopic_image':Icons.image_not_supported_rounded,
                        };
                        final Color accentColor = accentMap[category] ?? Colors.deepOrange.shade700;
                        final Color bgColor     = bgMap[category]     ?? Colors.deepOrange.shade50;
                        final IconData icon     = iconMap[category]   ?? Icons.gpp_bad_rounded;

                        showDialog(
                          context: this.context,
                          barrierDismissible: false,
                          builder: (ctx) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 20, 16, 28),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [

                                // ── Bouton X en haut à droite ──────────────────────
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    icon: Icon(Icons.close_rounded, color: Colors.grey.shade500, size: 24),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // ── Icône catégorie ──────────────────────────────
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                                  child: Icon(icon, color: accentColor, size: 38),
                                ),
                                const SizedBox(height: 16),

                                // ── Titre catégorisé ─────────────────────────────
                                Text(title,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.deepSlate),
                                  textAlign: TextAlign.center),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                                  child: Text('Détecté par l\'IA EcoRewind',
                                    style: GoogleFonts.inter(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(height: 16),

                                // ── Message backend catégorisé ───────────────────
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: bgColor.withOpacity(0.6)),
                                  ),
                                  child: Text(bodyTxt,
                                    style: GoogleFonts.inter(fontSize: 13, color: accentColor, height: 1.55),
                                    textAlign: TextAlign.center),
                                ),
                                const SizedBox(height: 10),

                                // ── Message admin review ─────────────────────────
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.orange.shade100),
                                  ),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Icon(Icons.admin_panel_settings_rounded, color: Colors.orange.shade700, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text('Transmise à l\'administrateur',
                                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.orange.shade800)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Votre publication a été envoyée à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.',
                                        style: GoogleFonts.inter(fontSize: 12, color: Colors.orange.shade700, height: 1.5),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        Icon(Icons.notifications_active_rounded, size: 13, color: Colors.orange.shade600),
                                        const SizedBox(width: 4),
                                        Expanded(child: Text('Une notification vous sera envoyée.',
                                          style: GoogleFonts.inter(fontSize: 11, color: Colors.orange.shade600, fontStyle: FontStyle.italic))),
                                      ]),
                                    ])),
                                  ]),
                                ),
                                const SizedBox(height: 10),

                                // ── Conseil écologique ───────────────────────────
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Icon(Icons.lightbulb_outline_rounded, size: 15, color: AppTheme.primaryGreen),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(tip,
                                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600, height: 1.4))),
                                  ]),
                                ),
                              ]),
                            ),
                          ),
                        );

                      // ── Cas 2 : En attente de validation (incertitude IA) ────
                      } else if (result['status'] == 'pending_review' && mounted) {
                        showDialog(
                          context: this.context,
                          builder: (ctx) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.amber.shade50]),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.hourglass_top_rounded, color: Colors.orange.shade700, size: 38),
                                ),
                                const SizedBox(height: 18),
                                Text('Vérification en cours', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 19, color: AppTheme.deepSlate)),
                                const SizedBox(height: 4),
                                Text('Modération IA', style: GoogleFonts.inter(fontSize: 12, color: Colors.orange.shade600, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.orange.shade100),
                                  ),
                                  child: Column(children: [
                                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Icon(Icons.admin_panel_settings_rounded, color: Colors.orange.shade700, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(
                                        'Notre IA a détecté un contenu potentiellement hors sujet. Un administrateur va examiner et approuver ou rejeter votre publication.',
                                        style: GoogleFonts.inter(fontSize: 13, color: Colors.orange.shade800, height: 1.5),
                                      )),
                                    ]),
                                    const SizedBox(height: 10),
                                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Icon(Icons.notifications_active_rounded, color: Colors.orange.shade600, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(
                                        'Vous serez notifié(e) dès la décision de l\'administrateur.',
                                        style: GoogleFonts.inter(fontSize: 12, color: Colors.orange.shade700),
                                      )),
                                    ]),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(children: [
                                        Icon(Icons.lightbulb_outline_rounded, size: 14, color: AppTheme.primaryGreen),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text(
                                          'Conseil : publiez des actions éco-citoyennes pour une approbation instantanée.',
                                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                                        )),
                                      ]),
                                    ),
                                  ]),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(width: double.infinity, child: ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade600,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    elevation: 0,
                                  ),
                                  child: Text('Compris !', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                )),
                              ]),
                            ),
                          ),
                        );

                      // ── Cas 3 : Publié avec succès ───────────────────────────
                      } else if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                          content: Row(children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Publication partagée avec la communauté !',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13))),
                          ]),
                          backgroundColor: AppTheme.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          duration: const Duration(seconds: 3),
                        ));
                      }

                    } else {

                      setModalState(() => isUploading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(result['message'] ?? 'Erreur de publication'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: isUploading
                      ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                          const SizedBox(width: 12),
                          Text('Publication en cours...', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
                        ])
                      : Text('PUBLIER', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_feed_new_post',
        onPressed: _createNewPost,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(delay: 1.seconds, curve: Curves.elasticOut),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.backgroundLight,
            elevation: 0, floating: true, centerTitle: false,
            title: Animate(
              effects: const [FadeEffect(), SlideEffect(begin: Offset(-0.2, 0))],
              child: Text('Communauté', style: AppTheme.seniorTheme.textTheme.headlineMedium?.copyWith(fontSize: 28)),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh_rounded, color: AppTheme.deepSlate), onPressed: _loadPosts),
              const SizedBox(width: 24),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)))
          else if (_error != null)
            SliverFillRemaining(
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), shape: BoxShape.circle), child: const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.red)),
                const SizedBox(height: 20),
                Text(_error!, style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Vérifiez que le serveur backend est démarré', style: GoogleFonts.inter(color: AppTheme.textMuted.withOpacity(0.6), fontSize: 12)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadPosts, icon: const Icon(Icons.refresh_rounded), label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
              ])),
            )
          else if (_posts.isEmpty)
            SliverFillRemaining(
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.article_outlined, size: 64, color: AppTheme.textMuted),
                const SizedBox(height: 16),
                Text('Aucune publication', style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textMuted)),
                const SizedBox(height: 8),
                Text('Soyez le premier à publier !', style: GoogleFonts.inter(color: AppTheme.textMuted)),
              ])),
            )
          else ...[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = _posts[index];
                  return Animate(
                    key: ValueKey(post['id']),
                    effects: [FadeEffect(delay: Duration(milliseconds: (index * 50).clamp(0, 300)), duration: const Duration(milliseconds: 600)), const SlideEffect(begin: Offset(0, 0.1))],
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RealPostCard(post: post, authService: _authService, onRefresh: _loadPosts, formatTime: _formatTime),
                    ),
                  );
                },
                childCount: _posts.length,
              ),
            ),
            // Loading more indicator
            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen, strokeWidth: 2.5)),
                ),
              ),
            // End of feed indicator
            if (!_hasMore && _posts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('Vous avez tout vu 🎉', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13))),
                ),
              ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ============================================
// Post Card with persistent like/save state
// ============================================
class _RealPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final AuthService authService;
  final VoidCallback onRefresh;
  final String Function(String?) formatTime;

  const _RealPostCard({required this.post, required this.authService, required this.onRefresh, required this.formatTime});

  @override
  State<_RealPostCard> createState() => _RealPostCardState();
}

class _RealPostCardState extends State<_RealPostCard> {
  late bool _isLiked;
  late int _likeCount;
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post['likes_count'] ?? 0;
    // Read persistent like/save state from backend response
    _isLiked = widget.post['is_liked'] == true;
    _isSaved = widget.post['is_saved'] == true;
  }

  @override
  void didUpdateWidget(covariant _RealPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync state when the post data changes (e.g. after refresh)
    if (oldWidget.post['id'] != widget.post['id'] ||
        oldWidget.post['likes_count'] != widget.post['likes_count'] ||
        oldWidget.post['is_liked'] != widget.post['is_liked'] ||
        oldWidget.post['is_saved'] != widget.post['is_saved']) {
      setState(() {
        _likeCount = widget.post['likes_count'] ?? 0;
        _isLiked = widget.post['is_liked'] == true;
        _isSaved = widget.post['is_saved'] == true;
      });
    }
  }

  Future<void> _handleLike() async {
    if (!AuthState.isLoggedIn) { _showAuthSnackBar('Connectez-vous pour liker'); return; }

    setState(() { _isLiked = !_isLiked; _isLiked ? _likeCount++ : _likeCount = (_likeCount - 1).clamp(0, 999999); });

    final result = await widget.authService.toggleLikePost(widget.post['id'].toString());
    if (result['success'] == true) {
      setState(() { _isLiked = result['liked'] ?? _isLiked; _likeCount = result['count'] ?? _likeCount; });
    }
  }

  Future<void> _handleSave() async {
    if (!AuthState.isLoggedIn) { _showAuthSnackBar('Connectez-vous pour enregistrer'); return; }

    setState(() => _isSaved = !_isSaved);

    final result = await widget.authService.toggleSavePost(widget.post['id'].toString());
    if (result['success'] == true) setState(() => _isSaved = result['saved'] ?? _isSaved);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isSaved ? 'Publication enregistrée !' : 'Publication retirée des favoris.'),
        duration: const Duration(seconds: 2),
        backgroundColor: _isSaved ? AppTheme.primaryGreen : AppTheme.deepSlate,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  String _formatCommentTime(dynamic comment) {
    // If we have a local _createdAt DateTime (just created), use it directly
    if (comment is Map && comment['_local_created_at'] != null) {
      final dt = comment['_local_created_at'] as DateTime;
      return timeago.format(dt, locale: 'fr');
    }
    return widget.formatTime(comment['created_at']);
  }

  void _showCommentModal() {
    final TextEditingController commentController = TextEditingController();
    final List<dynamic> comments = List<dynamic>.from(widget.post['comments'] ?? []);
    Timer? refreshTimer;
    Map<String, dynamic>? replyingTo; // The comment being replied to
    String? replyingToName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Auto-refresh timestamps every 30 seconds
          refreshTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
            if (context.mounted) setModalState(() {});
          });

          // Separate top-level comments and replies
          final topLevel = comments.where((c) => c['parent_id'] == null).toList();
          List<dynamic> getReplies(int parentId) =>
              comments.where((c) => c['parent_id'] == parentId).toList();

          Widget buildComment(dynamic comment, {bool isReply = false}) {
            final commentUserName = comment['user_name'] ?? 'Anonyme';
            final commentContent = comment['content'] ?? '';
            final commentTime = _formatCommentTime(comment);
            final isMyComment = AuthState.isLoggedIn && commentUserName == AuthState.currentUser?.name;
            final commentId = comment['id'];

            return Padding(
              padding: EdgeInsets.only(bottom: 12, left: isReply ? 40 : 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                  radius: isReply ? 14 : 18,
                  backgroundColor: isReply
                      ? const Color(0xFF5B8DEF).withOpacity(0.1)
                      : AppTheme.primaryGreen.withOpacity(0.1),
                  child: Text(
                    commentUserName.isNotEmpty ? commentUserName[0].toUpperCase() : '?',
                    style: GoogleFonts.outfit(
                      color: isReply ? const Color(0xFF5B8DEF) : AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: isReply ? 11 : 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isReply ? const Color(0xFFF0F4FF) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(commentUserName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: isReply ? 12 : 13)),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(commentTime, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
                        if (isMyComment && commentId != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () async {
                              final deleted = await widget.authService.deleteComment(commentId is int ? commentId : int.parse(commentId.toString()));
                              if (deleted) {
                                setModalState(() => comments.removeWhere((c) => c['id'] == commentId));
                                setState(() {});
                              }
                            },
                            child: Icon(Icons.delete_outline, size: 14, color: Colors.red.shade300),
                          ),
                        ],
                      ]),
                    ]),
                    const SizedBox(height: 4),
                    Text(commentContent, style: GoogleFonts.inter(fontSize: isReply ? 13 : 14)),
                    if (AuthState.isLoggedIn && !isReply) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            replyingTo = Map<String, dynamic>.from(comment);
                            replyingToName = commentUserName;
                          });
                          commentController.clear();
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.reply_rounded, size: 14, color: const Color(0xFF5B8DEF).withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Text('Répondre', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF5B8DEF))),
                        ]),
                      ),
                    ],
                  ]),
                )),
              ]),
            );
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
            child: Column(
              children: [
                Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Commentaires (${comments.length})', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () { refreshTimer?.cancel(); Navigator.pop(context); }, icon: const Icon(Icons.close)),
                  ]),
                ),
                Expanded(
                  child: comments.isEmpty
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('Aucun commentaire', style: GoogleFonts.inter(color: AppTheme.textMuted)),
                          Text('Soyez le premier à commenter !', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12)),
                        ]))
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: topLevel.length,
                          itemBuilder: (context, index) {
                            final comment = topLevel[index];
                            final replies = commentId(comment) != null ? getReplies(commentId(comment)!) : <dynamic>[];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildComment(comment),
                                ...replies.map((r) => buildComment(r, isReply: true)),
                              ],
                            );
                          },
                        ),
                ),
                // Reply banner
                if (replyingTo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B8DEF).withOpacity(0.06),
                      border: Border(top: BorderSide(color: const Color(0xFF5B8DEF).withOpacity(0.15))),
                    ),
                    child: Row(children: [
                      const Icon(Icons.reply_rounded, size: 16, color: Color(0xFF5B8DEF)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        'Réponse à $replyingToName',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5B8DEF)),
                      )),
                      GestureDetector(
                        onTap: () => setModalState(() { replyingTo = null; replyingToName = null; }),
                        child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF5B8DEF)),
                      ),
                    ]),
                  ),
                // Input
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                  child: Row(children: [
                    Expanded(child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: AuthState.isLoggedIn
                            ? (replyingTo != null ? 'Répondre à $replyingToName...' : 'Ajouter un commentaire...')
                            : 'Connectez-vous pour commenter',
                        enabled: AuthState.isLoggedIn,
                        filled: true, fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    )),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: AuthState.isLoggedIn ? () async {
                        if (commentController.text.isNotEmpty) {
                          final user = AuthState.currentUser;
                          final parentId = replyingTo != null ? commentId(replyingTo!) : null;
                          final result = await widget.authService.addComment(
                            widget.post['id'].toString(),
                            user?.name ?? 'Anonyme',
                            user?.avatarUrl,
                            commentController.text,
                            parentId: parentId,
                          );
                          if (result['success'] == true) {
                            final newComment = Map<String, dynamic>.from(result['data'] as Map);
                            newComment['_local_created_at'] = DateTime.now();
                            setModalState(() {
                              comments.insert(0, newComment);
                              replyingTo = null;
                              replyingToName = null;
                            });
                            setState(() {});
                            commentController.clear();
                          }
                        }
                      } : null,
                      icon: const Icon(Icons.send_rounded, color: AppTheme.primaryGreen),
                    ),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() => refreshTimer?.cancel());
  }

  /// Helper to safely extract comment id as int
  int? commentId(dynamic comment) {
    final id = comment['id'];
    if (id == null) return null;
    return id is int ? id : int.tryParse(id.toString());
  }

  void _showLikersModal() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  const Icon(Icons.favorite_rounded, color: Colors.pink, size: 22),
                  const SizedBox(width: 10),
                  Text('J\'aime ($_likeCount)', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                ]),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ]),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: widget.authService.fetchPostLikers(widget.post['id'].toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
                  }
                  final likers = snapshot.data ?? [];
                  if (likers.isEmpty) {
                    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.favorite_border_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Aucun j\'aime', style: GoogleFonts.inter(color: AppTheme.textMuted)),
                    ]));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: likers.length,
                    itemBuilder: (context, index) {
                      final liker = likers[index];
                      final name = liker['full_name'] ?? 'Utilisateur';
                      final email = liker['email'] ?? '';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.pink.withOpacity(0.1),
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: GoogleFonts.outfit(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                              if (email.isNotEmpty)
                                Text(email, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                            ],
                          )),
                          const Icon(Icons.favorite_rounded, color: Colors.pink, size: 18),
                        ]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.post['user_name'] ?? 'Anonyme';
    final description = widget.post['description'] ?? '';
    final imageUrl = widget.post['image_url'] ?? '';
    final timeStr = widget.formatTime(widget.post['created_at']);
    final comments = widget.post['comments'] as List<dynamic>? ?? [];
    final commentCount = comments.length;
    final isMyPost = AuthState.isLoggedIn && userName == AuthState.currentUser?.name;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: AppTheme.premiumShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.1), width: 1)),
              child: CircleAvatar(
                radius: 22, backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
              ),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(userName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(timeStr, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
            ]),
            const Spacer(),
            if (isMyPost)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.textMuted),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text('Supprimer ?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      content: const Text('Cette action est irréversible.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Supprimer'))],
                    ));
                    if (confirmed == true) {
                      await widget.authService.deletePost(widget.post['id'].toString());
                      widget.onRefresh();
                    }
                  }
                },
                itemBuilder: (ctx) => [const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), SizedBox(width: 8), Text('Supprimer')]))],
              )
            else
              const Icon(Icons.more_horiz_rounded, color: AppTheme.textMuted),
          ]),
        ),

        // Description
        if (description.isNotEmpty)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(description, style: GoogleFonts.inter(fontSize: 15, height: 1.6, color: AppTheme.textMain))),

        // Image
        if (imageUrl.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            height: 340, width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
          ),
        ],

        // Actions
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(children: [
            _buildActionIcon(_isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, '$_likeCount', _isLiked ? Colors.pink : AppTheme.textMuted, onTap: _handleLike, onLongPress: _likeCount > 0 ? _showLikersModal : null, onCountTap: _likeCount > 0 ? _showLikersModal : null),
            const SizedBox(width: 20),
            _buildActionIcon(Icons.chat_bubble_outline_rounded, '$commentCount', AppTheme.textMuted, onTap: _showCommentModal),
            const Spacer(),
            IconButton(
              onPressed: _handleSave,
              icon: Icon(_isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: _isSaved ? AppTheme.primaryGreen : AppTheme.textMuted, size: 24),
            ),
          ]),
        ),
      ]),
    );
  }

  void _showAuthSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text(message))]),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppTheme.deepNavy,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: SnackBarAction(label: 'CONNEXION', textColor: AppTheme.primaryGreen, onPressed: () => Navigator.pushNamed(context, '/login')),
    ));
  }

  Widget _buildActionIcon(IconData icon, String count, Color color, {VoidCallback? onTap, VoidCallback? onLongPress, VoidCallback? onCountTap}) {
    return Row(children: [
      GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Icon(icon, size: 24, color: color),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: onCountTap ?? onTap,
        child: Text(count, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      ),
    ]);
  }
}
