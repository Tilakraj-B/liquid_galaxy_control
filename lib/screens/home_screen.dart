import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_galaxy_control/screens/lg_connect_screen.dart';
import 'package:liquid_galaxy_control/utils/utils.dart';
import 'package:liquid_galaxy_control/widgets/buttons.dart';

import '../service/ssh.dart';
import '../widgets/toast_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FToast toast = FToast();
  LogMessage logMessage = LogMessage(Tag: "HomeScreen");
  bool isConnected = false;
  late SSH ssh;

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG(toast);
    logMessage.LogPrint(method: "_connectToLG", message: "$result");
    setState(() {
      isConnected = result!;
    });
    await ssh.cleanKML();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ssh = SSH();
      _connectToLG();
    });
  }

  @override
  Widget build(BuildContext context) {
    toast.init(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final textSize = width > height ? height * 0.05 : width * 0.05;
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: width > height
            ? _buildLandscape(context, width, height, textSize)
            : _buildPortrait(context, width, height, textSize));
  }

  _buildLandscape(
      BuildContext context, double width, double height, double textSize) {
    return Stack(children: [
      Image.asset(
        "assets/images/bg.png",
        width: width,
        fit: BoxFit.fitWidth,
      ),
      Column(
        children: [
          Expanded(
              flex: 3,
              child: Center(
                child: Image.asset(
                  "assets/images/lg_logo.png",
                  width: height / 4,
                  height: height / 4,
                ),
              )),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Card(
                  color: Colors.white.withOpacity(0.1),
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  LargeButton(
                                      leadingIcon: Icons.restart_alt,
                                      label: "Reboot LG",
                                      onPressed: () async {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.warning,
                                          animType: AnimType.rightSlide,
                                          title: 'Reboot Liquid Galaxy',
                                          desc:
                                              'Reboot the three Liquid Galaxies',
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () async {
                                            await ssh.restartLG(toast);
                                          },
                                        )..show();
                                      }),
                                  LargeButton(
                                      label: "Go Home",
                                      leadingIcon: Icons.home,
                                      onPressed: () async {
                                        SSHSession? sshSession =
                                            await ssh.flyToOrbit(
                                                toast,
                                                23.795399,
                                                86.427040,
                                                7095,
                                                60,
                                                0);
                                        if (sshSession != null) {
                                          logMessage.LogPrint(
                                              method: "Home Button Click",
                                              message: "Successfull");
                                          toast.showToast(
                                              child: ToastWidget(
                                                  "Go Home Successfull", null));
                                        } else {
                                          logMessage.LogPrint(
                                              method: "Home Button Click",
                                              message: "Failed");

                                          toast.showToast(
                                              child: ToastWidget(
                                                  "Go Home Failed", null));
                                        }
                                      }),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  LargeButton(
                                      label: "Start Orbiting",
                                      leadingIcon: Icons.threed_rotation,
                                      onPressed: () async {
                                        await ssh.startOrbiting(toast);
                                      }),
                                  LargeButton(
                                      label: "Toggle Info Dialog",
                                      leadingIcon: Icons.messenger,
                                      onPressed: () async {
                                        await ssh.rightScreenInfoDialog(toast);
                                      }),
                                ],
                              ),
                            ),
                          )
                        ],
                      ))),
            ),
          ),
          Expanded(
              flex: 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Card(
                  color: Colors.black.withOpacity(0.7),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Status : ",
                                    style: TextStyle(
                                        fontSize: textSize,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    isConnected ? "Connected" : "Not Connected",
                                    style: TextStyle(
                                      color: isConnected
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: textSize,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: LargeButton(
                              label: "Connection Manager",
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LGConnectScreen()));
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    ]);
  }

  _buildPortrait(
      BuildContext context, double width, double height, double textSize) {
    return Stack(children: [
      Image.asset(
        "assets/images/bg.png",
        width: width,
        fit: BoxFit.fitWidth,
      ),
      Column(
        children: [
          Expanded(
              flex: 3,
              child: Center(
                child: Image.asset(
                  "assets/images/lg_logo.png",
                  width: height / 4,
                  height: height / 4,
                ),
              )),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Card(
                  color: Colors.white.withOpacity(0.1),
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: LargeButton(
                                      leadingIcon: Icons.restart_alt,
                                      label: "Reboot LG",
                                      onPressed: () async {
                                        await ssh.restartLG(toast);
                                      }),
                                ),
                                Expanded(
                                  child: LargeButton(
                                      label: "Go Home",
                                      leadingIcon: Icons.home,
                                      onPressed: () async {
                                        SSHSession? sshSession =
                                            await ssh.flyToOrbit(
                                                toast,
                                                23.795399,
                                                86.427040,
                                                7095,
                                                60,
                                                0);
                                        if (sshSession != null) {
                                          logMessage.LogPrint(
                                              method: "Home Button Click",
                                              message: "Successfull");
                                          toast.showToast(
                                              child: ToastWidget(
                                                  "Go Home Successfull", null));
                                        } else {
                                          logMessage.LogPrint(
                                              method: "Home Button Click",
                                              message: "Failed");

                                          toast.showToast(
                                              child: ToastWidget(
                                                  "Go Home Failed", null));
                                        }
                                      }),
                                ),
                                Expanded(
                                  child: LargeButton(
                                      label: "Start Orbiting",
                                      leadingIcon: Icons.threed_rotation,
                                      onPressed: () async {
                                        await ssh.startOrbiting(toast);
                                      }),
                                ),
                                Expanded(
                                  child: LargeButton(
                                      label: "Toggle Info Dialog",
                                      leadingIcon: Icons.messenger,
                                      onPressed: () async {
                                        await ssh.rightScreenInfoDialog(toast);
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ))),
            ),
          ),
          Expanded(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Card(
                  color: Colors.black.withOpacity(0.7),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              child: Row(
                                children: [
                                  Text(
                                    "Status : ",
                                    style: TextStyle(
                                        fontSize: textSize,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    isConnected ? "Connected" : "Not Connected",
                                    style: TextStyle(
                                      color: isConnected
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: textSize,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: LargeButton(
                              label: "Connection Manager",
                              onPressed: () async {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LGConnectScreen()));
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    ]);
  }
}
