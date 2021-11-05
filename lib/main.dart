// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  // Firebase Init
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        DetailsPage.routeName: (context) => const DetailsPage(),
      },
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
      ),
      home: const MyHomePage(title: 'Restaurants Mobile App'),
    );
  }
}

// Home Page
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Main Page
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        // Stream builder
        body: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('restaurants').snapshots(),
          builder: (BuildContext bc, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text('Nothing is here...');
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext bc, int index) {
                  final docData = snapshot.data!.docs[index].data() as Map;
                  return GestureDetector(
                    onTap: () {
                      // Navigator to details page with arguments
                      Navigator.pushNamed(
                        context,
                        DetailsPage.routeName,
                        arguments: Restaurant(
                            docData['name'],
                            docData['description'],
                            docData['image'],
                            docData['menu']),
                      );
                    },
                    // List element
                    child: Card(
                      child: Text(docData["name"]),
                    ),
                  );
                });
          },
        ));
  }
}

// Restaurant class
class Restaurant {
  final String name;
  final String description;
  final String image;
  final List<dynamic> menu;

  Restaurant(this.name, this.description, this.image, this.menu);
}

// Details Widget
class DetailsPage extends StatelessWidget {
  const DetailsPage({Key? key}) : super(key: key);

  static const routeName = '/details';

  @override
  Widget build(BuildContext context) {
    // Arguments from parent widget
    final args = ModalRoute.of(context)!.settings.arguments as Restaurant;
    return Scaffold(
      appBar: AppBar(
        title: Text(args.name),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(args.name, style: TextStyle(fontSize: 32)),
              SizedBox(height: 50.0),
              Text(args.description,
                  style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
              SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Text('Menu',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    ...args.menu.map((food) => Text(food)).toList()
                  ]),
                  Column(children: [
                    Text('Popular',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    ...args.menu.map((food) => Text(food)).toList()
                  ])
                ],
              )
            ],
          )),
    );
  }
}
