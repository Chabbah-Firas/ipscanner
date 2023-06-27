import 'dart:async';
import 'dart:io';
//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<String> ipAddressList = [];
  

  Future<void> scanNetwork() async {
    ipAddressList.clear();
    final networkInfo = NetworkInfo();
    final ipAddress = await networkInfo.getWifiIP();
    //ipAddressList.add(ipAddress);
    final subnet = ipAddress!.substring(0, ipAddress.lastIndexOf('.'));
    const port =22;

    for (var i = 1; i < 254; i++) {
      final targetIp = '$subnet.$i';

      try {
        final socket = await Socket.connect(targetIp, port, timeout: Duration(milliseconds: 150));

        final host = await reverseLookup(targetIp);

        if (host != null) {
          final ip = socket.address.address;

          setState(() {
            ipAddressList.add('$host ($ip)');
          });
        }

        socket.destroy();
      } catch (error) {
        print('IP: $targetIp');
        print('Error: $error');
        
        if (error is SocketException && error.osError?.errorCode == 111) {
          // Error code 111 indicates "Connection refused"
          setState(() {
            ipAddressList.add(targetIp);
          });
        }
      }
    }

    print('Done');
  }
  


  Future<String?> reverseLookup(String ipAddress) async {
    try {
      final addresses = await InternetAddress.lookup(ipAddress);

      if (addresses.isNotEmpty) {
        return addresses.first.host;
      }
    } catch (error) {
      print('Error: $error');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Network Scanner'),
          
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                scanNetwork();
              },
              
              child: const Text('Scan Network'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ipAddressList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(ipAddressList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
