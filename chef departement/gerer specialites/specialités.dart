import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ajoutspecialité.dart';
import 'modifspes.dart';

class ListeIDsSpecialitesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listes des Spécialités'),
      ),
      backgroundColor: Color.fromARGB(255, 2, 3, 83),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('specialites').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final specialites = snapshot.data!.docs;
          return ListView.builder(
            itemCount: specialites.length,
            itemBuilder: (context, index) {
              final specialite = specialites[index];
              final specialiteData = specialite.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(specialite.id),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (specialiteData['modules'] != null)
                        ...specialiteData['modules'].map<Widget>((module) {
                          return Text(module);
                        }).toList(),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ModifierSpecialitePage(
                                      specialiteId: '',
                                      initialNom: '',
                                    )),
                          );
                        },
                        child: Text('Modifier'),
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
            MaterialPageRoute(builder: (context) => AjoutSpecialitePage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
