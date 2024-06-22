import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListeAbsencesPage extends StatefulWidget {
  @override
  _ListeAbsencesPageState createState() => _ListeAbsencesPageState();
}

class _ListeAbsencesPageState extends State<ListeAbsencesPage> {
  void _deleteAbsence(String absenceId) {
    FirebaseFirestore.instance
        .collection('absences')
        .doc(absenceId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Absence supprimée avec succès')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Absences'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('absences').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var absences = snapshot.data!.docs;

          if (absences.isEmpty) {
            return Center(child: Text('Aucune absence trouvée.'));
          }

          return ListView.builder(
            itemCount: absences.length,
            itemBuilder: (context, index) {
              var absenceDoc = absences[index];
              var absence = absenceDoc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(
                    'Nom : ${absence['nomPrenom']} ${absence['date']} ${absence['heure']}'),
                subtitle: Text('Module : ${absence['moduleId']}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteAbsence(absenceDoc.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
