import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../models/models.dart';

class ClubsListApiClient {
  final _baseUrl = 'https://www.mysporti.app';
  final http.Client httpClient;

  ClubsListApiClient({
    @required this.httpClient,
  }) : assert(httpClient != null);

  Future<ClubsList> fetchClubsList() async {
    ClubsList clubs;
    final url = '$_baseUrl/?app_request=true&get_clubs=true&version=2';
    final response =
        await this.httpClient.get(url, headers: {"Accept": "application/json"});

    if (response.statusCode != 200) {
      throw new Exception('Error getting Clubs List');
    }
    final json = jsonDecode(response.body);
    print('1, $url');
    clubs = ClubsList.fromJson(json);
    return clubs;
  }

  Future<GroundTypesList> fetchGroundTypesList(_clubId) async {
    GroundTypesList clubGroundT;
    final url =
        '$_baseUrl/?app_request=true&get_ground_types=true&id_club=' + _clubId + '&version=2';
    print('2, $url');
    final response =
        await this.httpClient.get(url, headers: {"Accept": "application/json"});

    if (response.statusCode != 200) {
      throw new Exception('Error getting club ground types');
    }
    final json = jsonDecode(response.body);
    clubGroundT = GroundTypesList.fromJson(json);
    return clubGroundT;
  }

  Future<ReservationTimeList> fetchReservationTimeList(
      _clubId, _groundTypeId, _date) async {
    ReservationTimeList resTimeList;
    final url = '$_baseUrl/?app_request=true&get_grounds=true&id_club=' +
        _clubId +
        '&id_ground_type=' +
        _groundTypeId +
        '&version=2' +
        '&date_time=' +
        DateFormat('yyyy-MM-dd|kk:mm').format(_date);

    print('3, $url');
    final response = await this
        .httpClient
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    if (response.statusCode != 200) {
      throw new Exception('Error getting reservation time list');
    }
    final json = jsonDecode(response.body);
//    print(json);
    resTimeList = ReservationTimeList.fromJson(json);
    return resTimeList;
  }
}
