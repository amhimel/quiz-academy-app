class Quiz {
  final String id;
  final String code;
  final String title;
  final String description;
  final String type;
  final String durationMinutes;
  final String numQuestions;
  final DateTime createdAt;
  final String createdBy;
  final String? creatorDisplayName;
  final String? creatorAvatarUrl;

  Quiz({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    required this.numQuestions,
    required this.createdAt,
    required this.createdBy,
    required this.creatorDisplayName,
    required this.creatorAvatarUrl,
  });

  factory Quiz.fromMap(Map<String, dynamic> m) => Quiz(
    id: m['id'] as String,
    code: m['code'] ?? '',
    title: m['title'] ?? '',
    description: m['description'] ?? '',
    type: m['type'] ?? '',
    durationMinutes: (m['duration_minutes'] ?? 0).toString(),
    numQuestions: (m['num_questions'] ?? 0).toString(),
    createdAt: DateTime.parse(m['created_at'] as String),
    createdBy: m['created_by'] as String,
    creatorDisplayName: m['display_name'] as String?,
    creatorAvatarUrl: m['avatar_url'] as String?,
  );
}
