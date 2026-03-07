import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Enhanced image loading with comprehensive error logging
/// Use this to debug profile image loading issues

class DebugNetworkImage extends StatefulWidget {
  final String url;
  final String? debugLabel; // Optional label for logging (e.g., user name)
  final Function(dynamic error, StackTrace stackTrace)? onError;
  final double? width;
  final double? height;
  final BoxFit fit;

  const DebugNetworkImage({
    required this.url,
    this.debugLabel,
    this.onError,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<DebugNetworkImage> createState() => _DebugNetworkImageState();
}

class _DebugNetworkImageState extends State<DebugNetworkImage> {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          print('[❌ IMAGE_FAILED] ${widget.debugLabel}');
          print('   URL: ${widget.url}');
          print('   Error Type: ${error.runtimeType}');
          print('   Error: $error');
          if (stackTrace != null) {
            print('   StackTrace: $stackTrace');
          }
        }
        if (stackTrace != null) {
          widget.onError?.call(error, stackTrace);
        }
        // Return transparent placeholder
        return SizedBox(width: widget.width, height: widget.height);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }
}

/// Widget to diagnose image loading issues
/// Shows the resolved URL and load status
class ImageDiagnostic extends StatefulWidget {
  final String imagePath;
  final String resolvedUrl;
  final String? debugLabel;
  final double radius;

  const ImageDiagnostic({
    required this.imagePath,
    required this.resolvedUrl,
    this.debugLabel,
    this.radius = 24,
  });

  @override
  State<ImageDiagnostic> createState() => _ImageDiagnosticState();
}

class _ImageDiagnosticState extends State<ImageDiagnostic> {
  String _loadStatus = 'loading';

  @override
  void initState() {
    super.initState();
    _diagnosticLog();
  }

  void _diagnosticLog() {
    if (kDebugMode) {
      print('📸 [IMAGE_DIAGNOSTIC] ${widget.debugLabel ?? "Unknown"}');
      print('   Raw imagePath: ${widget.imagePath}');
      print('   Resolved URL: ${widget.resolvedUrl}');
      print('   Is Asset: ${widget.imagePath.startsWith("assets")}');
      print('   Status: $_loadStatus');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.grey[700],
      backgroundImage: (widget.imagePath.startsWith('assets'))
          ? AssetImage(widget.imagePath) as ImageProvider
          : NetworkImage(widget.resolvedUrl),
      onBackgroundImageError: (error, stackTrace) {
        setState(() => _loadStatus = 'failed');
        if (kDebugMode) {
          print('🔴 [IMAGE_LOAD_ERROR] ${widget.debugLabel ?? "Unknown"}');
          print('   URL: ${widget.resolvedUrl}');
          print('   Error: $error');
        }
      },
    );
  }
}

/// Log the full image loading chain for a user
void logImageLoadingChain({
  required String userName,
  required String rawImagePath,
  required String resolvedImageUrl,
  required bool isAsset,
}) {
  if (kDebugMode) {
    print('═' * 60);
    print('📸 IMAGE LOADING CHAIN FOR: $userName');
    print('═' * 60);
    print('1️⃣  Raw imagePath from API/State: $rawImagePath');
    print('2️⃣  Is Asset Path: $isAsset');
    print('3️⃣  Resolved URL: $resolvedImageUrl');
    print('4️⃣  URL starts with http: ${resolvedImageUrl.startsWith("http")}');
    print('═' * 60);
  }
}
