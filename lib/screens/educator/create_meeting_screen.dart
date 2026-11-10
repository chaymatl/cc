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
  final Map<String, dynamic>? existingMeeting; // non-null = mode édition
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
  String    _audience        = 'all';  // 'all' | 'group' | 'citizens'
  bool      _isLoading       = false;

  // Groupes
  List<dynamic> _groups          = [];
  int?          _selectedGroupId;

  // Citoyens sélectionnés manuellement
  List<dynamic> _allCitizens     = [];
  List<dynamic> _filteredCitizens = [];
  final Set<int> _selectedCitizenIds = {};
  bool _citizensLoaded = false;
  bool _citizensLoading = false;

  static const _kGreen = Color(0xFF00C896);

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
      // Pré-sélectionner les participants existants si mode citizens
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

  Future<void> _loadCitizens() async {
    if (_citizensLoaded) return;
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

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _kGreen),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _kGreen),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Vérification : si citoyens, au moins 1 sélectionné
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
    bool ok = false;

    // Mapper audience 'citizens' → 'group' côté API (avec citizen_ids)
    final apiAudience  = _audience == 'citizens' ? 'group' : _audience;
    final citizenIds   = _audience == 'citizens'
        ? _selectedCitizenIds.toList()
        : <int>[];

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
    } catch (e) {
      ok = false;
    }

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
    final isEdit = widget.existingMeeting != null;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1923),
        elevation: 0,
        title: Text(
          isEdit ? 'Modifier la séance' : 'Planifier une séance',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2)),
            ))
          else
            TextButton(
              onPressed: _submit,
              child: Text(isEdit ? 'Enregistrer' : 'Créer',
                style: GoogleFonts.outfit(color: _kGreen, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionLabel('Nom du cours'),
              _StyledField(
                controller: _titleCtrl,
                hint: 'Ex : Tri des déchets plastiques',
                icon: Icons.menu_book_rounded,
                validator: (v) => (v == null || v.isEmpty) ? 'Titre requis' : null,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Description / Objectifs'),
              _StyledField(
                controller: _descCtrl,
                hint: 'Décrivez les objectifs de cette séance...',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Date & Heure'),
              Row(children: [
                Expanded(child: _DateTimeChip(
                  icon: Icons.calendar_today_rounded,
                  label: DateFormat('dd/MM/yyyy').format(_selectedDate),
                  onTap: _pickDate,
                )),
                const SizedBox(width: 12),
                Expanded(child: _DateTimeChip(
                  icon: Icons.access_time_rounded,
                  label: _selectedTime.format(context),
                  onTap: _pickTime,
                )),
              ]),
              const SizedBox(height: 20),

              _SectionLabel('Durée de la séance'),
              _DurationSelector(
                value: _durationMinutes,
                onChanged: (v) => setState(() => _durationMinutes = v),
              ),
              const SizedBox(height: 20),

              _SectionLabel('Destinataires'),
              _AudienceSelector(
                value: _audience,
                onChanged: (v) {
                  setState(() { _audience = v; });
                  if (v == 'citizens') _loadCitizens();
                },
              ),

              // ── Groupe ciblé ──────────────────────────────────────────────
              if (_audience == 'group') ...[
                const SizedBox(height: 12),
                _SectionLabel('Sélectionner un groupe'),
                if (_groups.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2634),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedGroupId,
                        dropdownColor: const Color(0xFF1A2634),
                        isExpanded: true,
                        hint: Row(children: [
                          const Icon(Icons.group_rounded, color: Color(0xFF00C896), size: 20),
                          const SizedBox(width: 8),
                          Text('Choisir un groupe',
                            style: GoogleFonts.inter(color: Colors.white38)),
                        ]),
                        items: [
                          DropdownMenuItem<int?>(value: null,
                            child: Text('- Aucun groupe -',
                              style: GoogleFonts.inter(color: Colors.white54))),
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
                                style: GoogleFonts.inter(color: Colors.white)),
                            ]),
                          )),
                        ],
                        onChanged: (v) => setState(() => _selectedGroupId = v),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2634),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF00C896), size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        'Aucun groupe. Créez d\'abord un groupe depuis votre tableau de bord.',
                        style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                      )),
                    ]),
                  ),
              ],

              // ── Citoyens individuels ──────────────────────────────────────
              if (_audience == 'citizens') ...[
                const SizedBox(height: 16),
                // Chips des citoyens sélectionnés
                if (_selectedCitizenIds.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002E22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _kGreen.withOpacity(0.5), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _kGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.people_rounded, color: Colors.black, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                '${_selectedCitizenIds.length} sélectionné(s)',
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8, runSpacing: 6,
                          children: _selectedCitizenIds.map((id) {
                            final c = _allCitizens.firstWhere(
                              (x) => x['id'] == id,
                              orElse: () => {'full_name': '#$id'},
                            );
                            return RawChip(
                              backgroundColor: const Color(0xFF004D3A),
                              side: const BorderSide(color: _kGreen, width: 1.5),
                              avatar: CircleAvatar(
                                backgroundColor: _kGreen,
                                child: Text(
                                  (c['full_name'] as String? ?? '?').isNotEmpty
                                      ? (c['full_name'] as String)[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              label: Text(
                                c['full_name'] as String? ?? '',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              deleteIcon: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: _kGreen,
                              ),
                              onDeleted: () => setState(() => _selectedCitizenIds.remove(id)),
                              selected: false,
                              onSelected: null,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Barre de recherche
                _SectionLabel('Rechercher un citoyen'),
                TextFormField(
                  controller: _searchCtrl,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nom ou email...',
                    hintStyle: GoogleFonts.inter(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search_rounded, color: _kGreen, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                            onPressed: () { _searchCtrl.clear(); },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF1A2634),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kGreen, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Liste des citoyens
                if (_citizensLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2),
                  ))
                else if (_filteredCitizens.isEmpty && _citizensLoaded)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2634),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(
                      'Aucun citoyen trouvé',
                      style: GoogleFonts.inter(color: Colors.white38),
                    )),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2634),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _filteredCitizens.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1, color: Colors.white.withOpacity(0.06),
                      ),
                      itemBuilder: (ctx, i) {
                        final c   = _filteredCitizens[i];
                        final id  = c['id'] as int;
                        final sel = _selectedCitizenIds.contains(id);
                        final initials = (c['full_name'] as String? ?? '?')
                            .split(' ')
                            .where((w) => w.isNotEmpty)
                            .take(2)
                            .map((w) => w[0].toUpperCase())
                            .join();
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: sel
                                ? _kGreen.withOpacity(0.3)
                                : Colors.white.withOpacity(0.07),
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: sel ? _kGreen : Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            c['full_name'] as String? ?? '',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            c['email'] as String? ?? '',
                            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                          ),
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
                                    child: const Icon(Icons.check_rounded, color: Colors.black, size: 16),
                                  )
                                : Container(
                                    key: const ValueKey('unchecked'),
                                    width: 26, height: 26,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white24, width: 1.5),
                                    ),
                                  ),
                          ),
                          onTap: () => setState(() {
                            if (sel) {
                              _selectedCitizenIds.remove(id);
                            } else {
                              _selectedCitizenIds.add(id);
                            }
                          }),
                        );
                      },
                    ),
                  ),
                // Bouton Tout sélectionner / Tout désélectionner
                if (_filteredCitizens.isNotEmpty) ...[
                  const SizedBox(height: 8),
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
                        size: 16,
                        color: _kGreen,
                      ),
                      label: Text(
                        _filteredCitizens.map((c) => c['id'] as int).every(_selectedCitizenIds.contains)
                            ? 'Tout désélectionner'
                            : 'Tout sélectionner',
                        style: GoogleFonts.inter(color: _kGreen, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                ],
              ],

              const SizedBox(height: 32),

              // -- Info Meet --------------------------------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kGreen.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.video_camera_front_rounded, color: _kGreen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    'Un lien Google Meet unique sera généré automatiquement et partagé avec les participants.',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.5),
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

// -- Sous-widgets --------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.outfit(
        color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600,
        letterSpacing: 0.5)),
  );
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;
  const _StyledField({
    required this.controller, required this.hint, required this.icon,
    this.maxLines = 1, this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    validator: validator,
    style: GoogleFonts.inter(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.white38),
      prefixIcon: Icon(icon, color: const Color(0xFF00C896), size: 20),
      filled: true,
      fillColor: const Color(0xFF1A2634),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00C896), width: 1.5),
      ),
    ),
  );
}

class _DateTimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DateTimeChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2634),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF00C896), size: 18),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
      ]),
    ),
  );
}

class _DurationSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  static const _options = [30, 45, 60, 90, 120];
  const _DurationSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    children: _options.map((d) {
      final selected = d == value;
      return ChoiceChip(
        label: Text('$d min'),
        selected: selected,
        onSelected: (_) => onChanged(d),
        selectedColor: const Color(0xFF00C896),
        backgroundColor: const Color(0xFF1A2634),
        labelStyle: GoogleFonts.inter(
          color: selected ? Colors.black : Colors.white70,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }).toList(),
  );
}

class _AudienceSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _AudienceSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: _AudienceChip(
      icon: Icons.public_rounded,
      label: 'Tous les\ncitoyens',
      selected: value == 'all',
      onTap: () => onChanged('all'),
    )),
    const SizedBox(width: 10),
    Expanded(child: _AudienceChip(
      icon: Icons.person_search_rounded,
      label: 'Citoyens\nspécifiques',
      selected: value == 'citizens',
      onTap: () => onChanged('citizens'),
    )),
    const SizedBox(width: 10),
    Expanded(child: _AudienceChip(
      icon: Icons.group_rounded,
      label: 'Groupe\nciblé',
      selected: value == 'group',
      onTap: () => onChanged('group'),
    )),
  ]);
}

class _AudienceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AudienceChip({required this.icon, required this.label,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF00C896).withOpacity(0.15) : const Color(0xFF1A2634),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? const Color(0xFF00C896) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: selected ? const Color(0xFF00C896) : Colors.white54, size: 22),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: selected ? const Color(0xFF00C896) : Colors.white54,
            fontSize: 11, fontWeight: FontWeight.w600, height: 1.3)),
      ]),
    ),
  );
}
