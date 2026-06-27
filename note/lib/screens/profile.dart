import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 114,
                child: CircleAvatar(
                  backgroundImage: AssetImage(
                    "assets/images/profile_image.jpg",
                  ),
                ),
              ),

              Image.asset(
                "assets/images/profile_image.jpg",
                height: 500,
                width: 500,
              ),
              Center(
                child: Text(
                  "lakpa Ngundu sherpa",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Text("Flutter Developer"),
              Text(
                "A flutter developer builds sleek mobile apps for both uos and android using Google's Flutter freamework",
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
