import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ajoutmodule.dart';
import 'modifmodule.dart';

class ModulesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Modules par Spécialité'),
      ),
      backgroundColor: Color.fromARGB(255, 2, 3, 83),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('specialites').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var specialites = snapshot.data!.docs;

          return ListView.builder(
            itemCount: specialites.length,
            itemBuilder: (context, index) {
              var specialite = specialites[index];

              return Center(
                child: Card(
                  margin: EdgeInsets.all(10.0),
                  child: ExpansionTile(
                    backgroundColor: Color.fromARGB(255, 201, 240, 245),
                    title: Text(
                      'Spécialité: ${specialite.id}',
                    ),
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('specialites')
                            .doc(specialite.id)
                            .collection('modules')
                            .snapshots(),
                        builder: (context, moduleSnapshot) {
                          if (!moduleSnapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          var modules = moduleSnapshot.data!.docs;

                          if (modules.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Aucun module disponible'),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: modules.length,
                            itemBuilder: (context, moduleIndex) {
                              var module = modules[moduleIndex];

                              return ListTile(
                                title: Text('Module: ${module.id}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.green),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ModifierModulePage(),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _supprimerModule(
                                            context, specialite.id, module.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
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
            MaterialPageRoute(builder: (context) => AjoutModulePage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _supprimerModule(
      BuildContext context, String specialiteId, String moduleId) async {
    await FirebaseFirestore.instance
        .collection('specialites')
        .doc(specialiteId)
        .collection('modules')
        .doc(moduleId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Module supprimé avec succès')),
    );
  }
}
