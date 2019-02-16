import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';
import '../widgets/theme.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  bool signingIn = false;

  Future<void> _signIn(SignInType type) async {
    setState(() => signingIn = true);

    try {
      await Bloc.of(context).signIn(type);
    } catch (e) { /* User aborted sign in or timeout (no internet). */ }
    setState(() { signingIn = false; });

    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EnterNameScreen()
    ));
  }

  Future<void> _signInWithGoogle() => _signIn(SignInType.google);
  Future<void> _signInAnonymously() => _signIn(SignInType.anonymous);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Spacer(),
          Container(
            height: 300,
            child: Placeholder(),
          ),
          SizedBox(height: 32),
          Text(
            "If you sign in, your games will be synchronized across all "
            "your devices.",
            textAlign: TextAlign.center,
            textScaleFactor: 1.2,
          ),
          SizedBox(height: 16),
          _buildGoogleButton(context),
          SizedBox(height: 16),
          Button(
            text: 'Sign in anonymously',
            isRaised: false,
            onPressed: _signInAnonymously,
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return MyTheme(
      data: MyTheme.of(context).copyWith(
        primaryButtonBackgroundColor: Colors.white,
        primaryButtonTextColor: Colors.red,
      ),
      child: Button(
        onPressed: _signInWithGoogle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SvgPicture.asset(
                'images/google_icon.svg',
                width: 36,
                height: 36,
                semanticsLabel: 'Google logo',
              ),
              SizedBox(width: 16),
              Text('Sign in with Google',
                textScaleFactor: 1.2,
                style: TextStyle(fontFamily: 'Signature')
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EnterNameScreen extends StatefulWidget {
  @override
  _EnterNameScreenState createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> with TickerProviderStateMixin {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = Bloc.of(context).name;
  }

  Future<void> _onNameEntered() async {
    final name = controller.text;
    await Bloc.of(context).createAccount(name);

    if (Bloc.of(context).isSignedIn) {
      await Navigator.of(context).pushNamedAndRemoveUntil('/setup', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Spacer(),
              Container(
                width: 200,
                height: 150,
                child: Placeholder(),
              ),
              Padding(
                padding: EdgeInsets.all(32),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter first and last name",
                  ),
                ),
              ),
              Button(
                text: "Continue",
                onPressed: _onNameEntered,
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Other players will be able to see it. To counter confusion "
                  "in large groups, it's recommended to enter both your first "
                  "and last name.",
                  textAlign: TextAlign.center,
                  textScaleFactor: 0.9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
