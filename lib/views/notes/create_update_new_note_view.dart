import 'package:fcc_app/services/auth/auth_service.dart';
import 'package:fcc_app/services/crud/notes_service.dart';
import 'package:fcc_app/utilities/generics/get_arguments.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';


//22:06

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({ Key? key }) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {

  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final existing_note = _note;
    
    final widgetNote = context.getArgument<DatabaseNote>();
    
    if(widgetNote != null){
      _note = widgetNote;
      _textController.text=widgetNote.text;
      return widgetNote;
    }
    
    if (existing_note != null){
      return existing_note;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final newNote= await _notesService.createNote(owner: owner); 
    _note = newNote;
    return newNote;
  }


  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note!=null) {
      _notesService.deleteNote(id: note.id);
    }
  }


  void _saveNoteIfTextNotEmpty() async{
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty){
        await _notesService.updateNote(note: note, text: text);
    }
  }



  @override
  void initState() {
    
    _notesService = NotesService();
    _textController = TextEditingController();

  }


  @override
  void dispose() {
    super.dispose();
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();

  }

  void _textControllerListener() async {
    final note = _note;
    if (note==null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setupControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context,snapshot) {
          switch(snapshot.connectionState){
              case ConnectionState.done:
              // _note = snapshot.data as DatabaseNote;
              _setupControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start Typing your note....',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
            
          },
      ),
    );
  }
}