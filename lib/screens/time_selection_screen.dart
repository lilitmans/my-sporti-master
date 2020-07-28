import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:mysporti/screens/club_selection_screen.dart';
import 'package:mysporti/screens/selected_time_screen.dart';
import '../common/app_bar.dart';
import 'package:intl/intl.dart';
import '../repositories/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  final String groundName;
  final String groundTypeId;
  final String filter;
  final String reservationName;
  final String reservationEmail;
  final String reservationPhone;
  final String reservationPin;

  TimeSelectionScreen(
      {this.club, this.groundName, this.groundTypeId, this.filter, this.reservationName, this.reservationEmail, this.reservationPhone,
        this.reservationPin});

  @override
  _TimeSelectionScreenState createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  DateTime date;
  String dateFormat;
  String tappedTime;
  String tappedTimeForServer;
  List reservationTimeList;
  String clubId;
  _TimeSelectionScreenState();

  @override
  void initState() {
    date = DateTime.now().toLocal();
    tappedTime = "";
    tappedTimeForServer = "";
    clubId = this.widget.club['id'];
    _readFavorite();
    super.initState();
  }

  void refresh(String tappedTimeChild, String tappedTimeForServerChild) {
    setState(() {
      tappedTime = tappedTimeChild;
      tappedTimeForServer = tappedTimeForServerChild;
    });
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

//    dateFormat = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (status) {
      BlocProvider.of<ReservationTimeListBloc>(context).add(
          FetchReservationTimeList(
              clubId: clubId,
              groundTypeId: this.widget.groundTypeId,
              date: date));
      tappedTimeList = [];
      tappedTime = "";
      status = false;
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
      body: BlocBuilder<ReservationTimeListBloc, ReservationTimeListState>(
        builder: (context, state) {
          if (state is ReservationTimeListEmpty) {
            BlocProvider.of<ReservationTimeListBloc>(context).add(
                FetchReservationTimeList(
                    clubId: clubId,
                    groundTypeId: this.widget.groundTypeId,
                    date: date));
            tappedTimeList = [];
            tappedTime = "";
          }
          if (state is ReservationTimeListError) {
            Future.delayed(
              const Duration(seconds: 3),
                  () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => ClubSelectionScreen(value: "")),
                      (Route<dynamic> route) => false),
            );
            return Center(
            child: Text('Failed to fetch reservation time list'),
              );
          }
          if (state is ReservationTimeListLoaded) {
            reservationTimeList = state.reservationTimeList.reservationTimeList;
            return Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true, onConfirm: (d) {
                                setState(() {
                                  tappedTimeList = [];
                                  tappedTime = "";
                                  date = d.toLocal();
                                  tappedTime =
                                      DateFormat('yyyy-MM-dd – kk:mm').format(date);
                                  BlocProvider.of<ReservationTimeListBloc>(context).add(
                                      FetchReservationTimeList(
                                          clubId: this.widget.club["id"],
                                          groundTypeId:
                                          this.widget.groundTypeId,
                                          date: date));
                                  tappedTimeList = [];
                                  tappedTime = "";
                                });
                              }, currentTime: date, locale: LocaleType.de);
                        },
                        child: Column(children: <Widget>[
                          Text("Datum und Uhrzeit auswählen"),
                          Text(DateFormat('yyyy-MM-dd – kk:mm').format(date))
                        ]),
                      ),
                      TimeSelectionSchedule(
                        club: this.widget.club,
                        reservationTimeList: reservationTimeList,
                        notifyParent: refresh,
                      ),
                    ],
                  ),
                ),
                thereIsClubImage(this.widget.club),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'btn3',
            onPressed: () {
              if (tappedTimeList.length > 0 && tappedTime != "") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectedTimeScreen(
                        club: this.widget.club,
                        groundTypeId: this.widget.groundTypeId,
                        date: date,
                        reservationName: this.widget.reservationName,
                        reservationEmail:  this.widget.reservationEmail,
                        reservationPhone: this.widget.reservationPhone,
                        reservationPin: this.widget.reservationPin,
                        tappedTimeForServer: tappedTimeForServer,
                        tappedTimeList: tappedTimeList,
                      ),
                    ),
                  );

              }
            },
            child: new Icon(Icons.arrow_forward_ios),
            backgroundColor: (tappedTime == "" ? Colors.grey : Colors.orange),
          ),
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

// Time Selection Schedule .....................................................

class TimeSelectionSchedule extends StatefulWidget {
  final Function(String tapT, String timeForServ) notifyParent;

  final Map<String, dynamic> club;
  final List reservationTimeList;

  TimeSelectionSchedule(
      {Key key,
      this.club,
      this.reservationTimeList,
      @required this.notifyParent})
      : super(key: key);

  @override
  _TimeSelectionScheduleState createState() => _TimeSelectionScheduleState();
}

class _TimeSelectionScheduleState extends State<TimeSelectionSchedule> {
  Color placeTimeBackgroundColor;
  Map<String, dynamic> thisGround;
  String tappedTimeChild;
  String tappedTimeForServerChild;

  @override
  void initState() {
    tappedTimeChild = "";
    tappedTimeForServerChild = "";
    super.initState();
  }

  void onTappedTime(Map<String, dynamic> ground, String free, String time,
      String timeForServer) {
    if (free != "1") return;

    if (tappedTimeChild.split("|").contains(time)) {
      setState(() {
        tappedTimeChild = tappedTimeChild.replaceAll("|" + time + "|", "");
        tappedTimeForServerChild =
            tappedTimeForServerChild.replaceAll("|" + timeForServer + "|", "");
        widget.notifyParent(tappedTimeChild, tappedTimeForServerChild);
        tappedTimeList = tappedTimeList;
      });
    } else {
      setState(() {
        tappedTimeChild += "|" + time + "|";
        tappedTimeForServerChild += "|" + timeForServer + "|";
        widget.notifyParent(tappedTimeChild, tappedTimeForServerChild);
        tappedTimeList = tappedTimeList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List reservationTimeList = this.widget.reservationTimeList;
    String resTime;
    String free;
    String placeTime;

    return Expanded(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: reservationTimeList == null ? 0 : reservationTimeList.length,
              itemBuilder: (BuildContext context, i) {
                String groundName = reservationTimeList[i]["name"];
                String groundId = reservationTimeList[i]["id"];
                return new ListTile(
                  title: new Text("$groundName"),
                  subtitle: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: reservationTimeList[i]["times"].length,
                      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, childAspectRatio: 2.5),
                      itemBuilder: (BuildContext context, int index) {
                        resTime = reservationTimeList[i]["times"][index]["hour"];
                        free = reservationTimeList[i]["times"][index]["free"];
                        placeTime = groundName + "." + resTime;

                        placeTimeBackgroundColor = Colors.black45;
                        if (tappedTimeChild.split("|").contains(placeTime)) {
                          placeTimeBackgroundColor = Colors.orange;
                          tappedTimeList = [];
                          tappedTimeList.add(tappedTimeChild);
                        } else if (free == "1") {
                          placeTimeBackgroundColor = Colors.green;
                        } else if (free == "0") {
                          placeTimeBackgroundColor = Colors.red;
                        }

                        return new GestureDetector(
                          onTap: () {
                            onTappedTime(
                                reservationTimeList[i],
                                reservationTimeList[i]["times"][index]["free"],
                                groundName +
                                    "." +
                                    reservationTimeList[i]["times"][index]["hour"],
                                groundId +
                                    '.' +
                                    reservationTimeList[i]["times"][index]["hour"]);
                          },
                          child: new Chip(
                            avatar: new CircleAvatar(
                                backgroundColor: placeTimeBackgroundColor),
                            label: new Text('$resTime'),
                          ),
                        );
                      }),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('not available', style: TextStyle(fontSize: 12.0),),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.green,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('available', style: TextStyle(fontSize: 12.0),),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.orange,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('selected', style: TextStyle(fontSize: 12.0),),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('reserved', style: TextStyle(fontSize: 12.0),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
