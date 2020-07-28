import 'package:flutter/material.dart';
import '../common/app_bar.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class ConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  final String groundTypeId;
  final String reservationName;
  final String reservationEmail;
  final String reservationPhone;
  final String reservationPin;
  final String tappedTimeForServer;
  final String dateFormat;

  ConfirmationScreen(
      {this.club,
      this.groundTypeId,
      this.reservationName,
      this.reservationEmail,
      this.reservationPhone,
      this.reservationPin,
      this.tappedTimeForServer,
      this.dateFormat});

  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {

  Completer<WebViewController> _controller = Completer<WebViewController>();

  void initState() {
    _readFavorite();
    super.initState();
  }

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
    List confirmationResponse;

    return
        Scaffold(
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
          body: Center(
          child: BlocBuilder<ConfirmationResponseListBloc,
              ConfirmationResponseListState>(builder: (context, state) {
            if (state is ConfirmationResponseListEmpty) {
              BlocProvider.of<ConfirmationResponseListBloc>(context).add(
                MakeRequestExecuteReservation(
                  clubId: this.widget.club["id"],
                  groundTypeId: this.widget.groundTypeId,
                  reservationName: this.widget.reservationName,
                  reservationEmail: this.widget.reservationEmail,
                  reservationPhone: this.widget.reservationPhone,
                  reservationPin: this.widget.reservationPin,
                  date: this.widget.dateFormat,
                  tappedTimeForServer: this.widget.tappedTimeForServer,
                ),
              );
            }
            if (state is ConfirmationResponseListError) {
              return Center(
                child: Text('Failed to fetch Reservation Confirmation List'),
              );
            }
            if (state is ConfirmationResponseListLoaded) {
              confirmationResponse = state.confirmationResponseList.confirmResult;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: confirmationResponse == null?
                      0 : confirmationResponse.length,
                      itemBuilder: (BuildContext context, i) {
                        return new ListTile(
                          leading: Icon(
                              confirmationResponse[i]["result"] == "ok"
                                  ? Icons.event_available : Icons.event_busy,
                              color: (confirmationResponse[i]["result"] == "ok"
                                  ? Colors.green : Colors.red)),
                          title: new Text(confirmationResponse[i]["description"]),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: WebView(
                      initialUrl: 'https://en.wikipedia.org/wiki/Kraken',
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                    ),
                  ),
                  thereIsClubImage(this.widget.club),
                ],
              );
            } else {
              return Container();
            }
          },
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Phoenix.rebirth(context);
        },
        child: new Image.asset('images/logo.png'),
      ),
    );
  }
}
