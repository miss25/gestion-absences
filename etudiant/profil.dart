import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'consultabs.dart';
import 'consultseance.dart';

class StudentProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupérer l'utilisateur actuellement connecté
    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('etudiants')
          .doc(user!.uid) // Utilisez l'ID de l'utilisateur connecté
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('Aucune donnée trouvée pour cet étudiant'));
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        // Extraire les informations de l'étudiant à partir du snapshot
        String nom = data['nom'] ?? '';
        String prenom = data['prenom'] ?? '';
        String dateNaissance = data['dateNaissance'] ?? '';
        String specialite = data['specialite'] ?? '';
        String groupe = data['groupe'] ?? '';
        String numTelephone = data['numTelephone'] ?? '';
        String email = data['email'] ?? '';

        return Scaffold(
          backgroundColor: Colors.grey[200],
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                            'assets/profile_placeholder.png'), // Placeholder image path
                      ),
                      SizedBox(height: 10),
                      Text(
                        '$prenom $nom',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Spécialité: $specialite',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Groupe: $groupe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.cake, color: Colors.teal),
                        title: Text('Date de naissance'),
                        subtitle: Text(dateNaissance),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone, color: Colors.teal),
                        title: Text('Téléphone'),
                        subtitle: Text(numTelephone),
                      ),
                      ListTile(
                        leading: Icon(Icons.email_outlined, color: Colors.teal),
                        title: Text('Email'),
                        subtitle: Text(email),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ConsultAbsencesPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 18),
                                ),
                                child: Text(
                                  'Consulter Absences',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListeSeancesEtudiantPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Color.fromARGB(255, 42, 71, 202),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 18),
                                ),
                                child: Text(
                                  'Consulter Séances',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/', (route) => false);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Color.fromARGB(255, 243, 33, 43),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 18),
                                ),
                                icon: Icon(Icons.logout),
                                label: Text(
                                  'Déconnecter',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
