import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget{
  final Widget? child;
  const SplashScreen({super.key, this.child});
  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }

}

class _SplashScreenState extends State<SplashScreen>{
  @override
  void initState(){
    Future.delayed
      (const Duration(seconds: 3), (){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>widget.child!), (route) => false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return  Scaffold(
      backgroundColor: Colors.lightGreen,
      body: Center(
       child: RichText(
         textAlign: TextAlign.center,
         text: TextSpan(
             style: GoogleFonts.getFont('Euphoria Script',
               textStyle: const TextStyle(
                 fontSize: 70, // Adjust the font size as needed
                 fontWeight: FontWeight.bold,
                 color: Colors.white,
               ),
             ),
           children: const [
             TextSpan(text: "Wellcome to\n"),
             TextSpan(text: "Foodgram"),
           ]
         ),
       ),
      ),
    );
  }
}