import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

class BarCodeScanner extends StatefulWidget {
  const BarCodeScanner({super.key, required this.title});
  final String title;

  @override
  State<BarCodeScanner> createState() => _BarCodeScannerState();
}

class _BarCodeScannerState extends State<BarCodeScanner> {
  File? image;
  late ImagePicker imagePicker;
  late ImageLabeler imageLabeler;
  late BarcodeScanner barCodeScanner;
  String results = "";
  @override
  void initState() {
    // TODO: implement initState
    imagePicker = ImagePicker();
    List<BarcodeFormat> formats = [BarcodeFormat.all];
    barCodeScanner = BarcodeScanner(formats: formats);
  }

  chooseImage(ImageSource imageSource) async {
    results = "";
    XFile? selectedImage = await imagePicker.pickImage(source: imageSource);
    if (selectedImage != null) {
      setState(() {
        image = File(selectedImage.path);
      });
      //performImageLabeling();
      doBarCodeScanning();
    }
  }

  doBarCodeScanning() async {
    InputImage inputImage = InputImage.fromFile(image!);
    List<Barcode> barcodes = await barCodeScanner.processImage(inputImage);

    for (Barcode barcode in barcodes) {
      final BarcodeType barcodeType = barcode.type;
      final Rect? boundingBox = barcode.boundingBox;
      final String? displayValue = barcode.displayValue;
      final String? rawValue = barcode.rawValue;

      switch (barcodeType) {
        case BarcodeType.wifi:
          BarcodeWifi? barcodeWifi = barcode.value as BarcodeWifi;
          results += "Wifi ${barcodeWifi.password}";
          break;
        case BarcodeType.url:
          BarcodeUrl barcodeUrl = barcode.value as BarcodeUrl;
          results += "Url ${barcodeUrl.url}";
          break;
        default:
          results += "Value ${barcode.value}";
          break;
      }

      setState(() {
        results;
      });
    }
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
