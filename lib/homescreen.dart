import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'constants.dart' as k;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isloaded = false;
  num? temperature;
  num? pressure;
  num? humidity;
  num? cover;
  String cityname = '';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xff85FFBD),
            Color(0xffFFFB7D),
          ], begin: Alignment.bottomLeft, end: Alignment.topRight),
        ),
        child: Visibility(
          visible: isloaded,
          replacement: const Center(child: CircularProgressIndicator()),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 85,
                height: MediaQuery.of(context).size.height * .09,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: TextFormField(
                    onFieldSubmitted: (String name) {
                      setState(() {
                        cityname = name;

                        isloaded = false;
                        controller.clear();
                      });
                    },
                    controller: controller,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search City',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 25,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.pin_drop,
                      size: 40,
                      color: Colors.red,
                    ),
                    Text(
                      cityname,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomCard(
                text: 'Temperature: ${temperature?.toStringAsFixed(1)}ºC',
                image: 'assets/images/thermometer.png',
              ),
              CustomCard(
                text: 'Pressure: ${pressure?.toInt()} hPa',
                image: 'assets/images/pressure.png',
              ),
              CustomCard(
                text: 'Humidity: ${humidity?.toInt()} %',
                image: 'assets/images/humidity.png',
              ),
              CustomCard(
                  text: 'Cloud cover: ${cover?.toInt()} %',
                  image: 'assets/images/cloud.png'),
            ],
          ),
        ),
      ),
    ));
  }

  getCurrentLocation() async {
    var p = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
    if (p != null) {
      print('Latitude:${p.latitude}, Longitude:${p.longitude}');
      getCurrentCityWeather(p);
    } else {
      print('Data Unavailable');
    }
    getCityWeather(String cityname) async {
      var client = http.Client();
      var uri = '${k.domain}q=$cityname &appid=${k.apiKey}';
      var url = Uri.parse(uri);
      var response = await client.get(url);
      if (response.statusCode == 200) {
        var data = response.body;
        var decodedData = json.decode(data);
        print(data);
        updateUI(decodedData);
        setState(() {
          isloaded = true;
        });
      } else {
        print(response.statusCode);
      }
    }
  }

  getCurrentCityWeather(Position position) async {
    var client = http.Client();
    var uri =
        '${k.domain}lat=${position.latitude}&lon=${position.longitude}&appid=${k.apiKey}';
    var url = Uri.parse(uri);
    var response = await client.get(url);
    if (response.statusCode == 200) {
      var data = response.body;
      var decodedData = json.decode(data);
      print(data);
      updateUI(decodedData);
      setState(() {
        isloaded = true;
      });
    } else {
      print(response.statusCode);
    }
  }

  updateUI(var decodedData) {
    setState(() {
      if (decodedData == null) {
        temperature = 0;
        pressure = 0;
        humidity = 0;
        cover = 0;
        cityname = "not available";
      } else {
        temperature = decodedData['main']['temp'] - 273;
        pressure = decodedData['main']['pressure'];
        humidity = decodedData['main']['humidity'];
        cover = decodedData['clouds']['all'];
        cityname = decodedData['name'];
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }
}

class CustomCard extends StatelessWidget {
  String text;
  String image;
  CustomCard({required this.text, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * .12,
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade900,
            offset: Offset(1, 2),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              image: AssetImage(image),
              width: MediaQuery.of(context).size.width * 0.15,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
