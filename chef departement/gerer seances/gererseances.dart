import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ajoutseance.dart';

class GlobalSeancesList extends StatefulWidget {
  @override
  _GlobalSeancesListState createState() => _GlobalSeancesListState();
}

class _GlobalSeancesListState extends State<GlobalSeancesList> {
  @override
  void initState() {
    super.initState();
  }

  void _afficherDetailsSeance(Map<String, dynamic> seanceData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails de la séance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Spécialité: ${seanceData['specialite']}'),
              Text('Module: ${seanceData['module']}'),
              Text('Enseignant: ${seanceData['enseignant']}'),
              Text('Groupe: ${seanceData['groupe']}'),
              Text('Salle: ${seanceData['salle']}'),
              Text('Heure: ${seanceData['heure']}'),
              Text('Jour: ${seanceData['jour']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _modifierSeance(String id, Map<String, dynamic> seanceData) {
    TextEditingController groupeController =
        TextEditingController(text: seanceData['groupe']);
    TextEditingController salleController =
        TextEditingController(text: seanceData['salle']);
    TextEditingController heureController =
        TextEditingController(text: seanceData['heure']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier la séance'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: groupeController,
                  decoration: InputDecoration(labelText: 'Groupe'),
                ),
                TextField(
                  controller: salleController,
                  decoration: InputDecoration(labelText: 'Salle'),
                ),
                TextField(
                  controller: heureController,
                  decoration: InputDecoration(labelText: 'Heure'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('seances')
                    .doc(id)
                    .update({
                  'groupe': groupeController.text,
                  'salle': salleController.text,
                  'heure': heureController.text,
                }).then((_) {
                  Navigator.of(context).pop();
                });
              },
              child: Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  void _supprimerSeance(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer la séance'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette séance ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('seances')
                    .doc(id)
                    .delete()
                    .then((_) {
                  Navigator.of(context).pop();
                });
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des séances '),
      ),
      backgroundColor: Color.fromARGB(255, 2, 3, 83),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('seances').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final seances = snapshot.data!.docs
              .map((doc) => {
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  })
              .toList();

          return ListView.builder(
            itemCount: seances.length,
            itemBuilder: (context, index) {
              final seance = seances[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                      '${index + 1}. ${seance['specialite']} - ${seance['module']} - ${seance['groupe']} '),
                  subtitle: Text(
                      'Jour: ${seance['jour']} - Heure: ${seance['heure']} - ${seance['salle']} - Enseignant: ${seance['enseignant']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.visibility,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          _afficherDetailsSeance(seance);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blueAccent[700],
                        ),
                        onPressed: () {
                          _modifierSeance(seance['id'], seance);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _supprimerSeance(seance['id']);
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
            MaterialPageRoute(builder: (context) => AjouterSeancePage()),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.blueGrey[700],
        ),
      ),
    );
  }
}
























/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ajoutseance.dart';

class GlobalSeancesList extends StatefulWidget {
  @override
  _GlobalSeancesListState createState() => _GlobalSeancesListState();
}

class _GlobalSeancesListState extends State<GlobalSeancesList> {
  List<Map<String, dynamic>> seances = [];

  @override
  void initState() {
    super.initState();
    _loadAllSeances();
  }

  Future<void> _loadAllSeances() async {
    try {
      var seancesSnapshot =
          await FirebaseFirestore.instance.collection('seances').get();
      setState(() {
        seances = seancesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Erreur lors de la récupération des séances: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des séances globales'),
      ),
      body: seances.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: seances.length,
              itemBuilder: (context, index) {
                final seance = seances[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                        '${seance['specialite']} - ${seance['module']} - ${seance['groupe']}'),
                    subtitle: Text(
                        'Salle: ${seance['salle']} - Heure: ${seance['heure']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility),
                          onPressed: () {
                            _afficherDetailsSeance(seance);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _modifierSeance(seance['id'], seance);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AjoutSeancesPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _afficherDetailsSeance(Map<String, dynamic> seanceData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails de la séance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Spécialité: ${seanceData['specialite']}'),
              Text('Module: ${seanceData['module']}'),
              Text('Enseignant: ${seanceData['enseignant']}'),
              Text('Groupe: ${seanceData['groupe']}'),
              Text('Salle: ${seanceData['salle']}'),
              Text('Heure: ${seanceData['heure']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _modifierSeance(String id, Map<String, dynamic> seanceData) {
    // Votre code de modification de séance ici
  }
}
*/
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ajoutseance.dart';

class GlobalSeancesList extends StatefulWidget {
  @override
  _GlobalSeancesListState createState() => _GlobalSeancesListState();
}

class _GlobalSeancesListState extends State<GlobalSeancesList> {
  String? selectedSpecialite;
  String? selectedModule;
  String? selectedEnseignant;
  List<Map<String, String>> specialites = [];
  List<String> modules = [];
  List<String> enseignants = [];

  @override
  void initState() {
    super.initState();
    fetchSpecialites();
  }

  Future<void> fetchSpecialites() async {
    try {
      var specialitesSnapshot =
          await FirebaseFirestore.instance.collection('specialites').get();
      setState(() {
        specialites = specialitesSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'specialite': doc.id,
          };
        }).toList();
      });
      print("Spécialités récupérées: $specialites");
    } catch (e) {
      print("Erreur lors de la récupération des spécialités: $e");
    }
  }

  Future<void> fetchModules() async {
    if (selectedSpecialite == null) return;
    try {
      var modulesSnapshot = await FirebaseFirestore.instance
          .collection('modules')
          .where('specialite', isEqualTo: selectedSpecialite)
          .get();
      setState(() {
        modules = modulesSnapshot.docs
            .map((doc) => doc.data()['modules'] as String)
            .toList();
        selectedModule = modules.isNotEmpty ? modules.first : null;
        fetchEnseignants();
      });
    } catch (e) {
      print("Erreur lors de la récupération des modules: $e");
    }
  }

  Future<void> fetchEnseignants() async {
    if (selectedModule == null) return;
    try {
      var enseignantsSnapshot = await FirebaseFirestore.instance
          .collection('enseignants')
          .where('modules', isEqualTo: selectedModule)
          .get();
      setState(() {
        enseignants = enseignantsSnapshot.docs
            .map((doc) => doc.data()['enseignant'] as String)
            .toList();
        selectedEnseignant = enseignants.isNotEmpty ? enseignants.first : null;
      });
    } catch (e) {
      print("Erreur lors de la récupération des enseignants: $e");
    }
  }

  void _modifierSeance(String id, Map<String, dynamic> seanceData) {
    selectedSpecialite = seanceData['specialite'];
    selectedModule = seanceData['module'];
    selectedEnseignant = seanceData['enseignant'];
    fetchModules();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier la séance'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSpecialite,
                  decoration: InputDecoration(labelText: 'Spécialité'),
                  items:
                      specialites.map<DropdownMenuItem<String>>((specialite) {
                    return DropdownMenuItem<String>(
                      value: specialite['id'],
                      child: Text(specialite['specialite']!),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedSpecialite = newValue;
                      fetchModules();
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedModule,
                  decoration: InputDecoration(labelText: 'Module'),
                  items: modules.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedModule = newValue;
                      fetchEnseignants();
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedEnseignant,
                  decoration: InputDecoration(labelText: 'Enseignant'),
                  items:
                      enseignants.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedEnseignant = newValue;
                    });
                  },
                ),
                TextField(
                  controller: TextEditingController(text: seanceData['groupe']),
                  decoration: InputDecoration(labelText: 'Groupe'),
                  onChanged: (newValue) {
                    seanceData['groupe'] = newValue;
                  },
                ),
                TextField(
                  controller: TextEditingController(text: seanceData['salle']),
                  decoration: InputDecoration(labelText: 'Salle'),
                  onChanged: (newValue) {
                    seanceData['salle'] = newValue;
                  },
                ),
                TextField(
                  controller: TextEditingController(text: seanceData['heure']),
                  decoration: InputDecoration(labelText: 'Heure'),
                  onChanged: (newValue) {
                    seanceData['heure'] = newValue;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('seances')
                    .doc(id)
                    .update({
                  'specialite': selectedSpecialite,
                  'module': selectedModule,
                  'enseignant': selectedEnseignant,
                  'groupe': seanceData['groupe'],
                  'salle': seanceData['salle'],
                  'heure': seanceData['heure'],
                }).then((_) {
                  Navigator.of(context).pop();
                });
              },
              child: Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des séances globales'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('seances').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Une erreur s\'est produite'));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucune séance disponible'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              DocumentSnapshot doc = snapshot.data!.docs[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                      '${data['specialite']} - ${data['module']} - ${data['groupe']}'),
                  subtitle:
                      Text('Salle: ${data['salle']} - Heure: ${data['heure']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: () {
                          _afficherDetailsSeance(data);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _modifierSeance(doc.id, data);
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
            MaterialPageRoute(builder: (context) => AjoutSeancesPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _afficherDetailsSeance(Map<String, dynamic> seanceData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails de la séance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Spécialité: ${seanceData['specialite']}'),
              Text('Module: ${seanceData['module']}'),
              Text('Enseignant: ${seanceData['enseignant']}'),
              Text('Groupe: ${seanceData['groupe']}'),
              Text('Salle: ${seanceData['salle']}'),
              Text('Heure: ${seanceData['heure']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
*/
