import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/CustomTextField.dart';
import '../widgets/PrimaryButton.dart';
import '../widgets/SecondaryButton.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController icController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController carModelController = TextEditingController();
  TextEditingController carBrandController = TextEditingController();
  TextEditingController carCapacityController = TextEditingController();
  List<String> carSpecialFeatures = [];
  List<TextEditingController> carSpecialFeaturesController = [];

  Uint8List? userImage;
  Uint8List? carImage;

  String gender = "";

  String icErrorText = "";
  String nameErrorText = "";
  String passwordErrorText = "";
  String phoneErrorText = "";
  String emailErrorText = "";
  String addressErrorText = "";
  String carModelErrorText = "";
  String carBrandErrorText = "";
  String carCapacityErrorText = "";

  bool icValid = false;
  bool passwordValid = false;
  bool nameValid = false;
  bool genderValid = false;
  bool phoneValid = false;
  bool emailValid = false;
  bool addressValid = false;
  bool userImageValid = false;
  bool carImageValid = false;
  bool carModelValid = false;
  bool carBrandValid = false;
  bool carCapacityValid = false;

  bool hidePassword = true;

  int pageIndex = 0;

  void CheckIc(String ic, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "${ic}@passenger.cc", password: "123456");
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account with ic ${ic} already exists")));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Navigator.pop(context);
        pageIndex += 1;
        setState(() {});
      } else if (e.code == 'wrong-password') {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Account with ic ${ic} already exists")));
      }
    }
  }

  void PickUserImage(ImageSource source, BuildContext context) async {
    final imagePicker = ImagePicker();
    final chosenImage = await imagePicker.pickImage(source: source);
    if (chosenImage != null) {
      final imageData = await File(chosenImage.path).readAsBytes();
      userImage = imageData;
      userImageValid = true;
      Navigator.pop(context);
      setState(() {});
    }
  }

  void Register(
      String ic,
      String password,
      String name,
      String phone,
      String email,
      String address,
      String gender,
      Uint8List userImage,
      BuildContext context
      ) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: "${ic}@passenger.cc",
        password: password,
      )
          .then((value) async {
        final uid = value.user!.uid;
        final userRef = FirebaseStorage.instance
            .ref("/passenger/${uid}/profile/${DateTime.now()}.jpg");

        await userRef.putData(userImage);

        final userImageUrl = await userRef.getDownloadURL();

        final data = <String, dynamic>{
          "email": email,
          "gender": gender,
          "ic": ic,
          "name": name,
          "phone": phone,
          "role": "passenger",
          "userImage": userImageUrl,
          "totalSpendings":0,
          "address":address
        };
        final db = FirebaseFirestore.instance;
        db.collection("Users").doc("${uid}").set(data).then((value) {
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Center(child: Text("Registration successful, continue to login"))));
        });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Navigator.pop(context);
        print('The password provided is too weak.');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Center(child: Text("The password provided is too weak."))));
      } else if (e.code == 'email-already-in-use') {
        Navigator.pop(context);
        print('The account already exists for that email.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Center(child: Text("The account already exists for that email."))));
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Center(child: Text("${e.message}"))));
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Center(child: Text(e.toString()))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 30 / 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Register",
                          style: GoogleFonts.montserrat(
                              color: CupertinoColors.systemGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 35),
                        ),
                        Text(
                          "Create a new passenger account",
                          style: GoogleFonts.montserrat(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                  CustomTextField(
                      controller: icController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12)
                      ],
                      onChanged: (value) {
                        if (value.length < 12) {
                          icErrorText = "Please enter a valid IC number";
                          icValid = false;
                        } else {
                          icErrorText = "";
                          icValid = true;
                        }
                        setState(() {});
                      },
                      hintText: "IC Number",
                      errorText: icErrorText),
                  SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      inputFormatters: [],
                      obscureText: hidePassword,
                      onChanged: (value) {
                        if (value.length < 6) {
                          passwordErrorText =
                          "Password length must not be less than 6";
                          passwordValid = false;
                        } else {
                          passwordErrorText = "";
                          passwordValid = true;
                        }
                        setState(() {});
                      },
                      suffixIcon: IconButton(
                          onPressed: () {
                            hidePassword = !hidePassword;
                            setState(() {});
                          },
                          icon: hidePassword == true
                              ? Icon(CupertinoIcons.eye_slash_fill)
                              : Icon(CupertinoIcons.eye_solid)),
                      hintText: "Password",
                      errorText: passwordErrorText),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: PrimaryButton(
                              onPressed: (icValid == true && passwordValid == true)
                                  ? () {
                                CheckIc(icController.text, context);
                              }
                                  : null,
                              text: "Register")),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Divider(color: Colors.grey, thickness: 2),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white),
                        child: Text(
                          "Or",
                          style: GoogleFonts.montserrat(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Login with an existing account",
                        style: GoogleFonts.montserrat(
                            color: CupertinoColors.systemGreen,
                            fontWeight: FontWeight.bold),
                      ))
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text("Complete Personal Details", style: GoogleFonts.montserrat(
                    fontSize: 19, fontWeight: FontWeight.bold
                  ),),
                  SizedBox(
                    height: 40,
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
                                              PickUserImage(ImageSource.camera, context);
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
                                              PickUserImage(ImageSource.gallery, context);
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
                        children: userImage == null
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
                          image: userImage != null
                              ? DecorationImage(
                              fit: BoxFit.cover, image: MemoryImage(userImage!))
                              : null),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Profile Picture"),
                  if (userImage == null)
                    Text(
                      "(Please choose a profile picture)",
                      style: GoogleFonts.montserrat(color: Colors.red),
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
                  RadioListTile(
                      activeColor: CupertinoColors.systemGreen,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text("Male"),
                      value: "Male",
                      groupValue: gender,
                      onChanged: (value) {
                        if (value != null) {
                          gender = value;
                          genderValid = true;
                        }
                        setState(() {});
                      }),
                  RadioListTile(
                      activeColor: CupertinoColors.systemGreen,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text("Female"),
                      value: "Female",
                      groupValue: gender,
                      onChanged: (value) {
                        if (value != null) {
                          gender = value;
                          genderValid = true;
                        }
                        setState(() {});
                      }),
                  RadioListTile(
                      activeColor: CupertinoColors.systemGreen,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text("Other"),
                      value: "Other",
                      groupValue: gender,
                      onChanged: (value) {
                        if (value != null) {
                          gender = value;
                          genderValid = true;
                        }
                        setState(() {});
                      }),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SecondaryButton(
                          onPressed: () {
                            pageIndex -= 1;
                            setState(() {});
                          },
                          text: "Back"),
                      PrimaryButton(
                          onPressed: (nameValid == true &&
                              emailValid == true &&
                              phoneValid == true &&
                              addressValid == true &&
                              genderValid == true&&userImageValid==true)
                              ? () {
                            Register(icController.text, passwordController.text, nameController.text, phoneController.text, emailController.text, addressController.text, gender, userImage!, context);
                          }
                              : null,
                          text: "Register"),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ][pageIndex],
          )),
    );
  }
}
