import 'dart:io';

import 'package:dartssh2/dartssh2.dart'
    show SSHClient, SSHSession, SSHSocket, SftpFileOpenMode;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_galaxy_control/entities/orbit_entity.dart';
import 'package:liquid_galaxy_control/info_dialog_provider.dart';
import 'package:liquid_galaxy_control/models/orbit_model.dart';
import 'package:liquid_galaxy_control/utils/utils.dart';
import 'package:liquid_galaxy_control/widgets/toast_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/looking_at_entity.dart';

class SSH {
  late String host;
  late String port;
  late String username;
  late String password;
  late String noOfRigs;
  SSHClient? client;
  Future<void> initConnection() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    host = pref.getString("ipAddress") ?? "default_host";
    port = pref.getString("port") ?? "22";
    username = pref.getString("username") ?? "lg";
    password = pref.getString("password") ?? "lg";
    noOfRigs = pref.getString("numberOfRigs") ?? "3";
  }

  LogMessage logMessage = LogMessage(Tag: "SSH");
  Future<bool?> connectToLG(FToast toast) async {
    await initConnection();
    try {
      logMessage.LogPrint(
          message: "$host\n$username\n$port\n$password\n$noOfRigs");

      final socket = await SSHSocket.connect(host, int.parse(port));
      client = SSHClient(socket,
          username: username, onPasswordRequest: () => password);

      logMessage.LogPrint(message: "Client : $client");
      return true;
    } on SocketException catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Socket Error : $e",
              const Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(message: "Error : $e");
      return false;
    }
  }

  Future<SSHSession?> execute(FToast toast) async {
    try {
      if (client == null) {
        logMessage.LogPrint(message: "execute : SSH Client in uninitalized");
        return null;
      }
      final executeResult =
          await client!.execute('echo "search=India" >/tmp/query.txt');
      logMessage.LogPrint(
          method: "execute", message: "executeResult : $executeResult");

      return executeResult;
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              const Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(method: "execute", message: "Error Occured : $e");
      return null;
    }
  }

  Future<void> restartLG(FToast toast) async {
    try {
      if (client == null) {
        logMessage.LogPrint(method: "restartLG", message: "Client : $client");
        toast.showToast(
            child: ToastWidget(
                "No Connection",
                Icon(
                  Icons.error,
                  color: Colors.red,
                )));
      }
      for (var i = 1; i <= int.parse(noOfRigs); i++) {
        final executeResult = await client!.execute(
            'sshpass -p ${password} ssh -t lg$i "echo ${password} | sudo -S reboot"');
        logMessage.LogPrint(
            method: "restartLG", message: "executeResult : $executeResult");
      }
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(method: "restartLG", message: "Error Occured : $e");
    }
  }

  startOrbit() async {
    try {
      await client!.run('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      // logMessage.LogPrint(method: "startOrbit", message: "Error Occured : $e");
      stopOrbit();
    }
  }

  Future<void> rightScreenInfoDialog(FToast toast) async {
    try {
      if (client == null) {
        logMessage.LogPrint(
            method: "startOrbiting", message: "Client : $client");
        toast.showToast(
            child: ToastWidget(
                "No Connection",
                Icon(
                  Icons.error,
                  color: Colors.red,
                )));
        return;
      }
      int totalScreen = int.parse(noOfRigs);
      int rightMostScreen = (totalScreen / 2).floor() + 1;
      toast.showToast(
          child: ToastWidget("Showing Info Dialog", Icon(Icons.chat_bubble)));
      final executeResult = await client!.execute(
          "echo '${InfoDialogProvider.dialog()}' > /var/www/html/kml/slave_$rightMostScreen.kml");
      print(executeResult);
      //fToast.showToast(child: getToastWidget(executeResult.toString(), Colors.grey, Icons.cable));
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(method: "loadKML", message: "Error Occured : $e");
    }
  }

  Future<SSHSession?> relaunchLG(FToast toast) async {
    try {
      int i = 1;
      toast.showToast(
          child: ToastWidget(
              "Relaunchig LG$i",
              Icon(
                Icons.replay,
                color: Colors.black,
              )));
      String cmd = """RELAUNCH_CMD="\\
          if [ -f /etc/init/lxdm.conf ]; then
            export SERVICE=lxdm
          elif [ -f /etc/init/lightdm.conf ]; then
            export SERVICE=lightdm
          else
            exit 1
          fi
          if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
            echo ${password} | sudo -S service \\\${SERVICE} start
          else
            echo ${password} | sudo -S service \\\${SERVICE} restart
          fi
          " && sshpass -p ${password} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
      final executeResult = await client!.execute(cmd);
      logMessage.LogPrint(
          method: "relaunch", message: "executeResult : $executeResult");
      toast.showToast(
          child: ToastWidget(
              executeResult.toString(),
              Icon(
                Icons.replay,
                color: Colors.black,
              )));

      return executeResult;
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(method: "relaunchLG", message: "Error Occured : $e");
      return null;
    }
  }

  Future<SSHSession?> shutDownLG(FToast toast) async {
    try {
      int i = 1;
      toast.showToast(
          child: ToastWidget(
              "Shutting Down LG$i",
              Icon(
                Icons.power_settings_new,
                color: Colors.red,
              )));
      String cmd =
          'sshpass -p ${password} ssh -t lg$i "echo ${password} | sudo -S poweroff"';
      final executeResult = await client!.execute(cmd);
      logMessage.LogPrint(
          method: "shutdownLG", message: "executeResult : $executeResult");
      toast.showToast(child: ToastWidget(executeResult.toString(), null));
      return executeResult;
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(method: "shutDownLG", message: "Error Occured : $e");
      return null;
    }
  }

  Future<SSHSession?> search(FToast toast, String home) async {
    try {
      if (client == null) {
        logMessage.LogPrint(method: "search", message: "Client : $client");
        toast.showToast(
            child: ToastWidget(
                "No Connection",
                Icon(
                  Icons.error,
                  color: Colors.red,
                )));
        return null;
      }
      toast.showToast(
          child: ToastWidget(
              "Searching",
              Icon(
                Icons.search,
                color: Colors.black,
              )));
      final executeResult =
          await client!.execute('echo "search=$home" >/tmp/query.txt');
      print(executeResult);
      toast.showToast(child: ToastWidget(executeResult.toString(), null));
      return executeResult;
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(method: "search", message: "Error Occured : $e");
      return null;
    }
  }

  createFile(FToast toast, String filename, String content) async {
    try {
      var localPath = await getApplicationDocumentsDirectory();
      File localFile = File('${localPath.path}/${filename}.kml');
      await localFile.writeAsString(content);
      return localFile;
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(method: "createFile", message: "Error Occured : $e");
      return null;
    }
  }

  String orbitLookAtLinear(double latitude, double longitude, double zoom,
      double tilt, double bearing) {
    return '<gx:duration>1.2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
  }

  Future<SSHSession?> flyToOrbit(FToast toast, double latitude,
      double longitude, double zoom, double tilt, double bearing) async {
    try {
      if (client == null) {
        logMessage.LogPrint(method: "search", message: "Client : $client");
        toast.showToast(
            child: ToastWidget(
                "No Connection",
                Icon(
                  Icons.error,
                  color: Colors.red,
                )));
        return null;
      }

      final executeResult = await client!.execute(
          'echo "flytoview=${orbitLookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
      logMessage.LogPrint(
          method: "flyToOrbit", message: "executeResult : $executeResult");
      toast.showToast(child: ToastWidget(executeResult.toString(), null));
      return executeResult;
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(method: "flyToOrbit", message: "Error Occured : $e");
      return null;
    }
  }

  Future<void> infoDialogAtHome(FToast toast) async {
    try {
      if (client == null) {
        logMessage.LogPrint(
            method: "infoDialogAtHome", message: "Client : $client");
        toast.showToast(
            child: ToastWidget(
                "No Connection",
                Icon(
                  Icons.error,
                  color: Colors.red,
                )));
        return;
      }

      String balloonKML = InfoDialogProvider.dialog();

      File inputFile = await createFile(toast, "InfoKML", balloonKML);
      await uploadKMLFile(toast, inputFile, "InfoKML", "Task_Balloon");
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(
          method: "infoDialogAtHome", message: "Error Occured : $e");
    }
  }

  Future<void> startOrbiting(FToast toast) async {
    try {
      if (client == null) {
        logMessage.LogPrint(
            method: "startOrbiting", message: "Client : $client");
        toast.showToast(
            child: ToastWidget(
                "No Connection",
                Icon(
                  Icons.error,
                  color: Colors.red,
                )));
        return;
      }

      //await cleanKML();

      LookingAtEntity lookingAtEntity = LookingAtEntity(
          lng: 86.427040, lat: 23.795399, range: 7000, tilt: 60, heading: 0);
      String orbitKML = OrbitModel(OrbitEntity(lookingAtEntity)).buildOrbit();
      // String orbitKML = OrbitEntity.buildOrbit(OrbitEntity.tag(LookingAtEntity(
      //     lng: 86.427040, lat: 23.795399, range: 7000, tilt: 60, heading: 0)));

      File inputFile = await createFile(toast, "OrbitKML", orbitKML);
      await uploadKMLFile(toast, inputFile, "OrbitKML", "Task_Orbit");
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(
          method: "startOrbiting", message: "Error Occured : $e");
    }
  }

  uploadKMLFile(
      FToast toast, File inputFile, String kmlName, String task) async {
    try {
      bool uploading = true;
      //fToast.showToast(child: getToastWidget("uploading true", Colors.grey, Icons.cable));
      final sftp = await client!.sftp();
      final file = await sftp.open('/var/www/html/$kmlName.kml',
          mode: SftpFileOpenMode.create |
              SftpFileOpenMode.truncate |
              SftpFileOpenMode.write);
      var fileSize = await inputFile.length();
      file.write(inputFile.openRead().cast(), onProgress: (progress) async {
        if (fileSize == progress) {
          //fToast.showToast(child: getToastWidget("uploading false", Colors.grey, Icons.cable));
          uploading = false;
          if (task == "Task_Orbit") {
            await loadKML(toast, "OrbitKML", task);
          } else if (task == "Task_Balloon") {
            await loadKML(toast, "BalloonKML", task);
          }
        }
      });
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(
          method: "uploadKMLFile", message: "Error Occured : $e");
    }
  }

  loadKML(FToast toast, String kmlName, String task) async {
    try {
      toast.showToast(child: ToastWidget('Loading KML', Icon(Icons.file_copy)));
      final v = await client!.execute(
          "echo 'http://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt");
      //fToast.showToast(child: getToastWidget('KML loaded $v', Colors.grey, Icons.cable));
      if (task == "Task_Orbit") {
        await beginOrbiting(toast);
      } else if (task == "Task_Balloon") {
        await showBalloon(toast);
      }
    } catch (e) {
      toast.showToast(
          child: ToastWidget(
              "Error : $e",
              Icon(
                Icons.error,
                color: Colors.red,
              )));
      logMessage.LogPrint(method: "loadKML", message: "Error Occured : $e");
      await loadKML(toast, kmlName, task);
    }
  }

  beginOrbiting(FToast toast) async {
    try {
      toast.showToast(child: ToastWidget('Begin Orbiting', null));
      final res = await client!.run('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (error) {
      await beginOrbiting(toast);
    }
  }

  showBalloon(FToast toast) async {
    try {
      String balloonKML = InfoDialogProvider.dialog();

      await client!.run("echo '$balloonKML' > /var/www/html/kml/slave_2.kml");

      toast.showToast(
          child: ToastWidget('Info Dialog Visible', Icon(Icons.chat_bubble)));
    } catch (error) {
      await showBalloon(toast);
    }
  }

  stopOrbit() async {
    try {
      await client!.run('echo "exittour=true" > /tmp/query.txt');
    } catch (e) {
      // logMessage.LogPrint(method: "stopOrbit", message: "Error Occured : $e");
      stopOrbit();
    }
  }

  cleanInfoDialog() async {
    try {
      await client!.run(
          "echo '${InfoDialogProvider.blankDialog()}' > /var/www/html/kml/slave_2.kml");
      await client!.run(
          "echo '${InfoDialogProvider.blankDialog()}' > /var/www/html/kml/slave_3.kml");
    } catch (e) {
      // logMessage.LogPrint(
      //     method: "cleanInfoDialog", message: "Error Occured : $e");
      await cleanInfoDialog();
    }
  }

  cleanSlaves() async {
    try {
      await client!.run("echo '' > /var/www/html/kml/slave_2.kml");
      await client!.run("echo '' > /var/www/html/kml/slave_3.kml");
    } catch (e) {
      // logMessage.LogPrint(method: "cleanSlaves", message: "Error Occured : $e");
      await cleanSlaves();
    }
  }

  cleanKML() async {
    try {
      await cleanInfoDialog();
      await stopOrbit();
      await client!.run("echo '' > /tmp/query.txt");
      await client!.run("echo '' > /var/www/html/kmls.txt");
    } catch (e) {
      await cleanKML();
    }
  }
}
