import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authententedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages yet'),
          );
        }

        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('An error occurred'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: chatSnapshot.data!.docs.length,
          itemBuilder: (ctx, index) {
            final chatMessages = chatSnapshot.data!.docs[index].data();
            final nextChatMessages = index < chatSnapshot.data!.docs.length - 1
                ? chatSnapshot.data!.docs[index + 1].data()
                : null;
            
            final currentMessageUserId = chatMessages['userId'];

            final nextMessageUserId = nextChatMessages != null
                ? nextChatMessages['userId']
                : null;


            final nextUserIsSame = currentMessageUserId == nextMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessages['text'],
                isMe: authententedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessages['userImage'],
                username: chatMessages['username'],
                message: chatMessages['text'],
                isMe: authententedUser.uid == currentMessageUserId,
              );
            }
            
          },
        );
      },
    );
  }
}
