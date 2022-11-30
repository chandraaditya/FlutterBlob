import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_morph/path_morph.dart';

class BlobParams {
  final double size;
  final int edges;
  final Paint? paint;
  // seed: will be ignored during animated blobs.
  final int? seed;

  BlobParams({this.edges = 6, required this.size, this.paint, this.seed}) : assert(edges >= 3);
}

class Blob extends StatefulWidget {
  final BlobParams blobParams;

  const Blob({Key? key, required this.blobParams}) : super(key: key);

  @override
  State<Blob> createState() => _BlobState();
}

class _BlobState extends State<Blob> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.blobParams.size,
      width: widget.blobParams.size,
      child: CustomPaint(
        painter: BlobCreator(
          blobParams: widget.blobParams
        )
      )
    );
  }
}

class BlobCreator extends CustomPainter {
  final BlobParams blobParams;

  BlobCreator({required this.blobParams});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = randPathGen(size.width, blobParams.edges, blobParams.seed);

    Paint paint;
    if (blobParams.paint != null) {
      paint = blobParams.paint!;
    } else {
      paint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.red;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BlobCreator oldDelegate) => false;
}



class AnimatedBlob extends StatefulWidget {
  final BlobParams blobParams;

  const AnimatedBlob({Key? key, required this.blobParams}) : super(key: key);

  @override
  State<AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<AnimatedBlob> with SingleTickerProviderStateMixin {
  late SampledPathData data;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    Path path1 = randPathGen(widget.blobParams.size, widget.blobParams.edges, widget.blobParams.seed);
    Path path2 = randPathGen(widget.blobParams.size, widget.blobParams.edges, 1 + widget.blobParams.seed!);

    data = PathMorph.samplePaths(path1, path2);

    controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    PathMorph.generateAnimations(controller, data, func);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    controller.forward();
  }

  void func(int i, Offset z) {
    setState(() {
      data.shiftedPoints[i] = z;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.blobParams.size,
      width: widget.blobParams.size,
      child: CustomPaint(
        painter: AnimatedBlobCreator(
          path: PathMorph.generatePath(data),
          blobParams: widget.blobParams
        )
      )
    );
  }
}

class AnimatedBlobCreator extends CustomPainter {
  final Path path;
  final BlobParams blobParams;

  AnimatedBlobCreator({required this.path, required this.blobParams});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint;
    if (blobParams.paint != null) {
      paint = blobParams.paint!;
    } else {
      paint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.red;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedBlobCreator oldDelegate) => true;
}

Path randPathGen(double size, int edges, int? seed) {
  double length = size;
  int numPoints = edges;

  double sliceAngle = 360 / numPoints;
  Random rnd;
  if (seed != null) {
    rnd = Random(seed);
  } else {
    rnd = Random();
  }

  List<double> slices = List<double>.filled(numPoints, 0.0);
  for (int i = 0; i < numPoints; i++) {
    double currentAngle = sliceAngle * i;
    double min, max = 0;
    double randAngle;

    if (i == 0) {
      min = currentAngle - (sliceAngle / 2);
      max = currentAngle + (sliceAngle / 2);
      var tempRandAngle = (rnd.nextDouble() * max * 2) + min;
      randAngle = tempRandAngle < 0 ? tempRandAngle + 360: tempRandAngle;
    } else if (i == numPoints - 1) {
      min = slices[i - 1];
      max = slices[0];
      if (max < 180) {
        max += 360;
      }
      randAngle = (rnd.nextDouble() * (max - min)) + min;
    } else if (i == 1) {
      if (slices[0] < 180) {
        min = slices[0];
      } else {
        min = slices[0] - 360;
      }
      max = currentAngle + (sliceAngle / 2);
      var tempRandAngle = (rnd.nextDouble() * max * 2) + min;
      randAngle = tempRandAngle < 0 ? tempRandAngle + 360: tempRandAngle;
    } else {
      min = slices[i - 1];
      max = currentAngle + (sliceAngle / 2);
      randAngle = (rnd.nextDouble() * (max - min)) + min;
    }

    slices[i] = randAngle;
  }

  List<List<double>> points = [];
  for (var degree in slices) {
    var rad = degree * (pi/180);
    var m = max((cos(rad)).abs(), (sin(rad)).abs());
    var x = ((length / 2) * cos(rad)) / m;
    var y = ((length / 2) * sin(rad)) / m;
    x += (length / 2);
    y += (length / 2);
    points.add([x, y]);
  }

  Path path = Path();

  var x1 = points[0][0];
  var y1 = points[0][1];
  var x2 = points[points.length - 1][0];
  var y2 = points[points.length - 1][1];
  var mx1 = (x1 + x2) / 2;
  var my1 = (y1 + y2) / 2;
  path.moveTo(mx1, my1);

  for (int i = 0; i < numPoints; i++) {
    var ax = points[i][0];
    var ay = points[i][1];
    var bx = points[i < (numPoints - 1) ? i + 1 : 0][0];
    var by = points[i < (numPoints - 1) ? i + 1 : 0][1];
    var mx = (ax + bx) / 2;
    var my = (ay + by) / 2;
    path.quadraticBezierTo(ax, ay, mx, my);
  }

  return path;
}