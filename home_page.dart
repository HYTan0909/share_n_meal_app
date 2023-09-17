import 'package:firebase_auth/firebase_auth.dart' // new
    hide EmailAuthProvider, PhoneAuthProvider;    // new
import 'package:flutter/material.dart';           // new
import 'package:provider/provider.dart';          // new

import 'app_state.dart';                          // new
import 'src/authentication.dart';                 // new
import 'src/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
              width: 200,
              height: 400,
              child: Image.asset('assets/colleges.png')
          ),
          const SizedBox(height: 8),
          // Add from here
          Consumer<ApplicationState>(
            builder: (context, appState, _) => AuthFunc(
                loggedIn: appState.loggedIn,
                signOut: () {
                  FirebaseAuth.instance.signOut();
                }),
          ),
          // to here
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          const Header("What is Share N Meal?"),
          const Paragraph(
            'Share & enhance your college experience!',
          ),
        ],
      ),
    );
  }
}