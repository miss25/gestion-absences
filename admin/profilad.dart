import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultAdminProfilePage extends StatefulWidget {
  @override
  _ConsultAdminProfilePageState createState() =>
      _ConsultAdminProfilePageState();
}

class _ConsultAdminProfilePageState extends State<ConsultAdminProfilePage> {
  late Future<DocumentSnapshot> _adminData;

  @override
  void initState() {
    super.initState();
    _adminData = _fetchAdminData();
  }

  Future<DocumentSnapshot> _fetchAdminData() async {
    // Récupération de l'utilisateur actuellement connecté
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      // L'utilisateur est connecté, récupération de son ID
      String userID = user.uid;

      // Utilisation de userID pour accéder aux données de l'administrateur dans Firestore
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc(userID) // Utilisation de l'ID de l'utilisateur connecté
          .get();

      return adminSnapshot;
    } else {
      // L'utilisateur n'est pas connecté, gestion de cette situation
      throw Exception('Aucun utilisateur connecté');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Administrateur'),
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _adminData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Aucune donnée disponible'));
          }

          final adminData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text(
                        'Prénom: ${adminData['prenom'] ?? 'Non spécifié'}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text(
                        'Nom: ${adminData['nom'] ?? 'Non spécifié'}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text(
                        'E-mail: ${adminData['email'] ?? 'Non spécifié'}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(
                        'Téléphone: ${adminData['telephone'] ?? 'Non spécifié'}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.cake),
                      title: Text(
                        'Date de naissance: ${adminData['date de naissance'] ?? 'Non spécifié'}',
                        style: TextStyle(fontSize: 18),
                      ),
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
