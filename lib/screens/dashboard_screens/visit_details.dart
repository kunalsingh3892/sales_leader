import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/full_image.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class VisitDetails extends StatefulWidget {
  final Object argument;
  const VisitDetails({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<VisitDetails> {
  bool _loading = false;
  var _userId;
  Future<dynamic> _visits;
  var visit_id,link_visit,member_id;
  final TextStyle stats = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white);
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    visit_id = data['visit_id'];
    link_visit = data['link_visit'];
    member_id = data['member_id'];

    _getUser();
  }


  Future _leadData() async {
    var response = await http.post(URL+"visitdetails",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
        "visit_id": visit_id.toString(),
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
      _visits = _leadData();
    });
  }
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Visit Details',
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

  Widget leadDetails(Size deviceSize) {
    if(link_visit=="Lead"){
    return FutureBuilder(
      future: _visits,
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
                    CircleAvatar(

                      backgroundColor:  Color(0xff9b56ff),

                      radius: 28,
                      child: Center(
                        child: Text(
                          snapshot.data['visit_details'][0]['link_visit'][0].toUpperCase(),
                          style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Container(
                      width: deviceSize.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Visiting To : "+snapshot.data['visit_details'][0]['link_visit'],
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10.0),

                          Container(
                            width: deviceSize.width * 0.7,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.calendar,
                                  size: 12.0,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    "Created at : "+snapshot.data['visit_details'][0]['created_at'],
                                    overflow:
                                    TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Container(
                            width: deviceSize.width * 0.8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.locationArrow,
                                  size: 12.0,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                      snapshot.data['visit_details'][0]['location'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                              ),

                              ],
                            ),
                          ),
                        ],
                      ),
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
                      "Subject : "+snapshot.data['visit_details'][0]['leadsubject']),
                ),
                SizedBox(height: 5.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Customer Name : "+snapshot.data['visit_details'][0]['customer_name']),
                ),
                SizedBox(height: 5.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Mobile No. : "+snapshot.data['visit_details'][0]['customer_phone']),
                ),
                SizedBox(height: 5.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Email Id : "+snapshot.data['visit_details'][0]['email_id']),
                ),
                SizedBox(height: 5.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Comments : "+snapshot.data['visit_details'][0]['comments']),
                ),
                SizedBox(height: 5.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Status : "+snapshot.data['visit_details'][0]['status'],
                      style: TextStyle(color: Colors.black87,)),
                ),
                SizedBox(height: 10.0),
                snapshot.data['visit_attachment'].length!=0? GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  primary: false,
                  childAspectRatio: 1,
                  padding: const EdgeInsets.only(left: 16,right: 16),
                  children: List.generate( snapshot.data['visit_attachment'].length, (index) {
                    return Container(
                      height: 400,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(snapshot.data['attachment_url']+
                              snapshot.data['visit_attachment'][index]['image']),
                          fit: BoxFit.fill,
                        ),

                      ),
                    );
                  }),
                ):Container(),
                SizedBox(height: 30.0),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: (){
                        if(member_id=="") {
                          Navigator.pushNamed(
                            context,
                            '/lead-details',
                            arguments: <String, String>{
                              'lead_id': snapshot
                                  .data['visit_details'][0]['linkid']
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
                              'lead_id': snapshot
                                  .data['visit_details'][0]['linkid']
                                  .toString(),

                            },
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 20,right: 20),
                        height: deviceSize.height * 0.05,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xff9b56ff),
                              blurRadius: 5.0, // has the effect of softening the shadow
                              //spreadRadius: 1.0, // has the effect of extending the shadow
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(left: 15.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "See Detailed Information",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Icon(
                                  Icons.chevron_right,
                                  color: Color(0xff9b56ff)
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 50.0),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
    }
    else if(link_visit=="Tour"){
      return FutureBuilder(
        future: _visits,
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
                      CircleAvatar(

                        backgroundColor:  Color(0xff9b56ff),

                        radius: 28,
                        child: Center(
                          child: Text(
                            snapshot.data['visit_details'][0]['link_visit'][0].toUpperCase(),
                            style: TextStyle(
                                fontSize: 30.0,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Container(
                        width: deviceSize.width * 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Visiting To : "+snapshot.data['visit_details'][0]['link_visit'],
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10.0),

                            Container(
                              width: deviceSize.width * 0.7,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.calendar,
                                    size: 12.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      "Created at : "+snapshot.data['visit_details'][0]['created_at'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Container(
                              width: deviceSize.width * 0.8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.locationArrow,
                                    size: 12.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      snapshot.data['visit_details'][0]['location'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
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
                        "Dealer Name: "+snapshot.data['visit_details'][0]['dealer_name']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Tour Code : "+snapshot.data['visit_details'][0]['tour_code']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Tour Title : "+snapshot.data['visit_details'][0]['tour_tittle']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Tour State : "+snapshot.data['visit_details'][0]['tourstate']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Tour City : "+snapshot.data['visit_details'][0]['tourcity']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Comments : "+snapshot.data['visit_details'][0]['comments']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Status : "+snapshot.data['visit_details'][0]['status'],
                        style: TextStyle(color: Colors.black87,)),
                  ),
                  SizedBox(height: 10.0),
                  snapshot.data['visit_attachment'].length!=0? GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    primary: false,
                    childAspectRatio: 1,
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    children: List.generate( snapshot.data['visit_attachment'].length, (index) {
                      return InkWell(
                        onTap: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                                return FullScreenImage(
                                  imageUrl:
                                  snapshot.data['attachment_url']+
                                      snapshot.data['visit_attachment'][index]['image'],
                                  tag: "generate_a_unique_tag",
                                );
                              }));
                        },
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(snapshot.data['attachment_url']+
                                  snapshot.data['visit_attachment'][index]['image']),
                              fit: BoxFit.fill,
                            ),

                          ),
                        ),
                      );
                    }),
                  ):Container(),
                  SizedBox(height: 30.0),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          Navigator.pushNamed(
                            context,
                            '/tour-details',
                            arguments: <String, String>{
                              'tour_id': snapshot.data['visit_details'][0]['linkid'].toString(),
                              'member_id': member_id,

                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 20,right: 20),
                          height: deviceSize.height * 0.05,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff9b56ff),
                                blurRadius: 5.0, // has the effect of softening the shadow
                                //spreadRadius: 1.0, // has the effect of extending the shadow
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 15.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "See Detailed Information",
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Icon(
                                    Icons.chevron_right,
                                    color: Color(0xff9b56ff)
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  )
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    }
    else if(link_visit=="Dealer/distributor"){
      return FutureBuilder(
        future: _visits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  SizedBox(height: 20.0),

                  Row(
                    children: <Widget>[
                      SizedBox(width: 20.0),
                      CircleAvatar(

                        backgroundColor:  Color(0xff9b56ff),

                        radius: 28,
                        child: Center(
                          child: Text(
                            snapshot.data['visit_details'][0]['link_visit'][0].toUpperCase(),
                            style: TextStyle(
                                fontSize: 30.0,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Container(
                        width: deviceSize.width * 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Visiting To : "+snapshot.data['visit_details'][0]['link_visit'],
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10.0),

                            Container(
                              width: deviceSize.width * 0.7,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.calendar,
                                    size: 12.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      "Created at : "+snapshot.data['visit_details'][0]['created_at'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Container(
                              width: deviceSize.width * 0.8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.locationArrow,
                                    size: 12.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      snapshot.data['visit_details'][0]['location'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
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
                        "Dealer Code : "+snapshot.data['visit_details'][0]['dealer_code']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Dealer Name : "+snapshot.data['visit_details'][0]['dealer_name']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Mobile No. : "+snapshot.data['visit_details'][0]['dealer_phone']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Email Id : "+snapshot.data['visit_details'][0]['dealer_email']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Comments : "+snapshot.data['visit_details'][0]['comments']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Status : "+snapshot.data['visit_details'][0]['status'],
                        style: TextStyle(color: Colors.black87,)),
                  ),
                  SizedBox(height: 10.0),
                  snapshot.data['visit_attachment'].length!=0? GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    primary: false,
                    childAspectRatio: 1,
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    children: List.generate( snapshot.data['visit_attachment'].length, (index) {
                      return Container(
                        height: 400,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(snapshot.data['attachment_url']+
                                snapshot.data['visit_attachment'][index]['image']),
                            fit: BoxFit.fill,
                          ),

                        ),
                      );
                    }),
                  ):Container(),
                  SizedBox(height: 30.0),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    }
    else if(link_visit=="Influancer"){
      return FutureBuilder(
        future: _visits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  SizedBox(height: 20.0),
                  /* Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.blue,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(snapshot.data['visit_details'][0]['lead_id'],
                          style: stats,
                        ),
                        const SizedBox(height: 5.0),
                        Text("Status"+snapshot.data['visit_details'][0]['status'].toUpperCase(),style: stats,)
                      ],
                    ),
                  ),
                ),*/
                  SizedBox(height: 10.0),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20.0),
                      CircleAvatar(

                        backgroundColor:  Color(0xff9b56ff),

                        radius: 28,
                        child: Center(
                          child: Text(
                            snapshot.data['visit_details'][0]['link_visit'][0].toUpperCase(),
                            style: TextStyle(
                                fontSize: 30.0,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Container(
                        width: deviceSize.width * 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Visiting To : "+snapshot.data['visit_details'][0]['link_visit'],
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10.0),

                            Container(
                              width: deviceSize.width * 0.7,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.calendar,
                                    size: 12.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      "Created at : "+snapshot.data['visit_details'][0]['created_at'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Container(
                              width: deviceSize.width * 0.8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.locationArrow,
                                    size: 12.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      snapshot.data['visit_details'][0]['location'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
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
                        "Dealer Code : "+snapshot.data['visit_details'][0]['dealer_code']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Dealer Name : "+snapshot.data['visit_details'][0]['dealer_name']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Mobile No. : "+snapshot.data['visit_details'][0]['dealer_phone']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Email Id : "+snapshot.data['visit_details'][0]['dealer_email']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Comments : "+snapshot.data['visit_details'][0]['comments']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Status : "+snapshot.data['visit_details'][0]['status'],
                        style: TextStyle(color: Colors.black87,)),
                  ),
                  SizedBox(height: 10.0),
                  snapshot.data['visit_attachment'].length!=0? GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    primary: false,
                    childAspectRatio: 1,
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    children: List.generate( snapshot.data['visit_attachment'].length, (index) {
                      return Container(
                        height: 400,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(snapshot.data['attachment_url']+
                                snapshot.data['visit_attachment'][index]['image']),
                            fit: BoxFit.fill,
                          ),

                        ),
                      );
                    }),
                  ):Container(),
                  SizedBox(height: 30.0),
                  /*Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          Navigator.pushNamed(
                            context,
                            '/lead-details',
                            arguments: <String, String>{
                              'lead_id':
                              snapshot.data['visit_details'][0]['linkid'].toString(),

                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 20,right: 20),
                          height: deviceSize.height * 0.05,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff9b56ff),
                                blurRadius: 5.0, // has the effect of softening the shadow
                                //spreadRadius: 1.0, // has the effect of extending the shadow
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 15.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "See Detailed Information",
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Icon(
                                    Icons.chevron_right,
                                    color: Color(0xff9b56ff)
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  )*/
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    }
    else if(link_visit=="Other Visit"){
      return FutureBuilder(
        future: _visits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  SizedBox(height: 20.0),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20.0),
                      CircleAvatar(

                        backgroundColor:  Color(0xff9b56ff),

                        radius: 28,
                        child: Center(
                          child: Text(
                            snapshot.data['visit_details'][0]['link_visit'][0].toUpperCase(),
                            style: TextStyle(
                                fontSize: 30.0,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Container(
                        width: deviceSize.width * 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Visiting To : "+snapshot.data['visit_details'][0]['link_visit'],
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10.0),

                            Container(
                              width: deviceSize.width * 0.7,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.calendar,
                                    size: 12.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      "Created at : "+snapshot.data['visit_details'][0]['created_at'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Container(
                              width: deviceSize.width * 0.8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.locationArrow,
                                    size: 12.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      snapshot.data['visit_details'][0]['location'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
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
                        "Comments : "+snapshot.data['visit_details'][0]['comments']),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Status : "+snapshot.data['visit_details'][0]['status'],
                        style: TextStyle(color: Colors.black87,)),
                  ),
                  SizedBox(height: 10.0),
                  snapshot.data['visit_attachment'].length!=0? GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    primary: false,
                    childAspectRatio: 1,
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    children: List.generate( snapshot.data['visit_attachment'].length, (index) {
                      return Container(
                        height: 400,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(snapshot.data['attachment_url']+
                                snapshot.data['visit_attachment'][index]['image']),
                            fit: BoxFit.fill,
                          ),

                        ),
                      );
                    }),
                  ):Container(),
                  SizedBox(height: 30.0),
                  /*Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          Navigator.pushNamed(
                            context,
                            '/lead-details',
                            arguments: <String, String>{
                              'lead_id':
                              snapshot.data['visit_details'][0]['linkid'].toString(),

                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 20,right: 20),
                          height: deviceSize.height * 0.05,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff9b56ff),
                                blurRadius: 5.0, // has the effect of softening the shadow
                                //spreadRadius: 1.0, // has the effect of extending the shadow
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 15.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "See Detailed Information",
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Icon(
                                    Icons.chevron_right,
                                    color: Color(0xff9b56ff)
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  )*/
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





}
