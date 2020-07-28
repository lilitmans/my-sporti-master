import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mysporti/screens/confirmation_screen.dart';
import '../common/app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/repositories.dart';
import 'package:intl/intl.dart';

final _formKeyGuestList = GlobalKey<FormState>();

class SelectedTimeScreen extends StatefulWidget {

  final Map<String, dynamic> club;
  final String groundTypeId;
  final String reservationName;
  final String reservationEmail;
  final String reservationPhone;
  final String reservationPin;
  final String tappedTimeForServer;
  final DateTime date;
  final List tappedTimeList;

  SelectedTimeScreen(
      {this.club,
        this.groundTypeId,
        this.reservationName,
        this.reservationEmail,
        this.reservationPhone,
        this.reservationPin,
        this.tappedTimeForServer,
        this.date,
        this.tappedTimeList});

  @override
  _SelectedTimeScreenState createState() => _SelectedTimeScreenState();
}

class _SelectedTimeScreenState extends State<SelectedTimeScreen> {
  DateTime date;
  String tappedTime;
  List reservationTimeList;
  String clubId;
  String dateForServer;

  @override
  void initState() {
    dateForServer = DateFormat('yyyy-MM-dd').format(this.widget.date);
    tappedTime = "";
    clubId = this.widget.club['id'];
    _readFavorite();
    super.initState();
  }

  bool status = true;
  bool _clubIsFav = false;
  String clubFavoriteKey = 'clubFavorite';
  String clubFavorite = "";

  void _readFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    clubFavorite = prefs.getString(clubFavoriteKey);
    if (clubFavorite == null) clubFavorite = "";
    isClubFavorite();
  }

  isClubFavorite() {
    setState(() {
      _clubIsFav = clubFavorite.contains(";" + this.widget.club["id"] + ";");
    });
  }

  @override
  Widget build(BuildContext context) {
    List _tappedTimeList = this.widget.tappedTimeList;
    String firstLetter = this.widget.club["TEXT_pin"].toString().substring(0, 1).toUpperCase();
    String confirmText = firstLetter + this.widget.club["TEXT_confirmation"].toString().substring(1);

    final List<String> items = <String>['1', '2', '3'];
    String selectedItem;

    Widget selectFormItems() {
      return new Column(children: ["1", "2", "3"].map((item) =>
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 2.0),
                child: Text('Spieler ${item}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0
                  ),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedItem = '${item}',
                    onChanged: (String string) => setState(() => selectedItem = string),
                    selectedItemBuilder: (BuildContext context) {
                      return items.map<Widget>((String item) {
                        return Text(item);
                      }).toList();
                    },
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        child: Text('Log $item'),
                        value: item,
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 2.0),
                child: const Text('Gast-Name:',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0
                  ),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Geben Sie den Gastnamen ein'
                    ),
                  ),
                ),
              ),
            ],
          ),
      ).toList());
    }


    return Scaffold(
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
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text("${this.widget.club["ground_type__description"]}",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0)),
                  SizedBox(height: 10),
                  Wrap(
                    direction: Axis.vertical,
                    alignment: WrapAlignment.center,
                    children: _tappedTimeList
                        .map((i) => Center(
                      child: Text(i.replaceAll("|","\n"),
                          style: TextStyle(
                            height: 0.6,
                            fontWeight: FontWeight.bold,
                          )),
                    ))
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  Text(confirmText),
                  Column(
                    children: <Widget>[
                      Form(
                        key: _formKeyGuestList,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 0.0, right: 16.0, bottom: 20.0),
                              child:
                              Column(
                                children: <Widget>[
                                  selectFormItems(),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: RaisedButton(
                                        color: Colors.orange,
                                        onPressed: () {
                                          // Validate returns true if the form is valid, otherwise false.
                                          //                        if (_formKeyReservationData.currentState.validate()) {
                                          //                            _savePinCookie();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ConfirmationScreen(
                                                club: this.widget.club,
                                                groundTypeId: this.widget.groundTypeId,
                                                dateFormat: dateForServer,
                                                reservationName: this.widget.reservationName,
                                                reservationEmail:  this.widget.reservationEmail,
                                                reservationPhone: this.widget.reservationPhone,
                                                reservationPin: this.widget.reservationPin,
                                                tappedTimeForServer: this.widget.tappedTimeForServer,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text('Reservieren'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          thereIsClubImage(this.widget.club),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
//          FloatingActionButton(
//            heroTag: 'btn3',
//            onPressed: () {
//              Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) => ConfirmationScreen(
//                    club: this.widget.club,
//                    groundTypeId: this.widget.groundTypeId,
//                    dateFormat: dateForServer,
//                    reservationName: this.widget.reservationName,
//                    reservationEmail:  this.widget.reservationEmail,
//                    reservationPhone: this.widget.reservationPhone,
//                    reservationPin: this.widget.reservationPin,
//                    tappedTimeForServer: this.widget.tappedTimeForServer,
//                  ),
//                ),
//              );
//            },
//            child: new Icon(Icons.arrow_forward_ios),
//            backgroundColor: (Colors.orange),
//          ),
          FloatingActionButton(
            heroTag: 'btn4',
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Icon(Icons.arrow_back_ios),
          ),
        ],
      ),
    );
  }
}
