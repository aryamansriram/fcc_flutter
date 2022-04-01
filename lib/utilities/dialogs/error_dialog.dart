
import 'package:fcc_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text
){
  return ShowGenericDialog<void>(context: context, title: "An error occurred", content: text, optionsBuilder: ()=>{
    'OK':null,

  });

}