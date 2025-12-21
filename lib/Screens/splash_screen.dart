import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // Future.delayed(Duration(seconds: 2), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen())), );
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Image.asset('assets/images/assistant.png',
                width: size.width *.45,
              ),
            ),
          ),
          Lottie.asset('assets/lottie/ai_loading.json', height: size.height *.4),
        ],
      ),
    );
  }
}
