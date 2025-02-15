import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
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
  late FaceDetector _faceDetector;
  late List<Face> faces;

  @override
  void initState() {
    // TODO: implement initState
    imagePicker = ImagePicker();
    _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
      minFaceSize: 0.3,
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ));

    super.initState();
  }

  chooseImage(ImageSource imageSource) async {
    results = "";
    XFile? selectedImage = await imagePicker.pickImage(source: imageSource);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
      doFaceDetection();
    }
  }

  doFaceDetection() async {
    results = "";
    InputImage inputImage = InputImage.fromFile(_image!);
    faces = await _faceDetector.processImage(inputImage);
    print("Number of faces ${faces.length}");
    for (Face face in faces) {
      if (face.smilingProbability! > 0.5) {
        results += "Similing";
      } else {
        results += "Serious";
      }
    }
    /* for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;
      final double? rotX = face.headEulerAngleX;
      final double? rotY = face.headEulerAngleY;
      final double? rotZ = face.headEulerAngleZ;

      final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];

      if (leftEar != null) {
        final Point<int> leftEarPos = leftEar.position;
      }

      if (face.smilingProbability != null) {
        final double? smileProd = face.smilingProbability;
      }
      if (face.trackingId != null) {
        final int? id = face.trackingId;
      }
    } */
    setState(() {
      results;
    });

    drawRectangleAroundFaces();
  }

  drawRectangleAroundFaces() async {
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
                                        facesList: faces, imageFile: drawImage),
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
  List<Face> facesList;
  dynamic imageFile;
  FacePainter({required this.facesList, required this.imageFile});
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
    for (Face face in facesList) {
      canvas.drawRect(face.boundingBox, paint);
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
    for (Face face in facesList) {
      print("The face number");
      Map<FaceContourType, FaceContour?> con = face.contours;
      print("The number of face contours is ${con.length}");
      List<Offset> offsetPoints = <Offset>[];
      con.forEach((key, value) {
        print("The contour key is $key");
        print("The contour value is $value");
        if (value != null) {
          print("The point value is $value");
          List<Point<int>>? points = value.points;
          for (Point point in points) {
            Offset offset = Offset(point.x.toDouble(), point.y.toDouble());
            offsetPoints.add(offset);
          }
          canvas.drawPoints(PointMode.points, offsetPoints, paint2);
          final FaceLandmark leftEar =
              face.landmarks[FaceLandmarkType.leftEar]!;
          if (leftEar != null) {
            final Point<int> leftEarPos = leftEar.position;
            canvas.drawRect(
                Rect.fromLTWH(leftEarPos.x.toDouble() - 5,
                    leftEarPos.y.toDouble() - 5, 10, 10),
                paint3);
          }
        }
      });
    }
    //return canvas.drawPaint(paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
