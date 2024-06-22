import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherGroupsPage extends StatefulWidget {
  @override
  _TeacherGroupsPageState createState() => _TeacherGroupsPageState();
}

class _TeacherGroupsPageState extends State<TeacherGroupsPage> {
  User? user;
  Map<String, String> teacherInfo = {};
  List<String> groups = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
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
      });
    } else {
      print('Informations enseignant non trouvées');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groupes enseignés'),
      ),
      body: Center(
        child: groups.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(groups[index]),
                  );
                },
              ),
      ),
    );
  }
}
