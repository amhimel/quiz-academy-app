import 'package:flutter/material.dart';
import 'package:quiz_academy/widgets/avatar.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDD),
      appBar: AppBar(title: const Text('Upload Image')),
      body: Center(
        child: Avatar(
          imageUrl: _imageUrl,
          onUpload: (imageUrl) {
            setState(() {
              _imageUrl = imageUrl;
            });
          },
        ),
      ),
    );
  }
}
