import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/CustomTextField.dart';
import '../widgets/PrimaryButton.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.uid});
  final String uid;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  Uint8List? userImage;

  String gender = "";

  String nameErrorText = "";
  String phoneErrorText = "";
  String emailErrorText = "";
  String addressErrorText = "";

  bool nameValid = true;
  bool genderValid = true;
  bool phoneValid = true;
  bool emailValid = true;
  bool addressValid = true;
  bool userImageValid = true;

  String? imgUrl;
  int totalSpendings = 0;

  final Stream<QuerySnapshot<Map<String, dynamic>>> userStream =
      FirebaseFirestore.instance.collection('Users').snapshots();

  final db = FirebaseFirestore.instance;
  Map<String, dynamic> myData = {};

  void UploadPick(Uint8List image) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );
    final userRef = FirebaseStorage.instance
        .ref("/passenger/${widget.uid}/profile/${DateTime.now()}.jpg");
    await userRef.putData(image);

    final userImageUrl = await userRef.getDownloadURL();
    imgUrl = userImageUrl;
    setState(() {});
    Navigator.pop(context);
  }

  void PickUserImage(ImageSource source, BuildContext context) async {
    final imagePicker = ImagePicker();
    final chosenImage = await imagePicker.pickImage(source: source);
    if (chosenImage != null) {
      final imageData = await File(chosenImage.path).readAsBytes();
      userImage = imageData;
      userImageValid = true;
      Navigator.pop(context);
      UploadPick(imageData);
    }
  }

  void Save(
    BuildContext context,
    String name,
    String phone,
    String email,
    String address,
    String imageUrl,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    final db = FirebaseFirestore.instance;
    db.collection("Users").doc(widget.uid).update({
      "name": name,
      "phone": phone,
      "email": email,
      "address": address,
      "userImage": imageUrl
    }).then((value) {
      GetData();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(child: Text("Successfully updated your profile"))));
    });
  }

  void GetData() async {
    final data = await db.collection("Users").doc(widget.uid).get();

    final newData = data.data();
    myData = newData!;
    print(newData);
    print(widget.uid);
    nameController.text = newData["name"];
    emailController.text = newData["email"];
    phoneController.text = newData["phone"];
    addressController.text = newData["address"];
    gender = newData["gender"];
    imgUrl = newData["userImage"];
    totalSpendings = newData["totalSpendings"];
    print(myData);
    print("data");
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    GetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text("Profile",
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600, fontSize: 19)),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          alignment: Alignment.center,
                          title: Text("Choose upload method"),
                          actions: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                          onPressed: () {
                                            PickUserImage(
                                                ImageSource.camera, context);
                                          },
                                          text: "Camera"),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                          onPressed: () {
                                            PickUserImage(
                                                ImageSource.gallery, context);
                                          },
                                          text: "Gallery"),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 90,
                    height: 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imgUrl == null
                          ? [
                              Icon(
                                CupertinoIcons.camera_fill,
                                color: Colors.white,
                              ),
                              Text(
                                "Upload",
                                style:
                                    GoogleFonts.montserrat(color: Colors.white),
                              )
                            ]
                          : [],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        image: imgUrl != null
                            ? DecorationImage(
                                fit: BoxFit.cover, image: NetworkImage(imgUrl!))
                            : null),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: CupertinoColors.systemGreen,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.money_dollar,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "My Total Spendings",
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600),
                              ),SizedBox(
                                height: 20,
                              ),
                              Text("RM${totalSpendings}.00", style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold
                              ),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                CustomTextField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    inputFormatters: [],
                    onChanged: (value) {
                      if (value.length < 1) {
                        nameErrorText = "Name cannot be empty";
                        nameValid = false;
                      } else {
                        nameErrorText = "";
                        nameValid = true;
                      }
                      setState(() {});
                    },
                    hintText: "Name",
                    errorText: nameErrorText),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [],
                    onChanged: (value) {
                      final validator = EmailValidator.validate(value);
                      if (validator != true) {
                        emailErrorText = "Invalid email provided";
                      } else {
                        emailErrorText = "";
                      }
                      emailValid = validator;
                      setState(() {});
                    },
                    hintText: "Email Address",
                    errorText: emailErrorText),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12)
                    ],
                    onChanged: (value) {
                      if (value.length < 10) {
                        phoneErrorText = "Invalid phone number";
                        phoneValid = false;
                      } else {
                        phoneErrorText = "";
                        phoneValid = true;
                      }
                      setState(() {});
                    },
                    hintText: "Phone Number",
                    errorText: phoneErrorText),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                    maxLines: 3,
                    controller: addressController,
                    keyboardType: TextInputType.streetAddress,
                    inputFormatters: [],
                    onChanged: (value) {
                      if (value.length < 1) {
                        addressErrorText = "Address cannot be empty";
                        addressValid = false;
                      } else {
                        addressErrorText = "";
                        addressValid = true;
                      }
                      setState(() {});
                    },
                    hintText: "Address",
                    errorText: addressErrorText),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text("Gender",
                        style: GoogleFonts.montserrat(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 5,
                    ),
                    gender == ""
                        ? Text(
                            "(Please select a gender)",
                            style: GoogleFonts.montserrat(color: Colors.red),
                          )
                        : SizedBox()
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Card(
                  color: (gender == "Male")
                      ? Colors.blueAccent
                      : (gender == "Female")
                          ? Colors.pink
                          : Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        (gender == "Male")
                            ? Icon(
                                Icons.male,
                                color: Colors.white,
                              )
                            : (gender == "Female")
                                ? Icon(
                                    Icons.female,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.transgender,
                                    color: Colors.white,
                                  ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          gender,
                          style: GoogleFonts.montserrat(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                          onPressed: (nameValid == true &&
                                  emailValid == true &&
                                  phoneValid == true &&
                                  addressValid == true)
                              ? () {
                                  Save(
                                      context,
                                      nameController.text,
                                      phoneController.text,
                                      emailController.text,
                                      addressController.text,
                                      imgUrl!);
                                }
                              : null,
                          text: "Save"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ));
  }
}
