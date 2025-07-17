import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

import 'package:weather/weather.dart';
import 'package:location/location.dart' as loc;
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:instant/instant.dart';
import 'package:weather_app/convertDate.dart';
import 'package:weather_app/weatherWidget.dart';

import 'colors.dart';
import 'day.dart';
import 'settings_page.dart';

WeatherFactory wf = new WeatherFactory("API_KEY");
loc.LocationData? _currentLocation;
String? _address, _dateTime;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Map<String, List<Weather>> forecasts = {};

class Location {
  double lat = 0, lon = 0;
  Location(this.lat, this.lon);
}

List<Weather?> weathers = [];
String tempunit = 'C', lengthunit = 'km';

class _MyHomePageState extends State<MyHomePage> {
  Weather? w;
  MyColor themecl = MyColor();
  loc.Location location = loc.Location();

  Map<String, Map<String, Day>> days_map = {}; //??
  List<Location> locations = [];
  List<String> locnames = [];
  double appwidth = 0, appheight = 0;
  bool darkMode = false;

  bool updating = true;

  /*
    
  */
  Future<void> getLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('Locations');
    if (list != null) {
      for (String str in list) {
        int i = 0;
        while (str[i] != ',') i++;
        locations.add(Location(double.parse(str.substring(0, i)),
            double.parse(str.substring(i + 1))));
      }
    }
  }

  Future<void> saveLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = [];
    for (int i = 0; i < locations.length; i++) {
      list.add('${locations[i].lat},${locations[i].lon}');
    }
    await prefs.setStringList('Locations', list);
  }

  Future<void> getWeather() async {
    DateTime d;
    //List<Placemark> placemarks = await placemarkFromCoordinates(
    //  _currentLocation!.latitude!, _currentLocation!.longitude!);
    //currentcity = placemarks[1].name!;
    weathers.clear();
    w = await wf.currentWeatherByLocation(
        _currentLocation!.latitude!, _currentLocation!.longitude!);
    weathers.add(w);
    forecasts[w!.areaName!] = await wf.fiveDayForecastByLocation(
        _currentLocation!.latitude!, _currentLocation!.longitude!);
    // var client = http.Client();
    // var uri = Uri.parse(
    //     'https://api.openweathermap.org/data/2.5/forecast?lat=${w?.latitude}&lon=${w?.longitude}&appid=948d1c01c03b0d40f373f3b61d1859eb');
    // var response = await client.get(uri);
    Map<String, Day> mpd = {};
    List<Weather> weaths = [];
    forecasts[w!.areaName!] = await wf.fiveDayForecastByLocation(
        _currentLocation!.latitude!, _currentLocation!.longitude!);
    double max = 0, min = 1000000;
    weaths = forecasts[w!.areaName!]!.toList();

    d = DateTime.now();
    if (d.hour == 23) {
      d.add(Duration(minutes: 60 - d.minute));
    }
    String date_now = d.toString().substring(0, 10);
    String date = weaths[0].date.toString().substring(0, 10), str;
    if (date_now != date) {
      double mint, maxt;
      if (tempunit == 'K') {
        mint = w!.tempMin!.kelvin!;
        maxt = w!.tempMax!.kelvin!;
      } else if (tempunit == 'F') {
        mint = w!.tempMin!.fahrenheit!;
        maxt = w!.tempMax!.fahrenheit!;
      } else {
        //C
        mint = w!.tempMin!.celsius!;
        maxt = w!.tempMax!.celsius!;
      }
      mpd[date_now] =
          Day(temp: TempMinMax(mint, maxt), glance_list: [Glance(w: w!)]);
    }
    double t;
    if (tempunit == 'K') {
      t = weaths[0].temperature!.kelvin!;
    } else if (tempunit == 'F') {
      t = weaths[0].temperature!.fahrenheit!;
    } else {
      //C
      t = weaths[0].temperature!.celsius!;
    }
    if (max < t) {
      max = t;
    }
    if (min > t) {
      min = t;
    }
    List<Glance> glance_list = [];
    glance_list.add(Glance(w: weaths[0]));
    int i = 1;
    while (i < weaths.length) {
      d = convertDate(
          weaths[i].date!, weaths[i].latitude!, weaths[i].longitude!);
      if (d.hour == 23) {
        d.add(Duration(minutes: 60 - d.minute));
      }
      str = d.toString().substring(0, 10);

      if (str == date) {
        if (tempunit == 'K') {
          t = weaths[i].temperature!.kelvin!;
        } else if (tempunit == 'F') {
          t = weaths[i].temperature!.fahrenheit!;
        } else {
          //C
          t = weaths[i].temperature!.celsius!;
        }
        if (max < t) {
          max = t;
        }
        if (min > t) {
          min = t;
        }
        glance_list.add(Glance(w: weaths[i]));
      } else {
        mpd[date] =
            Day(temp: TempMinMax(min, max), glance_list: glance_list.toList());
        date = str;
        min = 1000000;
        max = 0;
        glance_list.clear();
      }
      i++;
    }

    mpd[date] =
        Day(temp: TempMinMax(min, max), glance_list: glance_list.toList());
    days_map[w!.areaName!] = Map<String, Day>.from(mpd);
    mpd.clear();
    glance_list.clear();
    weaths.clear();
    locnames.clear();

    for (Location loc in locations) {
      w = await wf.currentWeatherByLocation(loc.lat, loc.lon);
      locnames.add(w!.areaName!);
      d = convertDate(DateTime.now(), w!.latitude!, w!.longitude!);
      if (d.hour == 23) {
        d.add(Duration(minutes: 60 - d.minute));
      }
      date_now = d.toString().substring(0, 10);
      weathers.add(w);
      forecasts[w!.areaName!] =
          await wf.fiveDayForecastByLocation(loc.lat, loc.lon);
      max = 0;
      min = 10000000;
      weaths = forecasts[w!.areaName]!.toList();
      d = convertDate(
          weaths[0].date!, weaths[0].latitude!, weaths[0].longitude!);
      if (d.hour == 23) {
        d.add(Duration(minutes: 60 - d.minute));
      }
      String date = d.toString().substring(0, 10),
          /*convertDate(
                  weaths[0].date!, weaths[0].latitude!, weaths[0].longitude!)
              .toString()
              .substring(0, 10),*/
          str;

      if (date_now != date) {
        double mint, maxt;
        if (tempunit == 'K') {
          mint = w!.tempMin!.kelvin!;
          maxt = w!.tempMax!.kelvin!;
        } else if (tempunit == 'F') {
          mint = w!.tempMin!.fahrenheit!;
          maxt = w!.tempMax!.fahrenheit!;
        } else {
          //C
          mint = w!.tempMin!.celsius!;
          maxt = w!.tempMax!.celsius!;
        }
        mpd[date_now] =
            Day(temp: TempMinMax(mint, maxt), glance_list: [Glance(w: w!)]);
      }
      if (tempunit == 'K') {
        t = weaths[0].temperature!.kelvin!;
      } else if (tempunit == 'F') {
        t = weaths[0].temperature!.fahrenheit!;
      } else {
        //C
        t = weaths[0].temperature!.celsius!;
      }
      if (max < t) {
        max = t;
      }
      if (min > t) {
        min = t;
      }
      i = 1;
      glance_list.add(Glance(w: weaths[0]));
      while (i < weaths.length) {
        d = convertDate(
            weaths[i].date!, weaths[i].latitude!, weaths[i].longitude!);
        if (d.hour == 23) {
          d.add(Duration(minutes: 60 - d.minute));
        }
        str = d.toString().substring(0, 10);
        if (str == date) {
          if (tempunit == 'K') {
            t = weaths[i].temperature!.kelvin!;
          } else if (tempunit == 'F') {
            t = weaths[i].temperature!.fahrenheit!;
          } else {
            //C
            t = weaths[i].temperature!.celsius!;
          }
          if (max < t) {
            max = t;
          }
          if (min > t) {
            min = t;
          }
          glance_list.add(Glance(w: weaths[i]));
        } else {
          mpd[date] = Day(
              temp: TempMinMax(min, max), glance_list: glance_list.toList());
          date = str;
          min = 1000000;
          max = 0;
          glance_list.clear();
        }
        i++;
      }
      mpd[date] =
          Day(temp: TempMinMax(min, max), glance_list: glance_list.toList());
      days_map[w!.areaName!] = Map<String, Day>.from(mpd);
      mpd.clear();
      glance_list.clear();
      weaths.clear();
    }
    updating = false;
    setState(() {});
  }

  @override
  initState() {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    getLocations();
    checkpermision();

    super.initState();
  }

  var permissionGranted;
  Future<void> checkpermision() async {
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    _currentLocation = await location.getLocation();
    getWeather();
    setState(() {});
  }

  PageController cnt = PageController();

  @override
  Widget build(BuildContext context) {
    appheight = MediaQuery.of(context).size.height;
    appwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      //backgroundColor: themecl.color,

      body: Container(
          decoration: BoxDecoration(gradient: themes['01d']),
          child: Stack(
            children: [
              !updating
                  ? Center(
                      child: PageView(
                        controller: cnt,
                        children: [
                          for (Weather? wh in weathers)
                            WeatheWidget(
                                wh: wh!,
                                days_map: days_map[wh.areaName!]!,
                                lenghtunit: lengthunit,
                                tempunit: tempunit,
                                appwidth: appwidth,
                                appheight: appheight),
                        ],
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
              Positioned(
                bottom: 10,
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          //gradient: secondarytheme,
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20)),
                      height: 60,
                      width: appwidth - 20,
                      child: Center(
                          child: Row(
                        children: [
                          Spacer(),
                          IconButton(
                              tooltip: 'Refresh',
                              iconSize: 40,
                              onPressed: () {
                                if (updating) return;
                                updating = true;
                                setState(() {});
                                getWeather();
                              },
                              icon: Icon(
                                Icons.restart_alt_outlined,
                                color: Colors.white,
                              )),
                          Spacer(),
                          IconButton(
                              tooltip: 'Settings',
                              iconSize: 40,
                              onPressed: () async {
                                if (updating) return;
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        Settings(),
                                  ),
                                );

                                updating = true;
                                setState(() {});
                                getWeather();
                              },
                              icon: Icon(
                                Icons.settings,
                                color: Colors.white,
                              )),
                          Spacer(),
                          IconButton(
                              tooltip: 'Edit locations',
                              iconSize: 40,
                              onPressed: () {
                                if (updating) return;
                                List<String> names = locnames.toList();
                                List<Location> locs = locations.toList();
                                LatLng point = LatLng(
                                    _currentLocation!.latitude!,
                                    _currentLocation!.longitude!);
                                List<Weather?> weathers1 = weathers.toList();

                                showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (BuildContext) => Container(
                                    height: appheight,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20))),
                                    child: Column(children: [
                                      Flexible(
                                        child: StatefulBuilder(builder:
                                            (context, StateSetter setState) {
                                          return ReorderableListView(
                                            onReorder: (oldIndex, newIndex) {
                                              setState(() {
                                                if (newIndex > oldIndex)
                                                  newIndex--;
                                                String name =
                                                    names.removeAt(oldIndex);
                                                names.insert(newIndex, name);
                                                Location loc =
                                                    locs.removeAt(oldIndex);
                                                locs.insert(newIndex, loc);
                                                Weather? w = weathers1
                                                    .removeAt(oldIndex + 1);
                                                weathers1.insert(
                                                    newIndex + 1, w);
                                              });
                                            },
                                            children: [
                                              for (String s in names)
                                                ListTile(
                                                  tileColor: Colors.black,
                                                  textColor: Colors.white,
                                                  iconColor: Colors.white,
                                                  key: ValueKey(s),
                                                  title: Row(children: [
                                                    Text(s,
                                                        style: TextStyle(
                                                            fontSize: 20)),
                                                    Spacer(),
                                                    IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            int index = names
                                                                .indexOf(s);
                                                            locs.removeAt(
                                                                index);
                                                            weathers1.removeAt(
                                                                index + 1);
                                                            names.remove(s);
                                                          });
                                                        },
                                                        icon: Icon(
                                                            Icons
                                                                .delete_rounded,
                                                            color:
                                                                Colors.white))
                                                  ]),
                                                ),
                                            ],
                                          );
                                        }),
                                      ),
                                      Row(
                                        children: [
                                          Spacer(),
                                          IconButton(
                                              onPressed: () {
                                                MapController map_cntrl =
                                                    MapController();
                                                TextEditingController
                                                    location_name =
                                                    TextEditingController();
                                                var location = [];
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Scaffold(
                                                        body: Stack(
                                                          children: [
                                                            FlutterMap(
                                                              mapController:
                                                                  map_cntrl,
                                                              options:
                                                                  MapOptions(
                                                                onTap: (p, lt) {
                                                                  setState(() {
                                                                    point.latitude =
                                                                        lt.latitude;
                                                                    point.longitude =
                                                                        lt.longitude;

                                                                    map_cntrl.move(
                                                                        point,
                                                                        map_cntrl
                                                                            .zoom);
                                                                  });
                                                                },
                                                                center: point,
                                                                // center: LatLng(
                                                                //   _currentLocation!
                                                                //       .latitude!,
                                                                //   _currentLocation!
                                                                //       .longitude!,
                                                                // ),
                                                                zoom: 10.0,
                                                              ),
                                                              layers: [
                                                                TileLayerOptions(
                                                                  urlTemplate:
                                                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                                                  subdomains: [
                                                                    'a',
                                                                    'b',
                                                                    'c'
                                                                  ],
                                                                ),
                                                                MarkerLayerOptions(
                                                                  markers: [
                                                                    Marker(
                                                                      width:
                                                                          80.0,
                                                                      height:
                                                                          80.0,
                                                                      point:
                                                                          point,
                                                                      builder:
                                                                          (ctx) =>
                                                                              Container(
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .location_on,
                                                                          color:
                                                                              Colors.red,
                                                                          size:
                                                                              40,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 24,
                                                                  horizontal:
                                                                      16),
                                                              child: Column(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          60,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          SizedBox(
                                                                              width: 10),
                                                                          Flexible(
                                                                            child:
                                                                                TextField(
                                                                              controller: location_name,
                                                                              decoration: InputDecoration(hintText: 'Location Name'),
                                                                              style: TextStyle(fontSize: 20),
                                                                            ),
                                                                          ),
                                                                          IconButton(
                                                                              onPressed: () async {
                                                                                try {
                                                                                  Weather w = await wf.currentWeatherByCityName(location_name.text);
                                                                                  point.latitude = w.latitude!;
                                                                                  point.longitude = w.longitude!;
                                                                                  map_cntrl.move(point, map_cntrl.zoom);
                                                                                  map_cntrl.rotate(0);
                                                                                } catch (e) {
                                                                                  showDialog(
                                                                                      context: context,
                                                                                      builder: (builder) {
                                                                                        return Center(
                                                                                          child: Container(
                                                                                            height: 200,
                                                                                            width: appwidth - 60,
                                                                                            child: Center(
                                                                                              child: Column(children: [
                                                                                                Spacer(),
                                                                                                Text(
                                                                                                  "Not found",
                                                                                                  style: TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.w400, decoration: TextDecoration.none),
                                                                                                ),
                                                                                                Spacer(
                                                                                                  flex: 2,
                                                                                                ),
                                                                                                TextButton(
                                                                                                  onPressed: () {
                                                                                                    Navigator.of(context).pop();
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    "OK",
                                                                                                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400, decoration: TextDecoration.none),
                                                                                                  ),
                                                                                                )
                                                                                              ]),
                                                                                            ),
                                                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                                                                                          ),
                                                                                        );
                                                                                      });
                                                                                }
                                                                                setState(() {});
                                                                              },
                                                                              icon: Icon(Icons.search))
                                                                        ],
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              20),
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    Spacer(),
                                                                    Container(
                                                                        width:
                                                                            appwidth /
                                                                                4,
                                                                        height:
                                                                            60,
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                                20),
                                                                            color: Colors
                                                                                .white),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            IconButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                icon: Icon(Icons.arrow_back_ios_new_rounded)),
                                                                            Spacer(),
                                                                            IconButton(
                                                                                onPressed: () {
                                                                                  locations.add(Location(point.latitude, point.longitude));
                                                                                  saveLocations();
                                                                                  setState(() {});
                                                                                  Navigator.of(context).pop();
                                                                                  Navigator.of(context).pop();
                                                                                  getWeather();
                                                                                },
                                                                                icon: Icon(Icons.save_alt_rounded))
                                                                          ],
                                                                        ))
                                                                  ]),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              },
                                              icon: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 40,
                                              )),
                                          Spacer(),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Spacer(),
                                          TextButton(
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 20),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          Spacer(),
                                          TextButton(
                                            child: Text(
                                              'Save',
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 20),
                                            ),
                                            onPressed: () {
                                              locnames = names.toList();
                                              locations = locs.toList();
                                              weathers = weathers1.toList();
                                              Navigator.pop(context);
                                              saveLocations();
                                              setState(() {});
                                            },
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                    ]),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.edit_location_alt_outlined,
                                color: Colors.white,
                              )),
                          Spacer(),
                        ],
                      )),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
