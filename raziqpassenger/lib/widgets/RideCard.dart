import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raziqpassenger/widgets/PrimaryButton.dart';

import '../pages/detail.dart';

class RideCard extends StatelessWidget {
  const RideCard({super.key, required this.rideId, required this.myId});
  final String rideId;
  final String myId;
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> rideStream =
        FirebaseFirestore.instance.collection('Rides').doc(rideId).snapshots();

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

    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return DetailPage(myId: myId, rideId: rideId);
        }));
      },
      child: Card(
        margin: EdgeInsets.all(10),
        color: Colors.white,
        elevation: 8,
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

            if (ride != null) {
              final db = FirebaseFirestore.instance;
              final driver = db.collection("Users").doc(ride["driverId"]).get();
              print(driver);
              print("${ride?["fare"].split("M")}");
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ride["date"],
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(ride["time"],
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600, fontSize: 16))
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    FutureBuilder(
                      future: driver,
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
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

                        final userData = snapshot.data!.data();

                        print(userData);
                        if (userData != null) {
                          return ListTile(
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    userData["carModel"],
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                        color: Colors.black),
                                  ),
                                  Text(userData["carBrand"],
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Colors.black)),
                                ],
                              ),
                              title: Row(
                                children: [
                                  userData["gender"] == "Male"
                                      ? Icon(
                                          Icons.male,
                                          color: Colors.blue,
                                        )
                                      : userData["gender"] == "Female"
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
                                    "${userData["name"].split(" ")[0]}",
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
                                      "${userData["avgRating"].toStringAsFixed(1)}",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14))
                                ],
                              ),
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: CupertinoColors.systemGreen),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            userData["userImage"]))),
                              ));
                        } else {
                          return Text("No data");
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person),
                            Text(
                                "${ride["passengerCount"]}/${ride["carCapacity"]}",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 20,
                          child: VerticalDivider(
                            color: Colors.black,
                            thickness: 2,
                          ),
                        ),
                        Icon(Icons.directions_car),
                        SizedBox(
                          width: 5,
                        ),
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
                          child: Text(
                            ride["status"],
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold),
                          ),
                          decoration: BoxDecoration(
                              color: ride["status"] == "pending"
                                  ? CupertinoColors.systemYellow
                                  : CupertinoColors.systemGreen,
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        if (ride["cancelled"].contains(myId) == true)
                          Container(
                            padding: EdgeInsets.only(
                                right: 15, left: 15, top: 2, bottom: 2),
                            child: Text(
                              "Cancelled",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5)),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      color: Colors.grey.shade50,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [Text("")],
                            ),
                            Text(
                              "${ride["origin"].split(",")[0]}",
                              maxLines: 3,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.blue),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Icon(
                              CupertinoIcons.arrowtriangle_down_fill,
                              size: 20,
                              weight: 8,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${ride["destination"].split(",")[0]}",
                              maxLines: 3,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            Row(
                              children: [Text("")],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              ride["fare"],
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.systemGreen,
                                  fontSize: 24),
                            ),
                            Text(
                              "/seat",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                        if (ride["passengers"].contains(myId))
                          PrimaryButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return DetailPage(myId: myId, rideId: rideId);
                                }));
                              },
                              text: "View")
                        else if (ride["cancelled"].contains(myId))
                          PrimaryButton(
                              onPressed: () {
                                final price =
                                    int.parse(ride["fare"].split("M")[1]);
                                Join(context, price);
                              },
                              text: "Rejoin")
                        else
                          PrimaryButton(
                              onPressed: () {
                                final price =
                                    int.parse(ride["fare"].split("M")[1]);
                                Join(context, price);
                              },
                              text: "Join")
                      ],
                    )
                  ],
                ),
              );
            } else {
              return Text(
                "No data",
              );
            }
          },
        ),
      ),
    );
  }
}
