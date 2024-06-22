import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MarquerAbsencesPage extends StatefulWidget {
  @override
  _MarquerAbsencesPageState createState() => _MarquerAbsencesPageState();
}

class _MarquerAbsencesPageState extends State<MarquerAbsencesPage> {
  late String moduleId;
  DateTime selectedDate = DateTime.now();
  String selectedHour = '08:00';
  User? user;
  String? enseignantId;
  Map<String, String> teacherInfo = {};
  List<String> groups = [];
  String? selectedGroup;
  Map<String, bool> presenceMap = {};

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      enseignantId = user!.uid;
      _getTeacherInfo();
    }
  }

  Future<void> _getTeacherInfo() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('enseignants')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        setState(() {
          moduleId = doc['moduleId'];
          teacherInfo = {
            'nom': doc['nom'],
            'prenom': doc['prenom'],
          };
        });
        _getGroups();
      } else {
        print('Document enseignant non trouvé');
      }
    } else {
      print('Utilisateur non authentifié');
    }
  }

  Future<void> _getGroups() async {
    if (teacherInfo.isNotEmpty) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('seances')
          .where('enseignant',
              isEqualTo: '${teacherInfo['nom']} ${teacherInfo['prenom']}')
          .get();

      List<String> tempGroups = [];
      querySnapshot.docs.forEach((doc) {
        tempGroups.add(doc['groupe']);
      });

      setState(() {
        groups = tempGroups;
        selectedGroup = groups.isNotEmpty ? groups[0] : null;
        if (selectedGroup != null) {
          _initializePresenceMap();
        }
      });
    } else {
      print('Informations enseignant non trouvées');
    }
  }

  void _initializePresenceMap() {
    if (selectedGroup != null) {
      FirebaseFirestore.instance
          .collection('etudiants')
          .where('groupe', isEqualTo: selectedGroup)
          .get()
          .then((QuerySnapshot querySnapshot) {
        setState(() {
          presenceMap = {};
          querySnapshot.docs.forEach((doc) {
            presenceMap[doc.id] = true;
          });
        });
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _markAbsences() {
    if (selectedGroup != null) {
      FirebaseFirestore.instance
          .collection('etudiants')
          .where('groupe', isEqualTo: selectedGroup)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          String nomPrenom = doc['nom'] + ' ' + doc['prenom'];
          if (presenceMap[doc.id] == false) {
            FirebaseFirestore.instance.collection('absences').add({
              'date': DateFormat('dd/MM/yyyy').format(selectedDate),
              'heure': selectedHour,
              'moduleId': moduleId,
              'nomPrenom': nomPrenom,
              'etudiantId': doc.id,
              'groupe': selectedGroup,
              'specialite': doc['specialite'],
              'enseignantId': enseignantId, // Ajoutez l'ID de l'enseignant
              'enseignantNomPrenom':
                  '${teacherInfo['nom']} ${teacherInfo['prenom']}', // Ajoutez le nom et prénom de l'enseignant
            }).then((_) {
              print(
                  "Absence marked for $nomPrenom on ${DateFormat('dd/MM/yyyy').format(selectedDate)} at $selectedHour");
            }).catchError((error) {
              print("Failed to mark absence: $error");
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> hours = [
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Marquer les Absences'),
        backgroundColor: Color(0xFF0077B6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date sélectionnée: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: Text('Sélectionner une date'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0096C7),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Heure sélectionnée: $selectedHour",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: selectedHour,
                          items: hours.map((String hour) {
                            return DropdownMenuItem<String>(
                              value: hour,
                              child: Text(hour),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedHour = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    DropdownButton<String>(
                      value: selectedGroup,
                      hint: Text("Sélectionner un groupe"),
                      items: groups.map((String group) {
                        return DropdownMenuItem<String>(
                          value: group,
                          child: Text(group),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGroup = newValue!;
                          _initializePresenceMap();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedGroup != null
                    ? FirebaseFirestore.instance
                        .collection('etudiants')
                        .where('groupe', isEqualTo: selectedGroup)
                        .snapshots()
                    : Stream.empty(),
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
                      final nomPrenom =
                          '${etudiant['nom']} ${etudiant['prenom']}';

                      return Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            nomPrenom,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(etudiant['email']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Présent'),
                              Radio(
                                value: true,
                                groupValue: presenceMap[etudiant.id],
                                onChanged: (value) {
                                  setState(() {
                                    presenceMap[etudiant.id] = value as bool;
                                  });
                                },
                              ),
                              Text('Absent'),
                              Radio(
                                value: false,
                                groupValue: presenceMap[etudiant.id],
                                onChanged: (value) {
                                  setState(() {
                                    presenceMap[etudiant.id] = value as bool;
                                  });
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
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _markAbsences();
                    Navigator.pop(context);
                  },
                  child: Text('Confirmer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF023E8A),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

/*     IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Delete the absence for this student
                                  FirebaseFirestore.instance
                                      .collection('absences')
                                      .where('etudiantId',
                                          isEqualTo: etudiant.id)
                                      .get()
                                      .then((QuerySnapshot querySnapshot) {
                                    querySnapshot.docs.forEach((doc) {
                                      _deleteAbsence(etudiant.id, doc.id);
                                    });
                                  });
                                },
                              ),*/

                              /*  void _deleteAbsence(String etudiantId, String absenceId) {
    FirebaseFirestore.instance
        .collection('absences')
        .doc(absenceId)
        .delete()
        .then((_) {
      print("Absence deleted for student $etudiantId");
    }).catchError((error) {
      print("Failed to delete absence: $error");
    });
  }*/