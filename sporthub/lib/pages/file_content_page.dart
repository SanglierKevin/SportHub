import 'dart:io';
import 'package:flutter/material.dart';

class FileContentPage extends StatefulWidget {
  final String fileName; // Garder fileName en tant que final

  const FileContentPage({required this.fileName, super.key});

  @override
  _FileContentPageState createState() => _FileContentPageState();
}

class _FileContentPageState extends State<FileContentPage> {
  late TextEditingController nameController;
  String? errorMessage;
  bool isEditMode = true;
  bool showSuccessIcon = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.fileName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  bool _fileExists(String fileName) {
    return File('lib/sessions/$fileName.txt').existsSync();
  }

  void _saveFileName() {
    final newFileName = nameController.text.trim();

    if (newFileName.isEmpty) {
      _setError("Name can't be empty.");
      return;
    }

    if (_fileExists(newFileName) && newFileName != widget.fileName) {
      _setError("Name already used.");
      return;
    }

    _renameFile(newFileName);
    _showSuccessMessage();
  }

  void _setError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  void _renameFile(String newFileName) {
    final oldFile = File('lib/sessions/${widget.fileName}.txt');
    final newFile = File('lib/sessions/$newFileName.txt');

    if (oldFile.existsSync()) {
      oldFile.renameSync(newFile.path);
    }

    setState(() {
      errorMessage = null;
      // Note: On ne peut pas modifier fileName ici car il est final
      // Cela nécessiterait une approche différente, comme un callback pour notifier le parent
    });
  }

  void _showSuccessMessage() {
    setState(() {
      showSuccessIcon = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showSuccessIcon = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '' : 'TODO : nom du fichier'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.visibility : Icons.edit),
            onPressed: () => setState(() {
              isEditMode = !isEditMode;
            }),
          ),
        ],
      ),
      body: isEditMode
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Session name",
                      errorText: errorMessage,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveFileName,
                    child: const Text("Save"),
                  ),
                  const SizedBox(height: 20),
                  if (showSuccessIcon)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    ),
                ],
              ),
            )
          : const Center(
              child: Text(
                "Mode Lecture",
                style: TextStyle(fontSize: 18),
              ),
            ),
    );
  }
}
