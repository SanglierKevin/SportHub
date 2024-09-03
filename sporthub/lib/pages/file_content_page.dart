import 'dart:io';
import 'package:flutter/material.dart';

class FileContentPage extends StatelessWidget {
  final String fileName;

  const FileContentPage({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    const String directory = "lib/sessions";
    final File file = File('$directory/$fileName.txt');

    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: FutureBuilder<String>(
        future: file.readAsString(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur lors du chargement du fichier"));
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(snapshot.data ?? "Contenu vide"),
            );
          } else {
            return Center(child: Text("Aucun contenu disponible"));
          }
        },
      ),
    );
  }
}
