import 'package:flutter/material.dart';

class Profile2 extends StatelessWidget {
  const Profile2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("profile", style: TextStyle(fontSize: 20)),
        actions: [Icon(Icons.edit)],
        leading: Icon(Icons.back_hand),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: const CircleAvatar(
              radius: 90,
              // clipRReact(borderRadius.circular(1000) child -Image.assets(""height:208 width:208))
              backgroundImage: AssetImage("assets/images/profileimage.png"),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 20),
              const Icon(Icons.person),
              const Column(
                children: [Text("Name"), Text("Lakpa Ngundu Sherpa")],
              ),
            ],
            //spacer()=> auto adjust the extra error space
          ),
        ],
      ),
    );
  }
}
