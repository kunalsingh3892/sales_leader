import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class InfluencerDetails extends StatefulWidget {
  final Object argument;
  const InfluencerDetails({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<InfluencerDetails> {
  bool _loading = false;
  var _userId;
  Future<dynamic> _visits;
  var dealer_id,link_visit;
  final TextStyle stats = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white);
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    dealer_id = data['dealer_id'];


    _getUser();
  }


  Future _leadData() async {
    var response = await http.post(URL+"contactinfluancerdetails",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
        "influancer_id":dealer_id.toString()
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
          'Company Promotion Details',
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
                        child: snapshot.data['influancer_details']['dealer_name']!=""?Text(
                          snapshot.data['influancer_details']['dealer_name'][0].toUpperCase(),
                          style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white),
                        ):Text(""),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Container(
                      width: deviceSize.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                snapshot.data['influancer_details']
                                ['dealer_name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                'Code : ' +
                                    snapshot.data['influancer_details']
                                    ['dealer_code'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            width: deviceSize.width * 0.8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.mobile,
                                  size: 12.0,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 10.0),
                                snapshot.data['influancer_details']['dealer_phone']!=""? Expanded(
                                  child: Text(
                                    snapshot.data['influancer_details']['dealer_phone'],
                                    overflow:
                                    TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ):Text(""),

                              ],
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            width: deviceSize.width * 0.8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.mailchimp,
                                  size: 12.0,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 10.0),
                                snapshot.data['influancer_details']['dealer_email']!=""? Expanded(
                                  child: Text(
                                    snapshot.data['influancer_details']['dealer_email'],
                                    overflow:
                                    TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ):Text(""),

                              ],
                            ),
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
                                    "Created at : "+snapshot.data['influancer_details']['created_at'],
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
                                    snapshot.data['influancer_details']['area_first'],
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
                      "Owner Name : "+snapshot.data['influancer_details']['owner_name']),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Zip Code : "+snapshot.data['influancer_details']['pincode']),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Status : "+snapshot.data['influancer_details']['status']),
                ),

                SizedBox(height: 10.0),
                snapshot.data['influancer_details']['comments']!=null? Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Comments : "+snapshot.data['influancer_details']['comments']),
                ):Container(),

                SizedBox(height: 10.0),

                Container(
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  child: Row(
                      children: <Widget>[ Expanded(
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(snapshot.data['attachment_url']+
                                  snapshot.data['influancer_details']['visiting_card']),
                              fit: BoxFit.fill,
                            ),

                          ),
                        ),
                      ),
                        SizedBox(width: 20.0),

                        Expanded(
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(snapshot.data['attachment_url']+
                                    snapshot.data['influancer_details']['visiting_card_back']),
                                fit: BoxFit.fill,
                              ),

                            ),
                          ),
                        ),
                      ]
                  ),
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





}
