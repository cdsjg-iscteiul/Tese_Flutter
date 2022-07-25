import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;
  static const String  siamese = "Siamese";
  static const String  tower = "Tower";

  final String _model = tower;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          Text(picture.name),
          const ElevatedButton(onPressed: null, child: Text("Run Model"))
        ]),
      ),
    );
  }


  towers(String image) async{
    var tower_Model = await Tflite.loadModel(
        model: "assets/Tower.tflite",
        numThreads: 2
    );

    var features = await Tflite.runModelOnImage(path: image);
    debugPrint(features.toString());
  }
}