import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'absencelist.dart';
import 'chefdepprofil.dart';
import 'gerer seances/gererseances.dart';
import 'gerer specialites/specialités.dart';
import 'gererjustification.dart/gererjust.dart';
import 'gerer groupe/listgrp.dart';
import 'gerer module/moduleslistes.dart';

class ChefDepartmentHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil Chef Département'),
      ),
      backgroundColor: Color.fromARGB(255, 2, 3, 83),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                icon: Icons.school,
                label: 'Gérer les spécialités',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListeIDsSpecialitesPage()),
                  );
                },
              ),
              SizedBox(height: 10),
              _buildCard(
                icon: Icons.book,
                label: 'Gérer les modules',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ModulesPage()),
                  );
                },
              ),
              SizedBox(height: 10),
              _buildCard(
                icon: Icons.group,
                label: 'Gérer les groupes',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupesPage()),
                  );
                },
              ),
              SizedBox(height: 10),
              _buildCard(
                icon: Icons.calendar_today,
                label: 'Gérer les séances',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GlobalSeancesList()),
                  );
                },
              ),
              SizedBox(height: 10),
              _buildCard(
                icon: Icons.person,
                label: 'Consulter Absences',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListeAbsencesPage()),
                  );
                },
              ),
              SizedBox(height: 10),
              _buildCard(
                icon: Icons.check_circle,
                label: 'Gérer les justifications d\'absence',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AfficherJustificationsPage()),
                  );
                },
              ),
              SizedBox(height: 10),
              _buildCard(
                icon: Icons.person,
                label: 'Consulter le profil',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilChefDepartementPage()),
                  );
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 153, 21, 21),
                  textStyle: TextStyle(
                    fontSize: 15,
                  ),
                  minimumSize: Size(50, 50),
                ),
                icon: Icon(Icons.logout),
                label: Text('Déconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30),
              SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
