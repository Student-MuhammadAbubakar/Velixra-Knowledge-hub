/// A clean, UI-friendly exception wrapping raw Dio errors, so screens
/// never need to know about Dio's internal error shape — they just
/// catch this and show `message` directly.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      final data = error.response.data;
      final detail = data is Map ? data["detail"]?.toString() : null;
      return ApiException(
        detail ?? "Something went wrong. Please try again.",
        statusCode: error.response.statusCode,
      );
    }
    return ApiException("Network error. Check your connection.");
  }

  @override
  String toString() => message;
}