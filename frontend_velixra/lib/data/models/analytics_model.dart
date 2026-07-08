/// Mirrors your backend's OwnerAnalyticsResponse schema exactly.
class DocumentAnalytics {
  final int totalDocuments;
  final int publicDocuments;
  final int restrictedDocuments;

  DocumentAnalytics({
    required this.totalDocuments,
    required this.publicDocuments,
    required this.restrictedDocuments,
  });

  factory DocumentAnalytics.fromJson(Map<String, dynamic> json) {
    return DocumentAnalytics(
      totalDocuments: json["total_documents"],
      publicDocuments: json["public_documents"],
      restrictedDocuments: json["restricted_documents"],
    );
  }
}

class TopQuestion {
  final String questionCluster;
  final int timesAsked;

  TopQuestion({required this.questionCluster, required this.timesAsked});

  factory TopQuestion.fromJson(Map<String, dynamic> json) {
    return TopQuestion(
      questionCluster: json["question_cluster"],
      timesAsked: json["times_asked"],
    );
  }
}

class OwnerAnalytics {
  final DocumentAnalytics documentStats;
  final List<TopQuestion> topQuestions;

  OwnerAnalytics({required this.documentStats, required this.topQuestions});

  factory OwnerAnalytics.fromJson(Map<String, dynamic> json) {
    return OwnerAnalytics(
      documentStats: DocumentAnalytics.fromJson(json["document_stats"]),
      topQuestions: (json["top_questions"] as List)
          .map((q) => TopQuestion.fromJson(q))
          .toList(),
    );
  }
}