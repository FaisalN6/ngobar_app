import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagePage extends StatefulWidget {
  final String recipientName;
  const MessagePage({super.key, required this.recipientName});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadUserId();
    fetchMessages();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('id_user');
    });
  }

  Future<void> fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/messages/${widget.recipientName}')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages.clear();
          _messages.addAll(
            data.map((item) => Message(
              id: item['kd_message'].toString(),
              text: item['message'],
              time: item['time'],
              isSent: item['is_sent_by_user'] == 1,
            )).toList()
          );
        });
      }
    } catch (e) {
      print('Error fetching messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil pesan')),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/message/$messageId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _messages.removeWhere((message) => message.id == messageId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesan berhasil dihapus')),
        );
        await fetchMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pesan')),
        );
      }
    } catch (e) {
      print('Error deleting message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menghapus pesan')),
      );
    }
  }

  Future<void> _handleSendMessage() async {
    if (_messageController.text.isEmpty || userId == null) return;

    final messageText = _messageController.text;
    final currentTime = DateTime.now().toIso8601String();

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'recipient_name': widget.recipientName,
          'id_user': userId,
          'message': messageText,
          'time': currentTime,
          'is_sent_by_user': 1,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        setState(() {
          _messages.add(
            Message(
              id: responseData['kd_message'].toString(),
              text: messageText,
              time: currentTime,
              isSent: true,
            ),
          );
          _messageController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan. Silakan coba lagi.')),
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat mengirim pesan')),
      );
    }
  }

  Future<void> _updateMessage(String messageId, String newMessage) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/message/$messageId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': newMessage,
          'is_sent_by_user': 1,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = _messages.indexWhere((message) => message.id == messageId);
          if (index != -1) {
            _messages[index] = Message(
              id: messageId,
              text: newMessage,
              time: _messages[index].time,
              isSent: true,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesan berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui pesan')),
        );
      }
    } catch (e) {
      print('Error updating message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat memperbarui pesan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Message>> groupedMessages = {};
    for (var message in _messages) {
      String date = DateFormat('yyyy-MM-dd').format(DateTime.parse(message.time));
      if (!groupedMessages.containsKey(date)) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(message);
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back, color: Colors.white),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        title: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.recipientName,
                style: const TextStyle(fontSize: 17, color: Colors.white),
              ),
              Text(
                'online',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, size: 24),
            onPressed: () {},
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.call, size: 22),
            onPressed: () {},
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: () {},
            color: Colors.white,
          ),
        ],
        backgroundColor: const Color(0xFF4D8FAC),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://i.pinimg.com/originals/97/c0/07/97c00759d90d786d9b6096d274ad3e07.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: groupedMessages.length,
                itemBuilder: (context, index) {
                  String date = groupedMessages.keys.elementAt(index);
                  List<Message> dayMessages = groupedMessages[date]!;
                  
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Text(
                          _formatDate(date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...dayMessages.map((message) => 
                        GestureDetector(
                          onLongPress: () {
                            if (message.isSent) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Hapus atau Edit Pesan'),
                                  content: Text('Apakah Anda yakin ingin menghapus atau mengedit pesan ini?'),
                                  actions: [
                                    TextButton(
                                      child: Text('Batal'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: Text('Hapus'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteMessage(message.id);
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Edit'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showEditMessageDialog(message.id, message.text);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: message.isSent
                            ? _buildSentMessage(message.text, message.time, context)
                            : _buildReceivedMessage(message.text, message.time, context),
                        )
                      ).toList(),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                    onPressed: _handleSendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMessageDialog(String messageId, String currentMessage) {
    final TextEditingController editController = TextEditingController(text: currentMessage);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Pesan'),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: 'Edit pesan...',
          ),
        ),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Simpan'),
            onPressed: () {
              Navigator.pop(context);
              _updateMessage(messageId, editController.text);
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    DateTime messageDate = DateTime.parse(date);
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));

    if (DateFormat('yyyy-MM-dd').format(messageDate) == DateFormat('yyyy-MM-dd').format(now)) {
      return 'Hari Ini';
    } else if (DateFormat('yyyy-MM-dd').format(messageDate) == DateFormat('yyyy-MM-dd').format(yesterday)) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(messageDate);
    }
  }

  Widget _buildReceivedMessage(String message, String time, BuildContext context) {
    DateTime messageTime = DateTime.parse(time);
    String formattedTime = "${messageTime.hour.toString().padLeft(2,'0')}:${messageTime.minute.toString().padLeft(2,'0')}";
    
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(fontSize: 16),
                  softWrap: true,
                ),
                SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentMessage(String message, String time, BuildContext context) {
    DateTime messageTime = DateTime.parse(time);
    String formattedTime = "${messageTime.hour.toString().padLeft(2,'0')}:${messageTime.minute.toString().padLeft(2,'0')}";
    
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                  ),
                  softWrap: true,
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.done_all,
                      size: 16,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String id;
  final String text;
  final String time;
  final bool isSent;

  Message({
    required this.id,
    required this.text,
    required this.time,
    required this.isSent,
  });
}
