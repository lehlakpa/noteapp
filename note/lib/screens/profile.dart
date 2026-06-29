import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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

              // Image.asset(
              //   "assets/images/profile_image.jpg",
              //   height: 500,
              //   width: 500,
              // ),
              Center(
                child: Text(
                  "lakpa Ngundu sherpa",
                  style: GoogleFonts.praise(fontSize: 30),
                ),
              ),
              Text("Flutter Developer"),
              Text(
                "A flutter developer builds sleek mobile apps for both uos and android using Google's Flutter freamework",
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromARGB(15, 98, 46, 43),
                ),
                child: Text(
                  "lakpa@gmial.com",
                  style: GoogleFonts.lato(color: Colors.white),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(
                        "https://www.instagram.com/reel/DZwofTqArFs/?utm_source=ig_web_copy_link&igsh=MzRlODBiNWFlZA==",
                      );

                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Could not open the link."),
                          ),
                        );
                      }
                    },
                    child: Image.asset("assets/images/Internet.png"),
                  ),
                  Image.asset("assets/images/Internet.png"),
                  Image.asset("assets/images/Internet.png"),
                  Image.asset("assets/images/Internet.png"),
                  Image.asset("assets/images/Internet.png"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
