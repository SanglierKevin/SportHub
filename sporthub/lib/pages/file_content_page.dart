import 'dart:io';
import 'package:flutter/material.dart';

class FileContentPage extends StatefulWidget {
  final String fileName;

  const FileContentPage({required this.fileName, super.key});

  @override
  _FileContentPageState createState() => _FileContentPageState();
}

class _FileContentPageState extends State<FileContentPage> {
  late TextEditingController nameController;
  String? errorMessage;
  bool isEditMode = false;
  bool showSuccessIcon = false;
  String fileContent = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.fileName);
    _loadFileContent(); // Charger le contenu du fichier
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // Charger le contenu du fichier texte
  void _loadFileContent() async {
    try {
      final file = File('lib/sessions/${widget.fileName}.txt');
      if (await file.exists()) {
        String content = await file.readAsString();
        setState(() {
          fileContent = content;
        });
      } else {
        _setError("File not found.");
      }
    } catch (e) {
      _setError("Error loading file.");
    }
  }

  // Fonction pour analyser et structurer la session avec gestion des groupes imbriqués
  List<dynamic> _parseSession(String content) {
    content = content.trim();
    return _parseGroup(content);
  }

  // Fonction récursive pour analyser un groupe ou une session imbriquée
  List<dynamic> _parseGroup(String content) {
    List<dynamic> result = [];
    int index = 0;

    while (index < content.length) {
      if (content[index] == '[') {
        // On détecte un groupe, on doit extraire ce groupe
        int endGroupIndex = _findMatchingBracket(content, index);
        String groupContent = content.substring(index + 1, endGroupIndex);
        List<dynamic> groupItems = _parseGroup(groupContent);

        // Extraire les informations de répétition pour le groupe
        List<String> groupHeader = groupContent.split(',').take(2).toList();
        int repeat = int.parse(groupHeader[0].trim());

        result.add({
          "type": "group",
          "repeat": repeat,
          "items": groupItems,
        });

        // Passer à la fin du groupe
        index = endGroupIndex + 1;
      } else if (content[index] == '(') {
        // On détecte un exercice
        int endExerciseIndex = content.indexOf(')', index);
        String exerciseContent = content.substring(index + 1, endExerciseIndex);
        var elements = exerciseContent.split(',');

        if (elements[1].contains('"x"')) {
          // Cas des répétitions (e.g., "3,x")
          result.add({
            "type": "exercise",
            "name": elements[2].replaceAll('"', '').trim(),
            "repeat": int.parse(elements[0].trim()),
          });
        } else if (elements[1].contains('"s"')) {
          // Cas du temps (e.g., "30,s")
          result.add({
            "type": "exercise",
            "name": elements[2].replaceAll('"', '').trim(),
            "time": int.parse(elements[0].trim()),
            "unit": "s",
          });
        }

        // Passer à la fin de l'exercice
        index = endExerciseIndex + 1;
      } else {
        index++;
      }
    }

    return result;
  }

  // Trouver la parenthèse fermante correspondante
  int _findMatchingBracket(String content, int startIndex) {
    int depth = 0;

    for (int i = startIndex; i < content.length; i++) {
      if (content[i] == '[') {
        depth++;
      } else if (content[i] == ']') {
        depth--;
        if (depth == 0) {
          return i;
        }
      }
    }
    return -1; // Erreur si jamais un groupe est mal formé
  }

  // Fonction pour afficher la session (structure dynamique avec groupes imbriqués)
  Widget _buildSessionView(List<dynamic> session) {
    return ListView.builder(
      itemCount: session.length,
      itemBuilder: (context, index) {
        final item = session[index];
        if (item['type'] == 'group') {
          return _buildGroup(item);
        } else if (item['type'] == 'exercise') {
          return _buildExercise(item);
        }
        return const SizedBox();
      },
    );
  }

  // Affichage d'un groupe
  Widget _buildGroup(Map<String, dynamic> group) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${group['repeat']}x",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...group['items'].map<Widget>((item) {
            if (item['type'] == 'group') {
              return _buildGroup(item); // Gestion des groupes imbriqués
            } else {
              return _buildExercise(item);
            }
          }).toList(),
        ],
      ),
    );
  }

  // Affichage d'un exercice
  Widget _buildExercise(Map<String, dynamic> exercise) {
    String description;
    if (exercise.containsKey('time')) {
      description = "${exercise['time']}s ${exercise['name']}";
    } else {
      description = "${exercise['repeat']}x ${exercise['name']}";
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(description),
    );
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
    final session = _parseSession(fileContent); // Parse le contenu du fichier

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.fileName), // Supprime le champ TextField dans la barre d'app
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.visibility : Icons.edit),
            onPressed: () => setState(() {
              isEditMode = !isEditMode;
            }),
          ),
        ],
      ),
      body: Stack(
        children: [
          isEditMode
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
                      const Spacer(), // Pousse le bouton vers le bas
                      ElevatedButton(
                        onPressed: _saveFileName,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                        ),
                        child: const Icon(Icons
                            .check), // Remplacer par une icône en forme de V
                      ),
                    ],
                  ),
                )
              : _buildSessionView(
                  session), // Affiche le contenu parsé du fichier

          if (showSuccessIcon)
            Center(
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100, // Taille plus grande et centrée
              ),
            ),
        ],
      ),
    );
  }
}
