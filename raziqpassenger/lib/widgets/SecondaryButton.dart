import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(
      {super.key, required this.onPressed, required this.text});
  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: Text(text,style: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        color: CupertinoColors.systemGreen
    )), style: OutlinedButton.styleFrom(
        side: BorderSide(
            width: 3,
            color: CupertinoColors.systemGreen
        )
    ),);
  }
}
