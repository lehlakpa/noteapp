import 'dart:math';
import 'package:flutter/material.dart';

class RockGame extends StatefulWidget {
  const RockGame({super.key});

  @override
  State<RockGame> createState() => _RockGameState();
}

class _RockGameState extends State<RockGame> {
  final List<String> images = [
    "assets/rockgame/r.png", // Rock
    "assets/rockgame/p.png", // Paper
    "assets/rockgame/s.png", // Scissors
  ];

  int player = 0;
  int computer = 0;
  String result = "Tap your choice";

  void play(int playerChoice) {
    setState(() {
      player = playerChoice;
      computer = Random().nextInt(images.length);

      if (player == computer) {
        result = "Draw!";
      } else if ((player == 0 && computer == 2) ||
          (player == 1 && computer == 0) ||
          (player == 2 && computer == 1)) {
        result = "You Win!";
      } else {
        result = "Computer Wins!";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/rockgame/background_image.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Computer",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                RotatedBox(
                  quarterTurns: 2,
                  child: Image.asset(images[computer], width: 150),
                ),

                Text(
                  result,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Image.asset(images[player], width: 150),

                const Text(
                  "Choose",
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => play(0),
                      child: Image.asset(images[0], width: 80),
                    ),
                    GestureDetector(
                      onTap: () => play(1),
                      child: Image.asset(images[1], width: 80),
                    ),
                    GestureDetector(
                      onTap: () => play(2),
                      child: Image.asset(images[2], width: 80),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
