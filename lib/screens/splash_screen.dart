import 'package:flutter/material.dart';
import 'package:flutter_chatapp_qualwebs_assignment/screens/sign_in_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SvgPicture.asset("assets/images/spalsh_logo.svg", height: 200,width: 200,),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
        Future.delayed(Duration(seconds: 5),(){
          Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (context) => SignInScreen())
          );
    });
  }
}
