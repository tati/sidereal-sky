import 'package:flutter/material.dart';

// Libre Baskerville italic — date header
const TextStyle delphiHeaderStyle = TextStyle(
  fontFamily: 'LibreBaskerville',
  fontStyle: FontStyle.italic,
  fontSize: 28,
  color: Colors.white,
);

// Libre Baskerville italic — section labels like "Sidereal Sky"
const TextStyle delphiLabelStyle = TextStyle(
  fontFamily: 'LibreBaskerville',
  fontStyle: FontStyle.italic,
  fontSize: 26,
  color: Colors.white,
);

// Libre Baskerville italic — data readout inside the Sidereal Longitudes box
const TextStyle delphiBodyItalicStyle = TextStyle(
  fontFamily: 'LibreBaskerville',
  fontStyle: FontStyle.italic,
  fontSize: 18,
  color: Colors.white,
);

// Libre Baskerville regular — numbers and degree values
const TextStyle delphiBodyStyle = TextStyle(
  fontFamily: 'LibreBaskerville',
  fontSize: 18,
  color: Colors.white,
);

// Maragsa — sign names inside parentheses e.g. (Cancer)
// inherit: false prevents the parent TextSpan's LibreBaskerville from bleeding through
const TextStyle delphiSignInlineStyle = TextStyle(
  inherit: false,
  fontFamily: 'Maragsa',
  fontSize: 18,
  color: Colors.white,
);

// Maragsa display, non-italic — Sun / Moon utility labels only
const TextStyle delphiUtilityStyle = TextStyle(
  fontFamily: 'Maragsa',
  fontSize: 22,
  color: Colors.white,
);
