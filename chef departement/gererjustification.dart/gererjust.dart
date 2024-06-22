import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AfficherJustificationsPage extends StatefulWidget {
  @override
  _AfficherJustificationsPageState createState() =>
      _AfficherJustificationsPageState();
}

class _AfficherJustificationsPageState
    extends State<AfficherJustificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Justifications des étudiants'),
      ),
      backgroundColor: Color.fromARGB(255, 2, 3, 83),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('justifications').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Aucune justification trouvée.',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final justifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: justifications.length,
            itemBuilder: (context, index) {
              final justification =
                  justifications[index].data() as Map<String, dynamic>;
              final docId =
                  justifications[index].id; // Obtenir l'ID du document
              final urlImage = justification['imageUrl'];
              final nomPrenom =
                  '${justification['nom']} ${justification['prenom']}';
              final groupe = justification['groupe'];
              final raisonDabsence = justification['raison'];
              final jour = justification['date'];
              final status = justification['status']; // Obtenir le statut
              final isConsulte = justification['isConsulte'] ??
                  false; // Nouveau champ pour vérifier si consulté

              return Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        nomPrenom,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Groupe: $groupe'),
                          Text('Raison d\'absence: $raisonDabsence'),
                          Text('Date: $jour'),
                          Text('Statut: $status'), // Afficher le statut
                          if (urlImage != null)
                            InkWell(
                              onTap: () => _launchURL(urlImage),
                              child: Text(
                                'Voir la justification',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          if (urlImage == null)
                            Text(
                              'Pas d\'image disponible',
                              style: TextStyle(color: Colors.grey),
                            ),
                          if (isConsulte)
                            Text(
                              'Consulté',
                              style: TextStyle(color: Colors.green),
                            ),
                        ],
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                // Accepter la justification
                                acceptJustification(justification, docId);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                // Refuser la justification
                                refuseJustification(justification, docId);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString(), forceSafariVC: false);
    } else {
      throw 'Impossible d\'ouvrir $url';
    }
  }

  void acceptJustification(
      Map<String, dynamic> justification, String docId) async {
    try {
      // Mettre à jour le statut de la justification et marquer comme consultée
      await FirebaseFirestore.instance
          .collection('justifications')
          .doc(docId)
          .update({'status': 'acceptée', 'isConsulte': true});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Justification acceptée pour ${justification['nom']} ${justification['prenom']}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l\'acceptation de la justification: $e',
          ),
        ),
      );
    }
  }

  void refuseJustification(
      Map<String, dynamic> justification, String docId) async {
    try {
      // Mettre à jour le statut de la justification et marquer comme consultée
      await FirebaseFirestore.instance
          .collection('justifications')
          .doc(docId)
          .update({'status': 'refusée', 'isConsulte': true});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Justification refusée pour ${justification['nom']} ${justification['prenom']}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du refus de la justification: $e',
          ),
        ),
      );
    }
  }
}
