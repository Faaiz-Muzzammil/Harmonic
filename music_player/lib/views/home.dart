import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/consts/colors.dart';
import 'package:music_player/consts/text_style.dart';
import 'package:music_player/controllers/player_controller.dart';
import 'package:music_player/views/player.dart';
import 'dart:math';

class Home extends StatelessWidget {
  Home(
      {super.key,
      required String selectedMood,
      required List<String> playlistSongs}) {
    final controller = Get.put(PlayerController(), permanent: true);
    controller.setMood(selectedMood); // Set mood in controller
    controller.setPlaylistSongs(playlistSongs); // Set playlist songs
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();
    final random = Random();
    final artistNames = [
      "Bruno Mars",
      "Dua Lipa",
      "The Weeknd",
      "Mitraz",
      "Malik"
    ];

    return Scaffold(
      backgroundColor: _getMoodThemeColor(controller.selectedMood.value),
      appBar: AppBar(
        backgroundColor: _getMoodThemeColor(controller.selectedMood.value),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.audio,
                allowMultiple: false,
              );
              if (result != null) {
                final filePath = result.paths.first!;
                await controller.addSongToCurrentMood(
                    filePath); // Add song to mood playlist
              }
            },
            icon: const Icon(Icons.add),
            color: whiteColor,
          ),
        ],
        leading: const Icon(
          Icons.sort_rounded,
          color: whiteColor,
        ),
        title: Obx(() => Text(
              "${controller.selectedMood.value} Mood",
              style: ourStyle(
                family: "bold",
                size: 18,
              ),
            )),
      ),
      body: Obx(() {
        final playlistSongs = controller.playlistSongs;

        if (playlistSongs.isEmpty) {
          return Center(
            child: Text(
              "No Songs Found for ${controller.selectedMood.value} Mood!",
              style: ourStyle(),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: playlistSongs.length,
              itemBuilder: (BuildContext context, int index) {
                final filePath = playlistSongs[index];
                final fileName = filePath.split('/').last;
                final randomArtist =
                    artistNames[random.nextInt(artistNames.length)];

                return Obx(() {
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
                      onTap: () async {
                        if (controller.currentPlaying.value == filePath &&
                            controller.audioPlayer.playing) {
                          Get.to(
                            () => Player(
                              filePath: filePath,
                              fileName: fileName,
                              artistName: randomArtist,
                            ),
                            transition: Transition.downToUp,
                          );
                        } else {
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
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: whiteColor,
                        ),
                        onPressed: () async {
                          if (isPlaying) {
                            await controller.audioPlayer.pause();
                          } else {
                            await controller.playOrStop(filePath);
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

  Color _getMoodThemeColor(String mood) {
    switch (mood) {
      case "Happy":
        return Colors.redAccent;
      case "Sad":
        return Colors.blueAccent;
      case "Relaxed":
        return Colors.greenAccent;
      case "Energetic":
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }
}
