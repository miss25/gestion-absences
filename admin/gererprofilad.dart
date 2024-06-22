import 'package:flutter/material.dart';

import 'profilad.dart';
import 'adminmodifprofil.dart';

class AdminProfilePage extends StatefulWidget {
  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Administrateur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConsultAdminProfilePage()),
                );
              },
              icon: Icon(Icons.person),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF191970), // Texte en blanc
                textStyle: TextStyle(
                  fontSize: 30, // Taille de texte
                  fontWeight: FontWeight.bold, // Gras
                ),
                minimumSize: Size(100, 50),
              ),
              label: Text('Consulter profil'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModifProfilPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    Color.fromARGB(255, 71, 71, 78), // Texte en blanc
                textStyle: TextStyle(
                  fontSize: 30, // Taille de texte
                  fontWeight: FontWeight.bold, // Gras
                ),
                minimumSize: Size(100, 50),
              ),
              icon: Icon(Icons.edit),
              label: Text('Modifier profil'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
