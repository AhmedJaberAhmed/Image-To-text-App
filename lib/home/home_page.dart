import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_background/animated_background.dart';

import '../claude_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  File? _image;
  String? _description;
  bool _isLoading = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 1080,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
        await analyzeImage();
      }
    } catch (e) {
      debugPrint("Image picking error: $e");
    }
  }

  Future<void> analyzeImage() async {
    if (_image == null) return;

    setState(() => _isLoading = true);

    try {
      final description = await GeminiService().analyzeImage(_image!);
      setState(() {
        _description = description;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Image analysis error: $e");
      setState(() {
        _description = "⚠️ Server is busy, please try again.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("  AI Vision App",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black87,
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: const ParticleOptions(
            baseColor: Colors.white,
            spawnOpacity: 0.0,
            opacityChangeRate: 0.25,
            minOpacity: 0.1,
            maxOpacity: 0.4,
            particleCount: 120,
            spawnMinSpeed: 10.0,
            spawnMaxSpeed: 30.0,
            spawnMinRadius: 1.0,
            spawnMaxRadius: 3.0,
          ),
        ),
        vsync: this,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _image == null
                      ? const Center(
                    child: Text(
                      "  Choose an image...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade900,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.blueAccent,
                        elevation: 10,
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: const Text("  Take Photo"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade900,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.purpleAccent,
                        elevation: 10,
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text("  Pick from Gallery"),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_description != null)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _description!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontFamily: 'monospace',
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.blueAccent,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
