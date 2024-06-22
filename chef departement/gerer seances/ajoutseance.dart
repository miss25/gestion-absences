import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjouterSeancePage extends StatefulWidget {
  @override
  _AjouterSeancePageState createState() => _AjouterSeancePageState();
}

class _AjouterSeancePageState extends State<AjouterSeancePage> {
  String? selectedSpecialite;
  String? selectedGroupe;
  String? selectedModule;
  String? selectedTypeSeance;
  String? selectedEnseignant;
  String? selectedJour;
  String? selectedHeure;
  String? selectedSalle;

  final List<String> jours = [
    'Samedi',
    'Dimanche',
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi'
  ];
  final List<String> heures = [
    '08h',
    '09h',
    '10h',
    '11h',
    '12h',
    '13h',
    '14h',
    '15h'
  ];
  final List<String> salles = [
    'Salle01',
    'Salle02',
    'Salle03',
    'Salle04',
    'Salle05',
    'Salle06',
    'Salle07',
    'Salle08',
    'Salle09',
    'Salle10'
  ];

  Future<List<QueryDocumentSnapshot>> _loadSpecialites() async {
    var snapshot =
        await FirebaseFirestore.instance.collection('specialites').get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> _loadModules() async {
    if (selectedSpecialite == null) return [];
    var snapshot = await FirebaseFirestore.instance
        .collection('specialites')
        .doc(selectedSpecialite)
        .collection('modules')
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> _loadGroupes() async {
    if (selectedSpecialite == null) return [];
    var snapshot = await FirebaseFirestore.instance
        .collection('specialites')
        .doc(selectedSpecialite)
        .collection('groupes')
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> _loadEnseignants() async {
    if (selectedModule == null) return [];
    var snapshot = await FirebaseFirestore.instance
        .collection('enseignantModule')
        .where('moduleId', isEqualTo: selectedModule)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Séances'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _loadSpecialites(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Spécialité'),
                  value: selectedSpecialite,
                  items: snapshot.data!.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc.id),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    selectedSpecialite = value;
                    selectedGroupe = null;
                    selectedModule = null;
                    selectedEnseignant = null;
                  }),
                );
              },
            ),
            if (selectedSpecialite != null)
              FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _loadGroupes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Groupe'),
                    value: selectedGroupe,
                    items: snapshot.data!.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc.id),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      selectedGroupe = value;
                    }),
                  );
                },
              ),
            if (selectedSpecialite != null)
              FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _loadModules(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Module'),
                    value: selectedModule,
                    items: snapshot.data!.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc.id),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      selectedModule = value;
                      selectedEnseignant = null;
                    }),
                  );
                },
              ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Type de Séance'),
              value: selectedTypeSeance,
              items: ['TD', 'TP'].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                selectedTypeSeance = value;
              }),
            ),
            if (selectedModule != null)
              FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _loadEnseignants(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Enseignant'),
                    value: selectedEnseignant,
                    items: snapshot.data!.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['enseignant'],
                        child: Text(doc['enseignant']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      selectedEnseignant = value;
                    }),
                  );
                },
              ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Jour'),
              value: selectedJour,
              items: jours.map((jour) {
                return DropdownMenuItem<String>(
                  value: jour,
                  child: Text(jour),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                selectedJour = value;
              }),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Heure'),
              value: selectedHeure,
              items: heures.map((heure) {
                return DropdownMenuItem<String>(
                  value: heure,
                  child: Text(heure),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                selectedHeure = value;
              }),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Salle'),
              value: selectedSalle,
              items: salles.map((salle) {
                return DropdownMenuItem<String>(
                  value: salle,
                  child: Text(salle),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                selectedSalle = value;
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSeance,
              child: Text('Ajouter Séance', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Couleur du texte du bouton
                elevation: 5, // Élévation du bouton (ombre)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Bordure arrondie
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20), // Rembourrage interne du bouton
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSeance() {
    if (selectedSpecialite != null &&
        selectedGroupe != null &&
        selectedModule != null &&
        selectedTypeSeance != null &&
        selectedEnseignant != null &&
        selectedJour != null &&
        selectedHeure != null &&
        selectedSalle != null) {
      FirebaseFirestore.instance.collection('seances').add({
        'specialite': selectedSpecialite,
        'groupe': selectedGroupe,
        'module': selectedModule,
        'typeSeance': selectedTypeSeance,
        'enseignant': selectedEnseignant,
        'jour': selectedJour,
        'heure': selectedHeure,
        'salle': selectedSalle,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Séance ajoutée avec succès')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'ajout de la séance')));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez remplir tous les champs')));
    }
  }
}


/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class Enseignant {
  final String uid;
  final String nomComplet;

  Enseignant(this.uid, this.nomComplet);
}

class AjoutSeancesPage extends StatefulWidget {
  @override
  _AjoutSeancesPageState createState() => _AjoutSeancesPageState();
}

class _AjoutSeancesPageState extends State<AjoutSeancesPage> {
  String? selectedSpecialite;
  String? selectedGroupe;
  String selectedTdTp = 'TD';
  String? selectedEnseignant;
  String? selectedModule;
  String selectedSalle = 'Salle 1';
  String selectedHeure = '8h';

  List<String> modulesEnseignes = [];

  final List<String> tdTpChoices = ['TD', 'TP'];
  final List<String> salleChoices =
      List<String>.generate(10, (index) => 'Salle ${index + 1}');
  final List<String> heureChoices =
      List<String>.generate(8, (index) => '${8 + index}h');

  List<String> specialites = [];
  List<String> groupes = [];
  List<String> moduleChoices = [];
  List<String> enseignantChoices = [];
  List<Enseignant> enseignants = [];

  @override
  void initState() {
    super.initState();
    _loadSpecialites();
  }

  Future<void> _loadSpecialites() async {
    final QuerySnapshot specialitesSnapshot =
        await FirebaseFirestore.instance.collection('specialites').get();
    if (mounted) {
      setState(() {
        specialites = specialitesSnapshot.docs
            .map((DocumentSnapshot document) => document.id as String)
            .toList();
      });
    }
    // Charger les groupes et les modules pour la première spécialité (si disponible)
    if (specialites.isNotEmpty) {
      await _loadGroupes(specialites.first);
      await _loadModules(specialites.first);
    }
  }

  Future<void> _loadGroupes(String specialiteId) async {
    final QuerySnapshot groupesSnapshot = await FirebaseFirestore.instance
        .collection('specialites')
        .doc(specialiteId)
        .collection('groupes')
        .get();
    if (mounted) {
      setState(() {
        groupes = groupesSnapshot.docs
            .map((DocumentSnapshot document) => document.id as String)
            .toList();
      });
    }
  }

  Future<void> _loadModules(String specialiteId) async {
    final QuerySnapshot modulesSnapshot = await FirebaseFirestore.instance
        .collection('specialites')
        .doc(specialiteId)
        .collection('modules')
        .get();
    if (mounted) {
      setState(() {
        moduleChoices = modulesSnapshot.docs
            .map((DocumentSnapshot document) => document.id as String)
            .toList();
        selectedModule = null;
        enseignantChoices = [];
        selectedEnseignant = null;
        enseignants = [];
      });
    }
    // Charger les enseignants pour le premier module (si disponible)
    if (moduleChoices.isNotEmpty) {
      await _loadEnseignants(moduleChoices.first);
    }
  }

  Future<void> _loadEnseignants(String moduleId) async {
    final QuerySnapshot enseignantModuleSnapshot = await FirebaseFirestore
        .instance
        .collection('enseignantModule')
        .where('moduleId', isEqualTo: moduleId)
        .get();

    final List<String> enseignantIds = enseignantModuleSnapshot.docs
        .map((DocumentSnapshot document) => document['enseignant'] as String)
        .toList();

    if (enseignantIds.isNotEmpty) {
      final QuerySnapshot enseignantsSnapshot = await FirebaseFirestore.instance
          .collection('enseignants')
          .where(FieldPath.documentId, whereIn: enseignantIds)
          .get();

      if (mounted) {
        setState(() {
          enseignantChoices = enseignantsSnapshot.docs
              .map((DocumentSnapshot document) =>
                  (document['nom'] as String) +
                  ' ' +
                  (document['prenom'] as String))
              .toList();
          enseignants = enseignantsSnapshot.docs
              .map((DocumentSnapshot document) => Enseignant(
                  document.id,
                  (document['nom'] as String) +
                      ' ' +
                      (document['prenom'] as String)))
              .toList();
          selectedEnseignant = null;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          enseignantChoices = [];
          enseignants = [];
          selectedEnseignant = null;
        });
      }
    }
  }

  Future<void> _loadModulesEnseignes(String enseignant) async {
    final QuerySnapshot enseignantsSnapshot = await FirebaseFirestore.instance
        .collection('enseignantModule')
        .where('enseignant', isEqualTo: enseignant)
        .get();
    if (enseignantsSnapshot.docs.isNotEmpty) {
      final DocumentSnapshot enseignantDoc = enseignantsSnapshot.docs.first;
      final List<dynamic> modules = enseignantDoc['moduleId'];
      if (mounted) {
        setState(() {
          modulesEnseignes = modules.cast<String>();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          modulesEnseignes = [];
        });
      }
    }
  }

  void _ajouterSeance() async {
    if (selectedSpecialite != null &&
        selectedGroupe != null &&
        selectedModule != null &&
        selectedEnseignant != null &&
        enseignants.isNotEmpty) {
      Enseignant? enseignantSelectionne = enseignants.firstWhereOrNull(
          (enseignant) => enseignant.nomComplet == selectedEnseignant);
      if (enseignantSelectionne != null) {
        await FirebaseFirestore.instance.collection('seances').add({
          'specialite': selectedSpecialite,
          'groupe': selectedGroupe,
          'tdTp': selectedTdTp,
          'enseignant': selectedEnseignant,
          'module': selectedModule,
          'salle': selectedSalle,
          'heure': selectedHeure,
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Séance ajoutée avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enseignant non trouvé'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Veuillez sélectionner une spécialité, un groupe, un module et un enseignant'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajout de Séances'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedSpecialite,
              hint: Text('Sélectionner une spécialité'),
              onChanged: (newValue) {
                setState(() {
                  selectedSpecialite = newValue;
                  selectedGroupe = null;
                  selectedModule = null;
                  selectedEnseignant = null;
                  groupes = [];
                  moduleChoices = [];
                  enseignantChoices = [];
                  enseignants = [];
                  _loadGroupes(selectedSpecialite!);
                  _loadModules(selectedSpecialite!);
                  _loadEnseignants(selectedModule!);
                });
              },
              items: specialites.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedGroupe,
              hint: Text('Sélectionner un groupe'),
              onChanged: (newValue) {
                setState(() {
                  selectedGroupe = newValue;
                });
              },
              items: groupes.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedModule,
              hint: Text('Sélectionner un module'),
              onChanged: (newValue) {
                setState(() {
                  selectedModule = newValue;
                  enseignantChoices = [];
                  selectedEnseignant = null;
                  _loadEnseignants(selectedModule!);
                });
              },
              items:
                  moduleChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedTdTp,
              onChanged: (newValue) {
                setState(() {
                  selectedTdTp = newValue!;
                });
              },
              items: tdTpChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedEnseignant,
              hint: Text('Sélectionner un enseignant'),
              onChanged: (newValue) {
                setState(() {
                  selectedEnseignant = newValue;
                  _loadModulesEnseignes(selectedEnseignant!);
                });
              },
              items: enseignantChoices
                  .map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedSalle,
              onChanged: (newValue) {
                setState(() {
                  selectedSalle = newValue!;
                });
              },
              items:
                  salleChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedHeure,
              onChanged: (newValue) {
                setState(() {
                  selectedHeure = newValue!;
                });
              },
              items:
                  heureChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _ajouterSeance,
              child: Text('Ajouter la Séance'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    Color.fromARGB(255, 33, 15, 202), // Texte en blanc
                textStyle: TextStyle(
                  fontSize: 15, // Taille de texte
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/


/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjoutSeancesPage extends StatefulWidget {
  @override
  _AjoutSeancesPageState createState() => _AjoutSeancesPageState();
}

class _AjoutSeancesPageState extends State<AjoutSeancesPage> {
  String? selectedSpecialite;
  String? selectedGroupe;
  String selectedTdTp = 'TD'; // Définir une valeur par défaut
  String? selectedEnseignant;
  String? selectedModule;
  String selectedSalle = 'Salle 1';
  String selectedHeure = '8h';
  String? enseignantUid;
  String? enseignantNom;
  String? enseignantPrenom;

  final List<String> tdTpChoices = ['TD', 'TP'];
  final List<String> salleChoices =
      List<String>.generate(10, (index) => 'Salle ${index + 1}');
  final List<String> heureChoices =
      List<String>.generate(8, (index) => '${8 + index}h');

  List<String> specialites = [];
  List<String> groupes = [];
  List<String> moduleChoices = [];
  List<String> enseignantChoices = [];
  List<String> modulesEnseignes = [];

  Future<void> _ajouterSeance() async {
    if (selectedSpecialite != null &&
        selectedGroupe != null &&
        selectedModule != null &&
        selectedEnseignant != null &&
        enseignantUid != null &&
        enseignantNom != null &&
        enseignantPrenom != null) {
      await FirebaseFirestore.instance.collection('seances').add({
        'specialite': selectedSpecialite,
        'groupe': selectedGroupe,
        'tdTp': selectedTdTp,
        'enseignantUid': enseignantUid,
        'enseignantNom': enseignantNom,
        'enseignantPrenom': enseignantPrenom,
        'module': selectedModule,
        'salle': selectedSalle,
        'heure': selectedHeure,
      });

      await ajouterSeanceAuxEtudiants(selectedSpecialite!, selectedGroupe!);
      await ajouterSeanceAEnseignant(enseignantUid!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Séance ajoutée avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Veuillez sélectionner une spécialité, un groupe, un module et un enseignant'),
        ),
      );
    }
  }

  Future<void> ajouterSeanceAuxEtudiants(
      String specialite, String groupe) async {
    final QuerySnapshot etudiantsSnapshot = await FirebaseFirestore.instance
        .collection('etudiants')
        .where('specialite', isEqualTo: specialite)
        .where('groupe', isEqualTo: groupe)
        .get();
    etudiantsSnapshot.docs.forEach((etudiantDoc) async {
      await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(etudiantDoc.id)
          .collection('seances')
          .add({
        'specialite': specialite,
        'groupe': groupe,
        'tdTp': selectedTdTp,
        'enseignantUid': enseignantUid,
        'enseignantNom': enseignantNom,
        'enseignantPrenom': enseignantPrenom,
        'module': selectedModule,
        'salle': selectedSalle,
        'heure': selectedHeure,
      });
    });
  }

  Future<void> ajouterSeanceAEnseignant(String enseignantUid) async {
    final QuerySnapshot enseignantsSnapshot = await FirebaseFirestore.instance
        .collection('enseignants')
        .where(FieldPath.documentId, isEqualTo: enseignantUid)
        .get();
    enseignantsSnapshot.docs.forEach((enseignantDoc) async {
      await FirebaseFirestore.instance
          .collection('enseignants')
          .doc(enseignantDoc.id)
          .collection('seances')
          .add({
        'specialite': selectedSpecialite,
        'groupe': selectedGroupe,
        'tdTp': selectedTdTp,
        'enseignantUid': enseignantUid,
        'enseignantNom': enseignantNom,
        'enseignantPrenom': enseignantPrenom,
        'module': selectedModule,
        'salle': selectedSalle,
        'heure': selectedHeure,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajout de Séances'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedSpecialite,
              hint: Text('Sélectionner une spécialité'),
              onChanged: (newValue) {
                setState(() {
                  selectedSpecialite = newValue;
                  selectedGroupe = null;
                  selectedModule = null;
                  selectedEnseignant = null;
                  groupes = [];
                  moduleChoices = [];
                  enseignantChoices = [];
                  modulesEnseignes = [];
                  _loadGroupes(selectedSpecialite!);
                  _loadModules(selectedSpecialite!);
                });
              },
              items: specialites.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedGroupe,
              hint: Text('Sélectionner un groupe'),
              onChanged: (newValue) {
                setState(() {
                  selectedGroupe = newValue;
                });
              },
              items: groupes.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedModule,
              hint: Text('Sélectionner un module'),
              onChanged: (newValue) {
                setState(() {
                  selectedModule = newValue;
                  enseignantChoices = [];
                  selectedEnseignant = null;
                  modulesEnseignes = [];
                  _loadEnseignants(selectedModule!);
                });
              },
              items:
                  moduleChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedTdTp,
              onChanged: (newValue) {
                setState(() {
                  selectedTdTp = newValue!;
                });
              },
              items: tdTpChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedEnseignant,
              hint: Text('Sélectionner un enseignant'),
              onChanged: (newValue) {
                setState(() {
                  selectedEnseignant = newValue!;
                  _loadModulesEnseignes(selectedEnseignant!);
                });
              },
              items: enseignantChoices
                  .map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            if (modulesEnseignes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Modules enseignés:'),
                  ...modulesEnseignes.map((module) => Text(module)).toList(),
                ],
              ),
            DropdownButton<String>(
              value: selectedSalle,
              onChanged: (newValue) {
                setState(() {
                  selectedSalle = newValue!;
                });
              },
              items:
                  salleChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedHeure,
              onChanged: (newValue) {
                setState(() {
                  selectedHeure = newValue!;
                });
              },
              items:
                  heureChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _ajouterSeance,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 74, 74, 253),
                  textStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  minimumSize: Size(100, 50),
                ),
                child: Text('Ajouter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSpecialites() async {
    final QuerySnapshot specialitesSnapshot =
        await FirebaseFirestore.instance.collection('specialites').get();
    setState(() {
      specialites = specialitesSnapshot.docs
          .map((DocumentSnapshot document) => document.id as String)
          .toList();
    });
  }

  Future<void> _loadGroupes(String specialiteId) async {
    final QuerySnapshot groupesSnapshot = await FirebaseFirestore.instance
        .collection('specialites')
        .doc(specialiteId)
        .collection('groupes')
        .get();
    setState(() {
      groupes = groupesSnapshot.docs
          .map((DocumentSnapshot document) => document.id as String)
          .toList();
    });
  }

  Future<void> _loadModules(String specialiteId) async {
    final QuerySnapshot modulesSnapshot = await FirebaseFirestore.instance
        .collection('specialites')
        .doc(specialiteId)
        .collection('modules')
        .get();
    setState(() {
      moduleChoices = modulesSnapshot.docs
          .map((DocumentSnapshot document) => document.id as String)
          .toList();
      selectedModule = null;
      enseignantChoices = [];
      selectedEnseignant = null;
      modulesEnseignes = [];
    });
  }

  Future<void> _loadEnseignants(String moduleId) async {
    final QuerySnapshot enseignantsSnapshot = await FirebaseFirestore.instance
        .collection('enseignants')
        .where('moduleId', isEqualTo: moduleId)
        .get();
    setState(() {
      enseignantChoices = enseignantsSnapshot.docs
          .map((DocumentSnapshot document) =>
              (document['nom'] as String) +
              ' ' +
              (document['prenom'] as String))
          .toList();
      selectedEnseignant = null;
    });
  }

  Future<void> _loadModulesEnseignes(String enseignant) async {
    final QuerySnapshot enseignantsSnapshot = await FirebaseFirestore.instance
        .collection('enseignants')
        .where('nomPrenom', isEqualTo: enseignant)
        .get();
    if (enseignantsSnapshot.docs.isNotEmpty) {
      final DocumentSnapshot enseignantDoc = enseignantsSnapshot.docs.first;
      final List<dynamic> modules = enseignantDoc['modulesEnseignes'];
      setState(() {
        modulesEnseignes = modules.cast<String>();
        enseignantUid = enseignantDoc.id;
        enseignantNom = enseignantDoc['nom'];
        enseignantPrenom = enseignantDoc['prenom'];
      });
    } else {
      setState(() {
        modulesEnseignes = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSpecialites();
  }
}


/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjoutSeancesPage extends StatefulWidget {
  @override
  _AjoutSeancesPageState createState() => _AjoutSeancesPageState();
}

class _AjoutSeancesPageState extends State<AjoutSeancesPage> {
  String? selectedSpecialite;
  String? selectedGroupe;
  String selectedTdTp = 'TD'; // Définir une valeur par défaut
  String? selectedEnseignant;
  String? selectedModule;
  String selectedSalle = 'Salle 1';
  String selectedHeure = '8h';

  final List<String> tdTpChoices = ['TD', 'TP'];
  final List<String> salleChoices =
      List<String>.generate(10, (index) => 'Salle ${index + 1}');
  final List<String> heureChoices =
      List<String>.generate(8, (index) => '${8 + index}h');

  List<String> specialites = [];
  List<String> groupes = [];
  List<String> moduleChoices = [];
  List<String> enseignantChoices = [];
  List<String> modulesEnseignes = [];

  @override
  void initState() {
    super.initState();
    _loadSpecialites();
  }

  Future<void> _loadSpecialites() async {
    final QuerySnapshot specialitesSnapshot =
        await FirebaseFirestore.instance.collection('specialites').get();
    setState(() {
      specialites = specialitesSnapshot.docs
          .map((DocumentSnapshot document) => document.id as String)
          .toList();
    });
  }

  Future<void> _loadGroupes(String specialiteId) async {
    final QuerySnapshot groupesSnapshot = await FirebaseFirestore.instance
        .collection('specialites')
        .doc(specialiteId)
        .collection('groupes')
        .get();
    setState(() {
      groupes = groupesSnapshot.docs
          .map((DocumentSnapshot document) => document.id as String)
          .toList();
    });
  }

  Future<void> _loadModules(String specialiteId) async {
    final QuerySnapshot modulesSnapshot = await FirebaseFirestore.instance
        .collection('specialites')
        .doc(specialiteId)
        .collection('modules')
        .get();
    setState(() {
      moduleChoices = modulesSnapshot.docs
          .map((DocumentSnapshot document) => document.id as String)
          .toList();
      selectedModule = null;
      enseignantChoices = [];
      selectedEnseignant = null;
      modulesEnseignes = [];
    });
  }

  Future<void> _loadEnseignants(String moduleId) async {
    final QuerySnapshot enseignantsSnapshot = await FirebaseFirestore.instance
        .collection('enseignants')
        .where('moduleId', isEqualTo: moduleId)
        .get();
    setState(() {
      enseignantChoices = enseignantsSnapshot.docs
          .map((DocumentSnapshot document) =>
              (document['nom'] as String) +
              ' ' +
              (document['prenom'] as String))
          .toList();
      selectedEnseignant = null;
    });
  }

  Future<void> _loadModulesEnseignes(String enseignant) async {
    final QuerySnapshot enseignantsSnapshot = await FirebaseFirestore.instance
        .collection('enseignants')
        .where('nomPrenom', isEqualTo: enseignant)
        .get();
    if (enseignantsSnapshot.docs.isNotEmpty) {
      final DocumentSnapshot enseignantDoc = enseignantsSnapshot.docs.first;
      final List<dynamic> modules = enseignantDoc['modulesEnseignes'];
      setState(() {
        modulesEnseignes = modules.cast<String>();
      });
    } else {
      setState(() {
        modulesEnseignes = [];
      });
    }
  }

  Future<void> _ajouterSeance() async {
    if (selectedSpecialite != null && selectedGroupe != null) {
      await FirebaseFirestore.instance
          .collection('specialites')
          .doc(selectedSpecialite)
          .collection('groupes')
          .doc(selectedGroupe)
          .collection('seance')
          .add({
        'tdTp': selectedTdTp,
        'enseignant': selectedEnseignant,
        'module': selectedModule,
        'salle': selectedSalle,
        'heure': selectedHeure,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Séance ajoutée avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Veuillez sélectionner une spécialité et un groupe')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajout de Séances'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedSpecialite,
              hint: Text('Sélectionner une spécialité'),
              onChanged: (newValue) {
                setState(() {
                  selectedSpecialite = newValue;
                  selectedGroupe = null; // Réinitialiser le groupe sélectionné
                  selectedModule = null; // Réinitialiser le module sélectionné
                  selectedEnseignant =
                      null; // Réinitialiser l'enseignant sélectionné
                  groupes = [];
                  moduleChoices = [];
                  enseignantChoices = [];
                  modulesEnseignes = [];
                  _loadGroupes(selectedSpecialite!);
                  _loadModules(selectedSpecialite!);
                });
              },
              items: specialites.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedGroupe,
              hint: Text('Sélectionner un groupe'),
              onChanged: (newValue) {
                setState(() {
                  selectedGroupe = newValue;
                });
              },
              items: groupes.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedModule,
              hint: Text('Sélectionner un module'),
              onChanged: (newValue) {
                setState(() {
                  selectedModule = newValue;
                  enseignantChoices = [];
                  selectedEnseignant = null;
                  modulesEnseignes = [];
                  _loadEnseignants(selectedModule!);
                });
              },
              items:
                  moduleChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedTdTp,
              onChanged: (newValue) {
                setState(() {
                  selectedTdTp = newValue!;
                });
              },
              items: tdTpChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedEnseignant,
              hint: Text('Sélectionner un enseignant'),
              onChanged: (newValue) {
                setState(() {
                  selectedEnseignant = newValue!;
                  _loadModulesEnseignes(selectedEnseignant!);
                });
              },
              items: enseignantChoices
                  .map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            if (modulesEnseignes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Modules enseignés:'),
                  ...modulesEnseignes.map((module) => Text(module)).toList(),
                ],
              ),
            DropdownButton<String>(
              value: selectedSalle,
              onChanged: (newValue) {
                setState(() {
                  selectedSalle = newValue!;
                });
              },
              items:
                  salleChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedHeure,
              onChanged: (newValue) {
                setState(() {
                  selectedHeure = newValue!;
                });
              },
              items:
                  heureChoices.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _ajouterSeance,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 74, 74, 253),
                  textStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  minimumSize: Size(100, 50),
                ),
                child: Text('Ajouter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
*/