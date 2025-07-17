import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/convertDate.dart';
import 'main.dart';

class TempMinMax {
  double tempMin = 0, tempMax = 0;
  TempMinMax(this.tempMin, this.tempMax);
}

class Glance {
  Weather w;
  double height = 150, width = 200;
  bool animated = false;
  Glance({required this.w});
}

class MyDouble {
  double value;
  MyDouble([this.value = 0]);
}

class Day {
  TempMinMax temp;
  List<Glance> glance_list = [];

  Day({required this.temp, required this.glance_list});
}

List<String> get_pron_weat(
    List<Glance> glist, String lenghtunit, Weather tdWeather) {
  Map<String, int> weathnumber = {};
  double windSum = 0, humSum = 0;

  for (Glance g in glist) {
    String str = g.w.weatherMain!.substring(0, 1).toUpperCase() +
        g.w.weatherMain!.substring(1) +
        '-' +
        g.w.weatherDescription!.substring(0, 1).toUpperCase() +
        g.w.weatherDescription!.substring(1) +
        '-' +
        g.w.weatherIcon!.substring(0, g.w.weatherIcon!.length - 1);
    DateTime now = convertDate(
            DateTime.now(), tdWeather.latitude!, tdWeather.longitude!),
        sunrise = convertDate(
            tdWeather.sunrise!, tdWeather.latitude!, tdWeather.longitude!),
        sunset = convertDate(
            tdWeather.sunset!, tdWeather.latitude!, tdWeather.longitude!);
    if (sunrise.compareTo(now) > 0 || sunset.compareTo(now) < 0)
      str += 'n';
    else
      str += 'd';
    double wind;
    if (lenghtunit == 'km') {
      wind = g.w.windSpeed! * 3.6;
    } else {
      //mi
      wind = g.w.windSpeed! * 3.6 / 1.6;
    }
    windSum += wind;
    humSum += g.w.humidity!;
    if (weathnumber.containsKey(str))
      weathnumber[str] = weathnumber[str]! + 1;
    else
      weathnumber[str] = 1;
  }
  int max = 0;
  String str = '';
  for (String s in weathnumber.keys) {
    if (max < weathnumber[s]!) {
      max = weathnumber[s]!;
      str = s;
    }
  }

  str += '-';
  str += (windSum ~/ glist.length).toString();
  str += lenghtunit + '/h';
  str += '-';
  str += (humSum ~/ glist.length).toString();
  return str.split('-');
}

String getwindspeed(Weather wh, String lenghtunit) {
  if (lenghtunit == 'mi') {
    return (wh.windSpeed! * 3.6 / 1.6).toInt().toString() + ' mi/h';
  } else {
    //km
    return (wh.windSpeed! * 3.6).toInt().toString() + ' km/h';
  }
}

int getwatervolume(Weather wh) {
  if (wh.rainLastHour == null) {
    return 0;
  } else {
    return (wh.rainLastHour!).toInt();
  }
}

double? getTemperature(Weather w, String tempunit) {
  if (tempunit == 'C') {
    return w.temperature!.celsius;
  } else if (tempunit == 'F') {
    return w.temperature!.fahrenheit!;
  } else {
    //K
    return w.temperature!.kelvin;
  }
}

Widget get_glance_card(
    List<Glance> glance_list,
    MyDouble maxheightgl,
    double appwidth,
    String tempunit,
    String lenghtunit,
    StateSetter setState,
    MyDouble slday_height,
    MyDouble slday_heightO) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 800),
    height: maxheightgl.value,
    width: appwidth,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        //scrollDirection: Axis.horizontal,
        children: [
          for (Glance gl in glance_list)
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                AnimatedContainer(
                  height: gl.height,
                  width: gl.width,
                  duration: Duration(milliseconds: 800),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 1),
                      color: Colors.white.withOpacity(0.2)),
                  child: Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (gl.animated == false) {
                          gl.height *= 2;
                          gl.width *= 2;
                          gl.animated = true;
                        } else {
                          gl.height /= 2;
                          gl.width /= 2;
                          gl.animated = false;
                        }

                        maxheightgl.value = gl.height;
                        for (Glance g in glance_list) {
                          if (g.w.date != gl.w.date) {
                            //if (g .animated) {
                            //   g.height /= 2;
                            //   g.width /= 2;
                            //   g.animated = false;
                            // }
                            if (g.height > maxheightgl.value)
                              maxheightgl.value = g.height;
                          }
                        }
                        slday_height.value =
                            slday_heightO.value + maxheightgl.value;
                        setState(() {});
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              convertDate(gl.w.date!, gl.w.latitude!,
                                          gl.w.longitude!)
                                      .hour
                                      .toString() +
                                  ':00',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300),
                            ),
                            Container(
                              height: 70,
                              width: 70,
                              child: SvgPicture.asset(
                                  'assets/${gl.w.weatherIcon}.svg'),
                            ),
                            Text(
                                '${getTemperature(gl.w, tempunit)!.toStringAsFixed(0)}°',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300)),
                            SizedBox(
                              width: 30,
                            ),
                            gl.animated
                                ? Column(
                                    children: [
                                      Text('${gl.w.weatherMain}°',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w300)),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: SvgPicture.asset(
                                                      'assets/wind.svg'),
                                                ),
                                                Text(
                                                  getwindspeed(
                                                      gl.w, lenghtunit),
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w200),
                                                ),
                                                Text(
                                                  'Wind',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          118, 255, 255, 255),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w200),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: SvgPicture.asset(
                                                      'assets/raindrops.svg'),
                                                ),
                                                Text(
                                                  '${getwatervolume(gl.w)} l/mp',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w200),
                                                ),
                                                Text(
                                                  'Rain last hour',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          118, 255, 255, 255),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w200),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: SvgPicture.asset(
                                                      'assets/humidity.svg'),
                                                ),
                                                Text(
                                                  '  ${gl.w.humidity!.toInt()}%',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w200),
                                                ),
                                                Text(
                                                  'Humidity',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          118, 255, 255, 255),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w200),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
