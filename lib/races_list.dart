import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'clubs_list.dart';
import 'package:intl/intl.dart';

class Race {
  final int best;
  final int clubid;
  final DateTime date;
  final int id;
  final int laps;
  final String name;
  final String winner;
  final int winnerId;
  final int winnerKart;
  final DateFormat _dateFormat = new DateFormat("E, d MMMM, H:m");

  String get formattedDate {
    return _dateFormat.format(this.date);
  }

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

  factory Race.fromJson(Map<String, dynamic> responseJson) {
    return Race(
      best: responseJson['best'],
      clubid: responseJson['clubid'],
      date: DateTime.parse(responseJson['date']),
      id: responseJson['id'],
      laps: responseJson['laps'],
      name: responseJson['name'],
      winner: responseJson['winner'],
      winnerId: responseJson['winnerId'],
      winnerKart: responseJson['winnerKart'],
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
  final GlobalKey<NavigatorState> navigatorKey;

  RacesList(this.navigatorKey, this.clubId);

  @override
  createState() => RacesListState(this.navigatorKey, this.clubId);
}

class Choice {
  Choice(this.title, this.icon);
  final String title;
  final IconData icon;
}

final List<Choice> choices = <Choice>[
  Choice('list', Icons.list),
  Choice('grade', Icons.grade)
];

class RacesListColumnTitle {
  RacesListColumnTitle(this.title, this.isNumeric);
  final String title;
  final bool isNumeric;
}

class RacesListState extends State<RacesList> {
  int _page = 0;
  final String clubId;
  final GlobalKey<NavigatorState> navigatorKey;
  final List<RacesListColumnTitle> racesListColumns = [
    RacesListColumnTitle("Заезд", false),
    RacesListColumnTitle("Дата", false),
    RacesListColumnTitle("Победитель", false),
    RacesListColumnTitle("Карт", true),
    RacesListColumnTitle("Лучшее время", true)
  ];

  Future<RacesResponse> racesPromise;
  RacesResponse races;
  Choice _selectedChoice = choices[0]; // The app's "state".

  RacesListState(this.navigatorKey, this.clubId);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    debugPrint("loading data Page ${this._page}");
    racesPromise = _getRaces(this.clubId, this._page);
  }

  Future<RacesResponse> _getRaces(String clubId, int page) async {
    final url = "https://pitstop.top/api/races/$clubId/$page";
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      debugPrint("json data fetched ${response.body}");

      this.races = RacesResponse.fromJson(json.decode(response.body));
      return this.races;
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

  Widget _pagination() {
    final int itemsPerPage = this.races.data.length;

    bool showNextPage = (this.races.total > itemsPerPage && (this._page + 1) * itemsPerPage < this.races.total );
    bool showPrevPage = (this._page > 0);

    Widget nextPageWidget = RaisedButton(
      onPressed: (){
        setState(() {
          _page = _page + 1;
          _loadData();
        });
      },
      child: Text("Дальше")
    );

    Widget prevPageWidget = RaisedButton(
      onPressed: (){
        setState(() {
          _page = _page - 1;
          _loadData();
        });
      },
      child: Text("Раньше")
    );

    return Row(
      children: <Widget>[
        if (showPrevPage) prevPageWidget,
        if (showNextPage) nextPageWidget
      ]
    );
  }

  Widget _racesTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: <Widget>[
            DataTable(
              columns: racesListColumns.map((column) {
                return DataColumn(label: Text(column.title), numeric: column.isNumeric);
              }).toList(),
              rows: races.data.map((Race race){
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(race.name)),
                    DataCell(Text(race.formattedDate)),
                    DataCell(Text(race.winner)),
                    DataCell(Text(race.winnerKart.toString())),
                    DataCell(Text(race.winner))
                  ]
                );
              }).toList()
            ),
            _pagination()
          ],
        )
      )
    );
  }

  Widget _renderRacesList() {
    return Center(
      child: FutureBuilder<RacesResponse>(
        future: racesPromise,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //return Text("Total races ${snapshot.data.total}. Selected ${_selectedChoice.title}");
            return _racesTable();

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Гонки в клубе ${ClubsList.getTitleById(this.clubId)}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              this.navigatorKey.currentState.pop();
            },
          ),
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