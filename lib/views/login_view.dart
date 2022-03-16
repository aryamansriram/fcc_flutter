import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fcc_app/firebase_options.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({ Key? key }) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();

}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Column(
                children: [
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter Email here'
                    ),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Enter your Password'
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      
            
                      final email = _email.text.trim();
                      final password = _password.text.trim();
                      
                      try{
    
                         final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email, 
                        password: password
                        );
                        //devtools.log(userCredential.toString());
                        Navigator.of(context)
                          .pushNamedAndRemoveUntil('/notes', (route) => false,);
                      
    
                      }
                      on FirebaseAuthException catch(e){
                          if (e.code=='user-not-found'){
                            devtools.log('User not found');
                          }
                          else if(e.code=='wrong-password') {
                            devtools.log("wrong password");
                          }
                      }
                      
                      //print("Email: $email");
            
                     
                    },
                    child: Text("Login"),
                    ),
                
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pushNamedAndRemoveUntil("/register", (route) => false);
                  }, 
                  child: const Text('Not registered yet? Register Now'))
                ],
              ),
    );
  }
}

