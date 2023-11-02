// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_n_meal_app/canteen_staff_dashboard.dart';
import 'package:share_n_meal_app/user_dashboard.dart';

import 'widgets.dart';

class AuthFunc extends StatelessWidget {
  const AuthFunc({
    super.key,
    required this.loggedIn,
    required this.signOut,
  });

  final bool loggedIn;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: StyledButton(
              onPressed: () {
                !loggedIn ? context.push('/sign-in') : signOut();
              },
              child: !loggedIn ? const Text('Login') : const Text('Logout')),
        ),
        Visibility(
          visible: loggedIn,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 32),
            child: StyledButton(
                onPressed: () {
                  context.push('/profile');
                },
                child: const Text('Profile')),
          ),
        ),
        Visibility(
            visible: loggedIn,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 32),
                child: StyledButton(
                  onPressed: () {
                    if(loggedIn) {
                      //check if canteen stuff is logged in
                      final user = FirebaseAuth.instance.currentUser;

                      if (user != null && user.email == 'canteenstaffs@gmail.com') {
                        //navigate to canteen stuffs dashboard
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CanteenStaffDashboard()
                            )
                        );
                      }
                      else {
                        //navigate to user dashboard
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserDashboard()
                            )
                        );
                      }
                    }
                  },
                  child: const Text('Dashboard'),
                )
            ),)
      ],
    );
  }
}
