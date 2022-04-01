import 'package:fcc_app/constants/routes.dart';
import 'package:fcc_app/firebase_options.dart';
import 'package:fcc_app/services/auth/auth_exceptions.dart';
import 'package:fcc_app/services/auth/auth_service.dart';
import 'package:fcc_app/utilities/dialogs/error_dialog.dart';
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
                          final userCredential = await AuthService.firebase().createUser(
                        email: email, 
                        password: password
                        );
                        final user = AuthService.firebase().currentUser;
                        await  AuthService.firebase().sendEmailVerification();
                        Navigator.of(context).pushNamed(verifyEmailRoute);
                      }
                      on WeakPasswordAuthException catch(_){
                          await showErrorDialog(context, "Password is weak");
                      }
                      on EmailAlreadyInUseAuthException catch(_){
                          await showErrorDialog(context, 'Email already in use');
                      }
                      on InvalidEmailAuthException catch(_){
                          await showErrorDialog(context, 'Invalid use');
                      }
                      on GenericAuthExceptions catch(_){
                          await showErrorDialog(context, 'Auth Error');
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



