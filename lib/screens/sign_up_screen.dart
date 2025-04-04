import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chatapp_qualwebs_assignment/data/sign_in_up_repo.dart';
import 'package:flutter_chatapp_qualwebs_assignment/screens/all_chats_screen.dart';
import 'package:flutter_chatapp_qualwebs_assignment/screens/sign_in_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String _profileImage ="";
  bool hidePass =true;
  bool hideConfirmPass=true;
  final AuthRepository auth_obj = AuthRepository();

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
  void _signUp() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phone = numberController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields with password length greater than 6")),
      );
      return;
    }
    if(password != confirmPassword){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords don't match")),
      );
      return;
    }
    setState(() => isLoading = true);
    auth_obj.signUpUser(name: name,email: email,phone: phone,password: password,profilePic: _profileImage,
    onSuccess: (){
      setState(() {
        isLoading=false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Successful, Please Sign In!")),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
        SignInScreen()
      )); // Navigate to home screen


    },
      onFailure: (error){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );

      }
    );



    // Future.delayed(Duration(seconds: 2), () {
    //   setState(() => isLoading = false);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Sign Up Successful!')),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign Up', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Create your account', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: (){
                  showImagePickerDialog(context, (selectedImage) async {
                      String base64img=await convertToBase64(selectedImage);
                      setState(() {
                        _profileImage=base64img;
                        print("PIC "+_profileImage);
                      });
                  });

                },
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: _profileImage != "" ? MemoryImage(base64Decode(_profileImage)) : null,
                  child: _profileImage == "" ? Icon(Icons.camera_alt, size: 40, color: Colors.white) : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(nameController, 'Full Name', TextInputType.text),
            _buildTextField(emailController, 'Email ID', TextInputType.emailAddress),
            _buildTextField(numberController, 'Mobile Number', TextInputType.phone),

          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: passwordController,
              obscureText: hidePass,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                hintText: "Enter Password",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                suffixIcon:  IconButton(
                  icon: Icon(
                    hidePass ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePass = !hidePass;
                    });
                  },
                )

              ),
            ),
             ),
           Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: confirmPasswordController,
              obscureText: hideConfirmPass,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                hintText: "Confirm Password",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  suffixIcon:  IconButton(
                    icon: Icon(
                      hideConfirmPass ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        hideConfirmPass = !hideConfirmPass;
                      });
                    },
                  )
              ),
            ),
          ),


            // _buildTextField(passwordController, 'Enter Password', TextInputType.visiblePassword, obscureText: hidePass),
            // _buildTextField(confirmPasswordController, 'Confirm Password', TextInputType.visiblePassword, obscureText: hideConfirmPass),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.blue),
              child: Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?", style: TextStyle(color: Colors.grey)),
                TextButton(onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SignInScreen()));

                }, child: Text("Sign In", style: TextStyle(fontStyle: FontStyle.italic)))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType inputType, {bool obscureText = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
