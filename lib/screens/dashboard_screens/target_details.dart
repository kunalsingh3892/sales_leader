import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';
import 'package:glen_lms/modal/order_json.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class SalesTargetDetails extends StatefulWidget {
  final Object argument;

  const SalesTargetDetails({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<SalesTargetDetails> {
  bool _loading = false;
  var _userId;
  Future<dynamic> _visits;
  var target_id,member_id;

  int _total = 0;
  List<OrderJson> xmlList = new List();
  List<String> quantityList = new List();
  final TextStyle stats = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white);
  List<TextEditingController> _controllers = new List();
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    target_id = data['target_id'];
    member_id = data['member_id'];


    _getUser();
  }

  Future _leadData() async {
    var response = await http.post(
      URL+"sales_target_details",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id":member_id!=""?member_id:_userId,
        "target_id": target_id.toString(),
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);

      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }
  TextStyle smallText = GoogleFonts.robotoSlab(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  TextStyle smallText2 = GoogleFonts.robotoSlab(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.white
  );

  TextStyle normalText = GoogleFonts.robotoSlab(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  TextStyle mediumText = GoogleFonts.robotoSlab(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

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
          'Sales Target Detail',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[],
        //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: leadDetails(deviceSize),
    );
  }
  Widget _networkImage(url) {
    return Container(
      margin: EdgeInsets.only(
        right: 8,
        left: 8,
      ),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(10)),
        //color: Colors.blue.shade200,
        image: DecorationImage(
            image: CachedNetworkImageProvider(
                url),
            fit: BoxFit.cover
        ),
      ),
    );
  }
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      borderSide: BorderSide(
        color: Color(0xff9b56ff),
      ));
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
                      backgroundColor: Color(0xff9b56ff),
                      radius: 28,
                      child: Center(
                        child: Text(
                          snapshot.data['targetlist'][0]['dealer_name'][0]
                              .toUpperCase(),
                          style: TextStyle(fontSize: 30.0, color: Colors.white),
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
                            "Name : " +
                                snapshot.data['targetlist'][0]['dealer_name'],
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
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
                                    "Created at : " +
                                        snapshot.data['targetlist'][0]
                                        ['created_at'],
                                    overflow: TextOverflow.ellipsis,
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
                                  FontAwesomeIcons.mobile,
                                  size: 12.0,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    snapshot.data['targetlist'][0]
                                    ['dealer_phone'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Row(children: <Widget>[
                            Expanded(
                              child: Text(
                                  "Sales Target: " +"₹ "+snapshot.data['targetlist']
                                  [0]['final_target_amount'],
                                  overflow:
                                  TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: normalText
                              ),
                            ),

                          ]),
                          snapshot.data['targetlist']
                          [0]['request_target_amount']!=null? Row(children: <Widget>[
                            Expanded(
                              child: Text(
                                  "New Sales Target: " +"₹ "+snapshot.data['targetlist']
                                  [0]['request_target_amount'],
                                  overflow:
                                  TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: normalText
                              ),
                            )
                          ]):Container(),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 15, left: 10, right: 10),
                          child: Text(
                            "TARGET HISTORY DETAILS",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Color(0xfffb4d6d),
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Divider(
                          height: 20,
                        ),
                        snapshot.data['targethistory'].length!=0?  Container(
                          margin: const EdgeInsets.only(left: 16,right: 16),
                          child: ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              itemCount: snapshot.data['targethistory'].length,
                              itemBuilder: (context,  index) {
                                return Container(

                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFfae3e2).withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ]),
                                  child: Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding:
                                        const EdgeInsets.only(top: 10, left: 10, right: 5,bottom: 10),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              /* CircleAvatar(
                                              backgroundColor:Color(0xff9b56ff),

                                              radius: 28,
                                              child: Center(
                                                child: Text(
                                                  snapshot.data['dealerlist'][index]['dealer_name'][0].toUpperCase(),
                                                  style: TextStyle(fontSize: 30.0,color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 12.0,
                                            ),*/
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
                                                          "Sales Target: "+snapshot.data['targethistory'][index]['target_amount'],
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 14.0,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                          'Status : ' + snapshot.data['targethistory'][index]['status'],
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
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          "New Sales Target: "+snapshot.data['targethistory'][index]['request_target_amount'],
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
                                                            'Created At : ' +snapshot.data['targethistory'][index]['created_at'],
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
                                                            'Comments : ' +snapshot.data['targethistory'][index]['comments'],
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 10.0,
                                                            ),
                                                          ),
                                                        ]
                                                    ),


                                                  ],
                                                ),
                                              ),
                                            ]
                                        ),
                                      )),
                                ) ;

                              }

                          ),
                        )
                            :
                        Container(),

                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.0),

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
