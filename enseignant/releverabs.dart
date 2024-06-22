import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListeAbsencesEnseignantPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Liste des Absences'),
        ),
        body: Center(
          child: Text('Utilisateur non authentifié'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Absences'),
        backgroundColor: Color(0xFF0077B6),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('absences')
            .where('enseignantId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucune absence trouvée.'));
          }

          final absences = snapshot.data!.docs;

          return ListView.builder(
            itemCount: absences.length,
            itemBuilder: (context, index) {
              final absence = absences[index];
              return Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    'Nom: ${absence['nomPrenom']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${absence['date']}'),
                      Text('Heure: ${absence['heure']}'),
                      Text('Module: ${absence['moduleId']}'),
                      Text('Groupe: ${absence['groupe']}'),
                      Text('Spécialité: ${absence['specialite']}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool confirm = await _confirmDelete(context);
                      if (confirm) {
                        _deleteAbsence(absence.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirmer la suppression'),
            content: Text('Êtes-vous sûr de vouloir supprimer cette absence?'),
            actions: [
              TextButton(
                child: Text('Annuler'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Supprimer'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _deleteAbsence(String absenceId) {
    FirebaseFirestore.instance
        .collection('absences')
        .doc(absenceId)
        .delete()
        .then((_) {
      print("Absence supprimée");
    }).catchError((error) {
      print("Échec de la suppression de l'absence: $error");
    });
  }
}
