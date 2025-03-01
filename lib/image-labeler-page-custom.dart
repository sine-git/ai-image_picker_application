import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CustomImageLabelerPage extends StatefulWidget {
  const CustomImageLabelerPage({super.key});

  @override
  State<CustomImageLabelerPage> createState() => _CustomImageLabelerPageState();
}

class _CustomImageLabelerPageState extends State<CustomImageLabelerPage> {
  File? image;
  late ImagePicker imagePicker;
  late ImageLabeler imageLabeler;
  String results = "";
  late ImageLabelerOptions options;
  @override
  void initState() {
    // TODO: implement initState
    imagePicker = ImagePicker();
    createLabler();
    super.initState();
  }

  chooseImage(ImageSource imageSource) async {
    results = "";
    XFile? selectedImage = await imagePicker.pickImage(source: imageSource);
    if (selectedImage != null) {
      setState(() {
        image = File(selectedImage.path);
      });
      performImageLabeling();
    }
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  createLabler() async {
    final modelPath =
        //await getModelPath('assets/models/mobilenet-v1-meta-data.tflite');
        await getModelPath('assets/models/efficientnet-model.tflite');
    setState(() {
      options = LocalLabelerOptions(
        confidenceThreshold: 0.9,
        modelPath: modelPath,
      );
      imageLabeler = ImageLabeler(options: options);
    });
  }

  performImageLabeling() async {
    InputImage inputImage = InputImage.fromFile(image!);
    print("...Processing image");

    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      print(
          "Image label : \n $text \n Image index: $index \n Image confidence: $confidence");
      results += "label :$text, confidence : $confidence\n";
    }
    setState(() {
      results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 109, 255, 114),
          title: Text("Custom Image labeler"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  child: Container(
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    child: image == null
                        ? Icon(Icons.image, size: 100)
                        : Image.file(
                            image!!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Card(
                  child: Container(
                    height: 100,
                    color: Color.fromARGB(255, 109, 255, 114),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            chooseImage(ImageSource.gallery);
                          },
                          child: Icon(
                            Icons.image,
                            size: 50,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            chooseImage(ImageSource.camera);
                          },
                          child: Icon(
                            Icons.camera,
                            size: 50,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Card(
                    child: Container(
                  width: double.infinity,
                  child: Text(results),
                  margin: EdgeInsets.all(10),
                ))
              ],
            ),
          ),
        ));
  }
}
