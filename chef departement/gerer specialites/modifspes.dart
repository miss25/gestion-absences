import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifierSpecialitePage extends StatefulWidget {
  final String specialiteId;
  final String initialNom;

  ModifierSpecialitePage(
      {required this.specialiteId, required this.initialNom});

  @override
  _ModifierSpecialitePageState createState() => _ModifierSpecialitePageState();
}

class _ModifierSpecialitePageState extends State<ModifierSpecialitePage> {
  late TextEditingController _nomController;
  late TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.initialNom);
    _idController = TextEditingController(text: widget.specialiteId);
  }

  void _modifierSpecialite() async {
    String nouveauNom = _nomController.text.trim();
    String nouvelId = _idController.text.trim();

    if (nouveauNom.isNotEmpty && nouvelId.isNotEmpty) {
      DocumentReference oldRef = FirebaseFirestore.instance
          .collection('specialites')
          .doc(widget.specialiteId);

      if (widget.specialiteId != nouvelId) {
        DocumentSnapshot snapshot = await oldRef.get();
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Supprimer l'ancien document
        await oldRef.delete();

        // Ajouter le nouveau document avec le nouvel ID
        await FirebaseFirestore.instance
            .collection('specialites')
            .doc(nouvelId)
            .set({
          'nom': nouveauNom,
          ...data,
        });
      } else {
        // Mettre à jour le document existant
        await oldRef.update({'nom': nouveauNom});
      }

      // Affiche un message de succès.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spécialité modifiée avec succès')),
      );

      // Retour à la page précédente
      Navigator.of(context).pop();
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
        title: Text('Modifier une spécialité'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration:
                  InputDecoration(labelText: 'Nouveau nom de la spécialité'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration:
                  InputDecoration(labelText: 'Nouvel ID de la spécialité'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _modifierSpecialite,
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
