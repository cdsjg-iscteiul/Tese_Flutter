import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'MQTT_mangar.dart';


class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  _PreviewPageDetection createState() => _PreviewPageDetection();
}

class _PreviewPageDetection extends State<PreviewPage> {
  bool _loading = true;
  late XFile _image;
  late List _output;

  MQTTClientManager mqttClientManager = MQTTClientManager();


  late XFile pic;
  @override
  void dispose() {
    Tflite.close();
    mqttClientManager.disconnect();
    super.dispose();
  }

  imageClassification(XFile image) async {
    var output = await Tflite.runModelOnImage(

      path: image.path,
      numResults: 20
    );

    print(output);

    setState(() {
      _output = output!;
      _loading = false;
    });

    print(_output);
  }

  _loadModel() async {
    try {
      await Tflite.loadModel(
          model: "assets/model_test.tflite",
          labels: "assets/labels_2.txt");
    } on PlatformException catch(e){
      debugPrint('Error occured while importing model: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadModel().then((value) {
      setState(() {});
    });
    setupMqttClient();
    setupUpdatesListener();
  }

  @override
  Widget build(BuildContext context) {
    File picture1 = File(widget.picture.path);
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(picture1, fit: BoxFit.cover, width: 160, height: 160),
          const SizedBox(height: 160, width: 160,),
          Text(picture1.path),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the command',
              ),
            ),
          ),
          ElevatedButton(onPressed: ()  {
            sendImage("images", widget.picture);
          }, child: const Text("TURN OFF")),
        ]),
      ),
    );
  }


  sendImage(String topic, XFile imagem) async {
    pic =  await resizeImage(imagem) ;
    File ficheiro = File(pic.path);
    final bytes = await ficheiro.readAsBytes();
    for (var byte in bytes) {
      setState(() {
        mqttClientManager.publishMessage_bytes(topic, byte.toString());
      });
    }

    setState(() {
      mqttClientManager.publishMessage(topic, "STOP");
    });
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe("images");
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


  Future<XFile> resizeImage(img) async {

    File compressedFile = await FlutterNativeImage.compressImage(img.path,
        quality: 90,
        targetWidth: 160,
        targetHeight: 160) ;

    // delete original file
    try {
      if (await img.exists()) {
        await img.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }

    return XFile(compressedFile.path);
  }

}