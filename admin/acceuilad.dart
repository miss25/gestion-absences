import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gerercompts.dart';
import 'gererprofilad.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'administrateur'),
        backgroundColor: const Color.fromARGB(255, 214, 233, 243),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              // Fetch and display the real counts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildNumberCase(
                        'Étudiants', _getRoleCount('etudiants', 'etudiant')),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildNumberCase('Enseignants',
                        _getRoleCount('enseignants', 'enseignant')),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildNumberCase(
                        'Chefs de département', _getRoleCount('users', 'chef')),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildNumberCase(
                        'Administrateurs', _getRoleCount('users', 'admin')),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminProfilePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF191970),
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                icon: Icon(Icons.person, size: 30),
                label: Text('Gérer le profil'),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GestionComptePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF191970),
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                icon: Icon(Icons.account_circle, size: 30),
                label: Text('Gérer les comptes'),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                icon: Icon(Icons.logout, size: 30),
                label: Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCase(String label, Future<int> countFuture) {
    return FutureBuilder<int>(
      future: countFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard(
            label,
            CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return _buildCard(
            label,
            Text(
              'Erreur',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
        } else {
          return _buildCard(
            label,
            Text(
              snapshot.data.toString(),
              style: TextStyle(fontSize: 18),
            ),
          );
        }
      },
    );
  }

  Widget _buildCard(String label, Widget content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Future<int> _getRoleCount(String collection, String role) async {
    var query = await FirebaseFirestore.instance
        .collection(collection)
        .where('role', isEqualTo: role)
        .get();
    return query.docs.length;
  }
}
