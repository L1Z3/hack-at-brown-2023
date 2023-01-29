import 'package:faq_helper/models/location.dart';
import 'package:faq_helper/utilities/network.dart';
import 'package:faq_helper/values/colors.dart';
import 'package:faq_helper/values/fonts.dart';
import 'package:faq_helper/values/phrases.dart';
import 'package:flutter/material.dart';
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

  void loadData() async {
    try {
      _placeData = await NetworkUtility.getLocationInfo(widget.placeId);
      print(_placeData.name);
      loading = false;
      success = true;
    } catch (e) {
      loading = false;
      success = false;
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
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : success
                  ? Column(
                children: <Widget>[
                  Text(
                    _placeData.name,
                    style: placeTitleStyle,
                  ),
                  PhoneNumberButton(number: _placeData.phone),
                  Text(
                    _placeData.address,
                    style: placeAddressStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: _placeData.hasDesc()
                        ? Text(_placeData.description)
                        : const Text(
                      locationNoDesc,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {},
                    child: Text("Ask me questions!"),
                  )
                ],
              )
                  : const Center(child: Text(locationFailedLoad)),
            ),
          ),
        ),
      ),
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
      return TextButton(onPressed: _launchCaller, child: Text(number));
    }
    return TextButton(onPressed: () {}, child: const Text(locationNoPhone));
  }
}