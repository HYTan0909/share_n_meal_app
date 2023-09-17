import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_n_meal_app/home_page.dart';
import 'package:share_n_meal_app/meal_options.dart';
import 'package:share_n_meal_app/ride_options.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            Text('Choose Your Next Step',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 160,
                    width: 160,
                    child: ElevatedButton(
                        onPressed: (){
                          //on press action
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MealOptions()
                              )
                          );
                        },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        )
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dining,
                            size: 40,
                          ),
                          SizedBox(
                            height: 10
                          ),
                          Text(
                            "Meal",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 160,
                    width: 160,
                    child: ElevatedButton(
                      onPressed: (){
                        //on press action
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RideOptions()
                            )
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          )
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: 40,
                          ),
                          SizedBox(
                              height: 10
                          ),
                          Text("Ride",
                              style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
