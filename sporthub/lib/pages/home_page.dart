import 'dart:io';
import 'package:flutter/material.dart';
import 'file_content_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<String> fileNames = [];

  @override
  void initState() {
    super.initState();
    _listFiles();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _listFiles();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _listFiles(); // Mettre à jour la liste chaque fois que les dépendances changent
  }

  void _listFiles() {
    const String directory = "lib/sessions";
    final dir = Directory(directory);
    dir.createSync(recursive: true);

    setState(() {
      fileNames = dir
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last.replaceAll('.txt', ''))
          .toList()
        ..sort(); // Trier les noms de fichiers
    });
  }

  String _generateNewFileName() {
    int counter = 1;
    String newFileName;

    do {
      newFileName = "New Session $counter";
      counter++;
    } while (fileNames.contains(newFileName));

    return newFileName;
  }

  void _createNewSession() {
    final newFileName = _generateNewFileName();
    File('lib/sessions/$newFileName.txt').writeAsStringSync("[]");
    _listFiles(); // Mettre à jour la liste des fichiers

    _navigateToFileContent(newFileName);
  }

  void _onFileTap(String fileName) {
    _navigateToFileContent(fileName);
  }

  Future<void> _navigateToFileContent(String fileName) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileContentPage(fileName: fileName),
      ),
    ).then((_) {
      _listFiles(); // Mettre à jour la liste des fichiers après le retour
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewSession,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: fileNames.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: InkWell(
              onTap: () => _onFileTap(fileNames[index]),
              child: Container(
                width: double.infinity,
                color: Colors.blue.shade100,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  fileNames[index],
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
