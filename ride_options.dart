import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_n_meal_app/home_page.dart';
import 'package:share_n_meal_app/ride_driver_main_page.dart';

class RideOptions extends StatelessWidget {
  const RideOptions({Key? key}) : super(key: key);

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
            Text('Select a Choice',
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
                          builder: (context) => RideDriverMainPage(),)
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 40,
                        ),
                        SizedBox(
                            height: 10
                        ),
                        Text(
                          "Driver",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 160,
                  width: 160,
                  child: ElevatedButton(
                    onPressed: (){
                      //on press action
                    },
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
                          size: 40,
                        ),
                        SizedBox(
                            height: 10
                        ),
                        Text("Passenger",
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
