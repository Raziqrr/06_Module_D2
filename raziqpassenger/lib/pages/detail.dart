import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/PrimaryButton.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.myId, required this.rideId});
  final String myId;
  final String rideId;

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> rideStream =
        FirebaseFirestore.instance.collection('Rides').doc(rideId).snapshots();
    final db = FirebaseFirestore.instance;
    final driverData = db.collection("Users").doc(myId).get();
    double myRating = 0;

    void Join(BuildContext context, int ridePrice) async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );
      final db = FirebaseFirestore.instance;
      final rideData =
          await db.collection("Rides").doc(rideId).get().then((value) {
        final docData = value.data();
        if (docData != null) {
          if (docData["cancelled"].contains(myId) == true) {
            db.collection("Rides").doc(rideId).update({
              "cancelled": FieldValue.arrayRemove([myId]),
              "passengers": FieldValue.arrayUnion([myId]),
              "passengerCount": FieldValue.increment(1)
            });
          } else {
            db.collection("Rides").doc(rideId).update({
              "passengers": FieldValue.arrayUnion([myId]),
              "passengerCount": FieldValue.increment(1),
            });
          }

          db
              .collection("Users")
              .doc(myId)
              .update({"totalSpendings": FieldValue.increment(ridePrice)});

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Center(child: Text("Successfully joined the ride"))));
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Center(child: Text("Failed to join ride"))));
        }
      });
    }

    void Rate(double rating, String driverId)async{
      final data = await db.collection("Users").doc(driverId).get().then((value){
        final newData = value.data();
        if (newData!=null) {
          print("d");
          print(newData);
          final currentRating = "${newData["avgRating"]}";
          final currentTotal = "${newData["ratingCount"]}";
          double cRating = double.parse(currentRating);
          double cTotal = double.parse(currentTotal);

          final newRating = ((cRating*cTotal)+rating)/(cTotal+1);
          print(newRating);
          print(cTotal);
          print(cRating);
          db.collection("Users").doc(driverId).update({
            "ratingCount":FieldValue.increment(1),"avgRating":newRating
          });
          db.collection("Rides").doc(rideId).update({
            "ratedBy":FieldValue.arrayUnion([myId])
          });
        }
      });
    }

    void Cancel(BuildContext context, int ridePrice) async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );
      final db = FirebaseFirestore.instance;
      final rideData =
          await db.collection("Rides").doc(rideId).get().then((value) {
        final docData = value.data();
        if (docData != null) {
          if (docData["cancelled"].contains(myId) == false) {
            db.collection("Rides").doc(rideId).update({
              "cancelled": FieldValue.arrayUnion([myId]),
              "passengers": FieldValue.arrayRemove([myId]),
              "passengerCount": FieldValue.increment(-1)
            });
          } else {
            db.collection("Rides").doc(rideId).update({
              "passengers": FieldValue.arrayRemove([myId]),
              "passengerCount": FieldValue.increment(-1),
            });
          }

          db
              .collection("Users")
              .doc(myId)
              .update({"totalSpendings": FieldValue.increment(-(ridePrice))});

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Center(child: Text("Successfully cancelled the ride"))));
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Center(child: Text("cancelled"))));
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Ride details",
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600, fontSize: 19)),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: rideStream,
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Center(child: const Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: const CircularProgressIndicator());
            }

            final ride = snapshot.data!.data();

            print(ride);

            if (ride != null) {
              print((ride["passengers"].contains(myId) &&
                  ride["status"] == "completed" &&
                  !ride["ratedBy"].contains(myId)));
              final myDriver =
                  db.collection("Users").doc(ride["driverId"]).get();
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 8,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(ride["date"],
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                Text(ride["time"],
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16))
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Text("${ride["duration"]} min",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600)),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("${ride["distance"]} km",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      right: 15, left: 15, top: 2, bottom: 2),
                                  child: Text(ride["status"],
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold)),
                                  decoration: BoxDecoration(
                                      color: ride["status"] == "pending"
                                          ? CupertinoColors.systemYellow
                                          : CupertinoColors.systemGreen,
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Divider(),
                            SizedBox(
                              height: 30,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${ride["origin"]}",
                                  maxLines: 4,
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "To",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "${ride["destination"]}",
                                  maxLines: 4,
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 20,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      elevation: 8,
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: FutureBuilder(
                            future: myDriver,
                            builder: (BuildContext context,
                                AsyncSnapshot<
                                        DocumentSnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: const Text('Something went wrong'));
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: const CircularProgressIndicator());
                              }

                              final myDriverData = snapshot.data!.data();

                              if (myDriverData != null) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text("Driver details",style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18
                                        )),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Row(
                                        children: [
                                          myDriverData["gender"] == "Male"
                                              ? Icon(
                                                  Icons.male,
                                                  color: Colors.blue,
                                                )
                                              : myDriverData["gender"] ==
                                                      "Female"
                                                  ? Icon(
                                                      Icons.female,
                                                      color: Colors.pink,
                                                    )
                                                  : Icon(
                                                      Icons.transgender,
                                                      color: Colors.grey,
                                                    ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            "${myDriverData["name"]}",
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16),
                                            overflow: TextOverflow.fade,
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                              "${myDriverData["avgRating"].toStringAsFixed(1)}",
                                              style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14))
                                        ],
                                      ),
                                      leading: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: CupertinoColors
                                                    .systemGreen),
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    myDriverData[
                                                        "userImage"]))),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.phone),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(myDriverData["phone"],
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.email),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(myDriverData["email"],
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    Divider(),SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [Text("Vehicle Details",style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                      ),)],
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: ClipRRect(
                                            child: Image.network(
                                                myDriverData["carImage"]),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          fit: FlexFit.loose,
                                          flex: 3,
                                        ),SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          child: Container(
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                        myDriverData["carModel"],
                                                        style: GoogleFonts.montserrat(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 19, color: Colors.white)),
                                                    Text(
                                                        myDriverData["carBrand"],style: GoogleFonts.montserrat(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16, color: Colors.white)),
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                ),
                                              ],
                                              mainAxisAlignment: MainAxisAlignment.center,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            padding: EdgeInsets.all(20),
                                          ),
                                          flex: 2,
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Row(
                                      children: [
                                        Text("Vehicle Special Features (${myDriverData["carSpecialFeatures"].length})", style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16
                                        ),),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ListView.builder(
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Card(
                                          color: Colors.blue,
                                          elevation: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                            child: Text(myDriverData[
                                                "carSpecialFeatures"][index], style: GoogleFonts.montserrat(
                                              color: Colors.white, fontWeight: FontWeight.w500
                                            ),),
                                          ),
                                        );
                                      },
                                      shrinkWrap: true,
                                      itemCount:
                                          myDriverData["carSpecialFeatures"]
                                              .length,
                                    ),
                                    SizedBox(height: 20,)
                                  ],
                                );
                              } else {
                                return Center(child: Text("No data found"));
                              }
                            },
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      elevation: 8,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Passengers (${ride["passengerCount"]}/${ride["carCapacity"]})",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                Row(
                                  children: [
                                    Text("${ride["fare"]}",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.systemGreen,
                                            fontSize: 16)),
                                    Text("/seat",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16))
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: ride["passengerCount"],
                              itemBuilder: (BuildContext context, int index) {
                                final passenger = ride["passengers"][index];
                                print(passenger);

                                final passengerGet =
                                    db.collection("Users").doc(passenger).get();
                                return FutureBuilder(
                                  future: passengerGet,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<
                                              DocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          snapshot) {
                                    if (snapshot.hasError) {
                                      return Center(
                                          child: const Text(
                                              'Something went wrong'));
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child:
                                              const CircularProgressIndicator());
                                    }
                                    final passengerData = snapshot.data!.data();

                                    if (passengerData != null) {
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        trailing:
                                            passengerData["gender"] == "Male"
                                                ? Icon(
                                                    Icons.male,
                                                    color: Colors.blue,
                                                  )
                                                : passengerData["gender"] ==
                                                        "Female"
                                                    ? Icon(
                                                        Icons.female,
                                                        color: Colors.pink,
                                                      )
                                                    : Icon(
                                                        Icons.transgender,
                                                        color: Colors.grey,
                                                      ),
                                        title: Text(passengerData["name"],
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16)),
                                        subtitle: Row(
                                          children: [
                                            Icon(Icons.phone),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(passengerData["phone"],
                                                style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16)),
                                          ],
                                        ),
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      passengerData[
                                                          "userImage"]))),
                                        ),
                                      );
                                    } else {
                                      return Center(child: Text("No data"));
                                    }
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (ride["status"] == "pending")
                      Row(
                        children: [
                          if (ride["passengers"].contains(myId) &&
                              ride["status"] == "completed" &&
                              !ride["ratedBy"].contains(myId))
                            Expanded(child: Text(""))
                          else if (ride["cancelled"].contains(myId))
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final price =
                                      int.parse(ride["fare"].split("M")[1]);
                                  Join(context, price);
                                },
                                child: Text(
                                  "Rejoin",
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        CupertinoColors.systemYellow),
                              ),
                            )
                          else if (ride["passengers"].contains(myId) &&
                              ride["status"] == "pending")
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final price =
                                      int.parse(ride["fare"].split("M")[1]);
                                  Cancel(context, price);
                                },
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                            )
                          else
                            Expanded(
                              child: PrimaryButton(
                                  onPressed: () {
                                    final price =
                                        int.parse(ride["fare"].split("M")[1]);
                                    Join(context, price);
                                  },
                                  text: "Join"),
                            ),
                        ],
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    (ride["passengers"].contains(myId) &&
                                ride["status"] == "completed" &&
                                !ride["ratedBy"].contains(myId) &&
                                !ride["cancelled"].contains(myId)) ==
                            true
                        ? Card(
                      elevation: 8,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  RatingBar.builder(
                                    itemCount: 5,
                                    initialRating: myRating,
                                    onRatingUpdate: (value) {
                                      myRating = value;
                                    },
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                      );
                                    },
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: PrimaryButton(
                                              onPressed: () {
                                                Rate(myRating, ride["driverId"]);
                                              }, text: "Rate")),
                                    ],
                                  )
                                ],
                              ),
                            ))
                        : Text(""),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text("No data"));
            }
          },
        ),
      ),
    );
  }
}
