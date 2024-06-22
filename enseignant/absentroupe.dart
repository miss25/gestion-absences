import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AbsentsGroupePage extends StatelessWidget {
  final String specialite;
  final String groupe;

  AbsentsGroupePage({required this.specialite, required this.groupe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Étudiants Absents - $groupe'),
        backgroundColor: Color(0xFF0077B6),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('etudiants')
            .where('specialite', isEqualTo: specialite)
            .where('groupe', isEqualTo: groupe)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun étudiant trouvé.'));
          }

          final etudiants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: etudiants.length,
            itemBuilder: (context, index) {
              final etudiant = etudiants[index];

              return StreamBuilder<QuerySnapshot>(
                stream: etudiant.reference.collection('absences').snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> absencesSnapshot) {
                  if (absencesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      title: Text('${etudiant['nom']} ${etudiant['prenom']}'),
                      subtitle: Text('Chargement...'),
                    );
                  }

                  if (absencesSnapshot.hasError) {
                    return ListTile(
                      title: Text('${etudiant['nom']} ${etudiant['prenom']}'),
                      subtitle: Text('Erreur lors du chargement des absences'),
                    );
                  }

                  if (!absencesSnapshot.hasData ||
                      absencesSnapshot.data!.docs.isEmpty) {
                    return ListTile(
                      title: Text('${etudiant['nom']} ${etudiant['prenom']}'),
                      subtitle: Text('Aucune absence trouvée.'),
                    );
                  }

                  final absences = absencesSnapshot.data!.docs;
                  return ExpansionTile(
                    title: Text('${etudiant['nom']} ${etudiant['prenom']}'),
                    children: absences.map((absence) {
                      return ListTile(
                        title: Text('Date: ${absence['date']}'),
                        subtitle: Text('Heure: ${absence['heure']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            absence.reference.delete();
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
