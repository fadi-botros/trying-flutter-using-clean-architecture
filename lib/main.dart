import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:io';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

abstract class HomePageInterface {
  void startLoading();
  void presentResult(String result);
  void stopLoading();
}

class _MyHomePageState extends State<MyHomePage> implements HomePageInterface {

  _MyHomePageState(): super() {
    // The APIWeatherRepository should not be passed here, keep the view unaware of the web and other
    // layers.
    presenter = new WeatherPresenter(this, new APIWeatherRepository());
  }

  String cityName = "";
  bool isLoading = false;
  String weather = "";
  WeatherPresenter presenter;

  void _setCityName(String value) {
    setState(() {
      cityName = value;
    });
  }

  void _startLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void _stopLoading() {
    setState(() {
      isLoading = false;
    });
  }

  void _setWeather(String value) {
    setState(() {
      weather = value;
    });
  }

  @override
  void startLoading() {
    _startLoading();
  }

  @override
  void stopLoading() {
    _stopLoading();
  }

  @override
  void presentResult(String result) {
    _setWeather(result);
  }

  bool focused = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
            new TextField(
              controller: new TextEditingController(text: cityName),
              onChanged: (String text) {_setCityName(text);},
            ),
            new Text(weather)
          ];

          if (isLoading) {
            children.insert(1, new CircularProgressIndicator(
            ));
          }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () { presenter.beginForLoading(cityName); },
        tooltip: 'Start',
        child: new Icon(Icons.add),
      ),
    );
  }
}

// This is "Clean Architecture" stuff
// Could be applied to any language, but must be refined.

class WeatherPresenter {
  APIWeatherRepository repository;
  HomePageInterface interface;

  // In real life, the repository should be taken from a dependency injection
  WeatherPresenter(HomePageInterface interface, APIWeatherRepository repository) {
    this.interface = interface;
    this.repository = repository;
  }

  void beginForLoading(String city) {
    interface.startLoading();
    repository.getTemp(city, (String data) { 
      interface.stopLoading();
      interface.presentResult(data); 
    }, (){
      interface.stopLoading();
      interface.presentResult("Error occured");
    });
  }
}

abstract class WeatherDeserializer<T> {
  void deserialize(T from, void result (String temp), void onError());
}

class WeatherJSONDeserializer implements WeatherDeserializer<List<int>> {
  @override
  void deserialize(List<int> from, void result (String temp), void onError()) {
    Int8List list = new Int8List.fromList(from);
    var dataAsArray = new JSONMessageCodec().decodeMessage(new ByteData.view(list.buffer));

    // Could be done simply using a try/catch
    // But for clean code, favour checking over try/catch, according to Martin Fowler
    if (!(dataAsArray is Map)) { onError(); return; }
    if (!dataAsArray.containsKey("main")) { onError(); return; }
    if (!(dataAsArray["main"] is Map)) { onError(); return; }
    if (!(dataAsArray["main"].containsKey("temp"))) { onError(); return; }

    String resultAsString = dataAsArray["main"]["temp"].toString();
    // This temperature is in Kelvin, so we need to parse the string, subtract the 273,
    // and revert to String,  in real life, this should be in a converter function.
    try {
      double inCelsius = double.parse(resultAsString) - 273.0;
      result(inCelsius.toString());
    } catch (ex) {
      onError();
    }
  }
}

abstract class WeatherRepository {
  void getTemp(String forCity, void onData(String data), void onError());
}

class APIWeatherRepository implements WeatherRepository {

  // Tightly coupled, because the API always return JSON.
  WeatherDeserializer<List<int>> deserializer = new WeatherJSONDeserializer();

  @override
  void getTemp(String forCity, void onData(String data), void onError()) {
    HttpClient httpClient = new HttpClient(); 
    // Base URL should get them from a dependency injection source or something.
    // And the query parameters (like API Key for example), should be generated by code from a Map.
    String url = "http://api.openweathermap.org/data/2.5/weather?q=$forCity&apikey=a0cd7076ef80d5d1668c774288bec764";

    // Should be something like a framework that simplify the requests
    httpClient.getUrl(Uri.parse(url)).then((HttpClientRequest req) {
      return req.close();
    }).then((HttpClientResponse response) {
      if (response.statusCode == 200) {
        response.listen((List<int> data) {
          deserializer.deserialize(data, (String string) { onData(string); }, () { onError(); });
        });
      } else {
        onError();        
      }
    });

  }
}
