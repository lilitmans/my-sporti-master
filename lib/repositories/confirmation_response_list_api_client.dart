import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:mysporti/models/models.dart';
import 'package:meta/meta.dart';
import '../models/models.dart';

class ConfirmationResponseListApiClient {
  final _baseUrl = 'https://www.mysporti.app';
  final http.Client httpClient;

  ConfirmationResponseListApiClient({
    @required this.httpClient,
  }) : assert(httpClient != null);

  Future<ConfirmationResponseList> makeRequestExecuteReservation(
    _clubId,
    _groundTypeId,
    _reservationName,
    _reservationEmail,
    _reservationPhone,
    _reservationPin,
      _tappedTimeForServer,
      _date,
  ) async {

    ConfirmationResponseList confirmationResponseList;

    String urlParams = "";
    urlParams += "&id_club=" + _clubId;
    urlParams += "&id_ground_type=" + _groundTypeId;
    urlParams += "&reservationName=" + base64.encode(utf8.encode(_reservationName));
    urlParams += "&reservationEmail=" + base64.encode(utf8.encode(_reservationEmail));
    urlParams += "&reservationPhone=" + base64.encode(utf8.encode(_reservationPhone));
    urlParams += "&reservationPin=" + base64.encode(utf8.encode(_reservationPin));
    urlParams += "&version=2";
    urlParams += "&date=" + base64.encode(utf8.encode(_date));
    urlParams += "&tappedTime=" + base64.encode(utf8.encode(_tappedTimeForServer));
//    urlParams += "&date=" + _date;
//    urlParams += "&tappedTime=" + _tappedTimeForServer;

    var response = await http.get(Uri.encodeFull(_baseUrl +'/?app_request=true&execute_reservation=true'+urlParams), headers: {"Accept": "application/json"});
//    var response = await http.get('https://inducesmile.com/google-flutter/how-load-a-local-html-file-in-flutter-webview/#inline_content', headers: {"Accept": "application/json"});
    print('4, ${response}');
    if (response.statusCode != 200) {
      throw new Exception(
          'Error getting Confirmation Reservation Response List');
    }

    final json = jsonDecode(response.body);
    print("${json}");
    confirmationResponseList = ConfirmationResponseList.fromJson(json);
    return confirmationResponseList;
  }
}
