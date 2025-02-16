import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class PoseDetectionPage extends StatefulWidget {
  const PoseDetectionPage({super.key});

  @override
  State<PoseDetectionPage> createState() => _PoseDetectionPageState();
}

class _PoseDetectionPageState extends State<PoseDetectionPage> {
  File? _image;
  dynamic image;
  dynamic drawImage;
  late ImagePicker imagePicker;
  String results = "";
  late PoseDetector _poseDetector;
  late List<Pose> _posesList;

  @override
  void initState() {
    // TODO: implement initState
    imagePicker = ImagePicker();
    _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
            mode: PoseDetectionMode.single,
            model: PoseDetectionModel.accurate));
    super.initState();
  }

  chooseImage(ImageSource imageSource) async {
    results = "";
    XFile? selectedImage = await imagePicker.pickImage(source: imageSource);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
      doPoseDetection();
    }
  }

  doPoseDetection() async {
    results = "";
    InputImage inputImage = InputImage.fromFile(_image!);
    _posesList = await _poseDetector.processImage(inputImage);

    setState(() {
      //  results = text;
    });
    for (Pose pose in _posesList) {
      pose.landmarks.forEach(
        (key, landMark) {
          final type = landMark.type;
          final x = landMark.x;
          final y = landMark.y;
          //results += "${type.name} ${x.toString()} ${y.toString()}";
          print("${type.name} ${x.toString()} ${y.toString()}");
        },
      );
      final landMark = pose.landmarks[PoseLandmarkType.nose];
    }
    setState(() {
      results;
    });

    drawPoses();
  }

  drawPoses() async {
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
            "Pose detector",
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
                                    painter: PosePainter(
                                        posesList: _posesList,
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
                  child: SelectableText(results),
                  margin: EdgeInsets.all(10),
                ))
              ],
            ),
          ),
        ));
  }
}

class PosePainter extends CustomPainter {
  List<Pose> posesList;
  dynamic imageFile;
  PosePainter({required this.posesList, required this.imageFile});
  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    Paint paint = Paint();
    paint
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    Paint leftPaint = Paint();
    leftPaint
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    Paint rightPaint = Paint();
    rightPaint
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke;

    for (Pose pose in posesList) {
      List<Offset> offsetPoints = <Offset>[];
      pose.landmarks.forEach(
        (poseLandMarkType, poseLandMark) {
          if (poseLandMark != null) {
            canvas.drawCircle(
                Offset(poseLandMark.x.toDouble(), poseLandMark.y.toDouble()),
                1,
                paint);
          }
        },
      );
      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Pose pose) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(joint1.x, joint1.y), Offset(joint2.x, joint2.y), paint);
      }

      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, pose);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, pose);
      paintLine(
          PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, pose);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, pose);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, pose);
      paintLine(
          PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, pose);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, pose);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, pose);

      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, pose);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, pose);
    }

    //return canvas.drawPaint(paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
