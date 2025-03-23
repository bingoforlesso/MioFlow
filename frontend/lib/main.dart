import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mio_ding/services/api_service.dart';
import 'package:mio_ding/screens/home_screen.dart';
import 'package:mio_ding/providers/auth_provider.dart';
import 'package:mio_ding/providers/cart_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MioDing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}