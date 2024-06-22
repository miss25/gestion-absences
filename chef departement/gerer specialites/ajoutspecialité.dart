import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjoutSpecialitePage extends StatefulWidget {
  @override
  _AjoutSpecialitePageState createState() => _AjoutSpecialitePageState();
}

class _AjoutSpecialitePageState extends State<AjoutSpecialitePage> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _idController = TextEditingController();

  void _ajouterSpecialite() async {
    String nom = _nomController.text.trim();
    String id = _idController.text.trim();

    if (nom.isNotEmpty && id.isNotEmpty) {
      // Ajoutez la spécialité dans Firestore avec l'ID spécifié.
      await FirebaseFirestore.instance.collection('specialites').doc(id).set({
        'nom': nom,
      });

      // Réinitialisez les contrôleurs de texte après l'ajout.
      _nomController.clear();
      _idController.clear();

      // Affiche un message de succès.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spécialité ajoutée avec succès')),
      );
    } else {
      // Affiche un message d'erreur si les champs sont vides.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une spécialité'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom de la spécialité'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID de la spécialité'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _ajouterSpecialite,
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
