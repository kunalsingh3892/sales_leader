import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class MyVisits extends StatefulWidget {
  final Object argument;

  const MyVisits({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<MyVisits>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  var _userId;
  var member_id;
  Future<dynamic> _leads;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    member_id = data['member_id'];
    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _leadData() async {
    var response = await http.post(
      URL+"visitlists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id":member_id!="" ?member_id:_userId,
      },
      headers: {
        "Accept": "application/json",
      },
    );

    print({
      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      "id":member_id!="" ?member_id:_userId,
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      //var result = data['Response'];
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      print(_userId.toString());
      _leads = _leadData();
    });
  }

  Widget mainWidget(Size deviceSize) {
    return ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: deviceSize.width * 0.03,
          ),
          child: ListView(
           // physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  leadList(deviceSize),

                ],
              )
            ],
          ),
        ));
  }
  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text('NO VISITS FOUND!')),
    );
  }
  Widget leadList(Size deviceSize) {
    return FutureBuilder(
      future: _leads,
      builder: (context, snapshot) {
        if (snapshot.hasData) {


          if(snapshot.data['visit_list'].length!=0) {
            return Container(
              // color: Colors.red,
              // height: deviceSize.height,
              child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: snapshot.data['visit_list'].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        elevation: 3.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/visit-details',
                                arguments: <String, String>{
                                  'visit_id': snapshot.data['visit_list'][index]['id'].toString(),
                                  'link_visit': snapshot.data['visit_list'][index]['link_visit'].toString(),
                                  'member_id':member_id

                                },
                              );
                            },
                            child: Container(
                              height: deviceSize.height * 0.10,
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: (index % 2) != 0
                                  ? BoxDecoration(
                                /*border: Border(
                              left: BorderSide(
                                width: 10.0,
                                color: primaryColor,
                              ),
                            )*/
                                  color: Color(0xFFf6f6f6))
                                  : BoxDecoration(
                                /*border: Border(
                              left: BorderSide(
                                width: 10.0,
                                color: primaryColor,
                              ),
                            ),*/
                                  color: Colors.white),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: (index % 2) != 0
                                          ? Color(0xff9b56ff)
                                          : Color(0xFFfe4c64),
                                      radius: 28,
                                      child: Center(
                                        child: Text(
                                          snapshot.data['visit_list'][index]
                                          ['visited'][0].toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 30.0,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12.0,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(
                                                  snapshot.data['visit_list'][index]
                                                  ['visited'],
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              Text(
                                                    snapshot.data['visit_list']
                                                    [index]['link_visit'],
                                                overflow:
                                                TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Row(children: <Widget>[
                                            Icon(
                                              Icons.access_time,
                                              size: 12.0,
                                              color: Colors.black54,
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              'Duration : ' +
                                                  snapshot.data['visit_list']
                                                  [index]['hours'].toString()+" hr  "+snapshot.data['visit_list']
                                              [index]['minutes']+" min",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ]),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Row(children: <Widget>[
                                            Icon(
                                              FontAwesomeIcons.calendar,
                                              size: 12.0,
                                              color: Colors.black54,
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              'Created Date : ' +
                                                  snapshot.data['visit_list']
                                                  [index]['created_at'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ]),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Row(children: <Widget>[
                                            Icon(
                                              FontAwesomeIcons.locationArrow,
                                              size: 12.0,
                                              color: Colors.black54,
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            snapshot.data['visit_list'][index]
                                            ['location'] !=
                                                null
                                                ? Expanded(
                                              child: Text(
                                                snapshot.data['visit_list']
                                                [index]['location'],
                                                overflow:
                                                TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                            )
                                                : Text(
                                              "",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            );
          }
          else{
            return _emptyOrders();
          }

        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Container(child: CircularProgressIndicator()));
        } else {
          return Center(child: Container(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      floatingActionButton:member_id==""? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add-visits',
            arguments: <String, String>{
              'visit_to': '',
              'contact':'',
              'contact_name':'',
              'tour_title':"",
              'tour_name':"",
              'pinCode':"",
            },
          );
        },
        child: Icon(Icons.add),
      ):Container(),
      appBar: AppBar(
        title: Text(
          'My Visits',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[],
        //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: mainWidget(deviceSize),
    );
  }
}
