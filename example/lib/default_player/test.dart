import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SimpleVideoPlayerTest extends StatefulWidget {
  const SimpleVideoPlayerTest({Key? key}) : super(key: key);

  @override
  State<SimpleVideoPlayerTest> createState() => _SimpleVideoPlayerTestState();
}

class _SimpleVideoPlayerTestState extends State<SimpleVideoPlayerTest> {
  VideoPlayerController? _controller;
  String _currentQuality = 'Loading...';
  bool _isLoading = true;
  String? _error;
  Map<String, String> _qualities = {};

  // M3U8 master playlist URL
  final String _masterPlaylistUrl =
      'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
  // Эсвэл таны холбоос:
  // 'https://sfux-ext.sfux.info/hls/chapter/105/1588724110/1588724110.m3u8';

  @override
  void initState() {
    super.initState();
    _loadQualities();
  }

  /// M3U8 playlist-аас чанаруудыг задлах
  Future<void> _loadQualities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Fetching M3U8 playlist from: $_masterPlaylistUrl');

      final response = await http.get(Uri.parse(_masterPlaylistUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load playlist: ${response.statusCode}');
      }

      final content = utf8.decode(response.bodyBytes);
      print('M3U8 Content:\n$content');

      // M3U8 задлах
      final qualities = _parseM3U8Playlist(content, _masterPlaylistUrl);

      if (qualities.isEmpty) {
        // Хэрэв variant stream олдоогүй бол master playlist-ийг өөрөө ашиглана
        qualities['Auto'] = _masterPlaylistUrl;
      }

      print('Found qualities: ${qualities.keys.join(", ")}');

      setState(() {
        _qualities = qualities;
        _currentQuality = qualities.keys.first;
      });

      // Эхний чанараар эхлүүлэх
      await _initializeVideo(qualities.values.first);
    } catch (e) {
      print('Error loading qualities: $e');
      setState(() {
        _error = 'Failed to load video qualities: $e';
        _isLoading = false;
      });
    }
  }

  /// M3U8 playlist задлах функц
  Map<String, String> _parseM3U8Playlist(String content, String baseUrl) {
    final qualities = <String, String>{};
    final lines = content.split('\n');

    // Base URL-ийн directory хэсэг
    final baseUri = Uri.parse(baseUrl);
    final basePath = baseUri
        .toString()
        .substring(0, baseUri.toString().lastIndexOf('/') + 1);

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // #EXT-X-STREAM-INF мөрийг хайх
      if (line.startsWith('#EXT-X-STREAM-INF:')) {
        // RESOLUTION задлах
        final resolutionMatch =
            RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(line);
        final bandwidthMatch = RegExp(r'BANDWIDTH=(\d+)').firstMatch(line);

        // Дараагийн мөр нь URL
        if (i + 1 < lines.length) {
          String url = lines[i + 1].trim();

          // Relative URL бол absolute болгох
          if (!url.startsWith('http')) {
            url = basePath + url;
          }

          // Чанарын нэр үүсгэх
          String qualityName;
          if (resolutionMatch != null) {
            final resolution = resolutionMatch.group(1)!;
            final height = resolution.split('x')[1];
            qualityName = '${height}p';
          } else if (bandwidthMatch != null) {
            final bandwidth = int.parse(bandwidthMatch.group(1)!);
            qualityName = '${(bandwidth / 1000000).toStringAsFixed(1)}Mbps';
          } else {
            qualityName = 'Quality ${qualities.length + 1}';
          }

          qualities[qualityName] = url;
          print('Found: $qualityName -> $url');
        }
      }
    }

    // Auto чанар нэмэх (master playlist)
    if (qualities.isNotEmpty) {
      qualities['Auto'] = baseUrl;
    }

    return qualities;
  }

  Future<void> _initializeVideo(String url) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Хуучин controller устгах
      await _controller?.dispose();

      print('Initializing video from: $url');

      // Шинэ controller үүсгэх
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));

      // Initialize хийх
      await _controller!.initialize();

      // Listener нэмэх
      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          print('Video Error: ${_controller!.value.errorDescription}');
          setState(() {
            _error = _controller!.value.errorDescription;
          });
        }
        if (mounted) setState(() {});
      });

      // Автоматаар тоглуулах
      await _controller!.play();

      print('Video initialized successfully');
      print('Duration: ${_controller!.value.duration}');
      print('Size: ${_controller!.value.size}');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Чанар солих функц
  Future<void> _changeQuality(String quality) async {
    if (_controller == null || !_qualities.containsKey(quality)) return;

    final url = _qualities[quality]!;

    // Одоогийн төлөв хадгалах
    final currentPosition = _controller!.value.position;
    final wasPlaying = _controller!.value.isPlaying;

    print('Changing quality to: $quality ($url)');

    setState(() {
      _currentQuality = quality;
      _isLoading = true;
    });

    try {
      // Шинэ видео ачаалах
      await _initializeVideo(url);

      // Position буцааж тохируулах
      if (_controller != null && currentPosition > Duration.zero) {
        await _controller!.seekTo(currentPosition);

        // Тоглуулах
        if (wasPlaying) {
          await Future.delayed(const Duration(milliseconds: 300));
          await _controller!.play();
        }
      }

      print('Quality changed successfully to $quality');
    } catch (e) {
      print('Error changing quality: $e');
      setState(() {
        _error = 'Failed to change quality: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Player Test'),
        backgroundColor: Colors.black87,
        actions: [
          // Чанар солих цэс
          PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hd),
                const SizedBox(width: 4),
                Text(_currentQuality, style: const TextStyle(fontSize: 12)),
              ],
            ),
            onSelected: _changeQuality,
            itemBuilder: (context) {
              return _qualities.keys.map((quality) {
                final isActive = _currentQuality == quality;
                return PopupMenuItem<String>(
                  value: quality,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        quality,
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? Colors.blue : null,
                        ),
                      ),
                      if (isActive)
                        const Icon(Icons.check, size: 18, color: Colors.blue),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: _buildBody(),
      ),
      bottomNavigationBar:
          _controller != null && _controller!.value.isInitialized
              ? _buildControls()
              : null,
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Video Loading Failed',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            // ElevatedButton.icon(
            //   onPressed: () => _initializeVideo(_videoUrls[_currentQuality]!),
            //   icon: const Icon(Icons.refresh),
            //   label: const Text('Retry'),
            // ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Loading video...', style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Text('Initializing...',
          style: TextStyle(color: Colors.white));
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }

  Widget _buildControls() {
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final isPlaying = _controller!.value.isPlaying;

    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: position.inMilliseconds.toDouble(),
                  max: duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    _controller!.seekTo(Duration(milliseconds: value.toInt()));
                  },
                  activeColor: Colors.red,
                  inactiveColor: Colors.white30,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Play/Pause button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  _controller!.seekTo(position - const Duration(seconds: 10));
                },
                icon: const Icon(Icons.replay_10, color: Colors.white),
                iconSize: 32,
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                  });
                },
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                ),
                iconSize: 64,
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {
                  _controller!.seekTo(position + const Duration(seconds: 10));
                },
                icon: const Icon(Icons.forward_10, color: Colors.white),
                iconSize: 32,
              ),
            ],
          ),
          // Debug info
          const SizedBox(height: 8),
          Text(
            'Quality: $_currentQuality | ${_controller!.value.size.width.toInt()}x${_controller!.value.size.height.toInt()} | ${_qualities.length} qualities available',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}

// Main.dart дээр ашиглах:
// void main() {
//   runApp(MaterialApp(
//     home: SimpleVideoPlayerTest(),
//   ));
// }
