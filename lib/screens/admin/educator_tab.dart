import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';


class EducatorTab extends StatefulWidget {
  const EducatorTab({Key? key}) : super(key: key);

  @override
  State<EducatorTab> createState() => _EducatorTabState();
}

class _EducatorTabState extends State<EducatorTab> {
  final AuthService _authService = AuthService();
  List<dynamic> _quizzes = [];
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);
    final quizzes = await _authService.fetchMyQuizzes();
    if (mounted) setState(() { _quizzes = quizzes; _isLoading = false; });
  }

  Future<void> _uploadQuizPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    // Demander le titre
    final titleController = TextEditingController(text: file.name.replaceAll('.pdf', ''));
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Nouveau Quiz', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Icon(Icons.picture_as_pdf, color: Colors.red.shade400, size: 32),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('${(file.size / 1024).toStringAsFixed(1)} Ko', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Titre du quiz',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, titleController.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Analyser avec l\'IA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;

    setState(() => _isUploading = true);

    // Créer un wrapper pour les bytes du fichier
    final fakeFile = _PdfFileWrapper(file.name, file.bytes!);
    final res = await _authService.createQuizFromPdf(fakeFile, title: title);

    setState(() => _isUploading = false);

    if (res['success'] == true && mounted) {
      final quiz = res['quiz'];
      final totalQ = quiz?['total_questions'] ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Quiz créé ! $totalQ questions extraites par Gemini.', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ]),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
      _loadQuizzes();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Erreur lors de la création du quiz'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _viewQuizResults(Map<String, dynamic> quiz) async {
    final quizId = quiz['id'];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
    );

    final results = await _authService.fetchQuizResults(quizId);
    if (mounted) Navigator.pop(context);

    if (!mounted) return;

    final stats = results['stats'] ?? {};
    final submissions = (results['submissions'] as List?) ?? [];
    final questions = (quiz['questions'] as List?) ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(quiz['title'] ?? 'Quiz', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            // Stats cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildMiniStat('Soumissions', '${stats['total_submissions'] ?? 0}', Icons.people_rounded, Colors.blue),
                  const SizedBox(width: 10),
                  _buildMiniStat('Moyenne', '${stats['average_score'] ?? 0}/10', Icons.analytics_rounded, Colors.orange),
                  const SizedBox(width: 10),
                  _buildMiniStat('Meilleure', '${stats['highest_score'] ?? 0}/10', Icons.emoji_events_rounded, Colors.amber),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Questions preview
            if (questions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(alignment: Alignment.centerLeft, child: Text('${questions.length} Questions extraites par l\'IA', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen))),
              ),
              const SizedBox(height: 8),
            ],
            // Submissions list
            Expanded(
              child: submissions.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Aucune soumission', style: GoogleFonts.inter(color: AppTheme.textMuted)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: submissions.length,
                      itemBuilder: (_, i) {
                        final sub = submissions[i];
                        final score = (sub['score'] as num?)?.toDouble() ?? 0;
                        final color = score >= 7 ? Colors.green : score >= 5 ? Colors.orange : Colors.red;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color.withOpacity(0.2)),
                          ),
                          child: Row(children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: color.withOpacity(0.1),
                              child: Text('${score.toStringAsFixed(1)}', style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sub['student_name'] ?? 'Étudiant', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                                Text(sub['submitted_at'] ?? '', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                              ],
                            )),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text('${score.toStringAsFixed(1)}/10', style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.deepSlate)),
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SingleChildScrollView(
        key: const PageStorageKey('educator_tab'),
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildQuickStats(context),
            const SizedBox(height: 48),

            _buildSectionHeader('QUIZ AUTOMATIQUE (IA GEMINI)', Icons.auto_awesome_rounded),
            const SizedBox(height: 20),
            _buildUploadCard(),
            const SizedBox(height: 20),

            // Liste des quiz créés
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppTheme.primaryGreen)))
            else if (_quizzes.isNotEmpty) ...[
              Text('Mes Quiz (${_quizzes.length})', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1)),
              const SizedBox(height: 12),
              ..._quizzes.map((q) => _buildQuizCard(q)).toList(),
            ],

            const SizedBox(height: 40),
            _buildSectionHeader('SÉANCES DE SENSIBILISATION', Icons.event_available_rounded),
            const SizedBox(height: 20),
            _buildAwarenessSessions(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_educator_new_quiz',
        onPressed: _isUploading ? null : _uploadQuizPdf,
        backgroundColor: _isUploading ? Colors.grey : AppTheme.primaryGreen,
        icon: _isUploading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.upload_file_rounded),
        label: Text(_isUploading ? 'ANALYSE IA...' : 'UPLOADER UN QUIZ PDF'),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Espace Éducateur', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.deepSlate)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user_rounded, color: AppTheme.primaryGreen),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Gérez vos quiz et contenus pédagogiques.', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 16)),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(context, 'Quiz Créés', '${_quizzes.length}', Icons.quiz_rounded, Colors.purple),
        const SizedBox(width: 12),
        _buildStatCard(context, 'Soumissions', '${_quizzes.fold<int>(0, (sum, q) => sum + ((q['submissions_count'] as num?) ?? 0).toInt())}', Icons.assignment_turned_in_rounded, Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard(context, 'Corrigés IA', '${_quizzes.fold<int>(0, (sum, q) => sum + ((q['submissions_count'] as num?) ?? 0).toInt())}', Icons.auto_awesome, Colors.amber),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.tightShadow,
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepSlate)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildUploadCard() {
    return GestureDetector(
      onTap: _isUploading ? null : _uploadQuizPdf,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.deepPurple.shade600]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quiz Automatique', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 4),
                Text(
                  'Uploadez un PDF → Gemini extrait les questions, corrige et note automatiquement sur 10.',
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 12, height: 1.4),
                ),
              ],
            )),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.6), size: 16),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildQuizCard(dynamic quiz) {
    final status = quiz['status'] ?? 'processing';
    final total = quiz['total_questions'] ?? 0;
    final subs = quiz['submissions_count'] ?? 0;
    final isReady = status == 'ready';

    return GestureDetector(
      onTap: isReady ? () => _viewQuizResults(Map<String, dynamic>.from(quiz)) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.tightShadow,
          border: Border(left: BorderSide(color: isReady ? AppTheme.primaryGreen : Colors.orange, width: 4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isReady ? Colors.purple : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isReady ? Icons.quiz_rounded : Icons.hourglass_top_rounded,
                color: isReady ? Colors.purple : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quiz['title'] ?? 'Quiz', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.help_outline, size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text('$total questions', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(width: 12),
                  const Icon(Icons.people_outline, size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text('$subs soumissions', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                ]),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (isReady ? AppTheme.primaryGreen : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isReady ? 'PRÊT' : 'EN COURS',
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: isReady ? AppTheme.primaryGreen : Colors.orange),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }

  Widget _buildAwarenessSessions(BuildContext context) {
    return Column(
      children: [
        _buildSessionCard(context, 'Atelier Compostage', 'Campus Universitaire, Tunis', '24 Mars • 14:00', '32 Inscrits', true),
        const SizedBox(height: 16),
        _buildSessionCard(context, 'Webinaire Zéro Déchet', 'En ligne (Zoom)', '28 Mars • 18:00', '150 Inscrits', false),
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context, String title, String location, String date, String attendees, bool isPhysical) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.tightShadow,
        border: Border(left: BorderSide(color: isPhysical ? Colors.orange : Colors.blue, width: 4)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: (isPhysical ? Colors.orange : Colors.blue).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [
                    Text(date.split('•')[0].split(' ')[0], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.deepSlate)),
                    Text(date.split('•')[0].split(' ')[1], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.deepSlate)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(location, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    ]),
                  ],
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.people_alt_rounded, size: 14, color: AppTheme.deepSlate),
                  const SizedBox(width: 4),
                  Text(attendees, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.deepSlate)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: (isPhysical ? Colors.orange : Colors.blue).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(isPhysical ? 'PRÉSENTIEL' : 'EN LIGNE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isPhysical ? Colors.orange : Colors.blue)),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}


/// Wrapper pour envoyer des bytes comme un XFile
class _PdfFileWrapper {
  final String name;
  final List<int> _bytes;
  _PdfFileWrapper(this.name, this._bytes);
  Future<List<int>> readAsBytes() async => _bytes;
}
