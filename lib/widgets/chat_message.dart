import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (ctx, chatSnapShots) {
          if (chatSnapShots.connectionState == ConnectionState.waiting) {
            return Center(
              child: const CircularProgressIndicator(),
            );
          }
          if (!chatSnapShots.hasData || chatSnapShots.data!.docs.isEmpty) {
            return Center(
              child: const Text('No messages found!'),
            );
          }
          if (chatSnapShots.hasError) {
            return Center(
              child: const Text('Something went wrong!'),
            );
          }
          final loadedMessages = chatSnapShots.data!.docs;
          return ListView.builder(
              itemCount: loadedMessages.length,
              itemBuilder: (ctx, index) {
                return Text(loadedMessages[index].data()['text']);
              });
        });
  }
}
