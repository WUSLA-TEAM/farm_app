import 'package:farm_app/src/ChatScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_app/src/AuthService.dart';
import 'package:provider/provider.dart';

class UploaderChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.getUserEmail() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading chats'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No active chats'));
          } else {
            final chatDocs = snapshot.data!.docs;
            final uniqueChats = chatDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final participants = List<String>.from(data['participants']);
              participants.remove(userEmail);
              return participants.isNotEmpty ? participants.first : null;
            }).toSet().toList();

            return ListView.builder(
              itemCount: uniqueChats.length,
              itemBuilder: (context, index) {
                final chatUser = uniqueChats[index];
                return ListTile(
                  title: Text(chatUser ?? 'Unknown User'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          productId: '', // Pass the relevant productId
                          receiverEmail: chatUser!,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
