// home.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/consts/colors.dart';
import 'package:music_player/consts/text_style.dart';
import 'package:music_player/controllers/player_controller.dart';
import 'dart:math';

import 'package:music_player/views/player.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());
    final random = Random();
    final artistNames = ["Bruno Mars", "Dua Lipa", "Weeknd", "Mitraz", "Malik"];

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
          leading: Icon(
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
                  physics: BouncingScrollPhysics(),
                  itemCount: controller.audioFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    // Extract file path
                    final filePath = controller.audioFiles[index];
                    final fileName = filePath.split('/').last; // File name
                    final randomArtist =
                        artistNames[random.nextInt(artistNames.length)];

                    return Obx(() {
                      final isPlaying = controller.currentPlaying == filePath &&
                          controller.audioPlayer.playing;
                      return Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          tileColor: bgColor,
                          title: Text(
                            fileName,
                            style: ourStyle(family: normal, size: 18),
                          ),
                          subtitle: Text(
                            randomArtist, // Display random artist name
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: const Icon(
                            Icons.music_note,
                            color: whiteColor,
                            size: 32,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: whiteColor,
                            ),
                            onPressed: () async {
                              print("Button tapped: \$filePath");
                              await controller.playOrStop(filePath);
                            },
                          ),
                          onTap: () {
                            Get.to(() => const Player());
                            // print("Tile tapped: \$filePath");
                            // await controller.playOrStop(filePath);
                          },
                        ),
                      );
                    });
                  }),
            );
          }
        }));
  }
}
