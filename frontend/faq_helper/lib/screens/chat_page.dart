import 'package:faq_helper/utilities/network.dart';
import 'package:faq_helper/values/colors.dart';
import 'package:faq_helper/values/margins.dart';
import 'package:faq_helper/values/phrases.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String title;
  final String placeId;

  const ChatPage({super.key, required this.title, required this.placeId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _askController = TextEditingController();

  List<String> queries = [];
  List<String> responses = [];
  bool thinking = false;

  List<Widget> chatBubbleList = [];

  void buildChatBubbles() {
    chatBubbleList = [
      WordBubble(content: initialMessage(widget.title), fromBot: true)
    ];
    for (int i = 0; i < queries.length; i++) {
      chatBubbleList.insert(0, WordBubble(content: queries[i], fromBot: false));
      if(responses.length > i) {
        chatBubbleList.insert(
            0, WordBubble(content: responses[i], fromBot: true));
      }
      else {
        print("Responses isn't ready yet");
      }
    }
  }

  void askQuestion() async {
    setState(() {
      thinking = true;
    });
    String question = _askController.text;
    _askController.clear();
    queries.add(question);
    chatBubbleList.insert(0, WordBubble(content: question, fromBot: false));
    setState(() {});
    try {
      String answer =
      await NetworkUtility.getAnswer(widget.placeId, 10, question);
      responses.add(answer);
    } catch (e) {
      responses.add(askUnableToRetrieve);
    }
    chatBubbleList.insert(
        0, WordBubble(content: responses.last, fromBot: true));
    thinking = false;
    setState(() {});
  }

  @override
  void initState() {
    buildChatBubbles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    buildChatBubbles();
    return Scaffold(
      body: Center(
        child: Container(
          color: Color(0xFFffd9e0),
          height: double.infinity,
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Column(
              verticalDirection: VerticalDirection.up,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(10)),
                    gradient: LinearGradient(
                      colors: [mainGradientStart, mainGradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  height: 120,
                  width: double.infinity,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: TextField(
                        enabled: !thinking,
                        onTap: () {},
                        controller: _askController,
                        autofocus: false,
                        showCursor: true,
                        onSubmitted: (query) {
                          askQuestion();
                        },
                        onChanged: (str) {},
                        // style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: askHint,
                          filled: true,
                          fillColor: searchBarColor,
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            onPressed: () {
                              askQuestion();
                            },
                            icon: const Icon(Icons.send),
                            tooltip: askSendTooltip,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(reverse: true, children: chatBubbleList),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WordBubble extends StatelessWidget {
  final String content;
  final bool fromBot;

  const WordBubble({super.key, required this.content, required this.fromBot});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: fromBot
            ? const EdgeInsets.only(
            right: messagesOppositeSpace, left: messagesOwnSideSpace)
            : const EdgeInsets.only(
            right: messagesOwnSideSpace, left: messagesOppositeSpace),
        child: Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(messagesRoundRadius)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(messagesRoundRadius),
              gradient: fromBot ? aiMessageGradient : userMessageGradient,
            ),
            child: Padding(
              padding: const EdgeInsets.all(messageInnerPadding),
              child: Text(
                content,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    color: fromBot ? Colors.white : offBlack,
                    fontSize: 18.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
