import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListeSeancesEtudiantPage extends StatefulWidget {
  @override
  _ListeSeancesEtudiantPageState createState() =>
      _ListeSeancesEtudiantPageState();
}

class _ListeSeancesEtudiantPageState extends State<ListeSeancesEtudiantPage> {
  User? user;
  String? specialite;
  String? groupe;
  List<Map<String, dynamic>> seances = [];

  @override
  void initState() {
    super.initState();
    _getConnectedEtudiant();
  }

  Future<void> _getConnectedEtudiant() async {
    // Supposons que l'étudiant est connecté via Firebase Auth
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir les informations de l'étudiant via son email
      var snapshot = await FirebaseFirestore.instance
          .collection('etudiants')
          .where('email', isEqualTo: user!.email)
          .get();
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();
        setState(() {
          specialite = data['specialite'];
          groupe = data['groupe'];
        });
        _loadSeances();
      }
    }
  }

  Future<void> _loadSeances() async {
    if (specialite == null || groupe == null) return;

    var snapshot = await FirebaseFirestore.instance
        .collection('seances')
        .where('specialite', isEqualTo: specialite)
        .where('groupe', isEqualTo: groupe)
        .get();
    setState(() {
      seances = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Séances'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            specialite != null && groupe != null
                ? Text(
                    'Étudiant: $specialite $groupe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  )
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: seances.length,
                itemBuilder: (context, index) {
                  var seance = seances[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Icon(Icons.book, color: Colors.teal),
                      title: Text(
                        '${seance['module']} - ${seance['typeSeance']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text('Jour: ${seance['jour']}'),
                          Text('Heure: ${seance['heure']}'),
                          Text('Salle: ${seance['salle']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
