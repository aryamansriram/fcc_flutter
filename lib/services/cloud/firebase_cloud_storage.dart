import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcc_app/services/cloud/cloud_note.dart';
import 'package:fcc_app/services/cloud/cloud_storage_constants.dart';
import 'package:fcc_app/services/cloud/cloud_storage_exceptions.dart';
import 'package:fcc_app/services/crud/crud_exceptions.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');


  Future<void> deleteNote({required String docId}) async{
    try{
      await notes.doc(docId).delete();
    }
    catch(e){
      throw CouldNotDeleteNotesException();
    }
  }



  Future<void> updateNote(
    {
      required String documentId,
      required String text
    }
  ) async {
    try{
      await notes.doc(documentId).update({textFieldName: text});
    }
    catch(_){
      throw CouldNotUpdateNotesException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
    notes.snapshots().map((event)=>event.docs.map(
      (doc)=>CloudNote.fromSnapshot(doc)
    ).where(
      (note)=>note.OwnerUserId == ownerUserId
    ));

  void createNewNote({required String ownerUserId}) async{
    await notes.add({
      ownerUserIdfieldname: ownerUserId,
      textFieldName: ''
    });
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserID}) async{

    try{

      return await notes.where(
        ownerUserIdfieldname, 
        isEqualTo: ownerUserID
      ).get()
      .then(
        (value) => value.docs.map(
          (doc){
        return CloudNote(documentId: doc.id, OwnerUserId: doc.data()[ownerUserIdfieldname] as String, text: doc.data()[textFieldName] as String);
      }));
      
    }
    catch(_){
      throw CouldNotGetAllNotesException();
    }

  }


  static final FirebaseCloudStorage _shared = 
  FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}