import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:faq_helper/models/location.dart';
import 'package:faq_helper/screens/chat_page.dart';
import 'package:faq_helper/utilities/network.dart';
import 'package:faq_helper/values/colors.dart';
import 'package:faq_helper/values/fonts.dart';
import 'package:faq_helper/values/phrases.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceInfo extends StatefulWidget {
  final String placeId;

  PlaceInfo({super.key, required this.placeId});

  @override
  _PlaceInfoState createState() => _PlaceInfoState();
}

class _PlaceInfoState extends State<PlaceInfo> {
  bool loading = true;
  bool success = false;
  late Location _placeData;
  String aiSummary = "Calcifer is thinking of a summary...";

  void loadData() async {
    try {
      _placeData = await NetworkUtility.getLocationInfo(widget.placeId);
      loading = false;
      success = true;
    } catch (e) {
      print(e);
      loading = false;
      success = false;
    }
    setState(() {});
    loadSummary();
  }

  void loadSummary() async {
    try {
      aiSummary = await NetworkUtility.getSummary(widget.placeId, 20);
    } catch (e) {
      aiSummary = "Calcifer could not summarize findings on this one.";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      print(widget.placeId);
      loadData();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore"),
        backgroundColor: mainGradientStart,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [mainGradientStart, mainGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : success
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                _placeData.name,
                                style: placeTitleStyle,
                              ),
                              _placeData.hasPhoto()
                                  ? Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          _placeData.photo,
                                          // width: double.infinity,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star_border,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "${_placeData.rating}/5.0",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 100,
                                      child: Stack(
                                        children: [
                                          LinearProgressIndicator(
                                            value: _placeData.rating / 5.0,
                                            minHeight: 30,
                                            semanticsLabel:
                                                'Linear progress indicator',
                                            color: Colors.green,
                                          ),
                                          Shimmer.fromColors(
                                            baseColor: Colors.transparent,
                                            highlightColor:
                                                Colors.white.withAlpha(50),
                                            child: Container(
                                              height: 30,
                                              width: 100,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              PhoneNumberButton(number: _placeData.phone),
                              AddressButton(address: _placeData.address),
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: _placeData.hasDesc()
                                    ? Text(
                                        _placeData.description,
                                        style: placeDescStyle,
                                      )
                                    : Text(
                                        locationNoDesc,
                                        style: placeDescStyle.copyWith(
                                            fontStyle: FontStyle.italic),
                                      ),
                              ),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Text(
                                    calciferSays,
                                    style: placeDescStyle,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child:
                                AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      aiSummary,
                                      textStyle: placeDescStyle,
                                      cursor: "🔥",
                                      textAlign: TextAlign.start
                                      // rotateOut: false,
                                    ),
                                  ],
                                  repeatForever: false,
                                  isRepeatingAnimation: false,
                                ),
                              ),
                              SizedBox(
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      )
                    : const Center(child: Text(locationFailedLoad)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: success
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: mainGradientEnd,
                side: BorderSide(width: 1.0, color: Colors.white),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      placeId: widget.placeId,
                      title: _placeData.name,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(
                  askQuestions,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }
}

class PhoneNumberButton extends StatelessWidget {
  final String number;

  const PhoneNumberButton({super.key, required this.number});

  String stripPhone(String num) {
    return num.replaceAll(RegExp(r'(\(|\)|\-| )'), '');
  }

  void _launchCaller() async {
    Uri url = Uri.parse('tel:${stripPhone(number)}');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (number != "None") {
      return TextButton(
          onPressed: _launchCaller,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone),
              SizedBox(
                width: 10,
              ),
              Text(
                number,
                style: phoneNumberStyle,
              ),
            ],
          ));
    }
    return TextButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone),
            SizedBox(
              width: 10,
            ),
            const Text(
              locationNoPhone,
              style: phoneNumberStyle,
            ),
          ],
        ));
  }
}

class AddressButton extends StatelessWidget {
  final String address;

  const AddressButton({super.key, required this.address});

  void _launchAddr() async {
    Uri url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (address != "None") {
      return TextButton(
          onPressed: _launchAddr,
          child: Expanded(
            child: Text(
              address,
              style: phoneNumberStyle,
              overflow: TextOverflow.fade,
              textAlign: TextAlign.center,
            ),
          ));
    }
    return TextButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.map_outlined),
            SizedBox(
              width: 10,
            ),
            Text(
              locationNoAddress,
              style: phoneNumberStyle,
            ),
          ],
        ));
  }
}
