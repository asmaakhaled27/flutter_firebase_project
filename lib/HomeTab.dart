import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final String userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blue Planet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: PostSearchDelegate());
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              return PostCard(postId: document.id);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_post');
        },
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

            return ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(userData['displayName'] ?? 'No Name'),
                  accountEmail: Text(userData['email'] ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: userData['photoUrl'] != null &&
                            userData['photoUrl'].isNotEmpty
                        ? NetworkImage(userData['photoUrl'])
                        : null,
                    child: userData['photoUrl'] == null ||
                            userData['photoUrl'].isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profile"),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Log Out"),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String postId;

  const PostCard({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error fetching post: ${snapshot.error}');
          return const Center(child: Text('Error loading post'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          print('Post does not exist');
          return const Center(child: Text('Post not found'));
        }

        var postData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        print('Post data: $postData');

        return Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(postData['username'] ?? 'Unknown User'),
                subtitle: Text(
                  postData['createdAt'] != null
                      ? (postData['createdAt'] as Timestamp).toDate().toString()
                      : 'No date',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(postData['text'] ?? 'No content available'),
              ),
              if (postData['imageUrl'] != null &&
                  postData['imageUrl'].isNotEmpty)
                Image.network(postData['imageUrl']),
              ButtonBar(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('posts')
                          .doc(postId)
                          .update({'likes': FieldValue.increment(1)});
                    },
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('0 Likes');
                      }
                      var likes = snapshot.data!['likes'] ?? 0;
                      return Text('$likes Likes');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {
                      _showCommentDialog(context, postId);
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .collection('comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('0 Comments');
                      }
                      var comments = snapshot.data!.docs.length;
                      return Text('$comments Comments');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentDialog(BuildContext context, String postId) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a Comment'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(hintText: "Write a comment..."),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Post'),
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .add({
                    'text': commentController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                    'userId': FirebaseAuth.instance.currentUser?.uid,
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
class PostSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: snapshot.data!.docs.map((document) {
            return PostCard(postId: document.id);
          }).toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
