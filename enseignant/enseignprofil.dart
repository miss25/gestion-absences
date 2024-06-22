import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilEnseignantPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupérer l'utilisateur actuellement connecté
    User? utilisateur = FirebaseAuth.instance.currentUser;

    if (utilisateur == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profil Enseignant'),
        ),
        body: Center(
          child: Text('Utilisateur non connecté'),
        ),
      );
    }

    String userId = utilisateur.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Enseignant'),
      ),
      backgroundColor: Color.fromARGB(255, 1, 98, 128),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('enseignants')
            .doc(userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Aucune donnée disponible'));
          }

          final enseignant = snapshot.data!.data() as Map<String, dynamic>;

          return Center(
            child: Card(
              margin: EdgeInsets.all(20),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        '${enseignant['nom']} ${enseignant['prenom']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Email: ${enseignant['email']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: Icon(Icons.person, size: 50),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Téléphone: ${enseignant['numTelephone']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: Icon(Icons.phone, size: 30),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Matières enseignées: ${enseignant['moduleId']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: Icon(Icons.school, size: 30),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
