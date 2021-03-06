import 'dart:async';

import 'package:flutter/material.dart';

import '../bloc/bloc.dart';

/// Screen with the logo. Is displayed when the app is openend.
///
/// Redirects to the next appropriate screen.
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 400), () {
      final bloc = Bloc.of(context);
      String targetRoute;

      if (!bloc.hasAccount) {
        targetRoute = '/intro';
      } else if (bloc.hasCurrentGame) {
        targetRoute = '/game';
      } else {
        targetRoute = '/setup';
      }

      Navigator.pushReplacementNamed(context, targetRoute);
    });
  }

  @override
  Widget build(BuildContext context) => Container(color: Colors.white);
}
