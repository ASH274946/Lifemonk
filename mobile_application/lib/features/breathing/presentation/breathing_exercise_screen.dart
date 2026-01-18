import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../shared/widgets/custom_dialog.dart';
import 'controllers/breathing_animation_controller.dart';
import 'controllers/breathing_timer_controller.dart';
import 'widgets/water_breathing_circle.dart';
import 'widgets/air_flow_layer.dart';
import 'widgets/bubble_effects.dart';
import 'widgets/celebration_overlay.dart';

/// Breathing Exercise Screen with calming animations
class BreathingExerciseScreen extends StatefulWidget {
  final int durationMinutes;

  const BreathingExerciseScreen({super.key, this.durationMinutes = 5});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late BreathingAnimationController _breathingController;
  late BreathingTimerController _timerController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const String _breathingAudioUrl =
      'https://cdn.pixabay.com/download/audio/2023/02/28/audio_d4b7c522f0.mp3?filename=relaxing-pad-loop-142963.mp3';

  bool _isPaused = false;
  bool _showStars = false;
  bool _showCelebration = false;
  bool _nearEnd = false;

  @override
  void initState() {
    super.initState();

    // Initialize breathing animation controller
    _breathingController = BreathingAnimationController(
      vsync: this,
      onPhaseChange: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    // Initialize timer controller
    _timerController = BreathingTimerController(
      sessionDurationSeconds: widget.durationMinutes * 60,
      onTick: () {
        if (mounted) {
          setState(() {});
        }
      },
      onThirtySecondsLeft: () {
        if (mounted) {
          setState(() {
            _nearEnd = true;
          });
        }
      },
      onTenSecondsLeft: () {
        if (mounted) {
          setState(() {
            _showStars = true;
          });
        }
      },
      onComplete: () {
        _breathingController.stop();
        if (mounted) {
          setState(() {
            _showCelebration = true;
          });
        }
      },
    );

    // Start the session
    _breathingController.start();
    _timerController.start();
    _startAudioLoop();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _timerController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;

      if (_isPaused) {
        _breathingController.pause();
        _timerController.pause();
        _audioPlayer.pause();
      } else {
        _breathingController.resume();
        _timerController.resume();
        _audioPlayer.resume();
      }
    });
  }

  void _stopSession() {
    CustomDialog.show(
      context: context,
      title: 'Stop Session?',
      message: 'Are you sure you want to end your breathing session?',
      primaryButtonText: 'Stop',
      secondaryButtonText: 'Cancel',
      isDangerous: true,
      onPrimaryPressed: () {
        _audioPlayer.stop();
        Navigator.pop(context); // Close breathing screen
      },
    );
  }

  Future<void> _startAudioLoop() async {
    try {
      await _audioPlayer.setSource(UrlSource(_breathingAudioUrl));
      await _audioPlayer.setVolume(0.35);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();
    } catch (_) {
      // Audio is optional; ignore failures to avoid blocking the UI.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              children: [
                // App bar
                _buildAppBar(),

                // Main breathing area
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main content column
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 1),

                          // Session title and duration
                          const Text(
                            'Mindful Breathing',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.durationMinutes} min session',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),

                          const Spacer(flex: 1),

                          // Layered breathing animations
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Air flow layer (behind)
                                AirFlowLayer(
                                  currentPhase:
                                      _breathingController.currentPhase,
                                  isAnimating: _breathingController.isAnimating,
                                ),

                                // Water breathing circle (center)
                                WaterBreathingCircle(
                                  animation: _breathingController.animation,
                                  currentPhase:
                                      _breathingController.currentPhase,
                                  timeRemaining: _timerController.formattedTime,
                                  isNearEnd: _nearEnd,
                                  isAlmostDone: _showStars,
                                ),

                                // Rising bubbles effect when almost done
                                if (_showStars)
                                  const Positioned.fill(
                                    child: Center(child: RisingBubblesEffect()),
                                  ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 1),

                          // Instruction text with animation
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              _breathingController.currentPhase.instruction,
                              key: ValueKey(_breathingController.currentPhase),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),

                          const Spacer(flex: 2),

                          // Control buttons
                          _buildControlButtons(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Celebration overlay
          if (_showCelebration)
            Positioned.fill(
              child: CelebrationOverlay(
                onComplete: () {
                  Navigator.pop(context);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        // Pause/Resume button
        GestureDetector(
          onTap: _togglePause,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Stop Session button
        GestureDetector(
          onTap: _stopSession,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
            ),
            child: const Text(
              'Stop Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    if (_nearEnd) {
      // Warmer color near the end
      return const Color(0xFFFFF8E7);
    }
    return const Color(0xFFF0F7FA); // Light blue background
  }
}
