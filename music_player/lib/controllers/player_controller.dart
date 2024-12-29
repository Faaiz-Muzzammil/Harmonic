import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class PlayerController extends GetxController {
  var audioFiles = <String>[].obs; // List of audio file paths
  final audioPlayer = AudioPlayer(); // Audio player instance
  var currentPlaying = RxnString(); // Currently playing file path
  var duration = Rx<Duration>(Duration.zero); // Observable for song duration
  var position = Rx<Duration>(Duration.zero); // Observable for current song position
  var isPlaying = false.obs; // Observable for playing state
  var currentIndex = 0.obs; // Current index in the song list
  var fileName = ''.obs; // Observable for file name (updated dynamically)

  // Method to select and add audio files using FilePicker
  Future<void> selectAndAddAudioFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        // Filter valid file paths
        final selectedFiles = result.paths.whereType<String>().toList();

        for (var file in selectedFiles) {
          final selectedFileName = file.split('/').last;

          // Check for duplicates by file name
          if (audioFiles.any((existingFile) =>
              existingFile.split('/').last == selectedFileName)) {
            // Show "Song Already Added!" message if duplicate is detected
            Get.snackbar(
              "Duplicate Song",
              "Song Already Added!",
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white,
            );
          } else {
            audioFiles.add(file); // Add non-duplicate files
          }
        }
        print("Songs added: $audioFiles");
        if (audioFiles.isNotEmpty) {
          _updateFileName(0); // Update the file name for the first song
        }
      }
    } catch (e) {
      print("Error fetching audio files: $e");
    }
  }

  // Play a song at a given index
  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= audioFiles.length) {
      print("Invalid index: $index");
      return;
    }
    currentIndex.value = index;
    currentPlaying.value = audioFiles[index];
    _updateFileName(index);
    await audioPlayer.stop(); // Ensure the previous song is stopped
    await audioPlayer.setFilePath(audioFiles[index]); // Load the new song
    await audioPlayer.play(); // Start playing the new song
    print("Playing song at index $index: ${audioFiles[index]}");
  }

  // Method to play the next song immediately
  Future<void> playNext() async {
    if (currentIndex.value < audioFiles.length - 1) {
      await _playSongAtIndex(currentIndex.value + 1); // Play the next song
    } else {
      print("No more songs to play next.");
    }
  }

  // Method to play the previous song immediately
  Future<void> playPrevious() async {
    if (currentIndex.value > 0) {
      await _playSongAtIndex(currentIndex.value - 1); // Play the previous song
    } else {
      print("No previous song available.");
    }
  }

  // Method to play or stop the current song
  Future<void> playOrStop(String? uri) async {
    try {
      if (uri == currentPlaying.value) {
        if (audioPlayer.playing) {
          await audioPlayer.pause();
          print("Paused song: $uri");
        } else {
          print("Resuming song: $uri");
          await audioPlayer.play();
        }
      } else {
        final index = audioFiles.indexOf(uri!);
        if (index != -1) {
          await _playSongAtIndex(index);
        }
      }
    } on Exception catch (e) {
      print("Error playing or stopping song: $e");
    }
  }

  // Update file name (used when navigating songs)
  void _updateFileName(int index) {
    fileName.value = audioFiles[index].split('/').last;
  }

  // Initialize listeners for audio player
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
        print("Song completed. Moving to next...");
        await playNext(); // Automatically play the next song
      }
    });

    audioPlayer.playingStream.listen((isPlayingValue) {
      isPlaying.value = isPlayingValue;
    });
  }

  @override
  void onInit() {
    super.onInit();
    _initializeListeners();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
