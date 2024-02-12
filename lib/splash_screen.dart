import 'package:flutter/material.dart';

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
         text: const TextSpan(
           style: TextStyle(
             fontSize: 24.0,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
           children: [
             TextSpan(text: "WELLCOME TO\n"),
             TextSpan(text: "FOODGRAM"),
           ]
         ),
       ),
      ),
    );
  }
}