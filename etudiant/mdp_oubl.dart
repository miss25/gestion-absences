import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text,
        );
        AwesomeDialog(
          context: context,
          animType: AnimType.rightSlide,
          dialogType: DialogType.success,
          title: 'Succès',
          desc:
              'Un e-mail de réinitialisation de mot de passe a été envoyé. Veuillez vérifier votre boîte de réception.',
        ).show();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          AwesomeDialog(
            context: context,
            animType: AnimType.rightSlide,
            dialogType: DialogType.error,
            title: 'Erreur',
            desc: "Aucun utilisateur trouvé pour cette adresse e-mail.",
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réinitialisation du mot de passe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entrez votre adresse e-mail pour réinitialiser votre mot de passe :',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Adresse e-mail',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse e-mail';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF191970), // Texte en blanc
                    textStyle: TextStyle(
                      fontSize: 18, // Taille de texte
                      fontWeight: FontWeight.bold, // Gras
                    ),
                  ),
                  child: Text('Réinitialiser le mot de passe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
