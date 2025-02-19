import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/shared_preference_helpert.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _loadEvents();
  }

  Future<void> _getUserId() async {
    String? userId = await SharedPreferencesHelper.getUserId();
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _loadEvents() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/events'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final Map<DateTime, List<dynamic>> events = {};
        for (var event in data) {
          DateTime eventDate = DateTime.parse(event['start_time']);
          if (events[eventDate] == null) {
            events[eventDate] = [];
          }
          events[eventDate]?.add(event);
        }
        setState(() {
          _events = events;
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Future<void> _addEvent(String title, String description, DateTime startTime, DateTime endTime) async {
    if (_userId == null) {
      print('User ID not found');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/events'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'title': title,
          'description': description,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'location': 'Online',
          'is_shared': false
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _loadEvents();
      } else {
        throw Exception('Failed to add event');
      }
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender',style: TextStyle(color: Color.fromARGB(255, 246, 246, 248),fontWeight: FontWeight.bold,fontSize: 24,),),
        backgroundColor: const Color(0xFF4D8FAC),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEventDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
          ),
          Expanded(
            child: _selectedDay != null && _events[_selectedDay] != null
                ? ListView.builder(
                    itemCount: _events[_selectedDay]!.length,
                    itemBuilder: (context, index) {
                      final event = _events[_selectedDay]![index];
                      return ListTile(
                        title: Text(event['title']),
                        subtitle: Text(event['description']),
                      );
                    },
                  )
                : const Center(
                    child: Text('Pilih tanggal untuk melihat acara'),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Acara Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul Acara'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
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
              final title = titleController.text;
              final description = descriptionController.text;
              _addEvent(title, description, _focusedDay, _focusedDay.add(Duration(hours: 1)));
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
