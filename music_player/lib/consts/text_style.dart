import 'package:flutter/material.dart';
import 'package:music_player/consts/colors.dart';

const normal = "normal";
const regular = "regular";

ourStyle({family = "regular", double? size = 14, color = whiteColor}) {
  return TextStyle(fontSize: size, color: color, fontFamily: family);
}
