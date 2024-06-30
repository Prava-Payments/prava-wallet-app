import 'package:flutter/material.dart';
import 'package:flutter_ethers/flutter_ethers.dart';
import 'package:background_sms/background_sms.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class Auth extends StatefulWidget {
  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final storage = FlutterSecureStorage();
  String _privateKey = "";
  String _publicAddress = '';

  void _signUp() async {
    String marker = 'Sarva';
    String message =
        ", from: client, to: relay, inst:signup";

    String finalMessage = marker+message;
    await BackgroundSms.sendMessage(
      phoneNumber: "7558436164", // Replace with actual phone number
      message: finalMessage,
    );

    Navigator.pushNamed(context, "/dashboard");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(color: Colors.green.shade800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "SARVA",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "NO INTERNET WE GOT YOU",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Make offline payments"),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _signUp();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade900,
                        ),
                        child: Text(
                          "IMPORT YOUR WALLET",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
