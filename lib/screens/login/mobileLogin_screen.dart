import 'package:flutter/material.dart';
import 'package:memorize/style/colors.dart';
import 'package:memorize/provider/mobileAuth_provider.dart';
import 'package:memorize/widgets/custom_widgets.dart';
import 'package:provider/provider.dart';

import '../../style/designSystem.dart'; // Import your custom widget

class LoginWithPhone extends StatefulWidget {
  const LoginWithPhone({Key? key}) : super(key: key);

  @override
  _LoginWithPhoneState createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {
  TextEditingController phoneController = TextEditingController(text: "+43");
  TextEditingController otpController = TextEditingController();
  bool enableCodeField = false;

  @override
  void initState() {
    super.initState();
    Provider.of<MobileAuth>(context, listen: false).initialize();
  }
  submitFunction() {
    final mobileAuth = Provider.of<MobileAuth>(context, listen: false);
    if (mobileAuth.otpVisibility) {
      mobileAuth.verifyOTP(otpController.text, context);
    } else {
      mobileAuth.loginWithPhone(phoneController.text);
    }
  }



  @override
  Widget build(BuildContext context) {
    final mobileAuth = Provider.of<MobileAuth>(context);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Login",
          style: DesignSystem.appBarTitle,
        ),
        backgroundColor: backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo/Logo.png',
                width: MediaQuery.of(context).size.width * 0.8, // 50% der Bildschirmbreite
              ),
              CustomTextField(hintText: 'Phone number', controller: phoneController),
              const SizedBox(
                height: 15,
              ),
                CustomTextField(hintText: 'Code', controller: otpController, enable: mobileAuth.otpVisibility ? true : false,),
              const SizedBox(
                height: 30,
              ),
              CustomButton(text: mobileAuth.otpVisibility ? "Verify" : "Login", onPressed: submitFunction,)
            ],
          ),
        ),
      ),
    );
  }
}
