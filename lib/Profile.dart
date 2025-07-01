import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    // final String username = FirebaseAuth.instance.currentUser!.us;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var userData = snapshot.data!.data() as Map<String, dynamic>;

                return Card(
                  margin: EdgeInsets.all(16.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: userData['photoUrl'] != null &&
                                    userData['photoUrl'].isNotEmpty
                                ? NetworkImage(userData['photoUrl'])
                                : null,
                            child: userData['photoUrl'] == null ||
                                    userData['photoUrl'].isEmpty
                                ? Icon(Icons.person, size: 50)
                                : null,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Name: ${userData['displayName'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Email: ${userData['email'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Phone: ${userData['phone'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Gender: ${userData['gender'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Address: ${userData['address'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('userid', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((document) {
                    return PostCard(postId: document.id);
                  }).toList(),
                );
              },
            ),
          ],
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
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var postData = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          margin: EdgeInsets.all(16.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postData['text'] ?? 'No content',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                if (postData['imageUrl'] != null)
                  Image.network(postData['imageUrl']),
                SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('0 Comments');
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${snapshot.data!.docs.length} Comments',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...snapshot.data!.docs.map((commentDoc) {
                          var commentData =
                              commentDoc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(commentData['text'] ?? 'No content'),
                            subtitle: Text(
                                'By: ${commentData['username'] ?? 'Unknown User'}'),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
