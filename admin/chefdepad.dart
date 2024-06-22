import 'package:flutter/material.dart';

import 'chefdepmodifprofil.dart';
import '../chef departement/chefdepprofil.dart';

class ChefDepartement {
  final String nom;
  final String prenom;

  ChefDepartement(this.nom, this.prenom);
}

class ChefDepartementPage extends StatefulWidget {
  @override
  _ChefDepartementPageState createState() => _ChefDepartementPageState();
}

class _ChefDepartementPageState extends State<ChefDepartementPage> {
  List<ChefDepartement> chefs = [
    ChefDepartement('Chef', 'Département'),

    // Ajoutez d'autres chefs de département ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chef de département')),
      body: ListView.builder(
        itemCount: chefs.length,
        itemBuilder: (context, index) {
          final chef = chefs[index];
          return ListTile(
            title: Text('${chef.nom}  ${chef.prenom}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.visibility),
                  color: Colors.lightBlue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilChefDepartementPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterChefPage()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
