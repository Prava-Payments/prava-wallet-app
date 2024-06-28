import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class Welcome extends StatefulWidget {

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
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
                    )),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      "NO INTERNET WE GOT YOU",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    )),
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
                        Navigator.pushNamed(context, "/auth");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade900,
                      ),
                      child:
                          Text("Join", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
