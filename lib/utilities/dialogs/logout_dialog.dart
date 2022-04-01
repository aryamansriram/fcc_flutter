
import 'package:fcc_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogoutDialog(BuildContext context){
  return ShowGenericDialog<bool>(context: context, title: 'Log Out', content: 'Are your sure you want to logout?', optionsBuilder: ()=>{
    'Cancel': false,
    'Logout': true
  }).then((value) => value ?? false);
}