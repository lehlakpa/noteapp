import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile1 extends StatelessWidget {
  const Profile1({super.key});

  // Phone Call
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse("tel:$phoneNumber");

    if (await launchUrl(phoneUri, mode: LaunchMode.externalApplication)) {
      return;
    }

    debugPrint("Could not launch phone call");
  }

  Future<void> openWhatsApp() async {
    final String message = Uri.encodeComponent(
      "Hello Lakpa,\nI would like to contact you.",
    );

    final Uri whatsappUri = Uri.parse(
      "https://wa.me/9779709047193?text=$message",
    );

    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }

  // Viber
  Future<void> openViber() async {
    final Uri viberUri = Uri.parse("viber://chat?number=%2B9779709047193");

    if (!await launchUrl(viberUri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not open Viber");
    }
  }

  // Email
  Future<void> sendEmail() async {
    final Uri emailUri = Uri(
      scheme: "mailto",
      path: "lakpaa@gmail.com",
      query: "subject=Hello Lakpa",
    );

    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not open email");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.blue,
        // foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Profile",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => makePhoneCall("9709047193"),
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.green),
            onPressed: openWhatsApp,
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.purple),
            onPressed: openViber,
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 90,
                  backgroundImage: AssetImage("assets/images/profileimage.png"),
                ),
              ),
              const SizedBox(height: 30),

              ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  "Name",
                  style: GoogleFonts.mochiyPopOne(fontSize: 16),
                ),
                subtitle: const Text(
                  "Lakpa Ngundu Sherpa",
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Icon(Icons.more_vert),
              ),

              ListTile(
                leading: const Icon(Icons.work),
                title: Text(
                  "Department",
                  style: GoogleFonts.mochiyPopOne(fontSize: 16),
                ),
                subtitle: const Text(
                  "Flutter Developer",
                  style: TextStyle(fontSize: 18),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(
                  "Phone",
                  style: GoogleFonts.mochiyPopOne(fontSize: 16),
                ),
                subtitle: InkWell(
                  onTap: () => makePhoneCall("9709047193"),
                  child: const Text(
                    "Phone",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => makePhoneCall("9709047193"),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: Text(
                  "WhatsApp",
                  style: GoogleFonts.mochiyPopOne(fontSize: 16),
                ),
                subtitle: InkWell(
                  onTap: openWhatsApp,
                  child: const Text(
                    "+977 9709047193",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green),
                  onPressed: openWhatsApp,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.message, color: Colors.purple),
                title: Text(
                  "Viber",
                  style: GoogleFonts.mochiyPopOne(fontSize: 16),
                ),
                subtitle: InkWell(
                  onTap: openViber,
                  child: const Text(
                    "+977 9709047193",
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.message, color: Colors.purple),
                  onPressed: openViber,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.email),
                title: Text(
                  "Email",
                  style: GoogleFonts.mochiyPopOne(fontSize: 16),
                ),
                subtitle: InkWell(
                  onTap: sendEmail,
                  child: const Text(
                    "lehlakpaa@gmial.com",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.email, color: Colors.red),
                  onPressed: sendEmail,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.grey),
            label: "Settings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note, color: Colors.grey),
            label: "Notes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
