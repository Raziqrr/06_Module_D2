import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raziqpassenger/pages/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/RideCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.uid});
  final String uid;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<String> statusCategories = ["pending", "completed"];
  bool cancelled = false;
  final Stream<QuerySnapshot> availableStream =
      FirebaseFirestore.instance.collection('Rides').snapshots();
  final Stream<QuerySnapshot> myStream =
      FirebaseFirestore.instance.collection('Rides').snapshots();
  final db = FirebaseFirestore.instance;
  late TabController tabController;


  String? imageUrl;

  void GetImage()async{
    final data = await db.collection("Users").doc(widget.uid).get();

    final newData = data.data();
    imageUrl = newData!["userImage"];
    setState(() {

    });
  }

  void Logout(BuildContext context) async {
    final _prefs = await SharedPreferences.getInstance();
    await _prefs.remove("ic");
    await _prefs.remove("password");
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    GetImage();
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = db.collection("Users").doc(widget.uid).get();

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.montserrat(
                  color: Colors.black, fontWeight: FontWeight.w600),
              dividerColor: Colors.blue,
              indicatorColor: Colors.blue,
              controller: tabController,
              tabs: [
                Tab(text: "Available rides"),
                Tab(
                  text: "My rides",
                )
              ]),
          leading: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) {
                  return ProfilePage(uid: widget.uid);
                }));
              },
              child: imageUrl!=null? Container(
                decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGreen),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(imageUrl!))),
              ):SizedBox(),
            ),
          ),
          elevation: 1,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
                onPressed: () {
                  Logout(context);
                },
                child: Text(
                  "Logout",
                  style: GoogleFonts.montserrat(
                      color: Colors.red, fontWeight: FontWeight.w600),
                ))
          ],
          title: Text(
            "Kongsi Kereta",
            style: GoogleFonts.montserrat(
                color: CupertinoColors.systemGreen,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: TabBarView(
            controller: tabController,
            children: [
              StreamBuilder(
                stream: availableStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: const Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: const CircularProgressIndicator());
                  }

                  final myRides = snapshot.data!.docs.where((doc) {
                    return (!doc["ratedBy"].contains(widget.uid) &&
                            !doc["passengers"].contains(widget.uid) &&
                            doc["status"] == "pending") &&
                        !doc["cancelled"].contains(widget.uid) &&
                        doc["passengerCount"] < doc["carCapacity"];
                  }).toList();

                  if (myRides != null) {
                    if (myRides.length == 0) {
                      return Center(child: Text("No rides at the moment"));
                    } else {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: myRides.length,
                              itemBuilder: (BuildContext context, int index) {
                                return RideCard(
                                  rideId: myRides[index].id,
                                  myId: widget.uid,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  } else {
                    return Center(child: Text("No Rides"));
                  }
                },
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RawChip(
                        labelPadding: EdgeInsets.only(right: 10, left: 10),
                        padding: EdgeInsets.zero,
                        side: BorderSide.none,
                        selected: statusCategories.contains("pending"),
                        label: Text(
                          "Pending",
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        backgroundColor: CupertinoColors.systemYellow,
                        selectedColor: CupertinoColors.systemYellow,
                        onPressed: () {
                          if (statusCategories.contains("pending")) {
                            statusCategories.remove("pending");
                          } else {
                            statusCategories.add("pending");
                          }
                          setState(() {});
                        },
                      ),
                      RawChip(
                        labelPadding: EdgeInsets.only(right: 10, left: 10),
                        padding: EdgeInsets.zero,
                        side: BorderSide.none,
                        selected: statusCategories.contains("completed"),
                        label: Text(
                          "Completed",
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        backgroundColor: CupertinoColors.systemGreen,
                        selectedColor: CupertinoColors.systemGreen,
                        onPressed: () {
                          if (statusCategories.contains("completed")) {
                            statusCategories.remove("completed");
                          } else {
                            statusCategories.add("completed");
                          }
                          setState(() {});
                        },
                      ),
                      RawChip(
                        labelPadding: EdgeInsets.only(right: 10, left: 10),
                        padding: EdgeInsets.zero,
                        side: BorderSide.none,
                        selected: cancelled,
                        label: Text(
                          "Cancelled",
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        backgroundColor: Colors.red,
                        selectedColor: Colors.red,
                        onPressed: () {
                          cancelled = !cancelled;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  StreamBuilder(
                    stream: myStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: const Text('Something went wrong'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: const CircularProgressIndicator());
                      }

                      final myRides = snapshot.data!.docs.where((doc) {
                        final status =
                            (statusCategories.contains(doc["status"]));
                        final cancelledStatus =
                            doc["cancelled"].contains(widget.uid) &&
                                cancelled == true;
                        final joined = doc["passengers"].contains(widget.uid);

                        return (joined && status) || cancelledStatus;
                      }).toList();

                      if (myRides != null) {
                        if (myRides.length == 0) {
                          return Center(child: Text("No rides at the moment"));
                        } else {
                          return Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: myRides.length,
                              itemBuilder: (BuildContext context, int index) {
                                return RideCard(
                                  rideId: myRides[index].id,
                                  myId: widget.uid,
                                );
                              },
                            ),
                          );
                        }
                      } else {
                        return Center(child: Text("No Rides"));
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
