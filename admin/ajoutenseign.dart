import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AjouterEnseignantPage extends StatefulWidget {
  @override
  _AjouterEnseignantPageState createState() => _AjouterEnseignantPageState();
}

class _AjouterEnseignantPageState extends State<AjouterEnseignantPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motdepasseController = TextEditingController();
  final TextEditingController _numTelephoneController = TextEditingController();

  String? _selectedModuleId;
  List<String> _moduleIds = [];

  @override
  void initState() {
    super.initState();
    _fetchModuleIds();
  }

  Future<void> _fetchModuleIds() async {
    QuerySnapshot specialitesSnapshot =
        await FirebaseFirestore.instance.collection('specialites').get();
    Set<String> moduleIdsSet = {};

    for (var specialiteDoc in specialitesSnapshot.docs) {
      QuerySnapshot modulesSnapshot = await FirebaseFirestore.instance
          .collection('specialites')
          .doc(specialiteDoc.id)
          .collection('modules')
          .get();

      for (var moduleDoc in modulesSnapshot.docs) {
        moduleIdsSet.add(moduleDoc.id);
      }
    }

    setState(() {
      _moduleIds = moduleIdsSet.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un enseignant'),
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
              _buildModuleDropdown(),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _ajouterEnseignant,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 74, 74, 253),
                    textStyle: TextStyle(
                      fontSize: 30,
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

  Widget _buildModuleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedModuleId,
      hint: Text('Sélectionner un module'),
      items: _moduleIds.map((String moduleId) {
        return DropdownMenuItem<String>(
          value: moduleId,
          child: Text(moduleId),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedModuleId = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner un module';
        }
        return null;
      },
    );
  }

  Future<void> _ajouterEnseignant() async {
    if (_formKey.currentState!.validate()) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _motdepasseController.text,
        );

        await FirebaseAuth.instance.currentUser!.sendEmailVerification();

        // Ajouter l'enseignant à la collection 'enseignants'
        await FirebaseFirestore.instance
            .collection('enseignants')
            .doc(credential.user!.uid)
            .set({
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'dateNaissance': _dateNaissanceController.text,
          'email': _emailController.text,
          'numTelephone': _numTelephoneController.text,
          'moduleId': _selectedModuleId,
          'role': 'enseignant',
        });

        // Ajouter l'enseignant à la collection 'users'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'email': _emailController.text,
          'role': 'enseignant',
        });

        // Ajouter l'enseignant à la collection 'enseignantModule'
        await FirebaseFirestore.instance
            .collection('enseignantModule')
            .doc(credential.user!.uid)
            .set({
          'email': _emailController.text,
          'enseignant': _nomController.text + ' ' + _prenomController.text,
          'moduleId': _selectedModuleId,
        });

        Navigator.of(context).pushReplacementNamed('/listenseignants');
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







  /*Future<void> _ajouterEnseignant() async {
    if (_formKey.currentState!.validate()) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _motdepasseController.text,
        );

        await FirebaseAuth.instance.currentUser!.sendEmailVerification();

        await FirebaseFirestore.instance
            .collection('enseignants')
            .doc(credential.user!.uid)
            .set({
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'dateNaissance': _dateNaissanceController.text,
          'email': _emailController.text,
          'numTelephone': _numTelephoneController.text,
          'moduleId': _selectedModuleId,
          'role': 'enseignant',
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'email': _emailController.text,
          'role': 'enseignant',
        });

        Navigator.of(context).pushReplacementNamed('/listenseignants');
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
*/