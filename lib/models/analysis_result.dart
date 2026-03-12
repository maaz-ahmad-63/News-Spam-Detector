class AnalysisResult {
  final String verdict;        // "Real", "Fake", "Misleading", "Satire", "Unverifiable"
  final double confidenceScore; // 0.0 - 1.0
  final String summary;
  final List<String> reasons;
  final List<String> redFlags;
  final List<String> suggestions;
  final String category;       // e.g., "Political", "Health", "Technology", etc.

  AnalysisResult({
    required this.verdict,
    required this.confidenceScore,
    required this.summary,
    required this.reasons,
    required this.redFlags,
    required this.suggestions,
    required this.category,
  });

  factory AnalysisResult.fromParsed(Map<String, dynamic> json) {
    return AnalysisResult(
      verdict: json['verdict'] ?? 'Unknown',
      confidenceScore: (json['confidence_score'] ?? 0.5).toDouble(),
      summary: json['summary'] ?? '',
      reasons: List<String>.from(json['reasons'] ?? []),
      redFlags: List<String>.from(json['red_flags'] ?? []),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      category: json['category'] ?? 'General',
    );
  }

  bool get isLikelyReal => confidenceScore >= 0.7 && verdict == 'Real';
  bool get isLikelyFake => verdict == 'Fake' || verdict == 'Misleading';
}
