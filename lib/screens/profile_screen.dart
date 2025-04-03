import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_qualwebs_assignment/data/preference_helper.dart';
import 'package:flutter_chatapp_qualwebs_assignment/screens/sign_in_screen.dart';
import 'package:flutter_svg/svg.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PreferenceHelper? _prefs;
  String userName = "";
  String email = "";
  String phone = "";
  String profilePic="";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _prefs = PreferenceHelper();
    String? fetchedUserName = await _prefs?.getUserName();
    String? fetchedEmail = await _prefs?.getUserEmail();
    String? fetchedPhone = await _prefs?.getUserPhone();
    String? fetchedProfilePic = await _prefs?.getUserPic();

    setState(() {
      userName = fetchedUserName ?? "Dummy Text";
      email = fetchedEmail ?? "dummyemail@gmail.com";
      phone = fetchedPhone ?? "9014636901";
      profilePic = fetchedProfilePic ?? "";
    });
  }

  Uint8List? base64ToImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    return base64Decode(base64String);
  }

  void _logout() async {
    await _prefs?.clearUserData();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SignInScreen()) ); // Update with your route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 65,
              backgroundImage: profilePic != "" ? MemoryImage(base64ToImage(profilePic)!) : AssetImage("assets/images/profile.png") as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("Hey there! I'm using Qualwebs ChatApp", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 20),
            _buildInfoTile("Email", email),
            _buildInfoTile("Mobile Number", phone),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Log Out", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
