import 'dart:io';
import 'package:flutter/material.dart';
import 'file_content_page.dart'; // Import de la page FileContentPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textController = TextEditingController();
  List<String> fileNames = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _listFiles();
  }

  // Méthode pour lister les fichiers dans le répertoire
  void _listFiles() {
    const String directory = "lib/sessions";
    final dir = Directory(directory);
    if (dir.existsSync()) {
      setState(() {
        fileNames = dir
            .listSync()
            .where((file) => file is File && file.path.endsWith('.txt'))
            .map((file) {
          String fileName = file.path.split('/').last;
          return fileName.replaceAll('.txt', ''); // Retirer l'extension .txt
        }).toList();

        // Trier les noms de fichiers par ordre alphabétique
        fileNames.sort();
      });
    }
  }

  _createTxt(String title) {
    const String directory = "lib/sessions";
    final File file = File('$directory/$title.txt');

    // Vérifier si le fichier existe déjà
    if (file.existsSync()) {
      setState(() {
        errorMessage = "Un fichier avec ce nom existe déjà.";
      });
    } else {
      file.writeAsString("[]").then((_) {
        // Mise à jour de la liste des fichiers après création
        _listFiles();
        Navigator.pop(context);
      });
    }
  }

  void test() {
    textController
        .clear(); // Vider le champ de texte à chaque ouverture de la boîte de dialogue
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: "Nom du fichier",
                    errorText: errorMessage,
                  ),
                  onChanged: (value) {
                    // Réinitialiser le message d'erreur quand le texte change
                    if (errorMessage != null) {
                      setState(() {
                        errorMessage = null;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  setState(() {
                    _createTxt(textController.text);
                  });
                },
                child: const Icon(Icons.done),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onFileTap(String fileName) {
    // Naviguer vers une autre page pour afficher le contenu du fichier
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileContentPage(fileName: fileName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: test,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: fileNames.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 4.0), // Espacement vertical entre les boutons
            child: Container(
              width: double.infinity, // Prendre toute la largeur de l'écran
              color: Colors.blue
                  .shade100, // Couleur de base différente du fond de la page
              child: InkWell(
                onTap: () => _onFileTap(fileNames[index]), // Action au clic
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    fileNames[index],
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
