
import 'package:fcc_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog(BuildContext context){
  return ShowGenericDialog<bool>(context: context, title: 'Delete', content: 'Are your sure you want to delete this item?', optionsBuilder: ()=>{
    'Cancel': false,
    'Yes': true
  }).then((value) => value ?? false);
}