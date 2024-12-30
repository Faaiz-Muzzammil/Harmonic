import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'choose_mood_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class MoodPlaylists extends StatefulWidget {
  const MoodPlaylists({super.key});

  @override
  _MoodPlaylistsState createState() => _MoodPlaylistsState();
}

class _MoodPlaylistsState extends State<MoodPlaylists> {
  final Map<String, List<String>> moodPlaylists = {
    "Happy": [],
    "Sad": [],
    "Relaxed": [],
    "Energetic": []
  };

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    moodPlaylists.forEach((mood, _) {
      final savedList = prefs.getStringList(mood) ?? [];
      moodPlaylists[mood] = savedList;
    });
    setState(() {});
  }

  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    moodPlaylists.forEach((mood, songs) {
      prefs.setStringList(mood, songs);
    });
  }

  Future<void> _addSongsToMood(String mood) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        final selectedFiles = result.paths.whereType<String>().toList();
        setState(() {
          moodPlaylists[mood]!.addAll(selectedFiles);
        });
        await _savePlaylists();
      }
    } catch (e) {
      print("Error adding songs to $mood playlist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Create Your Playlists",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
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
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  elevation: 4,
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
                      "$mood Playlist",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    subtitle: Text(
                      "${songs.length} songs added",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () => _addSongsToMood(mood),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _savePlaylists();
              Get.to(() => ChooseMoodPage(moodPlaylists: moodPlaylists));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
              child: Text(
                "Done",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}