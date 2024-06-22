import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'admin/acceuilad.dart';
import 'chef departement/acceuilch.dart';
import 'enseignant/acceuilenseign.dart';
import 'etudiant/profil.dart';
import 'etudiant/mdp_oubl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motdepasseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school,
                      size: 120.0,
                      color: Colors.black,
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Text(
                  'Bienvenue',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20.0),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.mail,
                  isPassword: false,
                ),
                SizedBox(height: 20.0),
                _buildTextField(
                  controller: _motdepasseController,
                  label: 'Mot de passe',
                  icon: Icons.lock,
                  isPassword: true,
                ),
                SizedBox(height: 20.0),
                _buildLoginButton(context),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPasswordPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 50.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType:
          isPassword ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await _loginUser(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        'Se connecter',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Future<void> _loginUser(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _motdepasseController.text.trim();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        if (credential.user!.emailVerified) {
          String role = await getUserRoleFromFirestore(credential.user!.uid);
          print('Rôle utilisateur récupéré: $role');

          // Autorisations basées sur le rôle
          if (role == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AdminHomePage(),
              ),
            );
          } else if (role == 'enseignant') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EnseignantHomePage(),
              ),
            );
          } else if (role == 'chef') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ChefDepartmentHomePage(),
              ),
            );
          } else if (role == 'etudiant') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return StudentProfilePage();
                },
              ),
            );
          } else {
            print('Rôle inconnu ou non autorisé');
            AwesomeDialog(
              context: context,
              animType: AnimType.rightSlide,
              dialogType: DialogType.error,
              title: 'Erreur',
              desc: "Rôle inconnu ou non autorisé",
            ).show();
          }
        } else {
          await FirebaseAuth.instance.currentUser!.sendEmailVerification();
          AwesomeDialog(
            context: context,
            animType: AnimType.rightSlide,
            dialogType: DialogType.info,
            title: "Erreur",
            desc: "Vérifiez votre e-mail ! Confirmez votre compte.",
          ).show();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        AwesomeDialog(
          context: context,
          animType: AnimType.rightSlide,
          dialogType: DialogType.error,
          title: 'Erreur',
          desc: "Cet utilisateur n'existe pas",
        ).show();
      } else if (e.code == 'wrong-password') {
        AwesomeDialog(
          context: context,
          animType: AnimType.rightSlide,
          dialogType: DialogType.error,
          title: 'Erreur',
          desc: "Mot de passe incorrect",
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          animType: AnimType.rightSlide,
          dialogType: DialogType.error,
          title: 'Erreur',
          desc: e.message ?? 'Une erreur est survenue',
        ).show();
      }
    }
  }

  Future<String> getUserRoleFromFirestore(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc['role'];
      } else {
        throw Exception("User document not found");
      }
    } catch (e) {
      print('Erreur lors de la récupération du rôle utilisateur: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getStudentData(String userId) async {
    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(userId)
          .get();
      if (studentDoc.exists) {
        return studentDoc.data()!;
      } else {
        throw Exception("Student document not found");
      }
    } catch (e) {
      print('Erreur lors de la récupération des données de l\'étudiant: $e');
      throw e;
    }
  }
}
