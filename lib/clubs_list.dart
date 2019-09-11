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

  static String getTitleById(String id) {
    return list.singleWhere((club)=> club.id == id).title;
  }
}