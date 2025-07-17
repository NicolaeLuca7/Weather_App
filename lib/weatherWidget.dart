import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;

import 'package:weather_app/convertDate.dart';
import 'colors.dart';
import 'day.dart';
import 'main.dart';

class WeatheWidget extends StatefulWidget {
  Weather wh;
  Map<String, Day> days_map;
  String lenghtunit;
  String tempunit;
  double appwidth;
  double appheight;
  WeatheWidget(
      {Key? key,
      required this.wh,
      required this.days_map,
      required this.lenghtunit,
      required this.tempunit,
      required this.appwidth,
      required this.appheight})
      : super(key: key);

  @override
  State<WeatheWidget> createState() => _WeatheWidgetState(
      wh: wh,
      days_map: days_map,
      lenghtunit: lenghtunit,
      tempunit: tempunit,
      appwidth: appwidth,
      appheight: appheight);
}

class _WeatheWidgetState extends State<WeatheWidget> {
  Weather wh;
  late String tempMin;
  late String tempMax;
  late DateTime date;
  double appwidth;
  double appheight;
  String lenghtunit;
  String tempunit;

  Map<String, Day> days_map;
  Map<String, List<String>> pronweath = {};
  late String selected_day;
  List<Glance> glance_list = [], glance_list1 = [];
  MyDouble slday_height = MyDouble(0);
  double daycrd_height = 80;
  MyDouble maxheightgl = MyDouble(150), fmaxheightgl = MyDouble(150);
  LinearGradient forecast_theme = LinearGradient(colors: [
    Colors.black,
    Colors.black,
    Color.fromARGB(255, 2, 26, 88),
    Colors.black
  ], begin: Alignment.bottomCenter, end: Alignment.topCenter);

  _WeatheWidgetState(
      {required this.wh,
      required this.days_map,
      required this.lenghtunit,
      required this.tempunit,
      required this.appwidth,
      required this.appheight}) {
    bool obtainedcurrentd = false;
    for (String s in days_map.keys) {
      if (!obtainedcurrentd) {
        glance_list = days_map[s]!.glance_list;
        tempMax = days_map[s]!.temp.tempMax.toInt().toString();
        tempMin = days_map[s]!.temp.tempMin.toInt().toString();
        date = DateTime.now();
        date = convertDate(date, wh.latitude!, wh.longitude!);
        selected_day = date.toString().substring(0, 10);
        obtainedcurrentd = true;
      }
      glance_list1 = days_map[s]!.glance_list;
      if (glance_list1.length > 0)
        pronweath[s] = get_pron_weat(glance_list1, lenghtunit, wh);
    }
    slday_height.value = appheight * 3.5 / 7;
  }

  double animatedbottom = 0, foreheight = 120;
  bool showhours = false;

  @override
  Widget build(BuildContext context) {
    DateTime date1, currentdate;
    currentdate = tz.TZDateTime.from(
        date,
        tz.getLocation(
            tzmap.latLngToTimezoneString(wh.latitude!, wh.longitude!)));
    String currentminutes = currentdate.minute.toString();
    if (currentminutes.length == 1) currentminutes = '0' + currentminutes;
    String dayoftheweek = DateFormat('EEEE')
            .format(
                DateTime(currentdate.year, currentdate.month, currentdate.day))
            .toString(),
        month = DateFormat('MMMM')
            .format(
                DateTime(currentdate.year, currentdate.month, currentdate.day))
            .toString();
    String sunrise, sunset;

    DateTime snrise = convertDate(wh.sunrise!, wh.latitude!, wh.longitude!),
        snset = convertDate(wh.sunset!, wh.latitude!, wh.longitude!);
    sunrise = snrise.hour.toString() + ':';
    if (snrise.minute < 10) sunrise += '0';
    sunrise += snrise.minute.toString();
    sunset = snset.hour.toString() + ':';
    if (snset.minute < 10) sunset += '0';
    sunset += snset.minute.toString();

    // secondarytheme = LinearGradient(colors: themes[wh.weatherIcon!]!.colors);
    // secondarytheme.colors.insert(0, Colors.black);
    // secondarytheme.colors.add(Colors.black);
    return Scaffold(
      //backgroundColor: themecl.color,
      body: Container(
        height: appheight,
        width: appwidth,
        decoration: BoxDecoration(gradient: secondarytheme),
        child: Center(
          child: SizedBox(
            height: appheight,
            width: appwidth,
            child: SingleChildScrollView(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: themes[wh.weatherIcon],
                        borderRadius: BorderRadius.circular(60)),
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        Text(
                          '${wh.areaName}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$dayoftheweek, ${currentdate.day} $month',
                          style: TextStyle(
                              color: Color.fromARGB(118, 255, 255, 255),
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          convertDate(currentdate, wh.latitude!, wh.longitude!)
                                  .hour
                                  .toString() +
                              ':' +
                              convertDate(
                                      currentdate, wh.latitude!, wh.longitude!)
                                  .minute
                                  .toString(),
                          style: TextStyle(
                              color: Color.fromARGB(118, 255, 255, 255),
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 250,
                          width: 300,
                          child:
                              SvgPicture.asset('assets/${wh.weatherIcon}.svg'),
                        ),
                        Text(
                          '${getTemperature(wh, tempunit)!.toStringAsFixed(0)}°',
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 100,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' $tempMax/$tempMin',
                          style: TextStyle(
                              color: Color.fromARGB(118, 255, 255, 255),
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${wh.weatherMain}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                              fontWeight: FontWeight.w300),
                        ),
                        Text(
                          '${wh.weatherDescription!.substring(0, 1).toUpperCase()}${wh.weatherDescription!.substring(1)}',
                          style: TextStyle(
                              color: Color.fromARGB(118, 255, 255, 255),
                              fontSize: 30,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: SvgPicture.asset('assets/wind.svg'),
                                ),
                                Text(
                                  getwindspeed(wh, lenghtunit),
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                                Text(
                                  'Wind',
                                  style: TextStyle(
                                      color: Color.fromARGB(118, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  child:
                                      SvgPicture.asset('assets/raindrops.svg'),
                                ),
                                Text(
                                  '${getwatervolume(wh)} l/mp',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                                Text(
                                  'Rain last hour',
                                  style: TextStyle(
                                      color: Color.fromARGB(118, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  child:
                                      SvgPicture.asset('assets/humidity.svg'),
                                ),
                                Text(
                                  '  ${wh.humidity!.toInt()}%',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                                Text(
                                  'Humidity',
                                  style: TextStyle(
                                      color: Color.fromARGB(118, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: appwidth - 100,
                          child: Divider(
                            height: 40,
                            thickness: 2,
                            color: Color.fromARGB(118, 255, 255, 255),
                          ),
                        ),
                        Row(
                          children: [
                            Spacer(),
                            Column(
                              children: [
                                Text(
                                  sunrise,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                                Text(
                                  'Sunrise',
                                  style: TextStyle(
                                      color: Color.fromARGB(118, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                                Container(
                                  height: 150,
                                  width: 150,
                                  child: SvgPicture.asset('assets/sunrise.svg'),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Text(
                                  sunset,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                                Text(
                                  'Sunset',
                                  style: TextStyle(
                                      color: Color.fromARGB(118, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200),
                                ),
                                Container(
                                  height: 150,
                                  width: 150,
                                  child: SvgPicture.asset('assets/sunset.svg'),
                                ),
                              ],
                            ),
                            Spacer(),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        showhours = !showhours;
                      });
                    },
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 50, color: Colors.white.withOpacity(0.5)),
                  ),
                  showhours
                      ? Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Today',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w300),
                                ),
                                Spacer(),
                                GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      showBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (BuildContext) => Container(
                                          height: appheight,
                                          decoration: BoxDecoration(
                                              gradient: forecast_theme,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight:
                                                      Radius.circular(20))),
                                          child: forecast_page(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          '5 days',
                                          style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(Icons.arrow_forward_ios_outlined,
                                            color:
                                                Colors.white.withOpacity(0.5)),
                                      ],
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            get_glance_card(
                                glance_list,
                                maxheightgl,
                                appwidth,
                                tempunit,
                                lenghtunit,
                                setState,
                                MyDouble(0),
                                MyDouble(0)),
                          ],
                        )
                      : Container(),
                  SizedBox(
                    height: 110,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool expandedDay = false;

  Widget forecast_page() {
    MyDouble slday_heightO = MyDouble(slday_height.value);
    MyDouble fmaxheightglO = MyDouble(fmaxheightgl.value);
    return SafeArea(
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return ListView(
          children: [
            AnimatedContainer(
              height: slday_height.value,
              duration: Duration(
                milliseconds: 800,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  gradient: themes[pronweath[selected_day]![2]]),
              child: SingleChildScrollView(
                  //dragStartBehavior: DragStartBehavior.down,
                  child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      IconButton(
                        highlightColor: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                          expandedDay = false;
                          slday_height.value = slday_heightO.value;
                          fmaxheightgl.value = fmaxheightglO.value;
                          slday_height.value = slday_heightO.value;
                          for (Glance g
                              in days_map[selected_day]!.glance_list) {
                            g.animated = false;
                            if (g.height != 150) {
                              g.height /= 2;
                              g.width /= 2;
                            }
                          }
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Text(
                            DateFormat('EEEE')
                                .format(DateTime(
                                    int.parse(selected_day.substring(0, 4)),
                                    int.parse(selected_day.substring(5, 7)),
                                    int.parse(selected_day.substring(8))))
                                .toString(),
                            style: TextStyle(
                                color: Color.fromARGB(118, 255, 255, 255),
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                '${days_map[selected_day]!.temp.tempMax.toInt()}°',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '/${days_map[selected_day]!.temp.tempMin.toInt()}°',
                                style: TextStyle(
                                    color: Color.fromARGB(118, 255, 255, 255),
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            '${pronweath[selected_day]![1]}',
                            style: TextStyle(
                                color: Color.fromARGB(118, 255, 255, 255),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Spacer(),
                      SvgPicture.asset(
                        'assets/${pronweath[selected_day]![2]}.svg',
                        height: 150,
                        width: 150,
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(
                    width: appwidth - 100,
                    child: Divider(
                      height: 40,
                      thickness: 2,
                      color: Color.fromARGB(118, 255, 255, 255),
                    ),
                  ),

                  Row(
                    children: [
                      Spacer(),
                      Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            child: SvgPicture.asset('assets/wind.svg'),
                          ),
                          Text(
                            pronweath[selected_day]![3],
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 20,
                                fontWeight: FontWeight.w200),
                          ),
                          Text(
                            'Wind',
                            style: TextStyle(
                                color: Color.fromARGB(118, 255, 255, 255),
                                fontSize: 20,
                                fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            child: SvgPicture.asset('assets/humidity.svg'),
                          ),
                          Text(
                            '${pronweath[selected_day]![4]}%',
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 20,
                                fontWeight: FontWeight.w200),
                          ),
                          Text(
                            'Humidity',
                            style: TextStyle(
                                color: Color.fromARGB(118, 255, 255, 255),
                                fontSize: 20,
                                fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                      Spacer(),
                    ],
                  ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  //
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (expandedDay) {
                          slday_height.value = slday_heightO.value;
                          fmaxheightgl.value = fmaxheightglO.value;
                          slday_height.value = slday_heightO.value;
                          for (Glance g
                              in days_map[selected_day]!.glance_list) {
                            g.animated = false;
                            if (g.height != 150) {
                              g.height /= 2;
                              g.width /= 2;
                            }
                          }
                        } else {
                          slday_height.value += maxheightgl.value;
                        }
                        expandedDay = !expandedDay;
                      });
                    },
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 50, color: Colors.white.withOpacity(0.5)),
                  ),
                  expandedDay
                      ? Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            get_glance_card(
                                days_map[selected_day]!.glance_list,
                                fmaxheightgl,
                                appwidth,
                                tempunit,
                                lenghtunit,
                                setState,
                                slday_height,
                                slday_heightO),
                          ],
                        )
                      : Container(),
                  //
                ],
              )),
            ),
            for (String strd in days_map.keys)
              pronweath[strd]?.length == 5
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        String old_day = selected_day;
                        selected_day = strd;
                        fmaxheightgl.value = fmaxheightglO.value;
                        slday_height.value = slday_heightO.value;
                        if (expandedDay)
                          slday_height.value += fmaxheightgl.value;
                        for (Glance g in days_map[selected_day]!.glance_list) {
                          g.animated = false;
                          if (g.height != 150) {
                            g.height /= 2;
                            g.width /= 2;
                          }
                        }
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Spacer(),
                          Container(
                              height: foreheight,
                              width: appwidth,
                              child: Row(
                                children: [
                                  Spacer(),
                                  Text(
                                    DateFormat('EEEE')
                                        .format(DateTime(
                                            int.parse(strd.substring(0, 4)),
                                            int.parse(strd.substring(5, 7)),
                                            int.parse(strd.substring(8))))
                                        .toString(),
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(118, 255, 255, 255),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    child: SvgPicture.asset(
                                        'assets/${pronweath[strd]?[2]}.svg'),
                                  ),
                                  Text(
                                    '${pronweath[strd]![0]}',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(118, 255, 255, 255),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Text(
                                    '${days_map[strd]!.temp.tempMax.toInt()}/${days_map[strd]!.temp.tempMin.toInt()}',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(118, 255, 255, 255),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                ],
                              )),
                          Spacer(),
                        ],
                      ),
                    )
                  : Container(),
          ],
        );
      }),
    );
  }
}
