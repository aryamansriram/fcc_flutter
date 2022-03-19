import 'package:fcc_app/constants/routes.dart';
import 'package:fcc_app/firebase_options.dart';
import 'package:fcc_app/utilities/show_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({ Key? key }) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

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
      appBar: AppBar(title: const Text('Register') ),
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
                      
                      
            
                      //print("Email: $email");
                      try{
                          final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email, 
                        password: password
                        );
                        final user = FirebaseAuth.instance.currentUser;
                        await  user?.sendEmailVerification();
                        Navigator.of(context).pushNamed(verifyEmailRoute);
                      }
                      on FirebaseAuthException catch(e){
                        if(e.code=="weak-password"){
                          
                          await showErrorDialog(context, "Password is weak");
    
                        }
                        else if(e.code=="email-already-in-use"){
                          
                          await showErrorDialog(context, 'Email already in use');
                        }
                        else if(e.code=="invalid-email"){
                          await showErrorDialog(context, 'Invalid use');
                        }
                        else{
                          await showErrorDialog(context, 'Error: ${e.code}');
                        }
                      }
                      catch(e){
                        await showErrorDialog(context, e.toString());
                      }
                      
                    },
                    child: Text("Register"),
                    ),
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }, 
                  child: const Text('Registered? Go back and login')
                  )
                ],
              ),
    );

  }
}



