import 'package:flutter/material.dart';

class ModifierProfilEnseignantPage extends StatefulWidget {
  @override
  _ModifierProfilEnseignantPageState createState() =>
      _ModifierProfilEnseignantPageState();
}

class _ModifierProfilEnseignantPageState
    extends State<ModifierProfilEnseignantPage> {
  String nom = "";
  String prenom = "";
  String email = "";
  String numeroTelephone = "";
  String matiereenseignes = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier Profil d'enseignant"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: nom,
              decoration: InputDecoration(labelText: "Nom"),
              onChanged: (value) {
                setState(() {
                  nom = value;
                });
              },
            ),
            TextFormField(
              initialValue: prenom,
              decoration: InputDecoration(labelText: "prenom"), // Nouveau champ
              onChanged: (value) {
                setState(() {
                  prenom = value;
                });
              },
            ),
            TextFormField(
              initialValue: email,
              decoration: InputDecoration(labelText: "Email"), // Nouveau champ
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            TextFormField(
              initialValue: numeroTelephone,
              decoration: InputDecoration(
                  labelText: "Numéro de téléphone"), // Nouveau champ
              onChanged: (value) {
                setState(() {
                  numeroTelephone = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: matiereenseignes,
              decoration: InputDecoration(
                  labelText: "Matiere Enseignées"), // Nouveau champ
              onChanged: (value) {
                setState(() {
                  matiereenseignes = value;
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Mettez à jour les données ici (par exemple, enregistrez-les dans une base de données)
                  // Affichez un message de confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Profil mis à jour !")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Color.fromARGB(255, 4, 165, 17), // Texte en blanc
                  textStyle: TextStyle(
                    fontSize: 30, // Taille de texte
                    fontWeight: FontWeight.bold, // Gras
                  ),
                  minimumSize: Size(100, 50),
                ),
                child: Text("Enregistrer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
