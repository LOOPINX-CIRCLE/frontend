import 'package:text_code/core/constants/api_constants.dart';

/// Resolve an image URL returned by the API into a fully-qualified URL.
///
/// Backend may return:
/// - Full URLs: https://app.loopinsocial.in/api/media/...
/// - Relative paths: /api/media/...
///
/// Rules:
/// - If [value] is null or empty → return empty string.
/// - If [value] starts with http:// or https:// → return as-is.
/// - Otherwise, treat it as relative and prepend [ApiConstants.baseUrl],
///   taking care to avoid double slashes.
String resolveImageUrl(String? value) {
  if (value == null || value.isEmpty) return '';

  final lower = value.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return value;
  }

  // Ensure base URL has no trailing slash
  final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/$'), '');
  final path = value.startsWith('/') ? value : '/$value';

  return '$base$path';
}


