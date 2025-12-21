import 'package:flutter/material.dart';

import 'Screens/splash_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // test 
  runApp(AiAssistant());
}

class AiAssistant extends StatelessWidget {
  const AiAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('Hello Everyone'));
  }
}
