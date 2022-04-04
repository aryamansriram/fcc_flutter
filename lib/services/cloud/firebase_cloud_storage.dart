import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcc_app/services/cloud/cloud_note.dart';
import 'package:fcc_app/services/cloud/cloud_storage_constants.dart';
import 'package:fcc_app/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');


  Future<void> deleteNote({required String docId}) async{
    try{
      await notes.doc(docId).delete();
    }
    catch(e){
      throw CouldNotDeleteNoteException();
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
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
    notes.snapshots().map((event)=>event.docs.map(
      (doc)=>CloudNote.fromSnapshot(doc)
    ).where(
      (note)=>note.OwnerUserId == ownerUserId
    ));

  Future<CloudNote> createNewNote({required String ownerUserId}) async{
    final document = await notes.add({
      ownerUserIdfieldname: ownerUserId,
      textFieldName: ''
    });

    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      OwnerUserId: ownerUserId,
      text: ''
    );
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
        return CloudNote.fromSnapshot(doc);
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