import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ajoutetud.dart';
import 'modifetudprof.dart';

class StudentListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des étudiants'),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('etudiants').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun étudiant trouvé.'));
          }

          var documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var etudiant = documents[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: ListTile(
                  title: Text('${etudiant['nom']} ${etudiant['prenom']}'),
                  subtitle:
                      Text('${etudiant['groupe']} ${etudiant['specialite']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, color: Colors.green),
                        onPressed: () {
                          _showStudentDetails(context, etudiant);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditStudentPage(docId: documents[index].id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteStudent(context, documents[index].id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AjouterEtudiantPage()),
          );
        },
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showStudentDetails(
      BuildContext context, Map<String, dynamic> etudiant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails de l\'étudiant'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Nom: ${etudiant['nom']} ${etudiant['prenom']}'),
                Text('Groupe: ${etudiant['groupe']}'),
                Text('Spécialité: ${etudiant['specialite']}'),
                // Ajoutez plus de détails si nécessaire
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteStudent(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer l\'étudiant'),
          content: Text('Êtes-vous sûr de vouloir supprimer cet étudiant?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('etudiants')
                    .doc(docId)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
