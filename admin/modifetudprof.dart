import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStudentPage extends StatefulWidget {
  final String docId;

  EditStudentPage({required this.docId});

  @override
  _EditStudentPageState createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _dateNaissanceController;
  late TextEditingController _groupeController;
  late TextEditingController _AnneeUnivController;
  late TextEditingController _specialiteController;
  late TextEditingController _emailController;
  late TextEditingController _numTelephoneController;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('etudiants')
        .doc(widget.docId)
        .get();

    var data = doc.data() as Map<String, dynamic>;

    setState(() {
      _nomController = TextEditingController(text: data['nom']);
      _prenomController = TextEditingController(text: data['prenom']);
      _dateNaissanceController =
          TextEditingController(text: data['dateNaissance']);
      _groupeController = TextEditingController(text: data['groupe']);
      _AnneeUnivController =
          TextEditingController(text: data['anneeUniversitaire']);
      _specialiteController = TextEditingController(text: data['specialite']);
      _emailController = TextEditingController(text: data['email']);
      _numTelephoneController =
          TextEditingController(text: data['numTelephone']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier étudiant'),
      ),
      body: _nomController == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(
                        _nomController, 'Nom', 'Veuillez entrer le nom'),
                    _buildTextField(_prenomController, 'Prénom',
                        'Veuillez entrer le prénom'),
                    _buildTextField(
                        _dateNaissanceController,
                        'Date de naissance',
                        'Veuillez entrer la date de naissance',
                        keyboardType: TextInputType.datetime),
                    _buildTextField(_groupeController, 'Groupe',
                        'Veuillez entrer le groupe'),
                    _buildTextField(_AnneeUnivController, 'Annéé Universitaire',
                        'Veuillez entrer l\'année'),
                    _buildTextField(_specialiteController, 'Specialité',
                        'Veuillez entrer la spécialité'),
                    _buildTextField(_emailController, 'Email',
                        'Veuillez entrer un email valide',
                        keyboardType: TextInputType.emailAddress),
                    _buildTextField(
                        _numTelephoneController,
                        'Numéro de téléphone',
                        'Veuillez entrer le numéro de téléphone',
                        keyboardType: TextInputType.phone),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateStudent,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 74, 74, 253),
                          textStyle: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          minimumSize: Size(100, 50),
                        ),
                        child: Text('Mettre à jour'),
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

  Future<void> _updateStudent() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(widget.docId)
          .update({
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'dateNaissance': _dateNaissanceController.text,
        'groupe': _groupeController.text,
        'anneeUniversitaire': _AnneeUnivController.text,
        'specialite': _specialiteController.text,
        'email': _emailController.text,
        'numTelephone': _numTelephoneController.text,
      });

      Navigator.of(context).pop();
    }
  }
}
