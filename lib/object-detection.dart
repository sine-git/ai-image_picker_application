import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image_picker/image_picker.dart';

class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({super.key, required this.title});
  final String title;

  @override
  State<ObjectDetectionPage> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  File? _image;
  dynamic image;
  dynamic drawImage;
  late ImagePicker imagePicker;

  String results = "";
  late ObjectDetector _objectDetector;
  late List<DetectedObject> objects;

  @override
  void initState() {
    // TODO: implement initState
    imagePicker = ImagePicker();
    _objectDetector = ObjectDetector(
        options: ObjectDetectorOptions(
            mode: DetectionMode.single,
            classifyObjects: true,
            multipleObjects: true));

    super.initState();
  }

  chooseImage(ImageSource imageSource) async {
    results = "";
    XFile? selectedImage = await imagePicker.pickImage(source: imageSource);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
      doObjectDetection();
    }
  }

  doObjectDetection() async {
    results = "";
    InputImage inputImage = InputImage.fromFile(_image!);
    objects = await _objectDetector.processImage(inputImage);

    setState(() {
      results;
    });

    drawRectangleAroundobjects();
  }

  drawRectangleAroundobjects() async {
    image = await _image?.readAsBytes();
    drawImage = await decodeImageFromList(image);
    setState(() {
      image;
      results;
      drawImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            "Image recognizer",
            style: TextStyle(color: Colors.white),
          ),
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
                    child: drawImage == null
                        ? Icon(Icons.image, size: 100)
                        : Center(
                            child: FittedBox(
                              child: InteractiveViewer(
                                child: SizedBox(
                                  width: drawImage.width.toDouble(),
                                  height: drawImage.height.toDouble(),
                                  child: CustomPaint(
                                    painter: FacePainter(
                                        objectsList: objects,
                                        imageFile: drawImage),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Card(
                  child: Container(
                    height: 100,
                    color: Colors.blue,
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

class FacePainter extends CustomPainter {
  List<DetectedObject> objectsList;
  dynamic imageFile;
  FacePainter({required this.objectsList, required this.imageFile});
  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    Paint paint = Paint();
    paint
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    print("Number of objects ${objectsList.length}");
    for (DetectedObject object in objectsList) {
      canvas.drawRect(object.boundingBox, paint);
      print("Number of labels ${object.labels.length}");
      for (Label label in object.labels) {
        print("Object ${label.text} ${label.confidence.toStringAsFixed(2)} ");
        TextSpan span = TextSpan(
            text: label.text,
            style: TextStyle(fontSize: 20, color: Colors.blue));
        TextPainter textPainter = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        textPainter.layout();
        textPainter.paint(
            canvas, Offset(object.boundingBox.left, object.boundingBox.right));
        break;
      }
    }

    Paint paint2 = Paint();
    paint2
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    Paint paint3 = Paint();
    paint3
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke;

    //return canvas.drawPaint(paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
