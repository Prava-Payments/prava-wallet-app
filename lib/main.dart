import 'package:flutter/material.dart';
import 'package:sarva/pages/auth.dart';
import 'package:sarva/pages/welcome.dart';
void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
    '/': (context) => Welcome(),
    '/auth': (context) => Auth(),
  },
  ));
}


