// player_controller.dart
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

class PlayerController extends GetxController {
  var audioFiles = <String>[].obs;
  final audioPlayer = AudioPlayer();
  var currentPlaying = RxnString();

  Future<void> selectAndAddAudioFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        audioFiles.addAll(result.paths.whereType<String>().toList());
        print("Songs added: \$audioFiles");
      }
    } catch (e) {
      print("Error fetching audio files: \$e");
    }
  }

  Future<void> playOrStop(String? uri) async {
    try {
      if (uri == currentPlaying.value) {
        if (audioPlayer.playing) {
          await audioPlayer.stop();
          currentPlaying.value = null;
          print("Stopped song: \$uri");
        } else {
          print("Resuming song: \$uri");
          await audioPlayer.setFilePath(uri!);
          await audioPlayer.play();
          currentPlaying.value = uri;
        }
      } else {
        await audioPlayer.stop();
        await audioPlayer.setFilePath(uri!);
        await audioPlayer.play();
        currentPlaying.value = uri;
        print("Started new song: \$uri");
      }
    } on Exception catch (e) {
      print("Error playing or stopping song: \$e");
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
