import 'package:flutter/material.dart';
import 'races_list.dart';
import 'clubs_list.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() => runApp(PitstopApp());

class PitstopApp extends StatelessWidget {

  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Pitstop',
      home: new ClubsListWidget(this.navigatorKey)
    );
  }
}

class ClubsListWidget extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  ClubsListWidget(this.navigatorKey);

  @override
  createState() => new ClubsListWidgetState(this.navigatorKey);
}

class ClubsListWidgetState extends State<ClubsListWidget> {
  final GlobalKey<NavigatorState> navigatorKey;
  ClubsListWidgetState(this.navigatorKey);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
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

  @override
  Widget build(BuildContext context) {
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
    this.navigatorKey.currentState.push(
      MaterialPageRoute(builder: (context) => RacesList(this.navigatorKey, clubId)),
    );
  }
}