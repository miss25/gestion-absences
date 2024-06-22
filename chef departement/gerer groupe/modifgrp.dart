import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../admin/ajoutetud.dart';

class ModifierGroupePage extends StatefulWidget {
  final String groupeId;
  final String specialiteId;

  ModifierGroupePage({required this.groupeId, required this.specialiteId});

  @override
  _ModifierGroupePageState createState() => _ModifierGroupePageState();
}

class _ModifierGroupePageState extends State<ModifierGroupePage> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  String selectedStudent = '';

  void _modifierGroupe() async {
    String nouveauNom = _nomController.text.trim();
    String nouvelId = _idController.text.trim();

    if (nouveauNom.isNotEmpty && nouvelId.isNotEmpty) {
      // Mettre à jour le groupe dans Firestore
      await FirebaseFirestore.instance
          .collection('specialites')
          .doc(widget.specialiteId)
          .collection('groupes')
          .doc(widget.groupeId)
          .update({
        'nom': nouveauNom,
        'id': nouvelId,
      });

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Groupe modifié avec succès')),
      );

      // Réinitialiser les contrôleurs de texte après la modification
      _nomController.clear();
      _idController.clear();
    } else {
      // Afficher un message d'erreur si l'un des champs est vide
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  void _supprimerEtudiant(String etudiantId) async {
    // Supprimer l'étudiant sélectionné de la collection d'étudiants
    await FirebaseFirestore.instance
        .collection('etudiants')
        .doc(etudiantId)
        .delete();

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Étudiant supprimé avec succès')),
    );
  }

  void _ajouterEtudiant() {
    // Naviguer vers la page pour ajouter un nouvel étudiant
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AjouterEtudiantPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier un groupe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nouveau nom du groupe'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'Nouvel ID du groupe'),
            ),
            SizedBox(height: 16),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('etudiants')
                  .where('specialite', isEqualTo: widget.specialiteId)
                  .where('groupe', isEqualTo: widget.groupeId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _modifierGroupe,
              child: Text('Modifier'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                textStyle: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
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
