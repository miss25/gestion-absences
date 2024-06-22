import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestion_absences_app/admin/acceuilad.dart';
import 'admin/ajoutetud.dart';
import 'admin/chefdepad.dart';
import 'admin/enseignlist.dart';
import 'admin/enseignprofil.dart';
import 'admin/listetudad.dart';
import 'chef departement/acceuilch.dart';
import 'etudiant/profil.dart';
import 'Loginpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: "AIzaSyBqiDJST6o8ahUmhkSU_i6lt1ZKMKliXR8",
      authDomain: "flutter-gestion-absence-c1787.firebaseapp.com",
      databaseURL:
          "https://flutter-gestion-absence-c1787-default-rtdb.firebaseio.com",
      projectId: "flutter-gestion-absence-c1787",
      storageBucket: "flutter-gestion-absence-c1787.appspot.com",
      messagingSenderId: "476276546743",
      appId: "1:476276546743:web:ca478e4592673d9bd58132",
      measurementId: "G-WXMV6RFYB6",
      /*   apiKey: 'AIzaSyBqiDJST6o8ahUmhkSU_i6lt1ZKMKliXR8',
            appId: '1:476276546743:web:06498e9c86210bb8d58132',
            messagingSenderId: '476276546743',
            projectId: 'flutter-gestion-absence-c1787',
            storageBucket: 'flutter-gestion-absence-c1787.appspot.com'*/
    ));
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('_________________User is currently signed out!');
      } else {
        print('******************User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gestion d\'Absences',
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),
          '/ajouteretudiant': (context) => AjouterEtudiantPage(),
          '/profilchef': (context) => ChefDepartmentHomePage(),
          '/profilchefdepad': (context) => ChefDepartementPage(),
          '/profilenseignant': (context) => ProfilEnseignantPage(
                docId: '',
              ),
          '/listesetudiants': (context) => StudentListPage(),
          '/listenseignants': (context) => EnseignantListPage(),
          '/profiletudiant': (context) => StudentProfilePage(),
          '/profiladmin': (context) => AdminHomePage(),
        });
  }
}
