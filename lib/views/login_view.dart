import 'package:fcc_app/constants/routes.dart';
import 'package:fcc_app/services/auth/auth_exceptions.dart';
import 'package:fcc_app/services/auth/auth_service.dart';
import 'package:fcc_app/utilities/show_error_dialog.dart';
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
    
                         final userCredential = await AuthService.firebase().logIn(email: email, password: password);

                        final user =  AuthService.firebase().currentUser;
                        if (user?.isEmailVerified ?? false){
                          Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                        }
                        else{
                          Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
                        }
                        //devtools.log(userCredential.toString());
                        Navigator.of(context)
                          .pushNamedAndRemoveUntil(notesRoute, (route) => false,);
                      
    
                      } on UserNotFoundException catch(_){
                          await showErrorDialog(context, 'User not found');
                      }
                      on WrongPasswordAuthException catch(_){
                        await showErrorDialog(context, 'Wrong Password');
                      }
                      on GenericAuthExceptions catch(_){
                        await showErrorDialog(context, 'Auth Error');

                      }
                      
                     
                    },
                    child: Text("Login"),
                    ),
                
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                  }, 
                  child: const Text('Not registered yet? Register Now'))
                ],
              ),
    );
  }
}

