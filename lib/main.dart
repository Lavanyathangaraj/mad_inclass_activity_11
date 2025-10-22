import 'package:flutter/material.dart';
import 'db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // initialize DB
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SQLite Database Example'),
        ),
        body: const Center(
          child: Text(
            'Database initialized and prepopulated!',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
