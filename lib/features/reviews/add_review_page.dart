import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';
import 'review_media_players.dart';

class AddReviewPage extends StatefulWidget {
  final String stationId;
  final String stationName;

  const AddReviewPage({
    super.key,
    required this.stationId,
    required this.stationName,
  });

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  // Hardcoded highly-reliable external test URLs
  final String testVideoUrl = "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
  final String testAudioUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";

  @override
  Widget build(BuildContext context) {
    final translator = Provider.of<DynamicTranslationProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(translator.translate("Player Test"), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background ambient glow
          Positioned(
            top: -120, left: -50, right: -50,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/images/Ellipse1.png', fit: BoxFit.cover, height: 400),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translator.translate("Testing Media Players"),
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 32),

                  // 1. Render the Video Player directly
                  Text(translator.translate("Video Player Test:"), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  VideoReviewPlayer(videoUrl: testVideoUrl),

                  const SizedBox(height: 40),

                  // 2. Render the Audio Player directly
                  Text(translator.translate("Audio Player Test:"), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  AudioReviewPlayer(audioUrl: testAudioUrl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}