import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_galaxy_control/screens/home_screen.dart';
import 'package:liquid_galaxy_control/utils/utils.dart';
import 'package:liquid_galaxy_control/widgets/buttons.dart';
import 'package:liquid_galaxy_control/widgets/textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/ssh.dart';
import '../widgets/toast_widget.dart';

class LGConnectScreen extends StatefulWidget {
  const LGConnectScreen({super.key});

  @override
  State<LGConnectScreen> createState() => _LGConnectScreenState();
}

class _LGConnectScreenState extends State<LGConnectScreen> {
  bool isConnected = false;
  final toast = FToast();
  TextEditingController ipController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController rigsNumController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final LogMessage logMessage = LogMessage(Tag: "LGConnectScreen");
  late SSH ssh;

  @override
  void dispose() {
    ipController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    portController.dispose();
    rigsNumController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (ipController.text.isNotEmpty) {
      await prefs.setString('ipAddress', ipController.text);
    }
    if (usernameController.text.isNotEmpty) {
      await prefs.setString('username', usernameController.text);
    }
    if (passwordController.text.isNotEmpty) {
      await prefs.setString('password', passwordController.text);
    }
    if (portController.text.isNotEmpty) {
      await prefs.setString('port', portController.text);
    }
    if (rigsNumController.text.isNotEmpty) {
      await prefs.setString('numberOfRigs', rigsNumController.text);
    }
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ipController.text = prefs.getString('ipAddress') ?? '';
      usernameController.text = prefs.getString('username') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      portController.text = prefs.getString('port') ?? '';
      rigsNumController.text = prefs.getString('numberOfRigs') ?? '';
    });
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG(toast);
    logMessage.LogPrint(method: "_connectToLG", message: "resutl : $result");
    setState(() {
      isConnected = result!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      ssh = SSH();
      _loadSettings();
      _connectToLG();
    });
  }

  void changeConnectionState() {
    setState(() {
      isConnected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final textSize = width > 1.5 * height ? height * 0.05 : width * 0.05;
    toast.init(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen())),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Container(
            child: Text(
              "Connect to LG",
              style: TextStyle(color: Colors.white, fontSize: textSize),
            ),
          ),
        ),
        body: Stack(children: [
          Image.asset(
            "assets/images/bg.png",
            width: width,
            fit: BoxFit.fitWidth,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: height >= 1.5 * width
                  ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Form(
                key: _formKey,
                child: Container(
                  height: height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(children: [
                        InputText(
                            label: "IP Address",
                            hintText: "IP Address",
                            controller: ipController),
                        InputText(
                            label: "Username",
                            hintText: "Username",
                            controller: usernameController),
                        InputText(
                            label: "Password",
                            hintText: "Password",
                            controller: passwordController),
                        InputText(
                            label: "Port",
                            hintText: "Port",
                            controller: portController),
                        InputText(
                            label: "No. of Rigs",
                            hintText: "No. of Rigs",
                            controller: rigsNumController),
                      ]),
                      Column(
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Status : ",
                                  style: TextStyle(
                                      fontSize: textSize, color: Colors.white),
                                ),
                                Text(
                                  isConnected ? "Connected" : "Not Connected",
                                  style: TextStyle(
                                    color:
                                        isConnected ? Colors.green : Colors.red,
                                    fontSize: textSize,
                                  ),
                                )
                              ],
                            ),
                          ),
                          LargeButton(
                              label: "Connect To LG",
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  toast.showToast(
                                      child: ToastWidget("Connecting..", null));
                                  await _saveSettings();
                                  SSH ssh = SSH();
                                  bool? result = await ssh.connectToLG(toast);
                                  logMessage.LogPrint(
                                      method: "Connect To LG",
                                      message: "result : $result");

                                  if (result == true) {
                                    changeConnectionState();
                                    toast.showToast(
                                        child: Container(
                                      color: Colors.green,
                                      child: const Text(
                                        "Connected",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ));
                                  } else {
                                    isConnected = false;
                                    toast.showToast(
                                        child: Container(
                                      color: Colors.red,
                                      child: const Text(
                                        "Failed to Connect",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ));
                                  }
                                }
                              }),
                          LargeButton(
                            label: "Start LG",
                            onPressed: () async {
                              SSH ssh = SSH();
                              await ssh.connectToLG(toast);
                              SSHSession? sshSession = await ssh.execute(toast);
                              if (sshSession != null) {
                                toast.showToast(
                                    child: Container(
                                        color: Colors.green,
                                        child: const Text(
                                          "Started LG Successfully",
                                          style: TextStyle(color: Colors.white),
                                        )));
                              } else {
                                toast.showToast(
                                    child: Container(
                                  color: Colors.red,
                                  child: const Text(
                                    "Fialed to Start LG",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ));
                              }
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
