import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/firebase/firebase_admin_stats_service.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/skeleton_loader.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});
  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedRole = 'tous';
  final TextEditingController _searchCtrl = TextEditingController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _roleFilters = [
    ('tous', 'Tous', Icons.people_rounded),
    ('citoyen', 'Citoyen', Icons.person_rounded),
    ('educator', 'Educateur', Icons.school_rounded),
    ('collector', 'Collecteur', Icons.recycling_rounded),
    ('pointManager', 'Gestionnaire', Icons.store_rounded),
    ('intercommunality', 'Intercom.', Icons.account_balance_rounded),
    ('admin', 'Admin', Icons.admin_panel_settings_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadUsers();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final users = await _authService.getAllUsers();
      if (mounted) {
        setState(() { _users = users; _isLoading = false; });
        _fadeCtrl.forward(from: 0);
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = 'Erreur: '; _isLoading = false; });
    }
  }

  List<dynamic> get _filteredUsers {
    return _users.where((u) {
      final role = (u['role'] ?? 'citoyen') as String;
      final name = ((u['full_name'] ?? '') as String).toLowerCase();
      final email = ((u['email'] ?? '') as String).toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchRole = _selectedRole == 'tous' || role == _selectedRole;
      final matchSearch = q.isEmpty || name.contains(q) || email.contains(q);
      return matchRole && matchSearch;
    }).toList();
  }

  int _countByRole(String role) {
    if (role == 'tous') return _users.length;
    return _users.where((u) => u['role'] == role).length;
  }

  void _showUserDialog({Map<String, dynamic>? user}) {
    final isEditing = user != null;
    final emailCtrl = TextEditingController(text: user?['email']);
    final nameCtrl = TextEditingController(text: user?['full_name']);
    final pwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();
    String selectedRole = user?['role'] ?? 'citoyen';
    String? errorMsg;
    final isSuperAdmin = AuthState.currentUser?.role == UserRole.superadmin;
    final availableRoles = isSuperAdmin
        ? ['citoyen', 'admin', 'superadmin', 'educator', 'pointManager', 'collector', 'intercommunality']
        : ['citoyen', 'educator', 'pointManager', 'collector', 'intercommunality'];
    if (isEditing && !availableRoles.contains(selectedRole)) availableRoles.add(selectedRole);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDS) {
          final screenH = MediaQuery.of(ctx).size.height;
          final bottomInsets = MediaQuery.of(ctx).viewInsets.bottom;
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            insetPadding: EdgeInsets.only(
              left: 24, right: 24,
              top: 24,
              bottom: bottomInsets > 0 ? bottomInsets + 8 : 24,
            ),
            title: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(isEditing ? Icons.edit_rounded : Icons.person_add_rounded, color: AppTheme.primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEditing ? 'Modifier Utilisateur' : 'Nouvel Utilisateur',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: (screenH - bottomInsets) * 0.58,
                minWidth: double.maxFinite,
              ),
              child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const SizedBox(height: 8),
                if (errorMsg != null) Container(
                  padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.red.shade900.withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade400)),
                  child: Row(children: [Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 18), const SizedBox(width: 8), Expanded(child: Text(errorMsg!, style: GoogleFonts.inter(fontSize: 12, color: Colors.red.shade200)))]),
                ),
                if (!isEditing) ...[_buildField(emailCtrl, 'Email', Icons.email_outlined, hint: 'exemple@gmail.com', keyboardType: TextInputType.emailAddress), const SizedBox(height: 12)],
                _buildField(nameCtrl, 'Nom complet', Icons.person_outline_rounded),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole, isExpanded: true,
                  dropdownColor: const Color(0xFF1E293B),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  items: availableRoles.map((r) => DropdownMenuItem(value: r, child: Row(children: [Icon(_getRoleIcon(r), size: 16, color: _getRoleColor(r)), const SizedBox(width: 8), Text(_getRoleLabel(r), style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))]))).toList(),
                  onChanged: (v) => selectedRole = v!,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: Color(0xFF00BFA6)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00BFA6), width: 1.5)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                _buildField(pwdCtrl, isEditing ? 'Nouveau mot de passe' : 'Mot de passe', Icons.lock_outline_rounded, obscure: true, helper: isEditing ? 'Laisser vide pour garder l\'actuel' : null),
                const SizedBox(height: 12),
                _buildField(confirmPwdCtrl, 'Confirmer le mot de passe', Icons.lock_rounded, obscure: true),
                const SizedBox(height: 8),
              ])),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Annuler', style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                onPressed: () {
                  if (!isEditing) {
                    final email = emailCtrl.text.trim();
                    if (email.isEmpty || !RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(email)) { setDS(() => errorMsg = 'Email invalide'); return; }
                  }
                  if (nameCtrl.text.trim().isEmpty) { setDS(() => errorMsg = 'Nom requis'); return; }
                  final pwd = pwdCtrl.text;
                  if (!isEditing && pwd.isEmpty) { setDS(() => errorMsg = 'Mot de passe requis'); return; }
                  if (pwd.isNotEmpty && pwd.length < 6) { setDS(() => errorMsg = 'Au moins 6 caracteres'); return; }
                  if (pwd.isNotEmpty && pwd != confirmPwdCtrl.text) { setDS(() => errorMsg = 'Mots de passe differents'); return; }
                  Navigator.pop(ctx);
                  _processUser(isEditing: isEditing, userId: user?['id'], email: emailCtrl.text.trim(), name: nameCtrl.text.trim(), role: selectedRole, password: pwd);
                },
                child: Text(isEditing ? 'Sauvegarder' : 'Créer', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {String? hint, bool obscure = false, String? helper, TextInputType? keyboardType}) {
    return TextField(
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      cursorColor: const Color(0xFF00BFA6),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
        helperText: helper,
        helperStyle: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF00BFA6)),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00BFA6), width: 1.5)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Future<void> _processUser({required bool isEditing, int? userId, required String email, required String name, required String role, required String password}) async {
    setState(() => _isLoading = true);
    Map<String, dynamic> result;
    if (isEditing) {
      result = await _authService.updateUserAdmin(userId: userId!, fullName: name, role: role, password: password.isNotEmpty ? password : null);
    } else {
      result = await _authService.createUserAdmin(email: email, fullName: name, role: role, password: password);
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (result['success']) {
      await _loadUsers();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Utilisateur enregistre', style: GoogleFonts.inter(fontWeight: FontWeight.w600)), backgroundColor: AppTheme.primaryGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    } else {
      setState(() => _isLoading = false);
      if (!mounted) return;
      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Erreur'), content: Text(result['message'] ?? 'Erreur inconnue'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Compris'))]));
    }
  }

  Future<void> _deleteUser(int userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red.shade400), const SizedBox(width: 10), const Text('Confirmation')]),
        content: const Text('Cette action est irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await _authService.deleteUserAdmin(userId);
      if (success) {
        await _loadUsers();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de supprimer.'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? ListView(
              padding: const EdgeInsets.only(top: 12),
              children: [
                // Skeleton KPI banner
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SkeletonKpiRow(count: 3),
                ),
                const SizedBox(height: 8),
                // Skeleton search bar
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SkeletonBox(height: 48, radius: 14),
                ),
                const SizedBox(height: 12),
                // Skeleton user rows
                ...List.generate(8, (_) => const SkeletonUserTile()),
              ],
            )
          : _errorMessage != null
              ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_off_rounded, size: 60, color: Colors.grey.shade300), const SizedBox(height: 16), Text(_errorMessage!, style: GoogleFonts.inter(color: AppTheme.textMuted), textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton.icon(onPressed: _loadUsers, icon: const Icon(Icons.refresh_rounded), label: const Text('Reessayer'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen))])))
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(children: [
                    const _KpisFirebase(),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100, borderRadius: BorderRadius.circular(14), border: Border.all(color: _searchQuery.isNotEmpty ? AppTheme.primaryGreen.withOpacity(0.5) : Colors.transparent)),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: InputDecoration(hintText: 'Rechercher par nom ou email...', hintStyle: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14), prefixIcon: Icon(Icons.search_rounded, color: _searchQuery.isNotEmpty ? AppTheme.primaryGreen : AppTheme.textMuted), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); }) : null, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _roleFilters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final (role, label, icon) = _roleFilters[i];
                          final count = _countByRole(role);
                          final isSelected = _selectedRole == role;
                          final color = role == 'tous' ? AppTheme.primaryGreen : _getRoleColor(role);
                          return GestureDetector(
                            onTap: () => setState(() => _selectedRole = role),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: isSelected ? color : color.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? color : color.withOpacity(0.25), width: isSelected ? 1.5 : 1)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(icon, size: 13, color: isSelected ? Colors.white : color),
                                const SizedBox(width: 5),
                                Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : color)),
                                if (count > 0) ...[const SizedBox(width: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.25) : color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Text('', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : color)))],
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(children: [
                        Text('${_filteredUsers.length} utilisateur${_filteredUsers.length > 1 ? 's' : ''}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                        const Spacer(),
                        const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.textMuted),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: _filteredUsers.isEmpty
                          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300), const SizedBox(height: 12), Text('Aucun resultat', style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textMuted)), if (_searchQuery.isNotEmpty || _selectedRole != 'tous') TextButton(onPressed: () => setState(() { _searchQuery = ''; _searchCtrl.clear(); _selectedRole = 'tous'; }), child: const Text('Reinitialiser les filtres'))]))
                          : RefreshIndicator(
                              onRefresh: _loadUsers,
                              color: AppTheme.primaryGreen,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                                itemCount: _filteredUsers.length,
                                itemBuilder: (_, i) {
                                  final u = _filteredUsers[i];
                                  final role = (u['role'] ?? 'citoyen') as String;
                                  final roleColor = _getRoleColor(role);
                                  final userName = (u['full_name'] ?? 'Sans nom') as String;
                                  final userEmail = (u['email'] ?? '') as String;
                                  final score = (u['global_score'] as num?)?.toDouble() ?? (u['score'] as num?)?.toDouble();
                                  final isCitoyen = role == 'citoyen';
                                  final isAdminRole = role == 'admin' || role == 'superadmin';
                                  final canEdit = AuthState.currentUser?.role == UserRole.superadmin || !isAdminRole;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2332) : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: roleColor.withOpacity(0.12)), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(18),
                                        onTap: canEdit ? () => _showUserDialog(user: u) : null,
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Row(children: [
                                            Container(
                                              width: 50, height: 50,
                                              decoration: BoxDecoration(gradient: LinearGradient(colors: [roleColor.withOpacity(0.2), roleColor.withOpacity(0.08)], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle, border: Border.all(color: roleColor.withOpacity(0.3))),
                                              child: Center(child: Text(userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : '?', style: TextStyle(color: roleColor, fontWeight: FontWeight.w900, fontSize: 20))),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              Row(children: [
                                                Expanded(child: Text(userName, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Colors.white : AppTheme.deepSlate), overflow: TextOverflow.ellipsis)),
                                                if (isCitoyen && score != null && score > 0)
                                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade400]), borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.stars_rounded, color: Colors.white, size: 11), const SizedBox(width: 3), Text('${score.toStringAsFixed(0)} pts', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))])),
                                              ]),
                                              const SizedBox(height: 2),
                                              Text(userEmail, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted), overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 6),
                                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: roleColor.withOpacity(0.2))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_getRoleIcon(role), size: 10, color: roleColor), const SizedBox(width: 4), Text(_getRoleLabel(role).toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: roleColor, letterSpacing: 0.5))])),
                                            ])),
                                            if (canEdit) ...[
                                              const SizedBox(width: 4),
                                              Column(mainAxisSize: MainAxisSize.min, children: [
                                                GestureDetector(onTap: () => _showUserDialog(user: u), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withOpacity(0.2))), child: const Icon(Icons.edit_outlined, color: Colors.blue, size: 16))),
                                                const SizedBox(height: 4),
                                                GestureDetector(onTap: () => _deleteUser(u['id'], userName), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.withOpacity(0.2))), child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16))),
                                              ]),
                                            ],
                                          ]),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ]),
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_user_management_add',
        onPressed: () => _showUserDialog(),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text('AJOUTER', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  String _getRoleLabel(String role) {
    const map = {'superadmin': 'Super Admin', 'admin': 'Administrateur', 'educator': 'Educateur', 'pointManager': 'Gestionnaire', 'collector': 'Collecteur', 'intercommunality': 'Intercommunalite', 'citoyen': 'Citoyen'};
    return map[role] ?? role;
  }

  Color _getRoleColor(String role) {
    const map = {'superadmin': Colors.deepPurple, 'admin': Colors.red, 'educator': Colors.orange, 'pointManager': Colors.purple, 'collector': Colors.brown, 'intercommunality': Colors.blue, 'citoyen': Colors.green};
    return map[role] ?? Colors.grey;
  }

  IconData _getRoleIcon(String role) {
    const map = {'superadmin': Icons.security_rounded, 'admin': Icons.admin_panel_settings_rounded, 'educator': Icons.school_rounded, 'pointManager': Icons.store_rounded, 'collector': Icons.recycling_rounded, 'intercommunality': Icons.account_balance_rounded, 'citoyen': Icons.person_rounded};
    return map[role] ?? Icons.person_outline_rounded;
  }
}

class _KpisFirebase extends StatelessWidget {
  const _KpisFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<AdminStatsSnapshot>(
      stream: FirebaseAdminStatsService().watchAdminStats(),
      builder: (ctx, snap) {
        final s = snap.data ?? AdminStatsSnapshot.empty();
        final isLive = snap.hasData;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: isDark ? [const Color(0xFF0F2027), const Color(0xFF1A3A2A)] : [AppTheme.primaryGreen.withOpacity(0.08), Colors.blue.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: isLive ? AppTheme.primaryGreen.withOpacity(0.15) : Colors.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: isLive ? AppTheme.primaryGreen : Colors.grey, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(isLive ? 'Firebase - Temps reel' : 'Connexion...', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: isLive ? AppTheme.primaryGreen : Colors.grey)),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Kpi(icon: Icons.people_rounded, color: Colors.blue, value: '${s.totalUsers}', label: 'Inscrits', sub: 'Total')),
              const SizedBox(width: 10),
              Expanded(child: _Kpi(icon: Icons.person_add_rounded, color: Colors.indigo, value: '+${s.newUsersMonth}', label: 'Nouveaux', sub: 'Ce mois')),
              const SizedBox(width: 10),
              Expanded(child: _Kpi(icon: Icons.trending_up_rounded, color: AppTheme.primaryGreen, value: '${s.activeUsersWeek}', label: 'Actifs', sub: 'Cette sem.')),
              const SizedBox(width: 10),
              Expanded(child: _Kpi(icon: Icons.stars_rounded, color: Colors.amber, value: s.averageScore.toStringAsFixed(1), label: 'Score moy.', sub: 'Moyenne')),
            ]),
          ]),
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String sub;
  const _Kpi({required this.icon, required this.color, required this.value, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: isDark ? color.withOpacity(0.08) : color.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.deepSlate), maxLines: 1),
        Text(sub, style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textMuted), maxLines: 1),
      ]),
    );
  }
}
