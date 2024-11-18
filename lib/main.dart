import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pack_mate/views/view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'packMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        HomePage.routeName: (context) => HomePage(),
        EditParty.routeName: (context) =>
            ModalRoute.of(context)!.settings.arguments as EditParty,
        AddParty.routeName: (context) => AddParty(),
        JoinParty.routeName: (context) => JoinParty(),
      },
    );
  }
}
