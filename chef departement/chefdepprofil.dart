import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilChefDepartementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Chef'),
      ),
      backgroundColor: Color.fromARGB(255, 2, 3, 83),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('chef').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final chefs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chefs.length,
            itemBuilder: (context, index) {
              final chef = chefs[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${chef['nom']} ${chef['prenom']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        title: Text('Nom: ${chef['nom']}'),
                        subtitle: Text('Prenom: ${chef['prenom']}'),
                      ),
                      ListTile(
                        title: Text('Email: ${chef['email']}'),
                        subtitle: Text('Téléphone: ${chef['telephone']}'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
