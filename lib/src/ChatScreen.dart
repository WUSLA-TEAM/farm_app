import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_app/src/AuthService.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String productId;
  final String receiverEmail;

  const ChatScreen({
    super.key,
    required this.productId,
    required this.receiverEmail,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.getUserEmail() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('productId', isEqualTo: widget.productId)
                  .where('participants', arrayContains: userEmail)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error loading messages'),
                        SizedBox(height: 8),
                        Text(snapshot.error.toString()),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the Firestore console link for creating the index
                            // Replace this with actual navigation logic if needed
                          },
                          child: Text('Create Index'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages'));
                } else {
                  return ListView(
                    reverse: true,
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['message']),
                        subtitle: Text(data['sender']),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.trim().isNotEmpty) {
                      await _firestore.collection('chats').add({
                        'productId': widget.productId,
                        'sender': userEmail,
                        'receiver': widget.receiverEmail,
                        'message': _messageController.text.trim(),
                        'timestamp': FieldValue.serverTimestamp(),
                        'participants': [userEmail, widget.receiverEmail],
                      });

                      // Send notification to uploader
                      await _firestore.collection('notifications').add({
                        'receiverEmail': widget.receiverEmail,
                        'message': 'You have a new message from $userEmail',
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
