import 'package:flutter/material.dart';
import 'screens/training_screen.dart';
import 'screens/diet_screen.dart';
import 'screens/stats_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('training_data');

  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initSettings = InitializationSettings(android: androidSettings);
  await notificationsPlugin.initialize(initSettings);
  runApp(const MyApp());
}


void showWorkoutReminder() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'workout_channel', 'Workout Reminder',
    importance: Importance.high, priority: Priority.high,
  );

  const NotificationDetails generalNotificationDetails = NotificationDetails(android: androidDetails);

  await notificationsPlugin.show(0, "Czas na trening!", "Dzisiaj masz siady!", generalNotificationDetails);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trening & Dieta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    TrainingScreen(),
    DietScreen(),
    StatsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Trening"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Dieta"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Statystyki"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
