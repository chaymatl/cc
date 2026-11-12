// ignore_for_file: prefer_const_constructors
// ignore_for_file: avoid_dynamic_calls
// lib/screens/educator/create_meeting_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/meetings_service.dart';
import '../../services/groups_service.dart';
import '../../models/user_model.dart';

class CreateMeetingScreen extends StatefulWidget {
  final Map<String, dynamic>? existingMeeting;
  const CreateMeetingScreen({super.key, this.existingMeeting});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _searchCtrl = TextEditingController();

  DateTime  _selectedDate    = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime    = const TimeOfDay(hour: 10, minute: 0);
  int       _durationMinutes = 60;
  String    _audience        = 'all';
  bool      _isLoading       = false;

  List<dynamic> _groups           = [];
  int?          _selectedGroupId;

  List<dynamic> _allCitizens      = [];
  List<dynamic> _filteredCitizens = [];
  final Set<int> _selectedCitizenIds = {};
  bool _citizensLoaded  = false;
  bool _citizensLoading = false;

  static const _kGreen = Color(0xFF00C896);

  // ── Palette adaptative ───────────────────────────────────────────────────
  Color _bg(bool dark)       => dark ? const Color(0xFF0F1923) : Colors.white;
  Color _card(bool dark)     => dark ? const Color(0xFF1A2634) : const Color(0xFFF5F7FA);
  Color _border(bool dark)   => dark ? const Color(0xFF2D3F50) : const Color(0xFFE2E8F0);
  Color _textMain(bool dark) => dark ? Colors.white : const Color(0xFF0F172A);
  Color _textSub(bool dark)  => dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color _textHint(bool dark) => dark ? const Color(0xFF4A5568) : const Color(0xFFB0BAC9);

  @override
  void initState() {
    super.initState();
    _loadGroups();
    final m = widget.existingMeeting;
    if (m != null) {
      _titleCtrl.text  = m['title'] ?? '';
      _descCtrl.text   = m['description'] ?? '';
      _audience        = m['audience'] ?? 'all';
      _durationMinutes = m['duration_minutes'] ?? 60;
      if (m['scheduled_at'] != null) {
        final dt = DateTime.tryParse(m['scheduled_at']) ?? _selectedDate;
        _selectedDate = dt;
        _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
      if (_audience == 'group') {
        final parts = m['participants'] as List? ?? [];
        for (final p in parts) {
          if (p['user_id'] != null) _selectedCitizenIds.add(p['user_id'] as int);
        }
      }
    }
    _searchCtrl.addListener(_onSearchChanged);
  }

  Future<void> _loadGroups() async {
    final data = await GroupsService.getMyGroups();
    if (mounted) setState(() => _groups = data);
  }

  Future<void> _loadCitizens({bool forceRefresh = false}) async {
    // Recharger si forcé (refresh) ou si jamais chargé
    if (_citizensLoaded && !forceRefresh) return;
    setState(() => _citizensLoading = true);
    final data = await MeetingsService.fetchCitizens();
    if (mounted) {
      setState(() {
        _allCitizens      = data;
        _filteredCitizens = data;
        _citizensLoaded   = true;
        _citizensLoading  = false;
      });
    }
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredCitizens = q.isEmpty
          ? _allCitizens
          : _allCitizens.where((c) {
              final name  = (c['full_name'] as String? ?? '').toLowerCase();
              final email = (c['email'] as String? ?? '').toLowerCase();
              return name.contains(q) || email.contains(q);
            }).toList();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  DateTime get _scheduledAt => DateTime(
    _selectedDate.year, _selectedDate.month, _selectedDate.day,
    _selectedTime.hour, _selectedTime.minute,
  );

  Future<void> _pickDate(bool dark) async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: dark
            ? ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _kGreen))
            : ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: _kGreen)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime(bool dark) async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: dark
            ? ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _kGreen))
            : ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: _kGreen)),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_audience == 'citizens' && _selectedCitizenIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sélectionnez au moins un citoyen'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    if (!AuthState.hasValidToken) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Session expirée, veuillez vous reconnecter'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    setState(() => _isLoading = true);

    final bool isEdit = widget.existingMeeting != null;
    final apiAudience = _audience == 'citizens' ? 'group' : _audience;
    final citizenIds  = _audience == 'citizens' ? _selectedCitizenIds.toList() : <int>[];
    bool ok = false;

    try {
      if (isEdit) {
        ok = await MeetingsService.updateMeeting(widget.existingMeeting!['id'], {
          'title':            _titleCtrl.text.trim(),
          'description':      _descCtrl.text.trim(),
          'scheduled_at':     _scheduledAt.toIso8601String(),
          'duration_minutes': _durationMinutes,
          'audience':         apiAudience,
          'citizen_ids':      citizenIds,
        });
      } else {
        final result = await MeetingsService.createMeeting(
          title:           _titleCtrl.text.trim(),
          description:     _descCtrl.text.trim(),
          scheduledAt:     _scheduledAt,
          durationMinutes: _durationMinutes,
          audience:        apiAudience,
          citizenIds:      citizenIds,
          groupId:         _audience == 'group' ? _selectedGroupId : null,
        );
        ok = result['success'] == true;
      }
    } catch (_) { ok = false; }

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEdit ? 'Séance modifiée !' : 'Séance créée et citoyens notifiés !'),
        backgroundColor: _kGreen,
      ));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erreur lors de la sauvegarde'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark   = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existingMeeting != null;

    return Scaffold(
      backgroundColor: _bg(dark),
      appBar: AppBar(
        backgroundColor: _bg(dark),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: _textMain(dark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Modifier la séance' : 'Planifier une séance',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            color: _textMain(dark),
            fontSize: 18,
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2.5)),
            ))
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  elevation: 0,
                ),
                child: Text(
                  isEdit ? 'Enregistrer' : 'Créer',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: _border(dark)),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [

              // ── Titre ───────────────────────────────────────────────────
              _Label('Nom du cours', dark: dark),
              _Field(
                controller: _titleCtrl,
                hint: 'Ex : Tri des déchets plastiques',
                icon: Icons.menu_book_rounded,
                dark: dark,
                validator: (v) => (v == null || v.isEmpty) ? 'Titre requis' : null,
              ),
              const SizedBox(height: 20),

              // ── Description ─────────────────────────────────────────────
              _Label('Description / Objectifs', dark: dark),
              _Field(
                controller: _descCtrl,
                hint: 'Décrivez les objectifs de cette séance...',
                icon: Icons.notes_rounded,
                dark: dark,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // ── Date & Heure ─────────────────────────────────────────────
              _Label('Date & Heure', dark: dark),
              Row(children: [
                Expanded(child: _DateChip(
                  icon: Icons.calendar_today_rounded,
                  label: DateFormat('dd/MM/yyyy').format(_selectedDate),
                  dark: dark,
                  onTap: () => _pickDate(dark),
                )),
                const SizedBox(width: 12),
                Expanded(child: _DateChip(
                  icon: Icons.access_time_rounded,
                  label: _selectedTime.format(context),
                  dark: dark,
                  onTap: () => _pickTime(dark),
                )),
              ]),
              const SizedBox(height: 20),

              // ── Durée ────────────────────────────────────────────────────
              _Label('Durée de la séance', dark: dark),
              _DurationSelector(
                value: _durationMinutes,
                dark: dark,
                onChanged: (v) => setState(() => _durationMinutes = v),
              ),
              const SizedBox(height: 20),

              // ── Destinataires ────────────────────────────────────────────
              _Label('Destinataires', dark: dark),
              _AudienceSelector(
                value: _audience,
                dark: dark,
                onChanged: (v) {
                  setState(() => _audience = v);
                  if (v == 'citizens') _loadCitizens();
                },
              ),

              // ── Groupe ciblé ──────────────────────────────────────────────
              if (_audience == 'group') ...[
                const SizedBox(height: 16),
                _Label('Sélectionner un groupe', dark: dark),
                if (_groups.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _card(dark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border(dark)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedGroupId,
                        dropdownColor: _card(dark),
                        isExpanded: true,
                        hint: Row(children: [
                          const Icon(Icons.group_rounded, color: _kGreen, size: 20),
                          const SizedBox(width: 8),
                          Text('Choisir un groupe',
                            style: GoogleFonts.inter(color: _textHint(dark))),
                        ]),
                        items: [
                          DropdownMenuItem<int?>(value: null,
                            child: Text('- Aucun groupe -',
                              style: GoogleFonts.inter(color: _textSub(dark)))),
                          ..._groups.map((g) => DropdownMenuItem<int?>(
                            value: g['id'] as int,
                            child: Row(children: [
                              Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: _hexColor(g['color'] ?? '#00C896'),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${g['name']} (${g['member_count']} membres)',
                                style: GoogleFonts.inter(color: _textMain(dark))),
                            ]),
                          )),
                        ],
                        onChanged: (v) => setState(() => _selectedGroupId = v),
                      ),
                    ),
                  )
                else
                  _InfoBox(
                    'Aucun groupe. Créez d\'abord un groupe depuis votre tableau de bord.',
                    dark: dark,
                  ),
              ],

              // ── Citoyens individuels ──────────────────────────────────────
              if (_audience == 'citizens') ...[
                const SizedBox(height: 16),

                // Récap sélectionnés
                if (_selectedCitizenIds.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _kGreen.withOpacity(dark ? 0.1 : 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _kGreen.withOpacity(0.35), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge compteur
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _kGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.people_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              '${_selectedCitizenIds.length} sélectionné(s)',
                              style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        // Chips des citoyens choisis
                        Wrap(
                          spacing: 8, runSpacing: 6,
                          children: _selectedCitizenIds.map((id) {
                            final c = _allCitizens.firstWhere(
                              (x) => x['id'] == id,
                              orElse: () => {'full_name': '#$id'},
                            );
                            final name = c['full_name'] as String? ?? '';
                            final initials = name.trim().split(' ')
                                .where((w) => w.isNotEmpty).take(2)
                                .map((w) => w[0].toUpperCase()).join();
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: dark ? const Color(0xFF1E3A2F) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _kGreen, width: 1.5),
                                boxShadow: dark ? [] : [
                                  BoxShadow(
                                    color: _kGreen.withOpacity(0.1),
                                    blurRadius: 6, offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                CircleAvatar(
                                  radius: 11,
                                  backgroundColor: _kGreen,
                                  child: Text(initials,
                                    style: const TextStyle(
                                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  name,
                                  style: GoogleFonts.inter(
                                    color: _textMain(dark),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => setState(() => _selectedCitizenIds.remove(id)),
                                  child: Icon(Icons.close_rounded, size: 15, color: _textSub(dark)),
                                ),
                              ]),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Barre de recherche
                Row(
                  children: [
                    Expanded(child: _Label('Rechercher un citoyen', dark: dark)),
                    // Bouton refresh : recharge la liste depuis le serveur
                    IconButton(
                      icon: _citizensLoading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _kGreen))
                          : const Icon(Icons.refresh_rounded, color: _kGreen, size: 20),
                      tooltip: 'Actualiser la liste',
                      onPressed: _citizensLoading ? null : () => _loadCitizens(forceRefresh: true),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _searchCtrl,
                  style: GoogleFonts.inter(color: _textMain(dark), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Nom ou email...',
                    hintStyle: GoogleFonts.inter(color: _textHint(dark)),
                    prefixIcon: const Icon(Icons.search_rounded, color: _kGreen, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: _textHint(dark), size: 18),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: _card(dark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _border(dark)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _border(dark)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kGreen, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Liste citoyens
                if (_citizensLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2.5),
                  ))
                else if (_filteredCitizens.isEmpty && _citizensLoaded)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _card(dark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border(dark)),
                    ),
                    child: Center(child: Text('Aucun citoyen trouvé',
                      style: GoogleFonts.inter(color: _textSub(dark)))),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF1A2634) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border(dark)),
                      boxShadow: dark ? [] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _filteredCitizens.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: _border(dark)),
                      itemBuilder: (ctx, i) {
                        final c   = _filteredCitizens[i];
                        final id  = c['id'] as int;
                        final sel = _selectedCitizenIds.contains(id);
                        final name = c['full_name'] as String? ?? '';
                        final initials = name.trim().split(' ')
                            .where((w) => w.isNotEmpty).take(2)
                            .map((w) => w[0].toUpperCase()).join();
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          tileColor: sel
                              ? _kGreen.withOpacity(dark ? 0.12 : 0.05)
                              : (dark ? const Color(0xFF1A2634) : Colors.white),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: sel
                                ? _kGreen
                                : (dark ? const Color(0xFF2D3F50) : const Color(0xFFE2E8F0)),
                            child: Text(initials,
                              style: TextStyle(
                                color: sel ? Colors.white : _textSub(dark),
                                fontSize: 13, fontWeight: FontWeight.bold,
                              )),
                          ),
                          title: Text(name,
                            style: GoogleFonts.inter(
                              color: _textMain(dark),
                              fontSize: 14,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                            )),
                          subtitle: Text(c['email'] as String? ?? '',
                            style: GoogleFonts.inter(color: _textSub(dark), fontSize: 12)),
                          trailing: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            child: sel
                                ? Container(
                                    key: const ValueKey('checked'),
                                    width: 26, height: 26,
                                    decoration: BoxDecoration(
                                      color: _kGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                  )
                                : Container(
                                    key: const ValueKey('unchecked'),
                                    width: 26, height: 26,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _border(dark), width: 1.5),
                                    ),
                                  ),
                          ),
                          onTap: () => setState(() {
                            if (sel) { _selectedCitizenIds.remove(id); }
                            else { _selectedCitizenIds.add(id); }
                          }),
                        );
                      },
                    ),
                  ),

                // Tout sélectionner
                if (_filteredCitizens.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton.icon(
                      onPressed: () => setState(() {
                        final allIds = _filteredCitizens.map((c) => c['id'] as int).toSet();
                        if (allIds.every(_selectedCitizenIds.contains)) {
                          _selectedCitizenIds.removeAll(allIds);
                        } else {
                          _selectedCitizenIds.addAll(allIds);
                        }
                      }),
                      icon: Icon(
                        _filteredCitizens.map((c) => c['id'] as int).every(_selectedCitizenIds.contains)
                            ? Icons.deselect_rounded
                            : Icons.select_all_rounded,
                        size: 16, color: _kGreen,
                      ),
                      label: Text(
                        _filteredCitizens.map((c) => c['id'] as int).every(_selectedCitizenIds.contains)
                            ? 'Tout désélectionner'
                            : 'Tout sélectionner',
                        style: GoogleFonts.inter(
                          color: _kGreen, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                ],
              ],

              const SizedBox(height: 28),

              // ── Info Meet ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(dark ? 0.1 : 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kGreen.withOpacity(0.25)),
                ),
                child: Row(children: [
                  const Icon(Icons.video_camera_front_rounded, color: _kGreen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    'Un lien Google Meet unique sera généré automatiquement et partagé avec les participants.',
                    style: GoogleFonts.inter(color: _textSub(dark), fontSize: 13, height: 1.5),
                  )),
                ]),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ── Sous-widgets ──────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final bool dark;
  const _Label(this.text, {required this.dark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.outfit(
      color: dark ? Colors.white : const Color(0xFF0F172A),
      fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3,
    )),
  );
}

class _InfoBox extends StatelessWidget {
  final String text;
  final bool dark;
  const _InfoBox(this.text, {required this.dark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: dark ? const Color(0xFF1A2634) : const Color(0xFFF5F7FA),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: dark ? const Color(0xFF2D3F50) : const Color(0xFFE2E8F0)),
    ),
    child: Row(children: [
      const Icon(Icons.info_outline_rounded, color: Color(0xFF00C896), size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(text,
        style: GoogleFonts.inter(
          color: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          fontSize: 12))),
    ]),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final bool dark;
  final String? Function(String?)? validator;
  const _Field({
    required this.controller, required this.hint, required this.icon,
    required this.dark, this.maxLines = 1, this.validator,
  });

  static const _kGreen = Color(0xFF00C896);

  Color get _cardColor   => dark ? const Color(0xFF1A2634) : const Color(0xFFF5F7FA);
  Color get _borderColor => dark ? const Color(0xFF2D3F50) : const Color(0xFFE2E8F0);
  Color get _textColor   => dark ? Colors.white : const Color(0xFF0F172A);
  Color get _hintColor   => dark ? const Color(0xFF4A5568) : const Color(0xFFB0BAC9);

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    validator: validator,
    style: GoogleFonts.inter(color: _textColor, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: _hintColor),
      prefixIcon: Icon(icon, color: _kGreen, size: 20),
      filled: true,
      fillColor: _cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    ),
  );
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dark;
  final VoidCallback onTap;
  const _DateChip({required this.icon, required this.label, required this.dark, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A2634) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dark ? const Color(0xFF2D3F50) : const Color(0xFFE2E8F0)),
      ),
      child: Row(children: [
        const Icon(Icons.edit_calendar_rounded, color: Color(0xFF00C896), size: 18),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(
          color: dark ? Colors.white : const Color(0xFF0F172A),
          fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

class _DurationSelector extends StatelessWidget {
  final int value;
  final bool dark;
  final ValueChanged<int> onChanged;
  static const _options = [30, 45, 60, 90, 120];
  const _DurationSelector({required this.value, required this.dark, required this.onChanged});

  static const _kGreen = Color(0xFF00C896);

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    children: _options.map((d) {
      final selected = d == value;
      return ChoiceChip(
        label: Text('$d min'),
        selected: selected,
        onSelected: (_) => onChanged(d),
        selectedColor: _kGreen,
        backgroundColor: dark ? const Color(0xFF1A2634) : const Color(0xFFF5F7FA),
        side: BorderSide(
          color: selected ? _kGreen : (dark ? const Color(0xFF2D3F50) : const Color(0xFFE2E8F0)),
        ),
        labelStyle: GoogleFonts.inter(
          color: selected ? Colors.white : (dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
      );
    }).toList(),
  );
}

class _AudienceSelector extends StatelessWidget {
  final String value;
  final bool dark;
  final ValueChanged<String> onChanged;
  const _AudienceSelector({required this.value, required this.dark, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: _AudienceChip(
      icon: Icons.public_rounded,
      label: 'Tous les\ncitoyens',
      selected: value == 'all',
      dark: dark,
      onTap: () => onChanged('all'),
    )),
    const SizedBox(width: 10),
    Expanded(child: _AudienceChip(
      icon: Icons.person_search_rounded,
      label: 'Citoyens\nspécifiques',
      selected: value == 'citizens',
      dark: dark,
      onTap: () => onChanged('citizens'),
    )),
    const SizedBox(width: 10),
    Expanded(child: _AudienceChip(
      icon: Icons.group_rounded,
      label: 'Groupe\nciblé',
      selected: value == 'group',
      dark: dark,
      onTap: () => onChanged('group'),
    )),
  ]);
}

class _AudienceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;
  const _AudienceChip({
    required this.icon, required this.label,
    required this.selected, required this.dark, required this.onTap,
  });

  static const _kGreen = Color(0xFF00C896);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? _kGreen.withOpacity(dark ? 0.15 : 0.1)
            : (dark ? const Color(0xFF1A2634) : const Color(0xFFF5F7FA)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? _kGreen : (dark ? const Color(0xFF2D3F50) : const Color(0xFFE2E8F0)),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon,
          color: selected ? _kGreen : (dark ? const Color(0xFF4A5568) : const Color(0xFF94A3B8)),
          size: 22),
        const SizedBox(height: 6),
        Text(label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: selected ? _kGreen : (dark ? const Color(0xFF64748B) : const Color(0xFF64748B)),
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            height: 1.3,
          )),
      ]),
    ),
  );
}
