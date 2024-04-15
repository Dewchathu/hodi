import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hodi/screens/splash_screen.dart';
import 'package:hodi/theme/theme_constants.dart';
import 'package:hodi/theme/theme_manager.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hodi',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeManager.themMode,
      home: SplashScreen(cameras: cameras),
    );
  }
}
