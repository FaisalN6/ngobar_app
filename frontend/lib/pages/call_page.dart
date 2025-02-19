import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final List<CallItem> _calls = [
    CallItem(
      name: "John Doe",
      time: "10:30 AM",
      isMissed: true,
      isVideo: false,
      isFavorite: true,
    ),
    CallItem(
      name: "Jane Smith", 
      time: "Yesterday",
      isMissed: false,
      isVideo: true,
      isFavorite: true,
    ),
    CallItem(
      name: "Mike Johnson",
      time: "Yesterday",
      isMissed: false,
      isVideo: false,
      isFavorite: false,
    ),
  ];

  List<CallItem> get _favoriteCalls => _calls.where((call) => call.isFavorite).toList();
  List<CallItem> get _recentCalls => _calls.where((call) => !call.isFavorite).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.only(left: 10),
          child: const Text(
            'Call',
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
      body: CustomScrollView(
        slivers: [
          if (_favoriteCalls.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Favorite',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4D8FAC),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => CallListItem(call: _favoriteCalls[index]),
                childCount: _favoriteCalls.length,
              ),
            ),
          ],
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Recent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4D8FAC),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => CallListItem(call: _recentCalls[index]),
              childCount: _recentCalls.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4D8FAC),
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }
}

class CallItem {
  final String name;
  final String time;
  final bool isMissed;
  final bool isVideo;
  final bool isFavorite;

  CallItem({
    required this.name,
    required this.time,
    required this.isMissed,
    required this.isVideo,
    required this.isFavorite,
  });
}

class CallListItem extends StatelessWidget {
  final CallItem call;

  const CallListItem({
    super.key,
    required this.call,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF4D8FAC),
        radius: 24,
        child: Text(
          call.name[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        call.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(
            call.isMissed ? Icons.call_missed : Icons.call_made,
            size: 16,
            color: call.isMissed ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(call.time),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            call.isVideo ? Icons.videocam : Icons.call,
            color: const Color(0xFF4D8FAC),
          ),
          if (call.isFavorite) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.star,
              color: Color(0xFF4D8FAC),
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}
