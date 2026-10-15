import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/providers/locale_provider.dart';
import 'review_media_players.dart';

// --- 1. THE STATES ---
abstract class ReviewMediaState {}

class ReviewMediaLoading extends ReviewMediaState {}

class ReviewMediaLoaded extends ReviewMediaState {
  final List<String> videoUrls;
  final List<String> audioUrls;
  final int selectedVideoIndex;

  ReviewMediaLoaded({
    required this.videoUrls,
    required this.audioUrls,
    required this.selectedVideoIndex
  });
}

class ReviewMediaError extends ReviewMediaState {
  final String message;
  ReviewMediaError(this.message);
}

// --- 2. THE CUBIT (BUSINESS LOGIC) ---
class ReviewMediaCubit extends Cubit<ReviewMediaState> {
  ReviewMediaCubit() : super(ReviewMediaLoading()) {
    // Automatically fetch media the moment this Cubit is created
    fetchMedia();
  }

  Future<void> fetchMedia() async {
    try {
      // Simulate an external API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock API Response: Videos
      final mockVideoResponse = [
        "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
      ];

      // Mock API Response: Audio
      final mockAudioResponse = [
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
      ];

      // Push the loaded state with the first video focused
      emit(ReviewMediaLoaded(
          videoUrls: mockVideoResponse,
          audioUrls: mockAudioResponse,
          selectedVideoIndex: 0
      ));
    } catch (e) {
      emit(ReviewMediaError("Failed to fetch media from server."));
    }
  }

  // Called whenever the user swipes horizontally on the video carousel
  void updateVideoIndex(int newIndex) {
    if (state is ReviewMediaLoaded) {
      final currentState = state as ReviewMediaLoaded;
      emit(ReviewMediaLoaded(
          videoUrls: currentState.videoUrls,
          audioUrls: currentState.audioUrls,
          selectedVideoIndex: newIndex
      ));
    }
  }
}

// --- 3. THE UI BLUEPRINT ---
class AddReviewPage extends StatelessWidget {
  final String stationId;
  final String stationName;

  const AddReviewPage({
    super.key,
    required this.stationId,
    required this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    // Inject the Cubit into this specific screen
    return BlocProvider(
      create: (context) => ReviewMediaCubit(),
      child: _AddReviewView(stationName: stationName),
    );
  }
}

// --- 4. THE ACTUAL VIEW (STATELESS) ---
class _AddReviewView extends StatelessWidget {
  final String stationName;

  const _AddReviewView({super.key, required this.stationName});

  @override
  Widget build(BuildContext context) {
    final translator = Provider.of<DynamicTranslationProvider>(context);
    // viewportFraction: 0.9 allows the edges of the next/previous videos to peek out slightly
    final PageController pageController = PageController(viewportFraction: 0.9);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
            "${translator.translate("Reviews")} - $stationName",
            style: const TextStyle(color: Colors.white)
        ),
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
            child: BlocBuilder<ReviewMediaCubit, ReviewMediaState>(
              builder: (context, state) {

                // 1. Loading State
                if (state is ReviewMediaLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2563EB))
                  );
                }

                // 2. Error State
                if (state is ReviewMediaError) {
                  return Center(
                    child: Text(state.message, style: const TextStyle(color: Colors.red)),
                  );
                }

                // 3. Loaded State (Split Layout)
                if (state is ReviewMediaLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 16.0),
                        child: Text(
                          translator.translate("Video Reviews"),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),

                      // --- HORIZONTAL VIDEO CAROUSEL (Fixed Height) ---
                      SizedBox(
                        height: 250,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: state.videoUrls.length,
                          onPageChanged: (index) {
                            context.read<ReviewMediaCubit>().updateVideoIndex(index);
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: VideoReviewPlayer(videoUrl: state.videoUrls[index]),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Video Indicator
                      Center(
                        child: Text(
                          "${translator.translate("Video")} ${state.selectedVideoIndex + 1} ${translator.translate("of")} ${state.videoUrls.length}",
                          style: const TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- VERTICAL AUDIO LIST ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          translator.translate("Audio Reviews"),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Expanded takes all remaining vertical space for the scrolling list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: state.audioUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: AudioReviewPlayer(audioUrl: state.audioUrls[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}