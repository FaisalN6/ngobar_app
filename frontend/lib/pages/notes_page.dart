import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/notes'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _notes = data.map((note) => Note.fromJson(note)).toList();
        });
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  Future<void> _addNote(String title, String content, bool isPrivate) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/notes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 1, // Replace with dynamic user ID if needed
          'title': title,
          'content': content,
          'is_private': isPrivate,
        }),
      );

      if (response.statusCode == 201) {
        _fetchNotes();
      } else {
        throw Exception('Failed to add note');
      }
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(
            color: Color.fromARGB(255, 246, 246, 248),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF4D8FAC),
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text('Belum ada catatan. Tap + untuk membuat catatan baru.'),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return NoteCard(note: _notes[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(),
        backgroundColor: const Color(0xFF4D8FAC),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isPrivate = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Catatan Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Isi Catatan'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Pribadi'),
                  Switch(
                    value: isPrivate,
                    onChanged: (value) {
                      setState(() {
                        isPrivate = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _addNote(
                  titleController.text,
                  contentController.text,
                  isPrivate,
                );
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

class Note {
  final int id;
  final String title;
  final String content;
  final bool isPrivate;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.isPrivate,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      isPrivate: json['is_private'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.content),
            const SizedBox(height: 4),
            Text(
              '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Implement note options (edit, delete, share)
          },
        ),
      ),
    );
  }
}
