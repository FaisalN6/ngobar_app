import 'package:flutter/material.dart';
import '../apps/setting_widget.dart';
// import '../apps/archive_screen.dart';
import '../pages/message_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatItem> chatItems = [];
  List<ChatItem> filteredChatItems = [];
  int? kdProfile;
  int? userId;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('id_user');
      if (userId != null) {
        prefs.setString('id_user', userId.toString());
      }
    });
    if (userId != null) {
      _loadChats();
    }
  }

  void filterChats(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredChatItems = List.from(chatItems);
      } else {
        filteredChatItems = chatItems
            .where((chat) =>
                chat.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _loadChats() async {
    if (userId == null) return;
    
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/chats?id_user=$userId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Fetched chats: $data');

        setState(() {
          chatItems = data.map((item) {
            String formattedTime = item['last_time'] != null 
                ? DateTime.parse(item['last_time']).toLocal().toString().substring(0, 10) 
                : DateTime.now().toString().substring(0, 10);
            
            return ChatItem(
              name: item['nama_chat'] ?? 'Tanpa Nama',
              message: item['last_message'] ?? '',
              time: formattedTime,
              avatarUrl: 'https://example.com/default_avatar.jpg',
              unreadCount: 0,
              kdChat: item['kd_chat'],
              nomorChat: item['nomor_chat'],
              userId: userId ?? 0
            );
          }).toList();
          filteredChatItems = List.from(chatItems);
        });
      }
    } catch (e) {
      print('Error fetching chat items: $e');
    }
  }

  Future<void> addChat(String namaChat, String nomorChat) async {
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/chats'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'nama_chat': namaChat,
          'nomor_chat': nomorChat,
          'id_user': userId,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Chat created with id: ${responseData['kd_chat']}');
        _loadChats();
      } else {
        print('Failed to create chat: ${response.body}');
      }
    } catch (e) {
      print('Error adding chat: $e');
    }
  }

  Future<void> updateChat(int kdChat, String namaChat, String nomorChat) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/chats/$kdChat'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'nama_chat': namaChat,
          'nomor_chat': nomorChat,
        }),
      );

      if (response.statusCode == 200) {
        print('Chat updated successfully');
        _loadChats();
      } else {
        print('Failed to update chat: ${response.body}');
      }
    } catch (e) {
      print('Error updating chat: $e');
    }
  }

  Future<void> deleteChat(int kdChat) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/chats/$kdChat'),
      );

      if (response.statusCode == 200) {
        print('Chat deleted successfully');
        _loadChats();
      } else {
        print('Failed to delete chat: ${response.body}');
      }
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ngobar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(chatItems, (query) {
                  filterChats(query);
                }),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingWidget()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor.withOpacity(0.1),
            child: ListTile(
              leading: Icon(Icons.archive, color: primaryColor),
              title: Text(
                'Arsip Chat',
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
              ),
              trailing: Icon(Icons.chevron_right, color: primaryColor),
              onTap: () {

              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredChatItems.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                return ChatListItem(
                  chatItem: filteredChatItems[index],
                  onMessageSent: _loadChats,
                  onEdit: (namaChat, nomorChat) {
                    updateChat(filteredChatItems[index].kdChat, namaChat, nomorChat);
                  },
                  onDelete: () {
                    deleteChat(filteredChatItems[index].kdChat);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => AddChatDialog(),
          );

          if (result != null) {
            await addChat(result.name, result.nomorChat);
          }
        },
        child: Icon(Icons.add, size: 28, color: Colors.white),
        backgroundColor: primaryColor,
        elevation: 4,
      ),
    );
  }
}

class ChatSearchDelegate extends SearchDelegate<String> {
  final List<ChatItem> chatItems;
  final Function(String) onSearch;

  ChatSearchDelegate(this.chatItems, this.onSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = chatItems.where((chat) =>
        chat.name.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].name),
          onTap: () {
            query = suggestions[index].name;
            onSearch(query);
            close(context, query);
          },
        );
      },
    );
  }
}

class AddChatDialog extends StatefulWidget {
  @override
  _AddChatDialogState createState() => _AddChatDialogState();
}

class _AddChatDialogState extends State<AddChatDialog> {
  final _nameController = TextEditingController();
  final _nomorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Chat Baru'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nama Kontak'),
          ),
          TextField(
            controller: _nomorController,
            decoration: InputDecoration(labelText: 'Nomor Telepon'),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Nama kontak tidak boleh kosong'))
              );
              return;
            }
            
            DateTime now = DateTime.now();
            String formattedTime = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
            
            final newChat = ChatItem(
              name: _nameController.text,
              message: '',
              time: formattedTime,
              avatarUrl: 'https://example.com/default_avatar.jpg',
              unreadCount: 0,
              kdChat: 0,
              nomorChat: _nomorController.text,
              userId: 1
            );
            Navigator.pop(context, newChat);
          },
          child: Text('Tambah'),
        ),
      ],
    );
  }
}

class ChatListItem extends StatelessWidget {
  final ChatItem chatItem;
  final VoidCallback onMessageSent;
  final Function(String, String) onEdit;
  final VoidCallback onDelete;

  const ChatListItem({
    Key? key,
    required this.chatItem,
    required this.onMessageSent,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(chatItem.avatarUrl),
      ),
      title: Text(
        chatItem.name,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chatItem.nomorChat,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          Text(
            chatItem.message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chatItem.time,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              SizedBox(height: 4),
              if (chatItem.unreadCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chatItem.unreadCount.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await showDialog(
                  context: context,
                  builder: (context) => EditChatDialog(
                    initialName: chatItem.name,
                    initialNomor: chatItem.nomorChat,
                  ),
                );
                if (result != null) {
                  onEdit(result.name, result.nomor);
                }
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Hapus Chat'),
                    content: Text('Apakah Anda yakin ingin menghapus chat ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Hapus'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  onDelete();
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Hapus'),
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagePage(
              recipientName: chatItem.name,
            ),
          ),
        );
        onMessageSent();
      },
    );
  }
}

class EditChatDialog extends StatefulWidget {
  final String initialName;
  final String initialNomor;

  const EditChatDialog({
    Key? key,
    required this.initialName,
    required this.initialNomor,
  }) : super(key: key);

  @override
  _EditChatDialogState createState() => _EditChatDialogState();
}

class _EditChatDialogState extends State<EditChatDialog> {
  late TextEditingController _nameController;
  late TextEditingController _nomorController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _nomorController = TextEditingController(text: widget.initialNomor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Chat'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nama Kontak'),
          ),
          TextField(
            controller: _nomorController,
            decoration: InputDecoration(labelText: 'Nomor Telepon'),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Nama kontak tidak boleh kosong'))
              );
              return;
            }
            Navigator.pop(context, EditChatResult(
              name: _nameController.text,
              nomor: _nomorController.text,
            ));
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}

class EditChatResult {
  final String name;
  final String nomor;

  EditChatResult({required this.name, required this.nomor});
}

class ChatItem {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final int unreadCount;
  final int kdChat;
  final String nomorChat;
  final int userId;

  ChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    this.unreadCount = 0,
    required this.kdChat,
    required this.nomorChat,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama_chat': name,
      'last_message': message,
      'last_time': time,
      'avatar_url': avatarUrl,
      'unread_count': unreadCount,
      'kd_chat': kdChat,
      'nomor_chat': nomorChat,
      'id_user': userId,
    };
  }
}
