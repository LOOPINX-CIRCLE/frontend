import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A smart image widget that automatically handles both network URLs and local assets
/// 
/// This widget prevents Flutter Web from trying to load network URLs as assets,
/// which causes 404 errors. It automatically detects if the image path is a URL
/// and uses Image.network, otherwise uses Image.asset.
/// 
/// Features:
/// - Automatic detection of network vs asset images
/// - Error handling with customizable error widget
/// - Loading state with customizable loading widget
/// - Supports Google Drive URLs and other network images
/// - Works seamlessly on Flutter Web
class SmartImage extends StatelessWidget {
  /// The image path - can be a network URL (http/https) or asset path
  final String imagePath;
  
  /// Image width
  final double? width;
  
  /// Image height
  final double? height;
  
  /// How the image should be inscribed into the available space
  final BoxFit? fit;
  
  /// Optional error widget builder
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  
  /// Optional loading widget builder
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  
  /// Optional placeholder widget while loading
  final Widget? placeholder;
  
  /// Optional frame builder for advanced customization
  final ImageFrameBuilder? frameBuilder;
  
  /// Optional color filter
  final ColorFilter? colorFilter;
  
  /// Optional alignment
  final AlignmentGeometry? alignment;
  
  /// Optional repeat
  final ImageRepeat? repeat;
  
  /// Optional center slice for nine-patch images
  final Rect? centerSlice;
  
  /// Optional match text direction
  final bool? matchTextDirection;
  
  /// Optional gapless playback
  final bool? gaplessPlayback;
  
  /// Optional filter quality
  final FilterQuality? filterQuality;
  
  /// Optional is anti alias
  final bool? isAntiAlias;
  
  /// Optional semantic label
  final String? semanticLabel;

  const SmartImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
    this.loadingBuilder,
    this.placeholder,
    this.frameBuilder,
    this.colorFilter,
    this.alignment,
    this.repeat,
    this.centerSlice,
    this.matchTextDirection,
    this.gaplessPlayback,
    this.filterQuality,
    this.isAntiAlias,
    this.semanticLabel,
  });

  /// Check if the image path is a network URL
  bool get _isNetworkImage {
    return imagePath.startsWith('http://') || 
           imagePath.startsWith('https://') ||
           imagePath.startsWith('//');
  }

  /// Convert Google Drive share URL to direct image URL if needed
  String _processGoogleDriveUrl(String url) {
    // Handle Google Drive share URLs
    // Format: https://drive.google.com/file/d/FILE_ID/view?usp=sharing
    // Convert to: https://drive.google.com/uc?export=view&id=FILE_ID
    if (url.contains('drive.google.com/file/d/')) {
      try {
        final fileIdMatch = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
        if (fileIdMatch != null) {
          final fileId = fileIdMatch.group(1);
          return 'https://drive.google.com/uc?export=view&id=$fileId';
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error processing Google Drive URL: $e');
        }
      }
    }
    // Handle Google Drive thumbnail URLs
    // Format: https://drive.google.com/thumbnail?id=FILE_ID
    if (url.contains('drive.google.com/thumbnail')) {
      return url; // Already in correct format
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetworkImage) {
      // Process Google Drive URLs if needed
      final processedUrl = _processGoogleDriveUrl(imagePath);
      
      Widget imageWidget = Image.network(
        processedUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ?? _defaultErrorBuilder,
        loadingBuilder: loadingBuilder ?? _defaultLoadingBuilder,
        frameBuilder: frameBuilder,
        alignment: alignment ?? Alignment.center,
        repeat: repeat ?? ImageRepeat.noRepeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection ?? false,
        gaplessPlayback: gaplessPlayback ?? false,
        filterQuality: filterQuality ?? FilterQuality.low,
        isAntiAlias: isAntiAlias ?? true,
        semanticLabel: semanticLabel,
      );
      
      // Apply color filter if provided
      if (colorFilter != null) {
        return ColorFiltered(
          colorFilter: colorFilter!,
          child: imageWidget,
        );
      }
      
      return imageWidget;
    } else {
      // Local asset image
      Widget imageWidget = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ?? _defaultErrorBuilder,
        frameBuilder: frameBuilder,
        alignment: alignment ?? Alignment.center,
        repeat: repeat ?? ImageRepeat.noRepeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection ?? false,
        gaplessPlayback: gaplessPlayback ?? false,
        filterQuality: filterQuality ?? FilterQuality.low,
        isAntiAlias: isAntiAlias ?? true,
        semanticLabel: semanticLabel,
      );
      
      // Apply color filter if provided
      if (colorFilter != null) {
        return ColorFiltered(
          colorFilter: colorFilter!,
          child: imageWidget,
        );
      }
      
      return imageWidget;
    }
  }

  /// Default error builder
  Widget _defaultErrorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.white70,
          size: 40,
        ),
      ),
    );
  }

  /// Default loading builder
  Widget _defaultLoadingBuilder(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) {
      return child;
    }
    return Container(
      width: width,
      height: height,
      color: Colors.grey[900],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
        ),
      ),
    );
  }
}

/// Extension method for easy conversion of existing Image.asset calls
extension SmartImageExtension on String {
  /// Convert a string path to a SmartImage widget
  Widget toSmartImage({
    double? width,
    double? height,
    BoxFit? fit,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
  }) {
    return SmartImage(
      imagePath: this,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
}

