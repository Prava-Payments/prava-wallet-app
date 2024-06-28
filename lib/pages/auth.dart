import 'package:flutter/material.dart';
import 'package:flutter_ethers/flutter_ethers.dart';
import 'package:background_sms/background_sms.dart';

class Auth extends StatefulWidget {
  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  String _privateKey = "";
  String _publicAddress = '';

  void _computePublicAddress() {
    try {
      final wallet = Wallet.fromPrivateKey(_privateKey);
      setState(() {
        if (wallet.address != null && wallet.address is String) {
          _publicAddress = wallet.address!;
        } else {
          _publicAddress = 'Invalid private key';
        }

        print("your public address is $_publicAddress");

        // Show alert dialog with public address
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Public Address"),
              content: Text("""
Your public Address is $_publicAddress
Import your account via sms"""),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    await BackgroundSms.sendMessage(
                      phoneNumber:
                          "7558436164", // Replace with actual phone number
                      message: """
Sarva
from: client,
to: relay,
public_address: $_publicAddress""",
                    );
                    Navigator.pushNamed(context, "/dashboard");
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      });
    } catch (e) {
      setState(() {
        _publicAddress = 'Invalid private key';
      });
    }
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
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _privateKey = "0x$value";
                            print(_privateKey);
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Paste your wallet ID",
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _computePublicAddress();
                          print("your private key is $_privateKey");
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
            )
          ],
        ),
      ),
    );
  }
}
