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
  String? sessionStr;
  String? walletAddr;

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
            if (smsData.body.contains("Sarva, from: relay, to: client")) {
              balanceMessage = smsData.body;
              extractBalances(balanceMessage!);
            }
          });
        });
      }
    });
  }

  void extractBalances(String message) {
    // Regular expressions to extract the ETH, USDC balances, session string, and wallet address
    final ethRegex = RegExp(r'ETH:\s*([0-9.]+)');
    final usdcRegex = RegExp(r'USDC:\s*([0-9.]+)');
    final sessionRegex = RegExp(r'session:\s*([a-zA-Z0-9]+)');
    final walletRegex = RegExp(r'wallet:\s*([a-zA-Z0-9]+)');

    final ethMatch = ethRegex.firstMatch(message);
    final usdcMatch = usdcRegex.firstMatch(message);
    final sessionMatch = sessionRegex.firstMatch(message);
    final walletMatch = walletRegex.firstMatch(message);

    if (ethMatch != null && ethMatch.groupCount > 0) {
      ethBalance = ethMatch.group(1);
    }

    if (usdcMatch != null && usdcMatch.groupCount > 0) {
      usdcBalance = usdcMatch.group(1);
    }

    if (sessionMatch != null && sessionMatch.groupCount > 0) {
      sessionStr = sessionMatch.group(1);
      print("your session str:$sessionStr");
    }

    if (walletMatch != null && walletMatch.groupCount > 0) {
      walletAddr = walletMatch.group(1);
      print("your wallet addr:$walletAddr");
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

  void refetchBalance() {}

  void generateSign() async {
    String marker = 'Sarva';
    String message =
        ", from: client, to: relay, inst:sendETH, wallet:$publicAddress, token:$tokenValue, session:$sessionStr";
    String finalMessage = marker + message;
    print(finalMessage);
    await BackgroundSms.sendMessage(
      phoneNumber: "9915712441",
      message: finalMessage,
    );
  }

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
                                        onPressed: () {
                                          generateSign();
                                        },
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
