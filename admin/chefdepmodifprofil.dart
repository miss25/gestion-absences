import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RegisterChefPage());
}

class RegisterChefPage extends StatefulWidget {
  @override
  _RegisterChefPageState createState() => _RegisterChefPageState();
}

class _RegisterChefPageState extends State<RegisterChefPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final dateNaissanceController = TextEditingController();
  final telephoneController = TextEditingController();
  String? documentId; // Initialiser avec null
  bool isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    fetchDocumentId();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nomController.dispose();
    prenomController.dispose();
    dateNaissanceController.dispose();
    telephoneController.dispose();
    super.dispose();
  }

  Future<void> fetchDocumentId() async {
    // Récupérer le document unique dans la collection 'chef'
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('chef').get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        documentId = snapshot.docs.first.id;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Aucun document trouvé dans la collection chef.')),
      );
    }
  }

  Future<void> registerAndSendVerification() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Un email de vérification a été envoyé à ${emailController.text}. Veuillez vérifier votre email pour confirmer l\'inscription.')),
        );
        await checkEmailVerified();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.message}')),
      );
    }
  }

  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      setState(() {
        isEmailVerified = user.emailVerified;
      });

      if (isEmailVerified) {
        await saveProfileData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email vérifié avec succès.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Veuillez vérifier votre email avant de continuer.')),
        );
      }
    }
  }

  Future<void> saveProfileData() async {
    if (documentId != null) {
      await FirebaseFirestore.instance
          .collection('chef')
          .doc(documentId)
          .update({
        'nom': nomController.text,
        'prenom': prenomController.text,
        'email': emailController.text,
        'date_naissance': dateNaissanceController.text,
        'telephone': telephoneController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil mis à jour avec succès.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ID du document non trouvé.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier Chef  département')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: prenomController,
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: dateNaissanceController,
                decoration: InputDecoration(labelText: 'Date de naissance'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une date de naissance';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: telephoneController,
                decoration: InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    registerAndSendVerification();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Couleur du texte du bouton
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bord arrondi
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 15), // Espacement interne
                ),
                child: Text('Modifier'),
              ),
              SizedBox(height: 20),
              if (!isEmailVerified)
                ElevatedButton(
                  onPressed: checkEmailVerified,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green, // Couleur du texte du bouton
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bord arrondi
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 15), // Espacement interne
                  ),
                  child: Text('J\'ai vérifié mon email'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
