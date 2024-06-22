import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjoutGroupePage extends StatefulWidget {
  @override
  _AjoutGroupePageState createState() => _AjoutGroupePageState();
}

class _AjoutGroupePageState extends State<AjoutGroupePage> {
  TextEditingController _nomController = TextEditingController();
  String selectedSpecialite = '';

  void _ajouterGroupe() async {
    if (selectedSpecialite.isNotEmpty &&
        _nomController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('specialites')
          .doc(selectedSpecialite)
          .collection('groupes')
          .doc(_nomController.text.trim())
          .set({
        'nom': _nomController.text.trim(),
      });

      // Réinitialisez les contrôleurs de texte après l'ajout.
      _nomController.clear();

      // Affichez un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Groupe ajouté avec succès')),
      );
    } else {
      // Affichez un message d'erreur si les champs sont vides
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un groupe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance.collection('specialites').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                var specialites = snapshot.data!.docs;

                // Utiliser une liste temporaire pour stocker les éléments DropdownMenuItem
                List<DropdownMenuItem<String>> dropdownItems = [];

                // Parcourir les spécialités et ajouter des éléments DropdownMenuItem
                specialites.forEach((specialite) {
                  dropdownItems.add(
                    DropdownMenuItem(
                      value: specialite.id,
                      child: Text(specialite.id),
                    ),
                  );
                });

                return DropdownButtonFormField(
                  items: dropdownItems,
                  onChanged: (value) {
                    setState(() {
                      selectedSpecialite = value as String;
                    });
                  },
                  decoration:
                      InputDecoration(labelText: 'Sélectionnez une spécialité'),
                );
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom du groupe'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _ajouterGroupe,
              child: Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Texte en blanc
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
