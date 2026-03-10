/// Image URL Helper - Resolves both full URLs and API paths
/// 
/// Backend returns images as either:
/// - Full URL: https://app.loopinsocial.in/api/media/s3/profile/...
/// - Path only: /api/media/s3/profile/...
/// 
/// This helper ensures both formats work correctly

const String API_BASE_URL = 'https://app.loopinsocial.in';

/// Resolves an image URL or path to a full URL
/// 
/// Example:
/// - imageUrl('https://example.com/image.jpg') → 'https://example.com/image.jpg'
/// - imageUrl('/api/media/s3/profile/image.jpg') → 'https://app.loopinsocial.in/api/media/s3/profile/image.jpg'
/// - imageUrl(null) → ''
String imageUrl(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  
  // If already a full URL, return as-is
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  
  // If it's a path, prepend API base URL
  if (value.startsWith('/')) {
    return API_BASE_URL + value;
  }
  
  // Fallback: treat as path and prepend base URL
  return API_BASE_URL + '/' + value;
}

/// Get image URL with fallback
/// Returns empty string if URL resolution fails
String safeImageUrl(String? value) {
  try {
    return imageUrl(value);
  } catch (e) {
    return '';
  }
}
