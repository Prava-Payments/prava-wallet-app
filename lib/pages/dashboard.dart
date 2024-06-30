import 'package:flutter/material.dart';
import 'package:readsms/readsms.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';

class Dashboard extends StatefulWidget {
  @override
  _Dashboard createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  final storage = FlutterSecureStorage();
  final _plugin = Readsms();
  List<SmsData> smsList = [];
  String? balanceMessage; // Variable to store the specific message content
  String? ethBalance; // Variable to store the ETH balance
  String? usdcBalance; // Variable to store the USDC balance
  String? publicAddress; // Variable to store the public address
  String? tokenValue;

  @override
  void initState() {
    super.initState();
    getPermission().then((value) {
      if (value) {
        _plugin.read();
        _plugin.smsStream.listen((event) {
          setState(() {
            SmsData smsData = SmsData(
              body: event.body,
              sender: event.sender,
              timeReceived: event.timeReceived,
            );
            smsList.insert(0, smsData);

            // Check for specific content and update the balanceMessage
            if (smsData.body
                .contains("Sarva, from: relay, to: client, balance:")) {
              balanceMessage = smsData.body;
              extractBalances(balanceMessage!);
            }
          });
        });
      }
    });
  }

  String? extractEncodeMsg(String messageContent) {
    try {
      final base64Part =
          messageContent.substring(messageContent.indexOf("Sarva") + 5).trim();
      final decodedBytes = base64Decode(base64Part);
      final decodedMessage = utf8.decode(decodedBytes);

      // Extract the instruction from the decoded message
      final instruction = decodedMessage
          .split(", ")
          .firstWhere((part) => part.startsWith("inst:"))
          .split(":")[1];
      return instruction;
    } catch (e) {
      print("Error decoding message: $e");
      return null;
    }
  }

  void extractBalances(String message) {
    // Regular expressions to extract the ETH, USDC balances, and nonce
    final ethRegex = RegExp(r'ETH:\s*([0-9.]+)');
    final usdcRegex = RegExp(r'USDC:\s*([0-9.]+)');

    final ethMatch = ethRegex.firstMatch(message);
    final usdcMatch = usdcRegex.firstMatch(message);

    if (ethMatch != null && ethMatch.groupCount > 0) {
      ethBalance = ethMatch.group(1);
    }

    if (usdcMatch != null && usdcMatch.groupCount > 0) {
      usdcBalance = usdcMatch.group(1);
    }
  }

  Future<bool> getPermission() async {
    if (await Permission.sms.status == PermissionStatus.granted) {
      return true;
    } else {
      if (await Permission.sms.request() == PermissionStatus.granted) {
        return true;
      } else {
        print("Permission denied");
        return false;
      }
    }
  }

  void refetchBalance() {
    // Simulate fetching public address from keychain
    setState(() {
      publicAddress =
          "0xYourPublicKeyHere"; // Replace with actual logic to fetch from keychain
    });

    // Send background SMS with public address
    BackgroundSms.sendMessage(
      phoneNumber: "7558436164", // Replace with actual phone number
      message: "Sarva, from: client, to: relay, public_address: $publicAddress",
    );
  }

  void generateSign() async {}

  @override
  void dispose() {
    super.dispose();
    _plugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (balanceMessage == null)
                  Text('Hearing response from relay...')
                else ...[
                  if (ethBalance != null && usdcBalance != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'ETH: $ethBalance',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'USDC: $usdcBalance',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Enter Public Address",
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        publicAddress = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Enter token amount",
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        tokenValue = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: ElevatedButton(
                                        onPressed: generateSign,
                                        child: Text("Send Tokens")))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: refetchBalance,
                                    child: Text("Refetch Balance"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance Update:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(balanceMessage!),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: smsList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(smsList[index].body),
                            subtitle: Text("From: ${smsList[index].sender}"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmsData {
  final String body;
  final String sender;
  final DateTime timeReceived;

  SmsData(
      {required this.body, required this.sender, required this.timeReceived});
}
