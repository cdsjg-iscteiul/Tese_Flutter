import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tese/camera_page.dart';
import 'package:tflite/tflite.dart';
import 'package:tese/main.dart';
import 'package:mqtt_client/mqtt_client.dart';

void main() {
  runApp(const MaterialApp(
    title: "Smart Home",
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Home App'),
          centerTitle: true,
          backgroundColor: Colors.black54,
        ),
        body: const Center(
          child: MyHomePage(),
        ),
      ),
    );
  }



}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
 final mqttControler = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: Colors.black54,
        ),
        body: Container(
            alignment: Alignment.center,
            child: SizedBox(
            width: 300,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:  <Widget>[
                     TextField(
                              controller: mqttControler,
                              decoration: const InputDecoration(
                              border:  OutlineInputBorder(),
                              labelText: 'MQTT IP Address'),
                             ),
                    OutlinedButton(onPressed: (){ Navigator.pop(context, mqttControler.text );}, child:  const Text('Save')),
          ],
        )
        )
    )

    );
  }

}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String ip = "0.0.0.0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:   [  Text("The IP is: $ip") ,
               ElevatedButton(onPressed: () async {WidgetsFlutterBinding.ensureInitialized();
                 try {
                   await availableCameras().then((value) =>
                       Navigator.push(context,
                         MaterialPageRoute(builder: (context) =>
                             CameraPage(cameras: value,),
                         ),)
                   );
                 }  on CameraException catch (e) {
                      debugPrint(e.code);
                      debugPrint(e.description);
                 }
              },  child: const Text('Open Camera'),  ),
              const ElevatedButton(onPressed: null, child: Text('Choose Picture')),
              TextButton (onPressed:  () {_settingsMQTTPageIP(context);}, child: const Icon(Icons.settings , color: Colors.black,)),
            ],
          ),
        ),
    );


  }


  void updateText(String ip2){
    setState(() {
      ip = ip2;
    });
  }

  Future<void> _settingsMQTTPageIP(BuildContext context) async {
      ip = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
      updateText(ip);
    if (!mounted) return;


    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text("Saved Settings")) );


  }
}


