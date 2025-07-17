import 'package:flutter/material.dart';

class MyColor {
  Color? color;
  MyColor({this.color = Colors.lightBlue}) {}
}

LinearGradient secondarytheme = LinearGradient(
    colors: [Colors.black, Color.fromARGB(255, 2, 26, 88), Colors.black],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter);

Map<String, LinearGradient> themes = {
  '01d': LinearGradient(
    colors: [
      Color.fromARGB(255, 28, 109, 163),
      Color.fromARGB(255, 70, 201, 241)
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '01n': LinearGradient(
    colors: [Color.fromARGB(255, 9, 10, 10), Color.fromARGB(255, 62, 65, 66)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '02d': LinearGradient(
    colors: [
      Color.fromARGB(255, 78, 79, 80),
      Color.fromARGB(255, 70, 201, 241)
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '02n': LinearGradient(
    colors: [Color.fromARGB(255, 9, 10, 10), Color.fromARGB(255, 62, 65, 66)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '03d': LinearGradient(
    colors: [
      Color.fromARGB(255, 86, 88, 88),
      Color.fromARGB(255, 145, 149, 150)
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '03n': LinearGradient(
    colors: [
      Color.fromARGB(255, 86, 88, 88),
      Color.fromARGB(255, 145, 149, 150)
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '04d': LinearGradient(
    colors: [Color.fromARGB(255, 73, 75, 75), Color.fromARGB(255, 35, 35, 36)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '04n': LinearGradient(
    colors: [Color.fromARGB(255, 73, 75, 75), Color.fromARGB(255, 35, 35, 36)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '09d': LinearGradient(
    colors: [
      Color.fromARGB(255, 35, 35, 36),
      Color.fromARGB(255, 3, 102, 168),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '09n': LinearGradient(
    colors: [
      Color.fromARGB(255, 35, 35, 36),
      Color.fromARGB(255, 3, 102, 168),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '10d': LinearGradient(
    colors: [
      Color.fromARGB(255, 35, 35, 36),
      Color.fromARGB(255, 4, 141, 233),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '10n': LinearGradient(
    colors: [
      Color.fromARGB(255, 35, 35, 36),
      Color.fromARGB(255, 4, 141, 233),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '11d': LinearGradient(
    colors: [Color.fromARGB(255, 73, 75, 75), Color.fromARGB(255, 35, 35, 36)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '11n': LinearGradient(
    colors: [Color.fromARGB(255, 73, 75, 75), Color.fromARGB(255, 35, 35, 36)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '13d': LinearGradient(
    colors: [
      Color.fromARGB(255, 231, 231, 235),
      Color.fromARGB(255, 144, 148, 148),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '13n': LinearGradient(
    colors: [
      Color.fromARGB(255, 231, 231, 235),
      Color.fromARGB(255, 144, 148, 148),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '50d': LinearGradient(
    colors: [
      Color.fromARGB(255, 175, 180, 180),
      Color.fromARGB(255, 175, 180, 180),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
  '50n': LinearGradient(
    colors: [
      Color.fromARGB(255, 175, 180, 180),
      Color.fromARGB(255, 175, 180, 180),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
};
