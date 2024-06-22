import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

class JustificationAbsencePage extends StatefulWidget {
  @override
  _JustificationAbsencePageState createState() =>
      _JustificationAbsencePageState();
}

class _JustificationAbsencePageState extends State<JustificationAbsencePage> {
  XFile? _imageFile;
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = user?.uid;
    });
  }

  Future<void> _getImage() async {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _imageFile = pickedImage;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  Future<Map<String, String>> _getUserInfo() async {
    if (userId != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(userId)
          .get();

      if (doc.exists) {
        return {
          'nom': doc['nom'],
          'prenom': doc['prenom'],
          'groupe': doc['groupe'],
          'specialite': doc['specialite'],
        };
      } else {
        print('Document utilisateur non trouvé');
      }
    } else {
      print('Utilisateur non authentifié');
    }
    return {};
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null &&
        _reasonController.text.isNotEmpty &&
        _selectedDate != null &&
        _selectedTime != null) {
      try {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('justifications/${DateTime.now().millisecondsSinceEpoch}');

        UploadTask uploadTask;
        if (kIsWeb) {
          uploadTask =
              storageReference.putData(await _imageFile!.readAsBytes());
        } else {
          uploadTask = storageReference.putFile(File(_imageFile!.path));
        }

        await uploadTask.whenComplete(() => print('Image uploaded'));

        String downloadURL = await storageReference.getDownloadURL();
        print('Download URL: $downloadURL');

        // Obtenir les informations de l'utilisateur
        Map<String, String> userInfo = await _getUserInfo();

        if (userInfo.isNotEmpty) {
          print('User info: $userInfo');

          // Formater la date et l'heure
          String formattedDate =
              "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}";
          String formattedTime =
              "${_selectedTime!.hour}:${_selectedTime!.minute}";

          // Ajoutez les informations de justification dans Firestore
          await FirebaseFirestore.instance.collection('justifications').add({
            'userId': userId,
            'imageUrl': downloadURL,
            'timestamp': Timestamp.now(),
            'nom': userInfo['nom'],
            'prenom': userInfo['prenom'],
            'groupe': userInfo['groupe'],
            'specialite': userInfo['specialite'],
            'raison': _reasonController.text,
            'heure': formattedTime,
            'jour': formattedDate,
            'status': 'en attente', // Initialiser le statut à 'en attente'
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Justification envoyée avec succès')),
          );
        } else {
          print('Informations utilisateur non trouvées');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Erreur lors de l\'obtention des informations de l\'utilisateur')),
          );
        }
      } catch (e) {
        print('Erreur lors de l\'envoi de la justification: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de l\'envoi de la justification')),
        );
      }
    } else {
      print(
          'Aucune image sélectionnée, raison non spécifiée, ou date/heure non sélectionnée');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Aucune image sélectionnée, raison non spécifiée, ou date/heure non sélectionnée')),
      );
    }
  }

  Widget _buildJustificationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('justifications')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucune justification trouvée.'));
        }

        final justifications = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: justifications.length,
          itemBuilder: (context, index) {
            final justification =
                justifications[index].data() as Map<String, dynamic>;
            final status = justification['status'];
            final date = justification['jour'];
            final time = justification['heure'];

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(justification['raison']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statut : $status'),
                    Text('Date : $date'),
                    Text('Heure : $time'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Justification d\'absence'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Raison de l\'absence',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _getImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Importer une image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_imageFile == null)
                Text('Aucune image sélectionnée')
              else
                Container(
                  width: 200,
                  height: 200,
                  child: kIsWeb
                      ? Image.network(_imageFile!.path)
                      : Image.file(File(_imageFile!.path)),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  style: TextStyle(color: Colors.white),
                  _selectedDate == null
                      ? 'Sélectionner la date'
                      : 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  style: TextStyle(color: Colors.white),
                  _selectedTime == null
                      ? 'Sélectionner l\'heure'
                      : 'Heure: ${_selectedTime!.hour}:${_selectedTime!.minute}',
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await _uploadImage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Envoyer la justification',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildJustificationList(),
            ],
          ),
        ),
      ),
    );
  }
}
