import 'package:flutter/material.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.only(left: 10),
          child: const Text(
            'Status',
            style: TextStyle(
              color: Color.fromARGB(255, 246, 246, 248),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 50,
        backgroundColor: const Color(0xFF4D8FAC),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: Stack(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF4D8FAC),
                  child: Icon(Icons.person, color: Colors.white, size: 35),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4D8FAC),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            title: const Text(
              'Status Saya',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Ketuk untuk menambahkan pembaruan status'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Pembaruan terbaru',
              style: TextStyle(
                color: Color(0xFF4D8FAC),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4D8FAC),
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
            title: const Text(
              'John Doe',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Hari ini, 10:30'),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.grey[200],
            onPressed: () {},
            child: const Icon(Icons.edit, color: Color(0xFF4D8FAC)),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: const Color(0xFF4D8FAC),
            onPressed: () {},
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ],
      ),
    );
  }
}