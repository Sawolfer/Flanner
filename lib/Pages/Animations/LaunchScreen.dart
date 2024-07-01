import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flanner/Pages/MainScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: AnimatedImages(),
        ),
        routes: {
          '/mainScreen': (context) => MainScreen(),
        },
      ),
    );
  }
}

class AnimatedImages extends StatefulWidget {
  @override
  _AnimatedImagesState createState() => _AnimatedImagesState();
}

class _AnimatedImagesState extends State<AnimatedImages>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.Image? _image1;
  ui.Image? _image2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.of(context).pushReplacementNamed('/mainScreen');
        }
      });
    _loadImages();
    _controller.forward();
  }

  Future<void> _loadImages() async {
    _image1 = await _loadImage('lib/assets/Hand.PNG');
    _image2 = await _loadImage('lib/assets/Note.PNG');
    setState(() {});
  }

  Future<ui.Image> _loadImage(String asset) async {
    final ByteData data = await rootBundle.load(asset);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MyPainter(_controller, _image1, _image2),
      child: Container(),
    );
  }
}

class MyPainter extends CustomPainter {
  final AnimationController controller;
  final ui.Image? image1;
  final ui.Image? image2;

  MyPainter(this.controller, this.image1, this.image2) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    if (image1 != null && image2 != null) {
      double centerX = size.width / 2;
      double centerY = size.height / 2;

      // Draw the first image (note) moving from left border to the center
      double notePosition = controller.value * centerX;
      canvas.drawImage(image2!, Offset(notePosition - image2!.width / 2, centerY - image2!.height / 2), Paint());

      // Draw the second image (hand) moving from right border to the center
      double handPosition = size.width - (controller.value * centerX);
      canvas.drawImage(image1!, Offset(handPosition - image1!.width / 2, centerY - image1!.height / 2), Paint());
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
