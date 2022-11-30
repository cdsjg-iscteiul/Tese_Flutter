import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tese/camera_page.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'MQTT_mangar.dart';

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
  MQTTClientManager mqttClientManager = MQTTClientManager();


  @override
  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
  }

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
              ElevatedButton (onPressed:  () {sendCommand("bulb", "OFF");} , child: const Text("Add new Object")),
              ElevatedButton (onPressed:  () {sendCommand("bulb", "OFF");} , child: const Text("TURN OFF")),
              ElevatedButton (onPressed:  () {sendCommand("bulb", "ON");} , child: const Text("TURN ON")),
            ],
          ),
        ),
    );

  }

   sendCommand(String topic, String command){
    setState(() {
      mqttClientManager.publishMessage(topic, command);
    });
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe("bulb");
  }

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
    });
  }

  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
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


