import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class MyFollowLeads extends StatefulWidget {
  final String recordName;
  MyFollowLeads(this.recordName);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<MyFollowLeads>  with SingleTickerProviderStateMixin{
  bool _loading = false;
  TabController controller;
  var _userId;
  Future<dynamic> _leads;
  String type = "";

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
        "status":"Follow up",
        "login_type":type
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
      type = prefs.getString('type');
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
            return   Container(
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
                              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                              decoration: snapshot
                                  .data['lead_list'][index]['colorcode']!="#fff"
                                  ? BoxDecoration(
                                  color: Color(0xFFf6f6f6))
                                  : BoxDecoration(
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
                                          SizedBox(
                                            height: 5.0,
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
                                              /*  Text(
                                                  "Duration: "+ snapshot
                                                      .data['lead_list'][index]['assign_lead_time_duration'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 11.0,
                                                  ),
                                                ),*/
                                                Text(
                                                  'Priority : ' + snapshot
                                                      .data['lead_list'][index]['priority'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 11.0,
                                                  ),
                                                ),
                                              ]
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Text(
                                            "Follow up date: "+ snapshot
                                                .data['lead_list'][index]['follow_date'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11.0,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                FontAwesomeIcons.calendar,
                                                size: 11.0,
                                                color: Colors.black54,
                                              ),
                                              SizedBox(width: 10.0),
                                              snapshot
                                                  .data['lead_list'][index]['assigned_date_time'] !=
                                                  null ? Text(
                                                snapshot
                                                    .data['lead_list'][index]['assigned_date_time'],
                                                style: TextStyle(
                                                    color: Colors.black54,fontSize: 11),
                                              ) : Text(
                                                "",
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),

                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                FontAwesomeIcons.locationArrow,
                                                size: 11.0,
                                                color: Colors.black54,
                                              ),
                                              SizedBox(width: 10.0),
                                              snapshot
                                                  .data['lead_list'][index]['location'] !=
                                                  null ? Text(
                                                snapshot
                                                    .data['lead_list'][index]['location'],
                                                style: TextStyle(
                                                    color: Colors.black54,fontSize: 11),
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
    return  mainWidget(deviceSize);


  }
}
