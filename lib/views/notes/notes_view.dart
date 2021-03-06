import 'package:fcc_app/services/auth/auth_service.dart';
import 'package:fcc_app/services/cloud/cloud_note.dart';
import 'package:fcc_app/services/cloud/firebase_cloud_storage.dart';
import 'package:fcc_app/utilities/dialogs/logout_dialog.dart';
import 'package:fcc_app/views/notes/notes_list_view.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../constants/routes.dart';
import '../../enums/menu_action.dart';


class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    //_notesService.open();
    super.initState();
  }


  @override
  void dispose() {
    
    //_notesService.close();
    developer.log("Closing notes service");
    super.dispose();
  }

  //21:46
   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
          },
          icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: MenuAction.logout,
                  child: const Text('Logout'),
                )
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
            stream: _notesService.allNotes(ownerUserId: userId),
            builder: (context,snapshot){
              switch(snapshot.connectionState){

                case ConnectionState.waiting:
                  
                case ConnectionState.active:
                  if (snapshot.hasData){
                    
                    final allNotes = snapshot.data as Iterable<CloudNote>;
                    return NotesListView(
                      notes: allNotes, 
                      onDeleteNote: (note) async{
                        await _notesService.deleteNote(docId: note.documentId);
                    },onTap: (note) {
                        Navigator.of(context).pushNamed(createOrUpdateNoteRoute,arguments: note);
                    },);
                    
                  }
                  else{
                    return CircularProgressIndicator();
                  }
                  
                default:
                  return CircularProgressIndicator();
              }
            
                
              },
              )

    );
  }
}

