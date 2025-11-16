import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ResultScreen extends StatelessWidget {
  final File image;
  final Map<String, dynamic> palette;
  final List<Map<String, String>> recommendations;

  const ResultScreen({
    super.key,
    required this.image,
    required this.palette,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Il Tuo Stile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.file(image, height: 250, fit: BoxFit.cover)),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("La tua palette: ${palette['season']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(palette['description'], style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: (palette['colors'] as List<String>).map((color) {
                        return Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Outfit consigliati per te:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...recommendations.map((item) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(item['item']!),
                subtitle: Text("${item['brand']} • ${item['price']}"),
                trailing: ElevatedButton(
                  onPressed: () => launchUrl(Uri.parse(item['link']!)),
                  child: const Text("Acquista"),
                ),
              ),
            )).toList(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text("Nuovo Scan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
