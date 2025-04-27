import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/note_tile.dart';

class NoteHome extends StatefulWidget {
  const NoteHome({super.key});

  @override
  State<NoteHome> createState() => _NoteHomeState();
}

class _NoteHomeState extends State<NoteHome> {
  final Box<String> myNoteBox = Hive.box<String>('mynotes');
  final TextEditingController noteController = TextEditingController();

  void saveNewNote() {
    if (noteController.text.trim().isNotEmpty) {
      myNoteBox.add(noteController.text.trim());
      noteController.clear();
      Navigator.of(context).pop();
    }
  }

  void showNewNoteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(hintText: 'Write something...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: saveNewNote,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void showEditDialog(int index) {
    noteController.text = myNoteBox.getAt(index) ?? '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Your Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(hintText: 'Update your note...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              myNoteBox.putAt(index, noteController.text.trim());
              noteController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void removeNote(int index) {
    myNoteBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
      ),
      body: ValueListenableBuilder(
        valueListenable: myNoteBox.listenable(),
        builder: (context, Box<String> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('Nothing here yet. Add your first note!'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final currentNote = box.getAt(index) ?? '';
              return NoteTile(
                noteText: currentNote,
                onEdit: () => showEditDialog(index),
                onDelete: () => removeNote(index),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showNewNoteDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      ),
    );
  }
}
