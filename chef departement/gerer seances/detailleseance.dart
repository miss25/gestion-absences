import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsSeancePage extends StatelessWidget {
  final DocumentSnapshot seance;

  DetailsSeancePage({required this.seance});

  @override
  Widget build(BuildContext context) {
    final data = seance.data() as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Séance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nom de la Séance: ${data?['nom'] ?? 'N/A'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Module: ${data?['module'] ?? 'N/A'}'),
            SizedBox(height: 10),
            Text('Heure: ${data?['heure'] ?? 'N/A'}'),
            // Ajoutez ici d'autres champs que vous souhaitez afficher
          ],
        ),
      ),
    );
  }
}
