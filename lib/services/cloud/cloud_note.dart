
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fcc_app/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String OwnerUserId;
  final String text;

  const CloudNote({
    required this.documentId, 
    required this.OwnerUserId, 
    required this.text
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String,dynamic>> snapshot)
  : documentId = snapshot.id,
    OwnerUserId = snapshot.data()[ownerUserIdfieldname],
    text = snapshot.data()[textFieldName] as String;
  


}