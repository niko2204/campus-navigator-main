import 'package:flutter/material.dart';
import 'package:google_maps_project/map_page.dart';
import 'package:google_maps_project/ui_string.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_project/custom_locations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocationRepository.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: myStrings['mytitle']!,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00959E)),
        useMaterial3: true,
      ),
      home: MapPage(),
    );
  }
}
