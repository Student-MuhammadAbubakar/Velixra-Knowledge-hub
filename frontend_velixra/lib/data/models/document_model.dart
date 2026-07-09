class DocumentModel {
  final int id;
  final String filename;
  final int uploadedBy;
  final String? uploadedByName;
  final String visibility;
  final String processStatus;
  final String createdAt;

  DocumentModel({
    required this.id,
    required this.filename,
    required this.uploadedBy,
    this.uploadedByName,
    required this.visibility,
    required this.processStatus,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json["id"],
      filename: json["filename"],
      uploadedBy: json["uploaded_by"],
      uploadedByName: json["uploaded_by_name"],
      visibility: json["visibility"],
      processStatus: json["process_status"],
      createdAt: json["created_at"],
    );
  }
}