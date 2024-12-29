import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/consts/colors.dart';
import 'package:music_player/consts/text_style.dart';
import 'package:music_player/controllers/player_controller.dart';
import 'package:music_player/views/player.dart';
import 'dart:math';

class Home extends StatelessWidget {
  Home({super.key});

  // Initialize the PlayerController once
  final controller = Get.put(PlayerController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final artistNames = [
      "Bruno Mars",
      "Dua Lipa",
      "The Weeknd",
      "Mitraz",
      "Malik"
    ];

    return Scaffold(
      backgroundColor: bgDarkColor,
      appBar: AppBar(
        backgroundColor: bgDarkColor,
        actions: [
          IconButton(
            onPressed: () async {
              await controller.selectAndAddAudioFiles();
            },
            icon: const Icon(Icons.add),
            color: whiteColor,
          )
        ],
        leading: const Icon(
          Icons.sort_rounded,
          color: whiteColor,
        ),
        title: Text(
          "Harmonic",
          style: ourStyle(
            family: "bold",
            size: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.audioFiles.isEmpty) {
          return Center(
            child: Text(
              "No Song Found!",
              style: ourStyle(),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: controller.audioFiles.length,
              itemBuilder: (BuildContext context, int index) {
                final filePath = controller.audioFiles[index];
                final fileName = filePath.split('/').last;
                final randomArtist =
                    artistNames[random.nextInt(artistNames.length)];

                return Obx(() {
                  // Check if the current song is playing
                  final isPlaying =
                      controller.currentPlaying.value == filePath &&
                          controller.audioPlayer.playing;

                  return Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: bgColor,
                      title: Text(
                        fileName,
                        style: ourStyle(family: normal, size: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        randomArtist,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(
                        Icons.music_note,
                        color: whiteColor,
                        size: 32,
                      ),
                      // On tap (anywhere except the button), navigate to Player
                      onTap: () async {
                        if (controller.currentPlaying.value == filePath &&
                            controller.audioPlayer.playing) {
                          // Navigate to player.dart without reloading the song
                          Get.to(
                            () => Player(
                              filePath: filePath,
                              fileName: fileName,
                              artistName: randomArtist,
                            ),
                            transition: Transition.downToUp,
                          );
                        } else {
                          // If a different song is selected, update and play it
                          controller.currentIndex.value = index;
                          await controller.playOrStop(filePath);
                          Get.to(
                            () => Player(
                              filePath: filePath,
                              fileName: fileName,
                              artistName: randomArtist,
                            ),
                            transition: Transition.downToUp,
                          );
                        }
                      },
                      trailing: IconButton(
                        icon: Obx(() => Icon(
                              controller.currentPlaying.value == filePath &&
                                      controller.audioPlayer.playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: whiteColor,
                            )),
                        onPressed: () async {
                          // Play/Pause logic for this song directly
                          if (controller.currentPlaying.value == filePath &&
                              controller.audioPlayer.playing) {
                            await controller.audioPlayer.pause();
                            controller.isPlaying.value =
                                false; // Explicitly update play state
                          } else {
                            await controller.playOrStop(filePath);
                            controller.currentPlaying.value =
                                filePath; // Update currentPlaying
                            controller.isPlaying.value =
                                true; // Explicitly update play state
                          }
                        },
                      ),
                    ),
                  );
                });
              },
            ),
          );
        }
      }),
    );
  }
}
