import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:weather_app/main.dart';

import 'keywords.dart';

class Settings extends StatefulWidget {
  Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  double appwidth = 0, appheight = 0;
  bool isDropped = false;
  List<String> langs = [];

  TextEditingController textCnt = TextEditingController(text: selectedLang);

  @override
  void initState() {
    langs = langList;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appwidth = MediaQuery.of(context).size.width;
    appheight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Column(children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 30)),
              Spacer(),
              Text("Settings",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w300)),
              Spacer(),
            ],
          ),
          SizedBox(height: 30),
          Container(
              height: appheight / 2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: Color.fromARGB(255, 2, 26, 88), width: 4)),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Text(
                        translatedWords["Language"]!,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300),
                      ),
                      Spacer(),
                      SizedBox(
                        height: 40,
                        width: 150,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.black,
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedLang,
                            icon:
                                const Icon(Icons.keyboard_arrow_down_outlined),
                            elevation: 16,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            underline: Container(
                              height: 2,
                              color: Color.fromARGB(255, 2, 26, 88),
                            ),
                            onChanged: (String? newValue) {
                              setState(() async {
                                selectedLang = newValue!;
                                await TranslateWords(languages[selectedLang]!);
                              });
                            },
                            items: langs
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Text(
                        "Temperature Unit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300),
                      ),
                      Spacer(),
                      SizedBox(
                        height: 40,
                        width: 100,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.black,
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: tempunit,
                            icon:
                                const Icon(Icons.keyboard_arrow_down_outlined),
                            elevation: 16,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            underline: Container(
                              height: 2,
                              color: Color.fromARGB(255, 2, 26, 88),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                tempunit = newValue!;
                              });
                            },
                            items: ['C', 'F', 'K']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Text(
                        "Length Unit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300),
                      ),
                      Spacer(),
                      SizedBox(
                        height: 40,
                        width: 100,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.black,
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: lengthunit,
                            icon:
                                const Icon(Icons.keyboard_arrow_down_outlined),
                            elevation: 16,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            underline: Container(
                              height: 2,
                              color: Color.fromARGB(255, 2, 26, 88),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                lengthunit = newValue!;
                              });
                            },
                            items: ['km', 'mi']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ],
              ))
        ])));
  }
}
