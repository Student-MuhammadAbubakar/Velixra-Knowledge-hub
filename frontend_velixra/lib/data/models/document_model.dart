/// Mirrors your backend's DocumentResponse schema exactly.
class DocumentModel {
  final int id;
  final String filename;
  final int uploadedBy;
  final String visibility;      // "public" | "restricted"
  final String processStatus;   // "pending" | "processing" | "ready" | "failed"
  final String createdAt;

  DocumentModel({
    required this.id,
    required this.filename,
    required this.uploadedBy,
    required this.visibility,
    required this.processStatus,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json["id"],
      filename: json["filename"],
      uploadedBy: json["uploaded_by"],
      visibility: json["visibility"],
      processStatus: json["process_status"],
      createdAt: json["created_at"],
    );
  }
}