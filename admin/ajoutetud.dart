import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjouterEtudiantPage extends StatefulWidget {
  @override
  _AjouterEtudiantPageState createState() => _AjouterEtudiantPageState();
}

class _AjouterEtudiantPageState extends State<AjouterEtudiantPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motdepasseController = TextEditingController();
  final TextEditingController _numTelephoneController = TextEditingController();

  String? _selectedSpecialite;
  String? _selectedGroupe;

  List<String> specialites = [];
  List<String> groupes = [];

  @override
  void initState() {
    super.initState();
    _loadSpecialites();
  }

  Future<void> _loadSpecialites() async {
    final specialitesSnapshot =
        await FirebaseFirestore.instance.collection('specialites').get();
    setState(() {
      specialites = specialitesSnapshot.docs
          .map((DocumentSnapshot document) => document.id)
          .toList();
      if (specialites.isNotEmpty) {
        _selectedSpecialite = specialites.first;
        _loadGroupesForSpecialite(_selectedSpecialite!);
      }
    });
  }

  Future<void> _loadGroupesForSpecialite(String specialite) async {
    print('Chargement des groupes pour la spécialité: $specialite');
    final groupesSnapshot = await FirebaseFirestore.instance
        .collection('specialites')
        .doc(specialite)
        .collection('groupes')
        .get();
    setState(() {
      groupes = groupesSnapshot.docs
          .map((DocumentSnapshot document) => document.id)
          .toList();
      print('Groupes récupérés: $groupes');
      if (groupes.isNotEmpty) {
        _selectedGroupe = groupes.first;
      } else {
        _selectedGroupe = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un étudiant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nomController, 'Nom', 'Veuillez entrer le nom'),
              _buildTextField(
                  _prenomController, 'Prénom', 'Veuillez entrer le prénom'),
              _buildTextField(_dateNaissanceController, 'Date de naissance',
                  'Veuillez entrer la date de naissance',
                  keyboardType: TextInputType.datetime),
              _buildDropdownField(
                'Spécialité',
                specialites,
                _selectedSpecialite,
                (value) {
                  setState(() {
                    _selectedSpecialite = value as String?;
                    if (_selectedSpecialite != null) {
                      _loadGroupesForSpecialite(_selectedSpecialite!);
                    }
                  });
                },
              ),
              _buildDropdownField(
                'Groupe',
                groupes,
                _selectedGroupe,
                (value) {
                  setState(() {
                    _selectedGroupe = value as String?;
                  });
                },
              ),
              _buildTextField(
                  _emailController, 'Email', 'Veuillez entrer un email valide',
                  keyboardType: TextInputType.emailAddress),
              _buildTextField(_motdepasseController, 'Mot de passe',
                  'Veuillez entrer un mot de passe',
                  obscureText: true),
              _buildTextField(_numTelephoneController, 'Numéro de téléphone',
                  'Veuillez entrer le numéro de téléphone',
                  keyboardType: TextInputType.phone),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _ajouterEtudiant,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 74, 74, 253),
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    minimumSize: Size(100, 50),
                  ),
                  child: Text('Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String errorText,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorText;
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      String? selectedValue, ValueChanged<String?>? onChanged) {
    return DropdownButtonFormField<String>(
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      value: selectedValue,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner $label';
        }
        return null;
      },
    );
  }

  Future<void> _ajouterEtudiant() async {
    if (_formKey.currentState!.validate()) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _motdepasseController.text,
        );

        await FirebaseAuth.instance.currentUser!.sendEmailVerification();

        await FirebaseFirestore.instance
            .collection('etudiants')
            .doc(credential.user!.uid)
            .set({
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'dateNaissance': _dateNaissanceController.text,
          'groupe': _selectedGroupe,
          'specialite': _selectedSpecialite,
          'email': _emailController.text,
          'numTelephone': _numTelephoneController.text,
          'role': 'etudiant',
        });

        Navigator.of(context).pushReplacementNamed('/listesetudiants');
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'weak-password') {
          errorMessage = 'Entrer un mot de passe fort';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Le compte existe déjà pour cet e-mail.';
        } else {
          errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
        }
        _showErrorDialog(errorMessage);
      } catch (e) {
        print(e);
      }
    }
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      animType: AnimType.rightSlide,
      dialogType: DialogType.error,
      title: 'Erreur',
      desc: message,
    ).show();
  }
}
