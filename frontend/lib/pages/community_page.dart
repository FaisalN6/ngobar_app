import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<CommunityItem> _communities = [
    CommunityItem(
      name: "Announcements",
      description: "Community announcements and updates",
      memberCount: 250,
    ),
    CommunityItem(
      name: "General Discussion",
      description: "Chat about anything with the community",
      memberCount: 180,
    ),
    CommunityItem(
      name: "Events",
      description: "Upcoming community events and meetups",
      memberCount: 120,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.only(left: 10),
          child: const Text(
            'Community',
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D8FAC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: const Text(
                      'New Community',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Communities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4D8FAC),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return CommunityListItem(community: _communities[index]);
              },
              childCount: _communities.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4D8FAC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CommunityItem {
  final String name;
  final String description;
  final int memberCount;

  CommunityItem({
    required this.name,
    required this.description,
    required this.memberCount,
  });
}

class CommunityListItem extends StatelessWidget {
  final CommunityItem community;

  const CommunityListItem({
    super.key,
    required this.community,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF4D8FAC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            community.name[0],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        community.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(community.description),
          const SizedBox(height: 4),
          Text(
            '${community.memberCount} members',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: () {},
    );
  }
}