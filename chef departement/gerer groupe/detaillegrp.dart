import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../gerer seances/detailleseance.dart';

class DetailsGroupePage extends StatelessWidget {
  final DocumentSnapshot groupe;

  DetailsGroupePage({required this.groupe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Séances du Groupe'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: groupe.reference.collection('seances').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final seances = snapshot.data!.docs;
          return ListView.builder(
            itemCount: seances.length,
            itemBuilder: (context, index) {
              final seance = seances[index];
              final seanceData = seance.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(seanceData['nom'] ?? 'Nom non disponible'),
                subtitle: Text(seanceData['module'] ?? 'Module non disponible'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsSeancePage(seance: seance),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
