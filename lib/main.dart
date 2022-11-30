import 'package:blob_animation/blob.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: HomeApp()
      ),
    );
  }
}

class HomeApp extends StatefulWidget {
  const HomeApp({Key? key}) : super(key: key);

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBlob(
        blobParams: BlobParams(
            size: 500,
            paint: Paint()
              ..style = PaintingStyle.fill
              ..color = Colors.green,
            edges: 5,
            seed: 34563
        ),
      ),
      // child: Blob(
      //   blobParams: BlobParams(
      //     size: 500,
      //     paint: Paint()
      //       ..style = PaintingStyle.fill
      //       ..color = Colors.green,
      //     edges: 5,
      //     seed: 34563
      //   ),
      // ),
    );
  }
}

