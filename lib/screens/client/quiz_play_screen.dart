
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';


/// Écran interactif pour répondre à un quiz (Citoyen)
/// Le citoyen répond question par question, puis Gemini corrige et donne une note /10
class QuizPlayScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;
  const QuizPlayScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final AuthService _authService = AuthService();
  int _currentQuestion = 0;
  final Map<String, String> _answers = {};
  bool _isSubmitting = false;
  Map<String, dynamic>? _result;

  List<dynamic> get _questions => (widget.quiz['questions'] as List?) ?? [];
  int get _total => _questions.length;

  void _selectAnswer(String answer) {
    setState(() {
      _answers['${_currentQuestion + 1}'] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _total - 1) {
      setState(() => _currentQuestion++);
    }
  }

  void _prevQuestion() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    }
  }

  Future<void> _submitQuiz() async {
    setState(() => _isSubmitting = true);

    final quizId = widget.quiz['id'];
    final res = await _authService.submitQuizAnswers(quizId, _answers);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (res['success'] == true) {
          _result = res['grading'] ?? res;
        }
      });

      if (res['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] ?? 'Erreur lors de la correction'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) return _buildResultScreen();
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Aucune question dans ce quiz')),
      );
    }
    return _buildQuizScreen();
  }

  Widget _buildQuizScreen() {
    final q = _questions[_currentQuestion];
    final qNum = q['number'] ?? (_currentQuestion + 1);
    final qText = q['question'] ?? '';
    final qType = q['type'] ?? 'mcq';
    final options = (q['options'] as List?)?.cast<String>() ?? [];
    final currentAnswer = _answers['${_currentQuestion + 1}'];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.deepSlate),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(widget.quiz['title'] ?? 'Quiz',
          style: GoogleFonts.outfit(color: AppTheme.deepSlate, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${_currentQuestion + 1}/$_total',
                  style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _total,
            backgroundColor: Colors.grey.shade100,
            color: AppTheme.primaryGreen,
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Question $qNum',
                      style: GoogleFonts.outfit(color: Colors.purple, fontWeight: FontWeight.w700, fontSize: 13)),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 20),

                  // Question text
                  Text(qText,
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.deepSlate, height: 1.3)),
                  const SizedBox(height: 32),

                  // Options
                  if (qType == 'mcq' || qType == 'true_false')
                    ...options.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final option = entry.value;
                      final letter = option.length > 1 ? option.split('.')[0].trim() : String.fromCharCode(65 + idx);
                      final isSelected = currentAnswer == letter;

                      return GestureDetector(
                        onTap: () => _selectAnswer(letter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryGreen.withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(letter,
                                    style: GoogleFonts.outfit(
                                      color: isSelected ? Colors.white : AppTheme.textMuted,
                                      fontWeight: FontWeight.bold, fontSize: 15)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(option,
                                  style: GoogleFonts.inter(
                                    fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected ? AppTheme.deepSlate : AppTheme.textMain)),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 22),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 100 * idx)).slideX(begin: 0.05);
                    }),

                  // Open question
                  if (qType == 'open')
                    TextField(
                      onChanged: (val) => _answers['${_currentQuestion + 1}'] = val,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tapez votre réponse ici...',
                        hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2)),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                if (_currentQuestion > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _prevQuestion,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Précédent'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                if (_currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _currentQuestion < _total - 1
                      ? ElevatedButton.icon(
                          onPressed: currentAnswer != null ? _nextQuestion : null,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Suivant'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: (_isSubmitting || currentAnswer == null) ? null : _submitQuiz,
                          icon: _isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send_rounded),
                          label: Text(_isSubmitting ? 'Correction IA...' : 'Soumettre'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final score = (_result!['score'] as num?)?.toDouble() ?? 0;
    final maxScore = (_result!['max_score'] as num?)?.toDouble() ?? 10;
    final totalCorrect = (_result!['total_correct'] as num?)?.toInt() ?? 0;
    final details = (_result!['details'] as List?) ?? [];
    final feedback = _result!['general_feedback'] ?? '';
    final percentage = (score / maxScore * 100).toInt();

    Color scoreColor;
    String emoji;
    String label;
    if (percentage >= 80) {
      scoreColor = Colors.green;
      emoji = '🏆';
      label = 'Excellent !';
    } else if (percentage >= 60) {
      scoreColor = Colors.orange;
      emoji = '👍';
      label = 'Bien joué !';
    } else if (percentage >= 40) {
      scoreColor = Colors.deepOrange;
      emoji = '💪';
      label = 'Peut mieux faire';
    } else {
      scoreColor = Colors.red;
      emoji = '📚';
      label = 'Continuez à apprendre';
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [scoreColor.shade700, scoreColor.shade400]),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 60)).animate().scale(delay: 300.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 8),
                  Text('$totalCorrect/$_total réponses correctes',
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 16),
                  Text('+${(score * 10).toInt()} points éco ajoutés !',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          if (feedback.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 22),
                    const SizedBox(width: 12),
                    Expanded(child: Text(feedback, style: GoogleFonts.inter(fontSize: 13, color: Colors.brown.shade800, height: 1.4))),
                  ],
                ),
              ).animate().fadeIn(delay: 700.ms),
            ),

          // Détails par question
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text('DÉTAIL PAR QUESTION', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppTheme.textMuted)),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              final d = details[i];
              final isCorrect = d['is_correct'] == true;
              return Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Question ${d['number'] ?? i + 1}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(isCorrect ? 'Correct' : 'Incorrect',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isCorrect ? Colors.green : Colors.red)),
                        ),
                      ],
                    ),
                    if (d['question'] != null) ...[
                      const SizedBox(height: 8),
                      Text(d['question'], style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMain)),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Votre réponse : ', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                        Text('${d['student_answer'] ?? '-'}',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isCorrect ? Colors.green : Colors.red)),
                      ],
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Bonne réponse : ', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                          Text('${d['correct_answer'] ?? ''}',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
                        ],
                      ),
                    ],
                    if (d['feedback'] != null) ...[
                      const SizedBox(height: 8),
                      Text(d['feedback'], style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 800 + i * 80));
            }, childCount: details.length),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Retour à la Formation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Quitter le quiz ?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Votre progression sera perdue.', style: GoogleFonts.inter(color: AppTheme.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continuer')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Quitter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

extension _ColorShade on Color {
  Color get shade700 => HSLColor.fromColor(this).withLightness(0.3).toColor();
  Color get shade400 => HSLColor.fromColor(this).withLightness(0.5).toColor();
}
