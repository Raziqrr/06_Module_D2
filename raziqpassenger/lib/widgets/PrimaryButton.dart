import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.onPressed, required this.text});
  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text, style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.white
      ),),
      style: ElevatedButton.styleFrom(
          backgroundColor: CupertinoColors.systemGreen
      ),
    );
  }
}
