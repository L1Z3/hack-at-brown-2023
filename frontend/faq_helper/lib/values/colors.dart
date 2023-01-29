import 'package:flutter/material.dart';

const offBlack = Color(0xFF1f1f1f);

const mainGradientStart = Color(0xFFf857a6);
const mainGradientEnd = Color(0xFFff5858);

const mainGradientEnd1 = Color(0xFFFF512F);
const mainGradientStart1 = Color(0xFFF09819);

const searchBarColor = Color.fromARGB(50, 255, 255, 255);

// Chat
const aiMessageColorBot = Color(0xFFf54c9b);
const aiMessageColorTop = Color(0xFFf567aa);
const aiMessageGradient = LinearGradient(
  colors: [aiMessageColorTop, aiMessageColorBot],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);
const userMessageColorBot = Color(0xFFffbddc);
const userMessageColorTop = Color(0xFFffd1e7);
const userMessageGradient = LinearGradient(
  colors: [userMessageColorTop, userMessageColorBot],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);