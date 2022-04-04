import 'package:fcc_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showCannotShareEmptyNotesDialog(BuildContext context){

  return ShowGenericDialog(
    context: context, 
    title: "Sharing", 
    content: "You cannot share an empty note", 
    optionsBuilder: ()=> {
      'OK':null
    });  


}