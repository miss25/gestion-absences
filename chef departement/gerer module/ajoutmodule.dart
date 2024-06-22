import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjoutModulePage extends StatefulWidget {
  @override
  _AjoutModulePageState createState() => _AjoutModulePageState();
}

class _AjoutModulePageState extends State<AjoutModulePage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  String? _selectedSpecialiteId;

  void _ajouterModule() async {
    String nom = _nomController.text.trim();
    String id = _idController.text.trim();

    if (_selectedSpecialiteId != null && nom.isNotEmpty && id.isNotEmpty) {
      // Ajouter le module sous la spécialité sélectionnée
      await FirebaseFirestore.instance
          .collection('specialites')
          .doc(_selectedSpecialiteId)
          .collection('modules')
          .doc(id)
          .set({
        'nom': nom,
      });

      // Réinitialiser les contrôleurs de texte après l'ajout
      _nomController.clear();
      _idController.clear();

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Module ajouté avec succès')),
      );
    } else {
      // Afficher un message d'erreur si les champs sont vides ou si aucune spécialité n'est sélectionnée
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Veuillez remplir tous les champs et sélectionner une spécialité')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un module'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('specialites')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var specialites = snapshot.data!.docs;
                return DropdownButton<String>(
                  hint: Text('Sélectionner une spécialité'),
                  value: _selectedSpecialiteId,
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecialiteId = value;
                    });
                  },
                  items: specialites.map((doc) {
                    String specialiteId = doc.id;
                    return DropdownMenuItem<String>(
                      value: specialiteId,
                      child: Text(specialiteId),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom du module'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID du module'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _ajouterModule,
              child: Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    Color.fromARGB(255, 74, 74, 253), // Texte en blanc
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
