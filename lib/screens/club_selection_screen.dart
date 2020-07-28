import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mysporti/screens/reservation_contact_information_screen.dart';
import '../common/app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reservation-pin-screen.dart';
import 'reservation_both.dart';

var _filter;
bool _isInputValueMatch = false;

class ClubSelectionScreen extends StatefulWidget {
  final String value;
  ClubSelectionScreen({this.value});

  @override
  _ClubSelectionScreenState createState() => _ClubSelectionScreenState();
}

class _ClubSelectionScreenState extends State<ClubSelectionScreen> {
  final _myController = TextEditingController();
  @override
  void initState() {
    _myController.addListener(_isSearchValueMatch);
    super.initState();

    setState(() {
      _myController.text = widget.value;
    });
  }

  _isSearchValueMatch() {
    _filter = _myController.text;
    if (_filter == null || _filter == "" || _filter.length < 4) {
      setState(() {
        _isInputValueMatch = false;
      });
    } else {
      setState(() {
        _isInputValueMatch = true;
      });
    }
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: appBar(context, 'Clubauswahl')),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                autofocus: true,
                controller: _myController,
                decoration: InputDecoration(
                  labelText: "Suche",
                  hintText: "Club-Name oder Adresse (min. 4 Zeichen)",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: ClubsItemList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn1',
        onPressed: () {
          Phoenix.rebirth(context);
        },
        child: new Image.asset('images/logo.png'),
      ),
    );
  }
}

class ClubsItemList extends StatefulWidget {
  @override
  _ClubsItemListState createState() => _ClubsItemListState();
}

class _ClubsItemListState extends State<ClubsItemList> {
  List clubs;

  @override
  void initState() {
    _readFavorite();
    super.initState();
  }

  String clubFavoriteKey = 'clubFavorite';
  String clubFavorite = "";
  bool _clubIsFavorite = false;

  void _readFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    clubFavorite = prefs.getString(clubFavoriteKey);
    if (clubFavorite == null) clubFavorite = "";
  }

  void _markAsFavorite(clubId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    clubFavorite = prefs.getString(clubFavoriteKey);
    if (clubFavorite == null) clubFavorite = "";

    if (clubFavorite.contains(";" + clubId + ";")) {
      clubFavorite = clubFavorite.replaceAll(";" + clubId + ";", ";");
    } else {
      clubFavorite = clubFavorite + ";" + clubId + ";";
    }
    clubFavorite = clubFavorite.replaceAll(";;", ";"); // cleanup

    prefs.setString(clubFavoriteKey, clubFavorite);

    _clubIsFavorite = clubFavorite.contains(";" + clubId + ";");
    setState(() {
      clubFavorite = clubFavorite;
    });
    isClubFavorite(clubId);
  }

  bool isClubFavorite(String clubId) {
    return clubFavorite.contains(";" + clubId + ";");
  }

  Widget determineSymbol(clubAllowBooking, clubAllowPin) {
    if (clubAllowBooking == "1" && clubAllowPin == "0") {
      return Icon(Icons.attach_money);
    } else if (clubAllowBooking == "0" && clubAllowPin == "1") {
      return Icon(Icons.person);
    } else if(clubAllowBooking == "1" && clubAllowPin == "1") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.attach_money),
          Icon(Icons.person),
        ],
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClubsListBloc, ClubsListState>(
      builder: (context, state) {
        if (state is ClubsListEmpty) {
          _readFavorite();
          BlocProvider.of<ClubsListBloc>(context).add(FetchClubsList());
        }
        if (state is ClubsListError) {
          return Center(
            child: Text('Failed to fetch clubs list'),
          );
        }
        if (state is ClubsListLoaded) {
          return Expanded(
            child: ListView.builder(
              itemCount: state.clubsList.clubs == null
                  ? 0
                  : state.clubsList.clubs.length,
              itemBuilder: (BuildContext context, i) {
                clubs = state.clubsList.clubs;
                String clubId = clubs[i]["id"];
                String clubName = clubs[i]["name"].toLowerCase();
                String clubAddress = clubs[i]["address"].toLowerCase();

                if (_isInputValueMatch == false && !isClubFavorite(clubId)) {
                  return new Container();
                } else if (clubName.contains(_filter.toLowerCase()) ||
                    clubAddress.contains(_filter.toLowerCase()) ||
                    isClubFavorite(clubId)) {
                  return SingleChildScrollView(
                    child: Hero(
                      tag: 'clubTag$i',
                      child: ListTile(
                        title: Text(clubs[i]["name"]),
                        subtitle: Text(clubs[i]["address"]),
                        leading: IconButton(
                          icon: isClubFavorite(clubId)
                              ? Icon(Icons.favorite)
                              : Icon(Icons.favorite_border),
                          onPressed: () {
                            _markAsFavorite(clubId);
                          },
                        ),
                        trailing:
                        determineSymbol(clubs[i]["allow_booking"], clubs[i]["allow_pin"]),
                        onTap: () {
                          if (clubs[i]["allow_booking"] == "0" && clubs[i]["allow_pin"] == "1") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservationPinScreen(
                                  club: clubs[i],
                                  filter: _filter,
//                                  date: date,
//                                  tappedTimeForServer: tappedTimeForServer,
//                                  reservationTimeList: reservationTimeList,
                                ),
                              ),
                            );
                          } else if (clubs[i]["allow_booking"] == "1" && clubs[i]["allow_pin"] == "0") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservationContactInformationScreen(
                                  club: clubs[i],
//                                  date: this.widget.
                                  filter: _filter,
                                ),
                              ),
                            );
                          } else if (clubs[i]["allow_booking"] == "1" && clubs[i]["allow_pin"] == "1") {
                                Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservationBothScreen(
                                  club: clubs[i],
//                                  date: this.widget.
                                  filter: _filter,
                                ),
                              ),
                            );
                          };
                        },
                      ),
                    ),
                  );
                } else {
                  return new Container();
                }
              },
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
