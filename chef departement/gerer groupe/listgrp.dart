import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ajoutgrp.dart';
import 'modifgrp.dart';

class Groupe {
  final String nom;

  Groupe(this.nom);
}

class Specialite {
  final String nom;
  final List<Groupe> groupes;

  Specialite(this.nom, this.groupes);
}

class GroupesPage extends StatefulWidget {
  @override
  _GroupesPageState createState() => _GroupesPageState();
}

class _GroupesPageState extends State<GroupesPage> {
  List<Specialite> specialites = [];

  @override
  void initState() {
    super.initState();
    _fetchSpecialitesEtGroupes();
  }

  void _fetchSpecialitesEtGroupes() async {
    // Récupérer les spécialités de Firestore
    QuerySnapshot specialitesSnapshot =
        await FirebaseFirestore.instance.collection('specialites').get();

    List<Specialite> specialitesTemp = [];
    for (var specialiteDoc in specialitesSnapshot.docs) {
      String specialiteNom = specialiteDoc.id;

      // Récupérer les groupes de chaque spécialité
      QuerySnapshot groupesSnapshot = await FirebaseFirestore.instance
          .collection('specialites')
          .doc(specialiteNom)
          .collection('groupes')
          .get();

      List<Groupe> groupesTemp = groupesSnapshot.docs
          .map((groupeDoc) => Groupe(groupeDoc.id))
          .toList();

      specialitesTemp.add(Specialite(specialiteNom, groupesTemp));
    }

    setState(() {
      specialites = specialitesTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des groupes'),
      ),
      backgroundColor: Color.fromARGB(255, 2, 3, 83),
      body: ListView.builder(
        itemCount: specialites.length,
        itemBuilder: (context, index) {
          final specialite = specialites[index];
          return Card(
            child: ExpansionTile(
              title: Text(specialite.nom),
              children: specialite.groupes.map((groupe) {
                return ListTile(
                  title: Text(groupe.nom),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.person, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListeEtudiantsPage(
                                groupeId: groupe.nom,
                                specialiteId: specialite.nom,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ModifierGroupePage(
                                      groupeId: groupe.nom,
                                      specialiteId: specialite.nom,
                                    )),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Gérer la suppression du groupe
                          FirebaseFirestore.instance
                              .collection('specialites')
                              .doc(specialite.nom)
                              .collection('groupes')
                              .doc(groupe.nom)
                              .delete();
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AjoutGroupePage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ListeEtudiantsPage extends StatelessWidget {
  final String groupeId;
  final String specialiteId;

  ListeEtudiantsPage({required this.groupeId, required this.specialiteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des étudiants'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('etudiants')
            .where('groupe', isEqualTo: groupeId)
            .where('specialite', isEqualTo: specialiteId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              var nom = student['nom'];
              var prenom = student['prenom'];

              return ListTile(
                title: Text('$nom $prenom'),
              );
            },
          );
        },
      ),
    );
  }
}
