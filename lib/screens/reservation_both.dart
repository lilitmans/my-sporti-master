import 'package:flutter/material.dart';
import 'package:mysporti/screens/court_type_selection_screen.dart';
import 'package:mysporti/screens/time_selection_screen.dart';
import '../common/app_bar.dart';
import '../repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

final _formKeyReservationContactInfoData = GlobalKey<FormState>();
final _formKeyReservationPinData = GlobalKey<FormState>();

class ReservationBothScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  final String groundName;
  final List reservationTimeList;
//  final DateTime date;
  final String tappedTimeForServer;
  final filter;

  ReservationBothScreen(
  {this.club, this.groundName, this.reservationTimeList, this.filter, this.tappedTimeForServer});

  @override
  _ReservationBothScreenState createState() => _ReservationBothScreenState();
}

class _ReservationBothScreenState extends State<ReservationBothScreen> {

  String cookieKey = "clubId";
  String reservationName;
  String reservationEmail;
  String reservationPhone;
//  String dateForServer;
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();

  String pinCookieKey = "clubId";
  String reservationPin = "";
  String dateForServer;
  TextEditingController _pinController = new TextEditingController();

  @override
  void initState() {
//    dateForServer = DateFormat('yyyy-MM-dd').format( this.widget.date);
    _readCookie();
    _readFavorite();
    dateForServer = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print(dateForServer);
    _readPinCookie();
    _readFavorite();
    super.initState();
  }

  void _readCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    reservationName = prefs.getString("name_"+cookieKey+widget.club["id"]);
    reservationEmail = prefs.getString("email_"+cookieKey+widget.club["id"]);
    reservationPhone = prefs.getString("phone_"+cookieKey+widget.club["id"]);
    if(reservationName == null || reservationEmail == null || reservationPhone == null) {
      reservationName = "";
      reservationEmail = "";
      reservationPhone = "";
    }
    setState(() {
      _nameController = new TextEditingController(text: reservationName);
      _emailController = new TextEditingController(text: reservationEmail);
      _phoneController = new TextEditingController(text: reservationPhone);
    });
  }

  void _saveCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("name_"+cookieKey+widget.club['id'], reservationName);
      prefs.setString("email_"+cookieKey+widget.club['id'], reservationEmail);
      prefs.setString("phone_"+cookieKey+widget.club['id'], reservationPhone);
    });
  }

  bool _clubIsFav = false;
  String clubFavoriteKey = 'clubFavorite';
  String clubFavorite = "";
  void _readFavorite() async
  {
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

  //..............................................................

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
//    List _tappedTimeList = tappedTimeList;
    String firstLetter = this.widget.club["TEXT_booking"].toString().substring(0,1).toUpperCase();
    String bookingText = firstLetter + this.widget.club["TEXT_booking"].toString().substring(1);

    bool _lockIcon = true;
    String firstLetterPin = this.widget.club["TEXT_pin"].toString().substring(0, 1).toUpperCase();
    String pinText = firstLetterPin + this.widget.club["TEXT_pin"].toString().substring(1);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appBar(context, this.widget.club["name"]),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: (_clubIsFav ? new Icon(Icons.favorite) : new Container())
          ),
        ],),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Center(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(height: 15),
                          Text("Reservierung per PIN", style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),),
                          Form(
                            key: _formKeyReservationPinData,
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
                                SizedBox(height: 15),
                                Text(pinText),
                                SizedBox(height: 10),
                                RaisedButton(
                                  color: Colors.orange,
                                  onPressed: () {
                                    // Validate returns true if the form is valid, otherwise false.
                                    if (_formKeyReservationPinData.currentState.validate()) {
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
                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                          Text("Reservierung per Kontaktdaten", style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),),
                          Form(
                            key: _formKeyReservationContactInfoData,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    decoration: InputDecoration(labelText: 'Name'),
                                    controller: _nameController,
                                    validator: (value) {
                                      reservationName = value;
                                      if (value.isEmpty) {
                                        return 'Bitte den Namen eintragen.';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    decoration:
                                    InputDecoration(labelText: 'E-Mail Adresse'),
                                    controller: _emailController,
                                    validator: (value) {
                                      reservationEmail = value;
                                      if (value.isEmpty) {
                                        return 'Bitte die E-Mail Adresse eintragen.';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    decoration:
                                    InputDecoration(labelText: 'Telefonnummer'),
                                    controller: _phoneController,
                                    validator: (value) {
                                      reservationPhone = value;
                                      if (value.isEmpty) {
                                        return 'Bitte die Telefonnummer eintragen.';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  Text(bookingText),
                                  SizedBox(height: 10),
                                  RaisedButton(
                                    color: Colors.orange,
                                    onPressed: () {
                                      if (_formKeyReservationContactInfoData.currentState
                                          .validate()) {
                                        _saveCookie();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TimeSelectionScreen(
                                    club: this.widget.club,
                                    groundTypeId:
                                    this.widget.club["ground_type__id"],
                                    reservationName: reservationName,
                                    reservationEmail: reservationEmail,
                                    reservationPhone: reservationPhone,
                                    reservationPin: "",
//                                            tappedTimeForServer: this.widget.tappedTimeForServer,
//                                            dateFormat: dateForServer,
                                  ),
                                ),
                              );
                                      }
                                    },
                                    child: Text('Fahren Sie mit den Kontaktdaten fort'),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
