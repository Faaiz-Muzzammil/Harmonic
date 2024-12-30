import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controllers/player_controller.dart';
import 'dart:math';

class Player extends StatefulWidget {
  final String filePath;
  final String fileName;
  final String artistName;

  const Player({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.artistName,
  });

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> with TickerProviderStateMixin {
  final random = Random();

  // List of random icons
  final List<IconData> randomIcons = [
    Icons.coffee,
    Icons.music_note,
    Icons.star,
    Icons.lightbulb,
    Icons.favorite,
    Icons.cloud,
    Icons.camera_alt,
    Icons.sports_esports,
    Icons.flight,
    Icons.anchor,
  ];

  // Mood-based gradient colors
  final Map<String, List<Color>> moodColors = {
    "Happy": [Colors.red[700]!, Colors.redAccent, Colors.deepOrange[400]!],
    "Sad": [Colors.blue[900]!, Colors.indigo[800]!, Colors.blueGrey[700]!],
    "Relaxed": [Colors.green[800]!, Colors.teal[600]!, Colors.cyan[400]!],
    "Energetic": [Colors.yellow[700]!, Colors.orange[600]!, Colors.amber[500]!],
    "Default": [Colors.grey[900]!, Colors.black87, Colors.blueGrey[800]!],
  };

  late AnimationController _iconController;
  late AnimationController _buttonController;
  late Animation<Color?> _iconStartColor;
  late Animation<Color?> _iconEndColor;
  late Animation<Color?> _buttonStartColor;
  late Animation<Color?> _buttonEndColor;

  late IconData currentIcon;

  @override
  void initState() {
    super.initState();

    // Initialize random icon for the first song
    currentIcon = randomIcons[random.nextInt(randomIcons.length)];

    // Initialize AnimationControllers for gradients
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Set up animations for icon and button gradients
    _setupAnimations();
  }

  void _setupAnimations() {
    // Get the selected mood from the controller
    final controller = Get.find<PlayerController>();
    final selectedMood = controller.selectedMood.value;

    // Get gradient colors based on the selected mood
    final gradientColors = moodColors[selectedMood] ?? moodColors["Default"]!;

    _iconStartColor = ColorTween(
      begin: gradientColors[random.nextInt(gradientColors.length)],
      end: gradientColors[random.nextInt(gradientColors.length)],
    ).animate(_iconController);

    _iconEndColor = ColorTween(
      begin: gradientColors[random.nextInt(gradientColors.length)],
      end: gradientColors[random.nextInt(gradientColors.length)],
    ).animate(_iconController);

    _buttonStartColor = ColorTween(
      begin: gradientColors[random.nextInt(gradientColors.length)],
      end: gradientColors[random.nextInt(gradientColors.length)],
    ).animate(_buttonController);

    _buttonEndColor = ColorTween(
      begin: gradientColors[random.nextInt(gradientColors.length)],
      end: gradientColors[random.nextInt(gradientColors.length)],
    ).animate(_buttonController);
  }

  void _onSongChange() {
    setState(() {
      // Change the icon to a new random one
      currentIcon = randomIcons[random.nextInt(randomIcons.length)];

      // Reset and restart the animations with new colors
      _setupAnimations();
      _iconController.reset();
      _iconController.forward();
      _buttonController.reset();
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Now Playing",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Animated gradient circle for the icon
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _iconController,
                  builder: (context, child) {
                    return Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _iconStartColor.value ?? Colors.black,
                            _iconEndColor.value ?? Colors.black,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_iconStartColor.value ?? Colors.black)
                                .withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        currentIcon,
                        size: 80,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Song details and controls
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reactive song title
                      Obx(() {
                        return Text(
                          controller.fileName.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }),
                      const SizedBox(height: 8),
                      // Static artist name passed from home.dart
                      Text(
                        widget.artistName,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Reactive slider for song position and duration
                      Obx(() {
                        final position = controller.position.value;
                        final duration = controller.duration.value;

                        // Ensure slider value stays within bounds
                        final sliderValue = position.inSeconds.toDouble();
                        final maxSliderValue = duration.inSeconds.toDouble();

                        return Row(
                          children: [
                            Text(
                              _formatDuration(position),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _iconController,
                                builder: (context, child) {
                                  return Slider(
                                    thumbColor: Colors.white,
                                    inactiveColor:
                                        (_iconEndColor.value ?? Colors.grey)
                                            .withOpacity(0.5),
                                    activeColor: _iconStartColor.value ??
                                        Colors.blueAccent,
                                    value:
                                        sliderValue.clamp(0.0, maxSliderValue),
                                    max: maxSliderValue > 0
                                        ? maxSliderValue
                                        : 1.0, // Prevent divide by 0
                                    onChanged: (newValue) async {
                                      if (duration > Duration.zero) {
                                        await controller.audioPlayer.seek(
                                          Duration(seconds: newValue.toInt()),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      // Play/Pause and skip buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Previous button
                          IconButton(
                            onPressed: () async {
                              await controller.playPrevious();
                              _onSongChange();
                            },
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          // Reactive Play/Pause button
                          Obx(() {
                            return CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey[800],
                              child: IconButton(
                                onPressed: () async {
                                  if (controller.isPlaying.value) {
                                    await controller.audioPlayer.pause();
                                  } else {
                                    await controller.audioPlayer.play();
                                  }
                                },
                                icon: Icon(
                                  controller.isPlaying.value
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                          // Next button
                          IconButton(
                            onPressed: () async {
                              await controller.playNext();
                              _onSongChange();
                            },
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
