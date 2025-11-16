import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _image;
  final picker = ImagePicker();
  bool _isAnalyzing = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isAnalyzing = true;
      });
      await _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    final inputImage = InputImage.fromFile(_image!);
    final faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
      ),
    );

    try {
      final faces = await faceDetector.processImage(inputImage);
      if (faces.isNotEmpty) {
        final face = faces.first;
        final skinTone = _detectSkinTone(face);
        final palette = _getColorPalette(skinTone);
        final recommendations = _getRecommendations(palette);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                image: _image!,
                palette: palette,
                recommendations: recommendations,
              ),
            ),
          );
        }
      } else {
        _showError("Nessun volto rilevato. Riprova!");
      }
    } catch (e) {
      _showError("Errore analisi: $e");
    } finally {
      setState(() => _isAnalyzing = false);
      await faceDetector.close();
    }
  }

  String _detectSkinTone(Face face) {
    // Simulazione: in produzione usa ML per pelle/capelli/occhi
    final smileProb = face.smilingProbability ?? 0.5;
    if (smileProb > 0.7) return "warm";
    if (smileProb > 0.4) return "neutral";
    return "cool";
  }

  Map<String, dynamic> _getColorPalette(String tone) {
    switch (tone) {
      case "warm":
        return {
          "season": "Autunno Caldo",
          "colors": ["#D4A574", "#8B5A2B", "#A0522D", "#CD853F", "#F4A460"],
          "description": "Toni caldi, dorati, terra. Perfetto per te!"
        };
      case "cool":
        return {
          "season": "Inverno Freddo",
          "colors": ["#4682B4", "#191970", "#4B0082", "#708090", "#B0C4DE"],
          "description": "Toni freddi, argento, blu. Elegante e raffinato."
        };
      default:
        return {
          "season": "Estate Morbida",
          "colors": ["#D8BFD8", "#FFB6C1", "#F0E68C", "#98FB98", "#87CEEB"],
          "description": "Toni pastello, delicati. Fresco e naturale."
        };
    }
  }

  List<Map<String, String>> _getRecommendations(Map<String, dynamic> palette) {
    final season = palette["season"] as String;
    return [
      {
        "item": "Giacca in pelle marrone",
        "brand": "Zara",
        "price": "€89,90",
        "link": "https://zara.com/it/giacca-pelle-affiliate-link", // Sostituisci con tuo link affiliazione
        "image": "https://static.zara.net/photos/...jpg"
      },
      {
        "item": "Maglia cashmere beige",
        "brand": "H&M",
        "price": "€49,99",
        "link": "https://hm.com/maglia-cashmere-affiliate",
        "image": "https://hm.com/images/..."
      },
      {
        "item": "Jeans slim blu scuro",
        "brand": "Levi's",
        "price": "€79,00",
        "link": "https://levis.com/jeans-affiliate",
        "image": "https://levis.com/images/..."
      },
    ];
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan del Corpo")),
      body: Center(
        child: _image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text("Posizionati davanti alla fotocamera", textAlign: TextAlign.center),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera),
                    label: const Text("Scatta Foto"),
                  ),
                ],
              )
            : _isAnalyzing
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text("Analisi in corso..."),
                    ],
                  )
                : Image.file(_image!, height: 400, fit: BoxFit.cover),
      ),
    );
  }
}
