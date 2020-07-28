import 'package:flutter/material.dart';
import '../common/app_bar.dart';
import 'club_selection_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import 'time_selection_screen.dart';
import '../repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourtTypeSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  final String clubId;
  final String filter;

  CourtTypeSelectionScreen({this.club, this.clubId, this.filter});

  @override
  _CourtTypeSelectionScreenState createState() =>
      _CourtTypeSelectionScreenState();
}

class _CourtTypeSelectionScreenState extends State<CourtTypeSelectionScreen> {
  bool _clubIsFav = false;
  String clubFavoriteKey = 'clubFavorite';
  String clubFavorite = "";

  @override
  void initState() {
    _readFavorite();
    super.initState();
  }

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
    double windowHeight = MediaQuery.of(context).size.height;
    double imgHeight = windowHeight * .25;

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GroundTypesList(
                  club: this.widget.club,
                ),
              ],
            ),
          ),
          thereIsClubImage(this.widget.club),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn2',
        onPressed: () {
          Navigator.pop(context);
        },
        child: new Icon(Icons.arrow_back_ios),
      ),
    );
  }
}

class GroundTypesList extends StatefulWidget {
  final Map<String, dynamic> club;

  GroundTypesList({this.club});

  @override
  _GroundTypesListState createState() => _GroundTypesListState();
}

class _GroundTypesListState extends State<GroundTypesList> {

  @override
  Widget build(BuildContext context) {
    List groundTypes;
    Map<String, dynamic> club = widget.club;

    return BlocBuilder<GroundTypesListBloc, GroundTypesListState>(
      builder: (context, state) {
        if (state is GroundTypesListEmpty) {
          BlocProvider.of<GroundTypesListBloc>(context)
              .add(FetchGroundTypesList(clubId: club["id"]));
        }
        if (state is GroundTypesListError) {
          return Center(
            child: Text('Failed to fetch ground types list'),
          );
        }
        if (state is GroundTypesListLoaded) {
          return Expanded(
            child: ListView.builder(
              itemCount: state.groundTypesList.groundTypesList == null
                  ? 0
                  : state.groundTypesList.groundTypesList.length,
              itemBuilder: (BuildContext context, i) {
                groundTypes = state.groundTypesList.groundTypesList;
                return SingleChildScrollView(
                  child: Hero(
                    tag: 'groundTag$i',
                    child: ListTile(
                      title: Text(
                          state.groundTypesList.groundTypesList[i]["name"]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeSelectionScreen(
                                club: club,
                                groundTypeId: groundTypes[i]["id"],
                                groundName: state.groundTypesList
                                    .groundTypesList[i]["name"]),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return SizedBox(
            height: 195,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
