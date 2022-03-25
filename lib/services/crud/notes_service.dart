import 'dart:async';

import 'package:fcc_app/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

//20:23

class NotesService{

  List<DatabaseNote> _notes = [];

  final  _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Database? _db;
  

  static final NotesService _shared = NotesService._shared_instance();
  NotesService._shared_instance();
  factory NotesService() => _shared;


  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }



  Database _getDatabaseOrThrow() {
      final db = _db;
      if (db==null) {
        throw DatabaseIsNotOpenException();
      }
      else{
        return db;
      }
  }

  Future<void> close() async {
  final db = _db;
  if(db == null){
    throw DatabaseIsNotOpenException();
  }
  else {
    await db.close();
    _db = null;
  }


}



  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
        //empty
    }
  }



  Future<void> open() async{
    if (_db != null){
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path,dbName);
      final db = await openDatabase(dbPath);
      _db = db;


      

      await db.execute(createUserTable);

      await db.execute(createNoteTable);

      await _cacheNotes();
      




    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException;
    }

  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = db.delete(userTable,where: 'email = ?',
                        whereArgs: [email.toLowerCase()]);
    if(deletedCount != 1){
        CouldNotDeleteUserException();
    }

  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,limit:1,where:'email=?',whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty){
      throw UserAlreadyExistsException();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email
    });


    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(userTable,limit:1,where:'email=?',whereArgs: [email.toLowerCase()]);

    if (results.isEmpty) {
      throw CouldNotFindUserException();
    }
    else{
      return DatabaseUser.fromRow(results.first);
    }

  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    
    
    // make sure owner exists and is the same one who is logged in
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner){
      throw CouldNotFindUserException();
    }

    const text='';
    // create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn:owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1
    });

    

    final note = DatabaseNote(id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);
    _notes.add(note);
    _notesStreamController.add(_notes);
    
    
    return note;

  }

   Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = db.delete(noteTable,where: 'id = ?',
                        whereArgs: [id]);
    if(deletedCount == 0){
        CouldNotDeleteNotesException();
    }
    else{
      _notes.removeWhere((element) => element.id==id);
      _notesStreamController.add(_notes);
    }

  }

   Future<int> deleteAllNotes() async {
     await _ensureDbIsOpen();
     final db = _getDatabaseOrThrow();
     
     final numberOfDeletions =  await db.delete(noteTable);
     _notes = [];
     _notesStreamController.add(_notes);
     return numberOfDeletions;
   }

  Future<DatabaseNote> getNote({required int id}) async{
      await _ensureDbIsOpen();
      final db = _getDatabaseOrThrow();
      final notes = await db.query(noteTable,limit:1,where:'id=?',whereArgs: [id]);
      if(notes.isEmpty){
        throw CouldNotFindNotesException();
      }
      else{
        
        final note =  DatabaseNote.fromRow(notes.first);
        _notes.removeWhere((note)=>note.id==id);
        _notes.add(note); 
        _notesStreamController.add(_notes);
        return note;
      }

  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
      final notes = await db.query(noteTable);

      final result = notes.map((n) => DatabaseNote.fromRow(n));
      
      return result;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    
    final updatesCount = await db.update(noteTable, {
      textColumn:text,
      isSyncedWithCloudColumn:0,
    });

    if (updatesCount == 0){
        throw CouldNotUpdateNotesException(); 
    }
    else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note)=>note.id== updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }

  }


  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    await _ensureDbIsOpen();
    try{
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUserException {
      final createdUser = createUser(email: email);
      return createdUser;
    } catch(_){
      rethrow;
    }
    
  }


}








@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String,Object?> map): id = map[idColumn] as int,email=map[emailColumn] as String;

  @override
  String toString() {
    return 'Person, ID= $id, email= $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id==other.id;

  @override
  
  int get hashCode => id.hashCode;


}

class DatabaseNote{
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({required this.id,required this.userId,
  required this.text,required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String,Object?> map): id = map[idColumn] as int,
  userId = map[userIdColumn] as int,
  text=map[textColumn] as String,
  isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int)==1 ? true:false;

  @override
  String toString() {
    // TODO: implement toString
    return 'Note, ID= $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';
  }

   @override
  bool operator ==(covariant DatabaseNote other) => id==other.id;

  @override
  int get hashCode => id.hashCode;


}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "userId";
const textColumn = "text";
const isSyncedWithCloudColumn = "isSyncedWithCloud"; 

const createUserTable = ''' 
      CREATE TABLE IF NOT EXISTS "User" (
	    "id"	INTEGER NOT NULL,
	    "email"	TEXT NOT NULL UNIQUE,
	    PRIMARY KEY("id" AUTOINCREMENT)
      );
      
      ''';


const createNoteTable = ''' 
      CREATE TABLE IF NOT EXISTS "note" (
	    "id"	INTEGER NOT NULL,
	    "userId"	INTEGER NOT NULL,
	    "text"	TEXT,
	    "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	    PRIMARY KEY("id" AUTOINCREMENT),
	    FOREIGN KEY("userId") REFERENCES "User"("id")
    );
      ''';

