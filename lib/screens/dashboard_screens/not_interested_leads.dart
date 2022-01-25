import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class NotInterestedLeads extends StatefulWidget {
  final String recordName;
  NotInterestedLeads(this.recordName);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<NotInterestedLeads>  with SingleTickerProviderStateMixin{
  bool _loading = false;
  TabController controller;
  var _userId;
  Future<dynamic> _leads;

  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: 3);
    _getUser();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  Future _leadData() async {
    var response = await http.post(URL+"getleadlist",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
        "id": widget.recordName!=""?widget.recordName:_userId,
        "status":"Not Interested",
      },
      headers: {
        "Accept": "application/json",
      },
    );
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
  Widget mainWidget(Size deviceSize){
    return ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: deviceSize.width * 0.03,
          ),
          child:
          ListView(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  /* Heading(
                      title: 'Last Leads',
                    ),*/
                  SizedBox(
                    height: 25.0,
                  ),
                  leadList(deviceSize),
                ],
              )
            ],
          ),


        )
    );
  }
  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text('NO LEADS FOUND!')),
    );
  }
  Widget leadList(Size deviceSize){
    return FutureBuilder(
      future: _leads,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if(snapshot.data['lead_list'].length!=0) {
            return Container(
              // color: Colors.red,
              // height: deviceSize.height ,
              child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: snapshot.data['lead_list'].length,
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
                              if(widget.recordName=="") {
                                Navigator.pushNamed(
                                  context,
                                  '/lead-details',
                                  arguments: <String, String>{
                                    'lead_id':
                                    snapshot.data['lead_list'][index]['id']
                                        .toString(),
                                    'type':''

                                  },
                                );
                              }
                              else{
                                Navigator.pushNamed(
                                  context,
                                  '/teamlead-details',
                                  arguments: <String, String>{
                                    'lead_id':
                                    snapshot.data['lead_list'][index]['id']
                                        .toString(),

                                  },
                                );
                              }
                            },
                            child: Container(
                              height: deviceSize.height * 0.10,
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: (index % 2) != 0
                                  ? BoxDecoration(/*border: Border(
                              left: BorderSide(
                                width: 10.0,
                                color: primaryColor,
                              ),
                            )*/
                                  color: Color(0xFFf6f6f6))
                                  : BoxDecoration(/*border: Border(
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
                                      backgroundColor: (index % 2) != 0 ? Color(
                                          0xff9b56ff) : Color(0xFFfe4c64),

                                      radius: 28,
                                      child: Center(
                                        child: Text(
                                          snapshot
                                              .data['lead_list'][index]['customer_name'][0]
                                              .toUpperCase(),
                                          style: TextStyle(fontSize: 30.0,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12.0,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Text(
                                            snapshot
                                                .data['lead_list'][index]['subject'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                snapshot
                                                    .data['lead_list'][index]['customer_name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                              Text(
                                                'LEAD ID : ' + snapshot
                                                    .data['lead_list'][index]['lead_id'],
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
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  snapshot
                                                      .data['lead_list'][index]['description'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10.0,
                                                  ),
                                                ),
                                                Text(
                                                  'Status : ' + snapshot
                                                      .data['lead_list'][index]['status'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10.0,
                                                  ),
                                                ),
                                              ]
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                FontAwesomeIcons.locationArrow,
                                                size: 12.0,
                                                color: Colors.black54,
                                              ),
                                              SizedBox(width: 10.0),
                                              snapshot
                                                  .data['lead_list'][index]['location'] !=
                                                  null ? Text(
                                                snapshot
                                                    .data['lead_list'][index]['location'],
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ) : Text(
                                                "",
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

              ),
            );
          }
          else{
            return _emptyOrders();
          }

        }  else {
          return Center(child: Container(child: CircularProgressIndicator()));
        }
      },
    );


  }
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return mainWidget(deviceSize);


  }
}

