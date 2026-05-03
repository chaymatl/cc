import 'dart:async';
import 'dart:io';
import 'dart:ui';
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
import '../../widgets/safe_network_image.dart';

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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nouvelle Publication', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _postController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Partagez votre action écologique du jour...",
                    hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedImage != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: kIsWeb
                              ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                              : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setModalState(() => selectedImage = null)),
                        ),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                      if (image != null) setModalState(() => selectedImage = image);
                    },
                    icon: const Icon(Icons.add_photo_alternate_rounded, color: AppTheme.primaryGreen),
                    label: Text('Ajouter une photo', style: GoogleFonts.inter(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isUploading || (_postController.text.isEmpty && selectedImage == null) ? null : () async {
                    setModalState(() => isUploading = true);
                    try {
                      String? uploadedUrl;
                      if (selectedImage != null) {
                        uploadedUrl = await _authService.uploadImageFromXFile(selectedImage!);
                      }
                      final user = AuthState.currentUser;
                      final result = await _authService.createPost(
                        userName: user?.name ?? 'Anonyme',
                        userAvatarUrl: user?.avatarUrl ?? '',
                        imageUrl: uploadedUrl ?? '',
                        description: _postController.text,
                      );

                      if (result['success'] == true) {
                        _postController.clear();
                        Navigator.pop(context);
                        _loadPosts();
                      }
                    } finally {
                      if (mounted) setModalState(() => isUploading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: isUploading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Publier', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        color: AppTheme.primaryGreen,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: _buildCreatePostButton(),
              ),
            ),
            if (_isLoading && _posts.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)))
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(_error!, style: GoogleFonts.inter(color: AppTheme.deepNavy, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: _loadPosts, child: const Text('Réessayer', style: TextStyle(color: AppTheme.primaryGreen))),
                    ],
                  ),
                ),
              )
            else if (_posts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Aucune publication pour le moment.', style: GoogleFonts.inter(color: AppTheme.textMuted)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _createNewPost,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: const Text('Soyez le premier à publier !', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == _posts.length) {
                      return _isLoadingMore
                          ? const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)))
                          : const SizedBox(height: 40);
                    }
                    return _RealPostCard(
                      key: ValueKey(_posts[index]['id']),
                      post: _posts[index],
                      authService: _authService,
                      onRefresh: _loadPosts,
                      formatTime: _formatTime,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
                  },
                  childCount: _posts.length + 1,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewPost,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(0.9),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            title: Text(
              'Communauté',
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostButton() {
    return GestureDetector(
      onTap: _createNewPost,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: Icon(Icons.person_rounded, color: AppTheme.primaryGreen.withOpacity(0.5)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Partagez une action écologique...',
                style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.image_rounded, color: AppTheme.primaryGreen.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}

class _RealPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final AuthService authService;
  final VoidCallback onRefresh;
  final String Function(String?) formatTime;

  const _RealPostCard({super.key, required this.post, required this.authService, required this.onRefresh, required this.formatTime});

  @override
  State<_RealPostCard> createState() => _RealPostCardState();
}

class _RealPostCardState extends State<_RealPostCard> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post['likes_count'] ?? 0;
    _isLiked = widget.post['is_liked'] == true;
  }

  Future<void> _handleLike() async {
    if (!AuthState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connectez-vous pour liker')));
      return;
    }
    setState(() { _isLiked = !_isLiked; _isLiked ? _likeCount++ : _likeCount = (_likeCount - 1).clamp(0, 999999); });
    final result = await widget.authService.toggleLikePost(widget.post['id'].toString());
    if (result['success'] == true) {
      if (mounted) setState(() { _isLiked = result['liked'] ?? _isLiked; _likeCount = result['count'] ?? _likeCount; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.post['user_name'] ?? 'Anonyme';
    final userAvatarUrl = widget.post['user_avatar_url'] as String?;
    final description = widget.post['description'] ?? '';
    final imageUrl = widget.post['image_url'] ?? '';
    final timeStr = widget.formatTime(widget.post['created_at']);
    final isMyPost = AuthState.isLoggedIn && userName == AuthState.currentUser?.name;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (userAvatarUrl != null && userAvatarUrl.isNotEmpty)
                  SafeNetworkCircleAvatar(url: userAvatarUrl, radius: 22)
                else
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.deepNavy)),
                      Text(timeStr, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (isMyPost)
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.textMuted),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Text('Supprimer ?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await widget.authService.deletePost(widget.post['id'].toString());
                        widget.onRefresh();
                      }
                    },
                  )
              ],
            ),
          ),

          // Content
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                description,
                style: GoogleFonts.inter(fontSize: 15, height: 1.5, color: AppTheme.textMain),
              ),
            ),

          // Image
          if (imageUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SafeNetworkImage(imageUrl, fit: BoxFit.cover),
              ),
            ),
          ],

          // Footer actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildActionIcon(
                  _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  '$_likeCount',
                  _isLiked ? Colors.pink : AppTheme.textMuted,
                  onTap: _handleLike,
                ),
                const Spacer(),
                Icon(Icons.bookmark_border_rounded, color: AppTheme.textMuted, size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String count, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(width: 6),
          Text(count, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        ],
      ),
    );
  }
}
