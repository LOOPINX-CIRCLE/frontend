// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WaitVideo extends StatefulWidget {
  final String videoPath;
  final bool autoPlay;
  final bool looping;
  final double volume;
  
  const WaitVideo({
    super.key,
    required this.videoPath,
    this.autoPlay = true,
    this.looping = true,
    this.volume = 0.0,
  });

  @override
  _WaitVideoState createState() => _WaitVideoState();
}

class _WaitVideoState extends State<WaitVideo> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _needsUserInteraction = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(widget.videoPath);
      
      // Add listener to handle playback state
      _videoController!.addListener(() {
        if (mounted && _videoController!.value.hasError) {
          print('Video error: ${_videoController!.value.errorDescription}');
        }
      });
      
      // Initialize the video first
      await _videoController!.initialize();
      
      // Update state first to show the video
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      
      // Set looping first
      _videoController!.setLooping(widget.looping);
      
      // Always start muted to ensure autoplay works (browsers allow muted autoplay)
      // This guarantees the video will play automatically on web and mobile
      _videoController!.setVolume(0.0);
      
      // Try to play the video if autoPlay is enabled
      if (widget.autoPlay && _videoController!.value.isInitialized) {
        try {
          // Play muted first (this works on all platforms)
          await _videoController!.play();
          print('Video playing muted (autoplay): ${_videoController!.value.isPlaying}');
          
          // If volume > 0, try to unmute after a short delay
          // On mobile, this should work. On web, it may require user interaction.
          if (widget.volume > 0) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _videoController != null && _videoController!.value.isPlaying) {
                try {
                  _videoController!.setVolume(widget.volume);
                  print('Video unmuted successfully');
                } catch (e) {
                  // If unmuting fails, mark that user interaction is needed
                  print('Failed to unmute automatically, user interaction required: $e');
                  if (mounted) {
                    setState(() {
                      _needsUserInteraction = true;
                    });
                  }
                }
              }
            });
          }
        } catch (playError) {
          print('Failed to play video: $playError');
          if (mounted) {
            setState(() {
              _needsUserInteraction = true;
            });
          }
        }
        
        // Verify it's actually playing
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      // Handle any errors during initialization
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void play() {
    if (_isInitialized && _videoController != null) {
      _videoController!.play();
    }
  }

  void pause() {
    if (_isInitialized && _videoController != null) {
      _videoController!.pause();
    }
  }

  void stop() {
    if (_isInitialized && _videoController != null) {
      _videoController!.pause();
      _videoController!.seekTo(Duration.zero);
    }
  }

  void _handleUserInteraction() {
    if (_needsUserInteraction && _videoController != null && !_videoController!.value.isPlaying) {
      _videoController!.setVolume(widget.volume);
      _videoController!.play().then((_) {
        if (mounted) {
          setState(() {
            _needsUserInteraction = false;
          });
        }
      }).catchError((e) {
        print('Failed to play after user interaction: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We wait for the controller to be initialized before showing the video
    if (!_isInitialized || _videoController == null) {
      return Container(color: Colors.black);
    }
    
    if (!_videoController!.value.isInitialized) {
      return Container(color: Colors.black);
    }
    
    return GestureDetector(
      onTap: _handleUserInteraction,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      ),
    );
  }
}

