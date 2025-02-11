import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? image;
  late ImagePicker imagePicker;
  late ImageLabeler imageLabeler;
  String results = "";
  @override
  void initState() {
    // TODO: implement initState
    imagePicker = ImagePicker();
    final ImageLabelerOptions options =
        ImageLabelerOptions(confidenceThreshold: 0.8);
    imageLabeler = ImageLabeler(options: options);
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

  performImageLabeling() async {
    InputImage inputImage = InputImage.fromFile(image!);
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
          title: Text("Image recognizer"),
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
