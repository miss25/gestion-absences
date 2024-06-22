import 'package:flutter/material.dart';

class ModifierModulePage extends StatefulWidget {
  @override
  _ModifierModulePageState createState() => _ModifierModulePageState();
}

class _ModifierModulePageState extends State<ModifierModulePage> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _idController = TextEditingController();

  void _modifierModule() {
    // Ajoutez ici la logique pour mettre à jour la spécialité dans votre base de données ou effectuer toute autre action nécessaire.

    // Réinitialisez les contrôleurs de texte après la modification.
    _nomController.clear();
    _idController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier un Module'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration:
                  InputDecoration(labelText: 'Nouveau nom de la Module'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'Nouvel ID de Module'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _modifierModule,
              child: Text('Modifier'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green, // Texte en blanc
                textStyle: TextStyle(
                  fontSize: 30, // Taille de texte
                  fontWeight: FontWeight.bold, // Gras
                ),
                minimumSize: Size(100, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ModifierModulePage(),
  ));
}
