import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifProfilPage extends StatefulWidget {
  @override
  _ModifProfilPageState createState() => _ModifProfilPageState();
}

class _ModifProfilPageState extends State<ModifProfilPage> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _motdepasseController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _birthdateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Administrateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _prenomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'E-mail'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _motdepasseController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Numéro de téléphone'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _birthdateController,
              decoration: InputDecoration(labelText: 'Date de naissance'),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _updateAdminProfile();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 4, 165, 17),
                  textStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  minimumSize: Size(100, 50),
                ),
                child: Text('Inscrire'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour mettre à jour le profil de l'administrateur dans Firestore
  Future<void> _updateAdminProfile() async {
    String firstName = _nomController.text;
    String lastName = _prenomController.text;
    String email = _emailController.text;
    String motdepasse = _motdepasseController
        .text; // Note: Ceci est pour démonstration seulement, vous devriez utiliser une méthode plus sécurisée pour modifier le mot de passe
    String phone = _phoneController.text;
    String birthdate = _birthdateController.text;

    try {
      // Mise à jour des informations de l'administrateur dans Firestore
      await FirebaseFirestore.instance
          .collection('admin')
          .doc('userId')
          .update({
        'prenom': firstName,
        'nom': lastName,
        'email': email,
        // Mettre à jour le mot de passe est une opération sensible et nécessite des méthodes de sécurité supplémentaires
        'telephone': phone,
        'date_naissance': birthdate,
      });

      // Mettre à jour les contrôleurs de texte avec les nouvelles valeurs
      setState(() {
        _nomController.text = firstName;
        _prenomController.text = lastName;
        _emailController.text = email;
        _phoneController.text = phone;
        _birthdateController.text = birthdate;
      });

      // Afficher un message de succès à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil mis à jour avec succès')),
      );
    } catch (error) {
      // En cas d'erreur, afficher un message d'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la mise à jour du profil: $error')),
      );
    }
  }
}
