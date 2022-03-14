
import 'package:fcc_app/views/login_view.dart';
import 'package:fcc_app/views/register_view.dart';
import 'package:fcc_app/views/verify_email_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView()
      },
    ));
}


class HomePage extends StatelessWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: Firebase.initializeApp(
                    options:DefaultFirebaseOptions.currentPlatform
                  ),
          builder: (context, snapshot) {

            switch(snapshot.connectionState){
              case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                if (user!=null){
                  if (user.emailVerified){
                      print('Email is verified');
                  }
                  else {
                  return const VerifyEmail();
                  } 
                  
                }
                else{
                  return const LoginView();
                }
                
                return const Text('Done');


          default:
            return const Text("Loading....");
              
            }


            
          },
        );
  }
}

