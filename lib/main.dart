import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_exam/providers/task_provider.dart';
import 'package:project_exam/screens/home_screen.dart';
import 'package:project_exam/services/voice_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initialize Hive
  await Hive.openBox<Map>('tasks'); // Open the 'tasks' box
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        Provider(create: (_) => VoiceService()),
      ],
      child: MaterialApp(
        title: 'Voice-Driven To-Do',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

