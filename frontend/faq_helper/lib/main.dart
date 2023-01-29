import 'dart:async';

import 'package:faq_helper/models/autocompleteRes.dart';
import 'package:faq_helper/screens/place_info.dart';
import 'package:faq_helper/utilities/network.dart';
import 'package:faq_helper/values/colors.dart';
import 'package:faq_helper/values/fonts.dart';
import 'package:faq_helper/values/phrases.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAiQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(title: 'FAiQ'),
      // home: PlaceInfo(placeId: "ChIJj-S0i8Zr5IkR5izIcdDkzyQ"),
      home: ChatPage(
        placeId: 'ChIJL-lNehNF5IkR1nzntAKsTt8',
        title: 'Pizza Queen',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _searchPlaceTextController = TextEditingController();
  bool _isSearching = false;
  List<PlacesAutocompletion> _autocompletions = [];
  Timer? _debounce;

  void autocompletePlace(String query) async {
    List<PlacesAutocompletion> suggestions =
        await NetworkUtility.getAutocompletions(query);
    // suggestions.forEach((element) {
    //   print(element.title);
    //   print(element.address);
    // });
    setState(() {
      _autocompletions = suggestions;
    });
  }

  void _focusSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _defocusSearch() {
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("widget.title"),
      // ),
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [mainGradientStart, mainGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: AnimatedContainer(
                // color: _isSearching ? Colors.black : mainGradientEnd,
                curve: Curves.easeInCirc,
                height: double.infinity,
                duration: const Duration(milliseconds: 500),
                child: AnimatedAlign(
                  alignment: _isSearching
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                  child: Column(
                    // mainAxisAlignment: _isSearching
                    //     ? MainAxisAlignment.start
                    //     : MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AnimatedDefaultTextStyle(
                        style: _isSearching
                            ? const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              )
                            : const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 50,
                              ),
                        curve: Curves.easeOutCirc,
                        duration: const Duration(milliseconds: 200),
                        child: const Text(
                          "FAiQ.",
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: TextField(
                          onTap: _focusSearch,
                          controller: _searchPlaceTextController,
                          autofocus: false,
                          showCursor: true,
                          onSubmitted: (str) {
                            autocompletePlace(str);
                          },
                          onChanged: (str) {
                            if (_debounce?.isActive ?? false) {
                              _debounce!.cancel();
                            }
                            _debounce =
                                Timer(const Duration(milliseconds: 500), () {
                              if (str.isNotEmpty) {
                                autocompletePlace(str);
                              }
                            });
                          },
                          // style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: searchHint,
                            filled: true,
                            fillColor: searchBarColor,
                            border: InputBorder.none,
                            // focusedBorder: OutlineInputBorder(
                            //   borderSide: const BorderSide(
                            //     width: 0
                            //   ),
                            // ),
                            // border: OutlineInputBorder(
                            //   borderSide: const BorderSide(
                            //     width: 0,
                            //     color: Colors.transparent,
                            //   ),
                            //   borderRadius: BorderRadius.circular(50.0),
                            // ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        searchSub,
                        style: TextStyle(
                          color: Color.fromARGB(150, 255, 255, 255),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child:
                                // ListView(
                                //   children: [
                                //     AutoCompleteResultCard(
                                //       item: PlacesAutocompletion(
                                //         description: "asdf",
                                //         placeId: "xxx",
                                //         reference: "asdf",
                                //         title: "McGolf",
                                //         address: "Dedham, MA, USA"
                                //       )
                                //     ),
                                //   ],
                                // ),
                                ListView.builder(
                              itemCount: _autocompletions.length,
                              // prototypeItem: ListTile(
                              //   title: Text(_autocompletions.first),
                              // ),
                              itemBuilder: (context, index) {
                                return AutoCompleteResultCard(
                                  item: _autocompletions[index],
                                );
                              },
                            )),
                      )
                      // Container(
                      //   child: ListView(
                      //     children: [
                      //       // AutoCompleteResultCard()
                      //     ],
                      //   ),
                      // ),
                      // Text(
                      //   '$_counter',
                      //   style: Theme.of(context).textTheme.headlineMedium,
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isSearching = !_isSearching;
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AutoCompleteResultCard extends StatefulWidget {
  final PlacesAutocompletion item;

  const AutoCompleteResultCard({super.key, required this.item});

  @override
  _AutoCompleteResultCardState createState() => _AutoCompleteResultCardState();
}

class _AutoCompleteResultCardState extends State<AutoCompleteResultCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: OutlinedButton(
          // color: Colors.white,
          // shape:
          //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          // elevation: 0,
          style: OutlinedButton.styleFrom(
            backgroundColor: searchBarColor,
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
          onPressed: () {
            print(widget.item.placeId);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlaceInfo(placeId: widget.item.placeId),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 22,
                        overflow: TextOverflow.fade,
                      ),
                      softWrap: false,
                    ),
                    Text(
                      widget.item.address,
                      style: const TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.fade,
                        color: Colors.black45,
                      ),
                      softWrap: false,
                    )
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded)
            ],
          ),
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {

  final String title;
  final String placeId;

  const ChatPage({super.key, required this.title, required this.placeId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _askController = TextEditingController();

  void askQuestion() async {
    print(
        await NetworkUtility.getAnswer(widget.placeId, 10, _askController.text)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
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
                        onTap: () {},
                        controller: _askController,
                        autofocus: false,
                        showCursor: true,
                        onSubmitted: (query) {
                          askQuestion();
                          _askController.clear();
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
                              _askController.clear();
                            },
                            icon: const Icon(Icons.send),
                            tooltip: askSendTooltip,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
