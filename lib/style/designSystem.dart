import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memorize/style/colors.dart';

class DesignSystem {
  DesignSystem._();
 //AppBar
  static TextStyle appBarTitle = GoogleFonts.openSans(
    textStyle: const TextStyle(
      fontSize: 24,
      color: whiteColor,
      fontWeight: FontWeight.bold,
    ),
  );

  static TextStyle header1 = GoogleFonts.openSans(
    textStyle: const TextStyle(
      fontSize: 24,
      color: whiteColor,
      fontWeight: FontWeight.bold,
    ),
  );

  static TextStyle header2 = GoogleFonts.openSans(
    textStyle: const TextStyle(
      fontSize: 20,
      color: whiteColor,
      fontWeight: FontWeight.bold,
    ),
  );

  static TextStyle header3 = GoogleFonts.openSans(
    textStyle: const TextStyle(
      fontSize: 16,
      color: whiteColor,
      fontWeight: FontWeight.bold,
    ),
  );

  //Button

  static TextStyle buttonText = GoogleFonts.openSans(
    textStyle: const TextStyle(
      fontSize: 16,
      color: blackColor,
      fontWeight: FontWeight.bold,
    ),
  );

  static TextStyle showAllButton = GoogleFonts.openSans(
    textStyle: const TextStyle(
      fontSize: 12,
      color: mainColor,
      fontWeight: FontWeight.bold,
    ),
  );


  static TextStyle lable = GoogleFonts.openSans(
    textStyle: const TextStyle(
      fontSize: 16,
      color: whiteColor,
      fontWeight: FontWeight.normal,
    ),
  );

  static TextStyle memberCount = GoogleFonts.openSans(
    textStyle: const TextStyle(
      fontSize: 12,
      color: whiteColor,
      fontWeight: FontWeight.bold,
    ),
  );
}




class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool? enable;
  final bool isError;  // Neu: Fehlerstatus
  final String errorText;  // Neu: Fehlertext

  CustomTextField({
    Key? key,
    required this.hintText,
    this.controller,
    this.enable,
    this.isError = false,  // Standardwert: false
    this.errorText = '',  // Standardwert: leerer String
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$hintText:",
            ),
            SizedBox(height: 5,),
            TextField(
              controller: controller,
              enabled: enable,
              style: TextStyle(height: 1.5, color: mainColor),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: isError ? Colors.red : mainColor,  // Farbe ändern, wenn isError true ist
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: isError ? Colors.red : mainColor,  // Farbe ändern, wenn isError true ist
                    width: 2.0,
                  ),
                ),
                fillColor: isError ? Colors.red.withOpacity(0.3) : mainColor.withOpacity(0.3),  // Hintergrundfarbe ändern, wenn isError true ist
                filled: true,  // Hintergrundfarbe aktivieren
                contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
              ),
            ),
            if (isError)  // Neu: Bedingung für die Anzeige des Fehlertexts
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorText,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomTextArea extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool? enable;

  CustomTextArea({Key? key, required this.hintText, this.controller, this.enable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$hintText:",
              style: DesignSystem.lable,
            ),
            SizedBox(height: 5,),
            TextFormField(
              controller: controller,
              enabled: enable,
              maxLines: 5,
              style: TextStyle(height: 1.5, color: whiteColor),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: whiteColor,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: mainColor,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

