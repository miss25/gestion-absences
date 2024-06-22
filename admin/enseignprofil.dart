import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilEnseignantPage extends StatelessWidget {
  final String docId;

  ProfilEnseignantPage({required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil d\'enseignant'),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('enseignants')
            .doc(docId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
                child: Text('Aucune donnée trouvée pour cet enseignant'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          // Filtrer les champs pour exclure "role"
          var filteredData = Map.of(data)..remove('role');

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: filteredData.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${_formatFieldName(entry.key)}: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              TextSpan(
                                text: '${entry.value}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatFieldName(String fieldName) {
    // Fonction pour formater le nom des champs de Firestore pour un affichage plus agréable
    return fieldName.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ').capitalize();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
