import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_absences_app/enseignant/mesgroupes.dart';
import 'consulterseanceenseign.dart';
import 'enseignprofil.dart';
import 'marqabs.dart';
import 'releverabs.dart';

class EnseignantHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil Enseignant'),
      ),
      backgroundColor: Color.fromARGB(255, 1, 98, 128),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCard(
              icon: Icons.groups,
              label: 'Mes Groupes',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeacherGroupsPage()),
                );
              },
            ),
            SizedBox(height: 15),
            _buildCard(
              icon: Icons.check_box,
              label: 'Marquer Absences',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MarquerAbsencesPage()),
                );
              },
            ),
            SizedBox(height: 15),
            _buildCard(
              icon: Icons.assignment,
              label: 'Relevés d\'absence',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListeAbsencesEnseignantPage(),
                  ),
                );
              },
            ),
            SizedBox(height: 15),
            _buildCard(
              icon: Icons.calendar_today,
              label: 'Consulter les séances',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListeSeancesPage()),
                );
              },
            ),
            SizedBox(height: 15),
            _buildCard(
              icon: Icons.person,
              label: 'Consulter le profil',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilEnseignantPage()),
                );
              },
            ),
            SizedBox(height: 70.0), // Affichez le numéro de téléphone ici
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    Color.fromARGB(255, 223, 10, 46), // Texte en blanc
                textStyle: TextStyle(
                  fontSize: 15, // Taille de texte
                ),
                minimumSize: Size(40, 40),
              ),
              icon: Icon(Icons.logout), // Icône de déconnexion
              label: Text('Déconnecter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(width: 16),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
