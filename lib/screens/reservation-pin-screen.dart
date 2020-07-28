import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysporti/screens/court_type_selection_screen.dart';
import 'package:mysporti/screens/time_selection_screen.dart';
import '../common/app_bar.dart';
import '../repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _formKeyReservationData = GlobalKey<FormState>();

class ReservationPinScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  final List reservationTimeList;
//  final String tappedTimeForServer;
  final String filter;

  ReservationPinScreen({this.club, this.filter, this.reservationTimeList,});


  @override
  _ReservationPinScreenState createState() => _ReservationPinScreenState();
}

class _ReservationPinScreenState extends State<ReservationPinScreen> {
  String pinCookieKey = "clubId";
  String reservationPin = "";
  String dateForServer;
  TextEditingController _pinController = new TextEditingController();

  @override
  void initState() {
    _readPinCookie();
    _readFavorite();
    super.initState();
  }

  bool _clubIsFav = false;
  String clubFavoriteKey = 'clubFavorite';
  String clubFavorite = "";

  void _readFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    clubFavorite = prefs.getString(clubFavoriteKey);
    if(clubFavorite==null) clubFavorite = "";
    isClubFavorite();
  }

  isClubFavorite() {
    setState(() {
      _clubIsFav = clubFavorite.contains(";"+this.widget.club["id"]+";");
    });
  }

  void _readPinCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    reservationPin = prefs.getString(pinCookieKey+widget.club["id"]);
    if(reservationPin==null) reservationPin = "";
    setState(() {
      _pinController = new TextEditingController(text: reservationPin);
    });
  }

  void _savePinCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString(pinCookieKey+widget.club['id'], reservationPin);
    });
  }

  @override
  Widget build(BuildContext context) {
    List _tappedTimeList = tappedTimeList;
    bool _lockIcon = true;
    String firstLetter = this.widget.club["TEXT_pin"].toString().substring(0, 1).toUpperCase();
    String pinText = firstLetter + this.widget.club["TEXT_pin"].toString().substring(1);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appBar(context, this.widget.club["name"]),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: (_clubIsFav ? new Icon(Icons.favorite) : new Container())
          ),
        ],
      ),
      body:Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Center(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Text("Reservierung per PIN", style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),),
                        SizedBox(
                          height: 20,
                        ),
                        Form(
                          key: _formKeyReservationData,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 30.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'PIN',
                                    icon: FlatButton(
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(
                                          _lockIcon ? Icons.lock : Icons.lock_open),
                                    ),
                                  ),
                                  controller: _pinController,
                                  obscureText: true,
                                  validator: (value) {
                                    reservationPin = value;
                                    if (value.isEmpty) {
                                      return 'Bitte den PIN eintragen.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 30),
                              Text(pinText, style:
                              TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                              SizedBox(height: 20),
                              RaisedButton(
                                color: Colors.orange,
                                onPressed: () {
                                  // Validate returns true if the form is valid, otherwise false.
                                  if (_formKeyReservationData.currentState.validate()) {
                                    _savePinCookie();
                                    if (this.widget.club["cnt_ground_type"] == "1") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TimeSelectionScreen(
                                            club: this.widget.club,
                                            groundTypeId:
                                            this.widget.club["ground_type__id"],
                                            reservationName: "",
                                            reservationEmail: "",
                                            reservationPhone: "",
                                            reservationPin: reservationPin,
                                            filter: this.widget.filter,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CourtTypeSelectionScreen(
                                            club: this.widget.club,
                                            filter: this.widget.filter,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Text('Fahren Sie mit der PIN fort'),
                              ),
                              SizedBox(height: 50)
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          thereIsClubImage(this.widget.club),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: new Icon(Icons.arrow_back_ios),
      ),
    );
  }
}

