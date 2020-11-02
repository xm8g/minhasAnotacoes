import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(NotasDiarias());
}

class NotasDiarias extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

