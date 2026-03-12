import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../config/theme.dart';
import '../models/analysis_result.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Share feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Verdict Card
            _buildVerdictCard()
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 20),

            // Confidence Score
            _buildConfidenceCard()
                .animate()
                .fadeIn(duration: 500.ms, delay: 150.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 20),

            // Summary
            _buildSummaryCard()
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 20),

            // Reasons
            if (result.reasons.isNotEmpty)
              _buildListCard(
                title: 'Analysis Reasons',
                icon: Icons.checklist_rounded,
                items: result.reasons,
                iconColor: AppTheme.primaryColor,
                itemIcon: Icons.check_circle_outline,
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms)
                  .slideY(begin: 0.2),

            if (result.reasons.isNotEmpty) const SizedBox(height: 20),

            // Red Flags
            if (result.redFlags.isNotEmpty)
              _buildListCard(
                title: 'Red Flags',
                icon: Icons.flag_rounded,
                items: result.redFlags,
                iconColor: AppTheme.dangerColor,
                itemIcon: Icons.warning_amber_rounded,
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms)
                  .slideY(begin: 0.2),

            if (result.redFlags.isNotEmpty) const SizedBox(height: 20),

            // Suggestions
            if (result.suggestions.isNotEmpty)
              _buildListCard(
                title: 'Suggestions',
                icon: Icons.tips_and_updates_rounded,
                items: result.suggestions,
                iconColor: AppTheme.secondaryColor,
                itemIcon: Icons.arrow_right_rounded,
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 750.ms)
                  .slideY(begin: 0.2),

            const SizedBox(height: 32),

            // Analyze Another Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Analyze Another'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 900.ms),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVerdictCard() {
    final verdictData = _getVerdictData();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            verdictData.color.withValues(alpha: 0.2),
            verdictData.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: verdictData.color.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: verdictData.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              verdictData.icon,
              size: 48,
              color: verdictData.color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            result.verdict.toUpperCase(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: verdictData.color,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.category,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard() {
    final verdictData = _getVerdictData();
    final percentage = (result.confidenceScore * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceBg),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 45,
            lineWidth: 8,
            percent: result.confidenceScore.clamp(0.0, 1.0),
            center: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: verdictData.color,
              ),
            ),
            progressColor: verdictData.color,
            backgroundColor: AppTheme.surfaceBg,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confidence Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getConfidenceDescription(result.confidenceScore),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceBg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.summarize_rounded, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.summary,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color iconColor,
    required IconData itemIcon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceBg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(itemIcon, color: iconColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
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

  _VerdictDisplayData _getVerdictData() {
    switch (result.verdict.toLowerCase()) {
      case 'real':
        return _VerdictDisplayData(
          color: AppTheme.successColor,
          icon: Icons.verified_rounded,
        );
      case 'fake':
        return _VerdictDisplayData(
          color: AppTheme.dangerColor,
          icon: Icons.dangerous_rounded,
        );
      case 'misleading':
        return _VerdictDisplayData(
          color: AppTheme.warningColor,
          icon: Icons.warning_rounded,
        );
      case 'satire':
        return _VerdictDisplayData(
          color: const Color(0xFF9B59B6),
          icon: Icons.theater_comedy_rounded,
        );
      default:
        return _VerdictDisplayData(
          color: AppTheme.textSecondary,
          icon: Icons.help_outline_rounded,
        );
    }
  }

  String _getConfidenceDescription(double score) {
    if (score >= 0.9) return 'Very high confidence in this assessment';
    if (score >= 0.7) return 'High confidence in this assessment';
    if (score >= 0.5) return 'Moderate confidence — verify with other sources';
    if (score >= 0.3) return 'Low confidence — claims are hard to verify';
    return 'Very low confidence — insufficient data to assess';
  }
}

class _VerdictDisplayData {
  final Color color;
  final IconData icon;

  _VerdictDisplayData({required this.color, required this.icon});
}
