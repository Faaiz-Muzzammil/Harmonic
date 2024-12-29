import 'package:flutter/material.dart';
import 'package:music_player/consts/colors.dart';
import 'package:music_player/consts/text_style.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
      ),
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
              alignment: Alignment.center,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16))),
              child: Column(
                children: [
                  Text("Music Name",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: bgDarkColor,
                          fontSize: 24)),
                  const SizedBox(
                    height: 12,
                  ),
                  Text("Artist Name",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: bgDarkColor,
                          fontSize: 20)),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Text(
                        "0:0",
                        style: TextStyle(
                          color: bgDarkColor,
                        ),
                      ),
                      Expanded(
                          child: Slider(
                              thumbColor: sliderColor,
                              inactiveColor: bgColor,
                              activeColor: sliderColor,
                              value: 0.0,
                              onChanged: (newValue) {})),
                      Text(
                        "4:00",
                        style: ourStyle(
                          color: bgDarkColor,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            size: 40,
                            color: bgDarkColor,
                          )),
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: bgDarkColor,
                        child: Transform.scale(
                            scale: 2.5,
                            child: IconButton(
                              onPressed: () {}, 
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                color: whiteColor,
                              ), 
                              )
                            ),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            size: 40,
                            color: bgDarkColor,
                          ))
                    ],
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
