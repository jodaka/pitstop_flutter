import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Race {
  final int best;
  final int clubid;
  final String date;
  final int id;
  final int laps;
  final String name;
  final String winner;
  final int winnerId;
  final int winnerKart;

  Race({
    this.best,
    this.clubid,
    this.date,
    this.id,
    this.laps,
    this.name,
    this.winner,
    this.winnerId,
    this.winnerKart
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      best: json['best'],
      clubid: json['clubid'],
      date: json['date'],
      id: json['id'],
      laps: json['laps'],
      name: json['name'],
      winner: json['winner'],
      winnerId: json['winnerId'],
      winnerKart: json['winnerKart'],
    );
  }
}

class RacesResponse {
  final List<Race> data;
  final int total;

  RacesResponse({
    this.data,
    this.total
  });

  factory RacesResponse.fromJson(Map<String, dynamic> racesListJsonResponse) {

    var rawRaceslist = racesListJsonResponse['data'] as List;
    final List<Race> racesList = rawRaceslist.map((rawRace) => Race.fromJson(rawRace)).toList();

    return RacesResponse(
      data: racesList,
      total: racesListJsonResponse['total']
    );
  }
}


class RacesList extends StatefulWidget {
  final String clubId;

  RacesList(this.clubId);

  @override
  createState() => RacesListState(this.clubId);
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'list', icon: Icons.list),
  const Choice(title: 'grade', icon: Icons.grade)
];

class RacesListState extends State<RacesList> {
  String _page = '0';
  final String clubId;
  Future<RacesResponse> races;
  Choice _selectedChoice = choices[0]; // The app's "state".

  RacesListState(this.clubId);

  @override
  void initState() {
    super.initState();
    races = _getRaces(this.clubId, this._page);
  }

  Future<RacesResponse> _getRaces(String clubId, String page) async {
    final url = "https://pitstop.top/api/races/$clubId/$page";
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.

      return RacesResponse.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load races list for club $clubId page $page');
    }
  }

  void _select(Choice choice) {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {
      _selectedChoice = choice;
    });
  }

  Widget _renderRacesList() {
    return Center(
      child: FutureBuilder<RacesResponse>(
        future: races,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text("Total races ${snapshot.data.total}. Selected ${_selectedChoice.title}");
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Гонки'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(choices[0].icon),
              onPressed: () {
                _select(choices[0]);
              },
            ),
            // action button
            IconButton(
              icon: Icon(choices[1].icon),
              onPressed: () {
                _select(choices[1]);
              },
            )
          ]
        ),
        body: _renderRacesList()
      ),
    );
  }
}