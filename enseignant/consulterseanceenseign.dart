import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListeSeancesPage extends StatefulWidget {
  @override
  _ListeSeancesPageState createState() => _ListeSeancesPageState();
}

class _ListeSeancesPageState extends State<ListeSeancesPage> {
  User? user;
  String? connectedEnseignant;
  List<Map<String, dynamic>> seances = [];

  @override
  void initState() {
    super.initState();
    _getConnectedEnseignant();
  }

  Future<void> _getConnectedEnseignant() async {
    // Supposons que l'enseignant est connecté via Firebase Auth
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir les informations de l'enseignant via son email
      var snapshot = await FirebaseFirestore.instance
          .collection('enseignants')
          .where('email', isEqualTo: user!.email)
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          connectedEnseignant =
              '${snapshot.docs.first['nom']} ${snapshot.docs.first['prenom']}';
        });
        _loadSeances();
      }
    }
  }

  Future<void> _loadSeances() async {
    if (connectedEnseignant == null) return;

    var snapshot = await FirebaseFirestore.instance
        .collection('seances')
        .where('enseignant', isEqualTo: connectedEnseignant)
        .get();
    setState(() {
      seances = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Séances'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            connectedEnseignant != null
                ? Text('Enseignant: $connectedEnseignant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                : CircularProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: seances.length,
                itemBuilder: (context, index) {
                  var seance = seances[index];
                  return ListTile(
                    title:
                        Text('${seance['groupe']} - ${seance['typeSeance']}'),
                    subtitle: Text(
                        '${seance['jour']} à ${seance['heure']} en ${seance['salle']}'),
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
