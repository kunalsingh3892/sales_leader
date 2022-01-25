import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class ExtendedTourDetails extends StatefulWidget {
  final Object argument;
  const ExtendedTourDetails({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<ExtendedTourDetails> {
  bool _loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _userId;
  Future<dynamic> _tours;
  var _tour_id,member_id;
  var dealerJson;
  var dealerData;
  Future _dealerData;
  String selectedDealer="";
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _tour_id = data['tour_id'];
    member_id = data['member_id'];

    _getUser();

  }

  Future _leadData() async {
    var response = await http.post(URL+"tourplandetails",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
        "tour_id": _tour_id.toString(),
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
      _tours = _leadData();
    });
  }


  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Tour Details',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[

        ],
        //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: leadDetails(deviceSize),
    );
  }

  Widget leadDetails(Size deviceSize)
  {
    return FutureBuilder(
      future: _tours,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 30.0),
                Row(
                  children: <Widget>[
                    SizedBox(width: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Tour Title : "+snapshot.data['tour_plan_details'][0]['tour_tittle'],
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'TOUR ID : ' + snapshot.data['tour_plan_details'][0]['tour_id'],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                          ),

                        ),
                        SizedBox(height: 10.0),
                      /*  Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              size: 12.0,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              snapshot.data['tour_plan_details'][0]['state'],
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_city,
                              size: 12.0,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              snapshot.data['tour_plan_details'][0]['city'],
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),*/
                        Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.calendar,
                              size: 12.0,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 10.0),
                            snapshot.data['tour_plan_details'][0]['start_date_time']!=null? Text(
                              'Start Date : ' + snapshot.data['tour_plan_details'][0]['start_date_time'],
                              style: TextStyle(color: Colors.black54),
                            ):Text(
                              "",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.calendar,
                              size: 12.0,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 10.0),
                            snapshot.data['tour_plan_details'][0]['end_date_time']!=null? Text(
                              'End Date : ' +snapshot.data['tour_plan_details'][0]['end_date_time'],
                              style: TextStyle(color: Colors.black54),
                            ):Text(
                              "",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Comments : "+snapshot.data['tour_plan_details'][0]['comments']),
                ),

                SizedBox(height: 5.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Status : "+snapshot.data['tour_plan_details'][0]['status'],
                      style: TextStyle(color: Colors.black87,)),
                ),

                SizedBox(height: 20.0),
                Row(
                    children: <Widget>[ Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "TOUR EXTENDED LIST",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color(0xfffb4d6d),
                              fontSize: 20,

                              wordSpacing: 1,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    ]
                ),
                SizedBox(
                  height: 10,
                ),
                snapshot.data['touragainextendlists'].length!=0?  Container(
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snapshot.data['touragainextendlists'].length,
                      itemBuilder: (context,  index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 15.0),
                          child: InkWell(

                            child: Container(

                              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                              decoration: BoxDecoration( color:Colors.grey.shade200),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor:Color(0xff9b56ff),

                                      radius: 28,
                                      child: Center(
                                        child: Text(
                                          snapshot.data['tour_plan_details'][0]['tour_tittle'][0].toUpperCase(),
                                          style: TextStyle(fontSize: 30.0,color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12.0,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                snapshot.data['tour_plan_details'][0]['tour_tittle'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              Text(
                                                'Tour Id : ' + snapshot.data['tour_plan_details'][0]['tour_id'],
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

                                              children: <Widget>[
                                                Icon(
                                                  FontAwesomeIcons.calendar,
                                                  size: 12.0,
                                                  color: Colors.black54,
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  'Extend Date: ' +snapshot.data['touragainextendlists'][index]['end_date_time'],
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
                                                  FontAwesomeIcons.comment,
                                                  size: 12.0,
                                                  color: Colors.black54,
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  'Comments: ' +snapshot.data['touragainextendlists'][index]['comments'],
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
                                          member_id!=""?snapshot.data['touragainextendlists'][index]['status']=="No Action"?
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () async {
                                                var response = await http.post(
                                                  URL+"tourextendedstatuschange",
                                                  body: {
                                                    "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
                                                    "id": member_id.toString(),
                                                    "extended_id": snapshot.data['touragainextendlists'][index]['id'].toString(),
                                                  },
                                                  headers: {
                                                    "Accept": "application/json",
                                                  },
                                                );

                                                if (response.statusCode == 200) {
                                                  setState(() {
                                                    _loading = false;
                                                  });
                                                  var data = json.decode(response.body);
                                                  Fluttertoast.showToast(
                                                      msg: 'Message: ' + data['message'].toString());

                                                  setState(() {
                                                    _tours = _leadData();
                                                  });
                                                  print(data);
                                                } else {
                                                  setState(() {
                                                    _loading = false;
                                                  });
                                                  Fluttertoast.showToast(msg: 'Error');
                                                }
                                              },
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: Container(
                                                  width: deviceSize.height * 0.12,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 7, horizontal: 7),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color: Color(0xff9b56ff)

                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      /* Icon(
                                                      Icons.edit, size: 10, color: Colors.white,),
                                                    SizedBox(
                                                      width: 5,
                                                    ),*/
                                                      Text(
                                                        "Approve",
                                                        // snapshot.data['cart_quantity'] > 0 ? 'Go to Basket' : 'Add to Basket',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ):Container():Container(),

                                        ],
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          ),


                        );
                      }

                  ),
                ) : Container()
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }





}
