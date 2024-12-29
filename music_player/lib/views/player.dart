import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/consts/colors.dart';
import 'package:music_player/consts/text_style.dart';
import 'package:music_player/controllers/player_controller.dart';
import 'dart:math';

class Player extends StatelessWidget {
  final String filePath;
  final String fileName;
  final String artistName;

  Player({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.artistName,
  });

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

  // List of random colors
  final List<Color> randomColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.cyan,
    Colors.amber,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();

    // Reactive observables for icon and color
    final currentIcon = randomIcons[random.nextInt(randomIcons.length)].obs;
    final currentColor = randomColors[random.nextInt(randomColors.length)].obs;

    // Update icon and color each time a new song starts
    Future.delayed(Duration.zero, () async {
      await controller.playOrStop(filePath);
      currentIcon.value = randomIcons[random.nextInt(randomIcons.length)];
      currentColor.value = randomColors[random.nextInt(randomColors.length)];
    });

    return Scaffold(
      backgroundColor: bgDarkColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Song icon with reactive updates
              Expanded(
                flex: 2,
                child: Obx(() {
                  return Container(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentColor.value,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      currentIcon.value,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              // Song details and controls
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(196, 85, 77, 77),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reactive song title
                      Obx(() {
                        return Text(
                          controller.fileName.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: bgDarkColor,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }),
                      const SizedBox(height: 12),
                      // Static artist name passed from home.dart
                      Text(
                        artistName,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: bgDarkColor,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Reactive slider for song position and duration
                      Obx(() {
                        final position = controller.position.value;
                        final duration = controller.duration.value;

                        return Row(
                          children: [
                            Text(
                              _formatDuration(position),
                              style: const TextStyle(color: bgDarkColor),
                            ),
                            Expanded(
                              child: Slider(
                                thumbColor: const Color.fromARGB(255, 0, 0, 0),
                                inactiveColor: bgColor,
                                activeColor:
                                    const Color.fromARGB(255, 203, 201, 222),
                                value: position.inSeconds.toDouble(),
                                max: duration.inSeconds.toDouble(),
                                onChanged: (newValue) async {
                                  await controller.audioPlayer.seek(
                                    Duration(seconds: newValue.toInt()),
                                  );
                                },
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: ourStyle(color: bgDarkColor),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 12),
                      // Play/Pause and skip buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Previous button
                          IconButton(
                            onPressed: () async {
                              await controller.playPrevious();
                              currentIcon.value =
                                  randomIcons[random.nextInt(randomIcons.length)];
                              currentColor.value =
                                  randomColors[random.nextInt(randomColors.length)];
                            },
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              size: 40,
                              color: bgDarkColor,
                            ),
                          ),
                          // Reactive Play/Pause button
                          Obx(() {
                            return CircleAvatar(
                              radius: 35,
                              backgroundColor: bgDarkColor,
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
                                  color: whiteColor,
                                ),
                              ),
                            );
                          }),
                          // Next button
                          IconButton(
                            onPressed: () async {
                              await controller.playNext();
                              currentIcon.value =
                                  randomIcons[random.nextInt(randomIcons.length)];
                              currentColor.value =
                                  randomColors[random.nextInt(randomColors.length)];
                            },
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              size: 40,
                              color: bgDarkColor,
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
