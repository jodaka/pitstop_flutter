import 'package:flutter/material.dart';
import 'races_list.dart';

void main() => runApp(MyApp());

class Club {
  final String id;
  final String name;
  final String title;

  Club({this.id, this.name, this.title});
}

class ClubsList {
  static List<Club> list = [
    Club(id: "586", name: "pulkovo", title: "Пулково"),
    Club(id: "686", name: "drive", title: "Драйв"),
    Club(id: "786", name: "pulkovo", title: "Нарвская"),
    Club(id: "25506", name: "pulkovo", title: "Ладожская"),
  ];
}

class MyApp extends StatelessWidget {

  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Pitstop',
      home: _clubsList()
    );
  }

  Widget _generateClubButton(Club club) {
    return Container(
      child: RaisedButton(
      padding: const EdgeInsets.all(8),
      onPressed: () {
        _showClubRacesScreen(club.id);
      },
      child: Text(club.title),
      )
    );
  }

  Widget _clubsList() {
    return Center(
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(50),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: ClubsList.list.map((Club club) => _generateClubButton(club)).toList()
      )
    );
  }

  void _showClubRacesScreen(String clubId) {
    navigatorKey.currentState.push(
      MaterialPageRoute(builder: (context) => RacesList(clubId)),
    );
  }
}