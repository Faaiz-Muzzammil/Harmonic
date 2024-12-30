import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerController extends GetxController {
  var audioFiles = <String>[].obs; // List of audio file paths
  final audioPlayer = AudioPlayer(); // Audio player instance
  var currentPlaying = RxnString(); // Currently playing file path
  var duration = Rx<Duration>(Duration.zero); // Observable for song duration
  var position =
      Rx<Duration>(Duration.zero); // Observable for current song position
  var isPlaying = false.obs; // Observable for playing state
  var currentIndex = 0.obs; // Current index in the song list
  var fileName = ''.obs; // Observable for file name (updated dynamically)

  // Properties for mood and playlists
  var selectedMood = ''.obs; // Observable for the currently selected mood
  var playlists = <String, List<String>>{}.obs; // Playlists mapped by mood
  var playlistSongs = <String>[].obs; // Songs for the selected mood playlist

  // Method to select and add audio files using FilePicker
  Future<void> selectAndAddAudioFiles({String? mood}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        final selectedFiles = result.paths.whereType<String>().toList();

        if (mood != null && !playlists.containsKey(mood)) {
          playlists[mood] = [];
        }

        for (var file in selectedFiles) {
          final selectedFileName = file.split('/').last;

          // Check for duplicates
          if (mood != null &&
              playlists[mood]!.any((existingFile) =>
                  existingFile.split('/').last == selectedFileName)) {
            Get.snackbar(
              "Duplicate Song",
              "Song Already Added to $mood Playlist!",
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white,
            );
          } else {
            if (mood != null) {
              playlists[mood]!.add(file);
            }
          }
        }

        // Update playlistSongs if the selected mood matches
        if (mood == selectedMood.value) {
          playlistSongs.assignAll(playlists[mood]!);
        }

        await _savePlaylists(); // Save playlists to persistent storage
      }
    } catch (e) {
      print("Error fetching audio files: $e");
    }
  }

// Method to set playlist songs
  void setPlaylistSongs(List<String> songs) {
    playlistSongs.assignAll(songs);
    update(); // Notify observers about the change
  }

  // Set mood and load playlist
  void setMood(String mood) {
    selectedMood.value = mood;
    playlistSongs.assignAll(playlists[mood] ?? []);
    print("Mood set to $mood. Songs: ${playlistSongs.value}");
  }

  // Add a song to the current mood's playlist and save persistently
  Future<void> addSongToCurrentMood(String filePath) async {
    if (selectedMood.value.isNotEmpty) {
      playlists[selectedMood.value] ??= [];
      playlists[selectedMood.value]!.add(filePath); // Add song to mood playlist
      playlistSongs.add(filePath); // Update playlist songs for the UI
      await _savePlaylistForMood(
          selectedMood.value); // Save only the current mood playlist
      update(); // Notify observers
    }
  }

  // Save the current mood's playlist to SharedPreferences
  Future<void> _savePlaylistForMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(mood, playlists[mood]!);
  }

  // Save all playlists to SharedPreferences
  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    playlists.forEach((mood, songs) {
      prefs.setStringList(mood, songs);
    });
  }

  // Load playlists from SharedPreferences
  Future<void> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    playlists.forEach((mood, _) {
      final savedList = prefs.getStringList(mood) ?? [];
      playlists[mood] = savedList;
    });
    update();
  }

  // Play song at index
  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= playlistSongs.length) {
      print("Invalid index: $index");
      return;
    }
    currentIndex.value = index;
    currentPlaying.value = playlistSongs[index];
    _updateFileName(index);
    await audioPlayer.stop();
    await audioPlayer.setFilePath(playlistSongs[index]);
    await audioPlayer.play();
    print("Playing song at index $index: ${playlistSongs[index]}");
  }

  // Play or stop song
  Future<void> playOrStop(String? uri) async {
    try {
      if (uri == currentPlaying.value) {
        if (audioPlayer.playing) {
          await audioPlayer.pause();
        } else {
          await audioPlayer.play();
        }
      } else {
        final index = playlistSongs.indexOf(uri!);
        if (index != -1) {
          await _playSongAtIndex(index);
        }
      }
    } catch (e) {
      print("Error playing or stopping song: $e");
    }
  }

  // Update file name
  void _updateFileName(int index) {
    fileName.value = playlistSongs[index].split('/').last;
  }

  // Listeners
  void _initializeListeners() {
    audioPlayer.positionStream.listen((pos) {
      position.value = pos;
    });

    audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        duration.value = dur;
      }
    });

    audioPlayer.processingStateStream.listen((processingState) async {
      if (processingState == ProcessingState.completed) {
        await playNext();
      }
    });

    audioPlayer.playingStream.listen((isPlayingValue) {
      isPlaying.value = isPlayingValue;
    });
  }

  // Next and Previous
  Future<void> playNext() async {
    if (currentIndex.value < playlistSongs.length - 1) {
      await _playSongAtIndex(currentIndex.value + 1);
    }
  }

  Future<void> playPrevious() async {
    if (currentIndex.value > 0) {
      await _playSongAtIndex(currentIndex.value - 1);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeListeners();
    _loadPlaylists(); // Load saved playlists on initialization
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
