import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/views/home.dart';

class ChooseMoodPage extends StatelessWidget {
  final Map<String, List<String>> moodPlaylists;

  const ChooseMoodPage({super.key, required this.moodPlaylists});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "What's Your Mood?",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: moodPlaylists.keys.length,
          itemBuilder: (context, index) {
            final mood = moodPlaylists.keys.elementAt(index);
            final songs = moodPlaylists[mood]!;

            return Card(
              color: Colors.grey[900], // Dark theme card background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Text(
                    mood[0],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                title: Text(
                  mood,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                subtitle: Text(
                  "${songs.length} songs available",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                onTap: () {
                  Get.to(() => Home(
                        selectedMood: mood,
                        playlistSongs: songs,
                      ));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
