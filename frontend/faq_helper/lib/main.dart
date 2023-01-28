import 'package:faq_helper/models/autocompleteRes.dart';
import 'package:faq_helper/secret.dart';
import 'package:faq_helper/utilities/network.dart';
import 'package:faq_helper/values/colors.dart';
import 'package:flutter/material.dart';

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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'FAiQ'),
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

  void autocompletePlace(String query) async {
    List<PlacesAutocompletion> suggestions =
        await NetworkUtility.getAutocompletions(query);
    suggestions.forEach((element) {
      print(element.title);
      print(element.address);
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
                color: _isSearching ? Colors.black : mainGradientEnd,
                curve: Curves.easeInCirc,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  mainAxisAlignment: _isSearching
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "FAiQ.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 50,
                      ),
                      textAlign: TextAlign.start,
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
                        // style: TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Where are you going?',
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
                      "Search for any establishment and ask questions based on "
                      "previous reviews.",
                      style: TextStyle(
                        color: Color.fromARGB(150, 255, 255, 255),
                      ),
                    ),
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
