import 'package:flutter/material.dart';
import 'package:memorize/screens/splash/splash_screen.dart';
import 'package:memorize/style/designSystem.dart';

import '../../style/colors.dart';
import '../../widgets/custom_widgets.dart';

class AlphaScreen extends StatefulWidget {
  const AlphaScreen({Key? key}) : super(key: key);

  @override
  State<AlphaScreen> createState() => _AlphaScreenState();
}

class _AlphaScreenState extends State<AlphaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
                child: Image.asset(
              'assets/images/logo/Logo.png',
              height: 300,
              width: 300,
            )),
            Icon(Icons.warning_rounded, color: mainColor, size: 50),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Diese App ist eine Testversion und dient ausschließlich zu Evaluierungszwecken. "
                      "Bitte beachten Sie, dass es sich um eine vorläufige Version in der Entwicklungsphase handelt. "
                      "Die App kann Fehler enthalten und bestimmte Funktionen möglicherweise nicht wie erwartet funktionieren. "
                      "Die Nutzung dieser Testversion ist nur autorisierten Personen gestattet. Jegliche unbefugte Nutzung oder Weitergabe von Zugangsdaten "
                      "ist strengstens untersagt. Wir übernehmen keine Haftung für eventuelle Schäden oder Verluste, die durch die Nutzung der Testversion "
                      "entstehen können. Durch Klicken auf den Continue-Button bestätigen Sie die Datenschutzbedingungen. Ihre Nutzung der App bestätigt, "
                      "dass Sie die vorläufige Natur dieser Version verstehen, sich dazu berechtigt fühlen und damit einverstanden sind.",
                  style: DesignSystem.memberCount,
                ),
              )
            ),
            SizedBox(height: 30),
            CustomButton(
              text: "Continue",
              onPressed: () async {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
