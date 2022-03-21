
import 'package:fcc_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fcc_app/constants/routes.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({ Key? key }) : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(
          children: [
            Text("We've sent you an email verification, please open it to verify your account."),
            Text("If you haven't recieved verification press the button below"),
            TextButton(onPressed: () async{
              final user = AuthService.firebase().currentUser;
              await AuthService.firebase().sendEmailVerification();
            }, 
            child: const Text('Send EMail verification')
            ),
            TextButton(
              onPressed: () async {
                await AuthService.firebase().logOut();
                Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
              }, 
              child: Text('Restart')
              )
          ],
        ),
    );
   
}
}