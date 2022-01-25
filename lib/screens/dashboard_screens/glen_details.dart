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

class GlenDetails extends StatefulWidget {
  final Object argument;
  const GlenDetails({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<GlenDetails> {
  bool _loading = false;
  var _userId;
  Future<dynamic> _visits;
  var glen_id,link_visit;
  final TextStyle stats = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white);
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    glen_id = data['glen_id'];


    _getUser();
  }


  Future _leadData() async {
    var response = await http.post(URL+"glen_promotion_details",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
        "gp_id":glen_id.toString()
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
                        child: snapshot.data['glen_promotionlist_details'][0]['dealer_name']!=""?Text(
                          snapshot.data['glen_promotionlist_details'][0]['dealer_name'][0].toUpperCase(),
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
                          snapshot.data['glen_promotionlist_details'][0]['dealer_name']!=""? Text(
                            "Name: "+snapshot.data['glen_promotionlist_details'][0]['dealer_name'],
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ):Text(""),
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
                                snapshot.data['glen_promotionlist_details'][0]['dealer_phone']!=""? Expanded(
                                  child: Text(
                                    snapshot.data['glen_promotionlist_details'][0]['dealer_phone'],
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
                                    "Created at : "+snapshot.data['glen_promotionlist_details'][0]['created_at'],
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
                                    snapshot.data['glen_promotionlist_details'][0]['location'],
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
                      "Comments : "+snapshot.data['glen_promotionlist_details'][0]['comments']),
                ),

                SizedBox(height: 10.0),
                snapshot.data[',glen_promotion_document_list'].length!=0? GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  primary: false,
                  childAspectRatio: 1,
                  padding: const EdgeInsets.only(left: 16,right: 16),
                  children: List.generate( snapshot.data[',glen_promotion_document_list'].length, (index) {
                    return InkWell(
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                              return FullScreenImage(
                                imageUrl:
                                snapshot.data['attachment_url']+
                                    snapshot.data[',glen_promotion_document_list'][index]['image'],
                                tag: "generate_a_unique_tag",
                              );
                            }));
                      },
                      child: Container(
                        height: 400,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(snapshot.data['attachment_url']+
                                snapshot.data[',glen_promotion_document_list'][index]['image']),
                            fit: BoxFit.fill,
                          ),

                        ),
                      ),
                    );
                  }),
                ):Container(),

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
