class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.error,
  });

  final String message;
  final int? statusCode;
  final Object? error;

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');
    if (statusCode != null) {
      buffer.write(' (statusCode: $statusCode)');
    }
    if (error != null) {
      buffer.write(' -> $error');
    }
    return buffer.toString();
  }
}

