import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_service.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

final chatServiceProvider =
    Provider((ref) => ChatService('AIzaSyC1KeU8J2SrvUq8Bc00wi8cHffUeqYgQ44'));

final messagesProvider = StateProvider<List<Map<String, String>>>((ref) => []);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(BuildContext context, WidgetRef ref) async {
    final userMessage = _controller.text;
    if (userMessage.isEmpty) return;

    ref.read(messagesProvider.notifier).update((state) => [
          ...state,
          {'sender': 'user', 'text': userMessage}
        ]);

    _controller.clear();

    final chatService = ref.read(chatServiceProvider);
    final response = await chatService.sendMessage(userMessage);

    ref.read(messagesProvider.notifier).update((state) => [
          ...state,
          {'sender': 'ai', 'text': response}
        ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('AI Chat App'),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['sender'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: message['sender'] == 'user'
                          ? CupertinoColors.systemBlue.withOpacity(0.2)
                          : CupertinoColors.systemGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: buildStyledText(message['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    onSubmitted: (value) {
                      _sendMessage(context, ref);
                    },
                    controller: _controller,
                    placeholder: 'Type your message...',
                    padding: EdgeInsets.all(12.0),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _sendMessage(context, ref),
                  child: Icon(
                    CupertinoIcons.arrow_up_circle_fill,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to parse and build styled text
  Widget buildStyledText(String text) {
    final segments = text.split('**');
    List<TextSpan> spans = [];

    for (int i = 0; i < segments.length; i++) {
      if (i % 2 == 0) {
        // Regular text
        spans.add(TextSpan(text: segments[i]));
      } else {
        // Bold text
        spans.add(TextSpan(
          text: segments[i],
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
      }
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: CupertinoColors.black),
        children: spans,
      ),
    );
  }
}
