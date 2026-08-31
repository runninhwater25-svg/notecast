enum WorkflowStage { idle, recording, transcribing, generating, ready, failed }

class TranscriptResult {
  const TranscriptResult({required this.text});
  final String text;
}

class NoteDraft {
  const NoteDraft({
    required this.title,
    required this.summary,
    required this.chapters,
    required this.concepts,
    required this.examples,
    required this.reviewQuestions,
    required this.uncertainTerms,
  });

  final String title;
  final List<String> summary;
  final List<Map<String, dynamic>> chapters;
  final List<String> concepts;
  final List<String> examples;
  final List<String> reviewQuestions;
  final List<String> uncertainTerms;

  factory NoteDraft.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) => (json[key] as List? ?? const [])
        .map((item) => item.toString())
        .toList();
    final rawChapters = json['chapters'] as List? ?? const [];
    return NoteDraft(
      title: json['title']?.toString().trim().isNotEmpty == true
          ? json['title'].toString().trim()
          : '未命名课程',
      summary: strings('summary'),
      chapters: rawChapters
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      concepts: strings('concepts'),
      examples: strings('examples'),
      reviewQuestions: strings('review_questions'),
      uncertainTerms: strings('uncertain_terms'),
    );
  }
}
