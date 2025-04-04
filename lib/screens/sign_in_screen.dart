import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_qualwebs_assignment/data/sign_in_up_repo.dart';
import 'package:flutter_chatapp_qualwebs_assignment/screens/all_chats_screen.dart';
import 'package:flutter_chatapp_qualwebs_assignment/screens/profile_screen.dart';
import 'package:flutter_chatapp_qualwebs_assignment/screens/sign_up_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/preference_helper.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final AuthRepository authObj= AuthRepository();
  final prefs = PreferenceHelper();
  bool _hidePassword = true;


  void onSignInPressed() {
    setState(() {
      isLoading = true;
    });


    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email.isEmpty || password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    authObj.signInUser(emailOrPhone: email, password: password,

        onSuccess:(userProfile) async {

          await prefs.setLoggedIn(true);
          await prefs.saveUserName(userProfile.name);
          await prefs.saveUserID(userProfile.uid);
          await prefs.saveUserEmail(userProfile.email);
          await prefs.saveUserPhone(userProfile.name);
          await prefs.saveUserPic(userProfile.profilePic);

          setState(() {
            isLoading=false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Welcome ${userProfile.name}")),
          );
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context)=>

              AllChatsScreen()
              // ProfileScreen()
              ));
        },
        onFailure: (error){

        }
    );
   }

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions(context);

  }

  // Future<void> checkAndRequestPermissions() async {
  //   List<Permission> permissions = [
  //     Permission.camera,
  //     Permission.photos, // For Android 13+ gallery access
  //   ];
  //
  //   if (await Permission.storage.isDenied) {
  //     permissions.add(Permission.storage); // For Android 12 and below
  //   }
  //
  //   Map<Permission, PermissionStatus> statuses = await permissions.request();
  //
  //   if (statuses.values.any((status) => !status.isGranted)) {
  //     // Show alert if permissions are denied
  //     print("Permissions denied! Camera & Gallery access required.");
  //     exit(0); // Closes the app
  //
  //   }
  // }

  Future<void> checkAndRequestPermissions(BuildContext context) async {
    // Define required permissions
    List<Permission> permissions = [Permission.camera];

    if (Platform.isAndroid) {
      print("version"+Platform.version);
      final deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      int sdkInt = androidInfo.version.sdkInt;

      if (sdkInt <= 32) {
        permissions.add(Permission.storage); // For Android 12 and below
      } else {
        permissions.add(Permission.photos); // For Android 13+
      }
    }

    // Request permissions
    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Check if any permission is denied
    if (statuses.values.any((status) => status.isDenied || status.isPermanentlyDenied)) {
      // Show alert only if permissions are denied
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permissions Required"),
          content: const Text("Camera & Gallery permissions are required."),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(), // Open settings to manually grant permissions
              child: const Text("Grant Permissions"),
            ),
            TextButton(
              onPressed: () => exit(0), // Exit app only after user confirmation
              child: const Text("Exit"),
            ),
          ],
        ),
      );
    }
  }



  void showImagePickerDialog(BuildContext context, Function(File) onImageSelected) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Image"),
          actions: [
            TextButton(
              onPressed: () => pickImage(ImageSource.camera, context, onImageSelected),
              child: Text("Take Photo"),
            ),
            TextButton(
              onPressed: () => pickImage(ImageSource.gallery, context, onImageSelected),
              child: Text("Choose from Gallery"),
            ),
          ],
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source, BuildContext context, Function(File) onImageSelected) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      onImageSelected(imageFile);
    }

    Navigator.pop(context);
  }

  Future<String> convertToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }


  void onForgotPasswordPressed() {
    // TODO: Implement forgot password functionality
  }

  void onSignUpPressed() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpScreen()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SoraBold',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your credentials',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'SoraRegular',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter email or mobile number',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: passwordController,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });

                    }, icon: Icon(
                     _hidePassword ? Icons.visibility_off : Icons.visibility

                    )),

                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                ),

                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSignInPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 16, fontFamily: 'SoraSemiBold', color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don’t have an account?',
                      style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'SoraRegular'),
                    ),
                    TextButton(
                      onPressed: onSignUpPressed,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'SoraMedium',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
        ],
      ),
    );
  }

}


