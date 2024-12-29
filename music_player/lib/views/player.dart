import 'package:flutter/material.dart';
import 'package:music_player/consts/colors.dart';
import 'package:music_player/consts/text_style.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(backgroundColor: whiteColor,),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.music_note),
              ),
            ),

            Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16)
                  )
                ),
                child: Column(
                  children: [
                    Text(
                      "Music Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: bgDarkColor,
                        fontSize: 24
                      )
                    )
                  ],
                ),
            )),
          ],
        ),
      ),
    );
  }
}
