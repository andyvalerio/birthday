import 'dart:collection';

import 'package:birthday/birthday_widget.dart';
import 'package:date_util/date_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:slidable_action/widget/slidable_widget.dart';

import 'auth.dart';
import 'crud_birthday.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Birthday App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _initialized = false;
  bool _error = false;
  String message = "";
  Auth auth = Auth.instance;
  FirebaseDatabase database;
  Map<String, Map> birthdays = Map<String, Map>();

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return ErrorWidget(_error);
    }

    if (!_initialized) {
      return Scaffold();
    }

    if (auth.status == Status.not_ready || auth.status == Status.signed_out) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Login to get started',
                style: Theme.of(context).textTheme.headline4,
              ),
              FloatingActionButton(
                  child: Icon(Icons.account_box_outlined),
                  onPressed: () => signIn())
            ],
          ),
        ),
      );
    }

    if (auth.status == Status.signed_in) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                    flex: 9,
                    child: ListView.separated(
                      primary: false,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: birthdays.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        var keyAt = birthdays.keys.elementAt(index);
                        final item = birthdays[keyAt];
                        return SlidableWidget(
                          child: BirthdayTile(item.keys.first,
                              toPrettyDate(item.values.first), 300 + index),
                          onDismissed: (action) => setState(() {
                            deleteBirthday(keyAt);
                          }),
                        );
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: Stack(children: <Widget>[
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: FloatingActionButton(
                              onPressed: () => signOut(),
                              child: Icon(Icons.logout),
                              heroTag: 'logout')),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CrudBirthday()));
                            },
                            child: Icon(Icons.add),
                            heroTag: 'birthday',
                          ))
                    ]))
              ]),
        ),
      );
    }

    print('Or here');
    return Scaffold();
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
        database = FirebaseDatabase();
        signIn();
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  void readDatabase() {
    database
        .reference()
        .child('birthdays')
        .child(auth.userId)
        .onValue
        .listen((event) {
      birthdays.clear();
      var map = HashMap.from(event.snapshot.value);
      for (String key in map.keys) {
        var birthday = HashMap.from(map[key]);
        birthdays.putIfAbsent(key, () => birthday);
      }
      setState(() {});
    });
  }

  signOut() async {
    await auth.signOut();
    setState(() {});
  }

  signIn() async {
    await auth.initAuth();
    setState(() {
      readDatabase();
      saveToken();
    });
  }

  String toPrettyDate(String date) {
    var split = date.split('-');
    var day = split[0];
    var month = split[1];
    return day + ' ' + DateUtil().month(int.parse(month));
  }

  deleteBirthday(String key) async {
    await database
        .reference()
        .child('birthdays')
        .child(auth.userId)
        .child(key)
        .remove();
    setState(() {});
  }

  void saveToken() {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((token) {
      database
          .reference()
          .child('tokens')
          .child(auth.userId)
          .set(<String, String>{'android': token});
    });
  }
}
