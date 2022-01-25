import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../constants.dart';

class History extends StatefulWidget {
  final Object argument;

  const History({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<History>
    with SingleTickerProviderStateMixin {
  bool _loading = false;

  var _userId;
  Future<dynamic> leads;
  String type = "";
  String name = "";
  String name1 = "";
  String _dropdownValue = "";
  String _dropdownValue1 = "";

  var lead_id = "";
  var lead_i = "";
  var subject = "";

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    subject = data['subject'];
    lead_id = data['lead_id'];
    lead_i = data['id'];
    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _leadData() async {
    var response = await http.post(
      URL+"getleadactivity",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
        "lead_id": lead_i
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
      leads = _leadData();
    });
  }

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Lead History',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[],
        //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: mainWidget(deviceSize)
    );
  }
  Widget mainWidget(Size deviceSize){
    return ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
          child:
          ListView(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  header(),
                  SizedBox(
                    height: 25.0,
                  ),
                  leadList(),
                ],
              )
            ],
          ),


        )
    );
  }
  Widget header() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE9E9E9),
            width: 3,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'SUBJECT',
                    style: GoogleFonts.yantramanav(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subject,
                    style: GoogleFonts.yantramanav(
                      color: const Color(0xff9b56ff),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'LEAD ID',
                    style: GoogleFonts.yantramanav(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    lead_id,
                    style: GoogleFonts.yantramanav(
                      color: const Color(0xff9b56ff),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyOrders() {
    return Center(
      child: Container(child: Text('NO HISTORY FOUND!')),
    );
  }

  Widget leadList() {
    return FutureBuilder(
      future: leads,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['activity_history_list'].length != 0) {
            return Container(
              // color: Colors.red,
              // height: deviceSize.height ,
              child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: snapshot.data['activity_history_list'].length,
                  itemBuilder: (context, index) {
                    return Container(
                     // padding: EdgeInsets.only(bottom: 15.0),
                      child: Container(
                        child:
                            TimelineTile(
                              alignment: TimelineAlign.manual,
                              lineXY: 0.1,
                              isFirst: index==0?true:false,
                              isLast:index ==(snapshot.data['activity_history_list'].length-1)?true:false,
                              indicatorStyle: const IndicatorStyle(
                                width: 20,
                                color:  Color(0xFF2B619C),
                                padding: EdgeInsets.all(6),
                              ),
                              endChild:  _RightChild(
                                asset: 'assets/images/leads.png',
                                title: lead_id,

                               //disabled: index==(snapshot.data['activity_history_list'].length-1)? true : false,
                                message:snapshot.data['activity_history_list'][index]['description'],
                              ),
                              beforeLineStyle: const LineStyle(
                                color:Color(0xFF2B619C),
                              ),

                            ),

                      ),
                    );
                  }

              ),
            );
          }
          else {
            return _emptyOrders();
          }
        } else {
          return Center(child: Container(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

class _RightChild extends StatelessWidget {
   _RightChild({
    Key key,
    this.asset,
    this.title,
    this.message,
    this.disabled = false,
  }) : super(key: key);

  final String asset;
  final String title;
  final String message;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Opacity(
            child: Image.asset(asset, height: 20,color:  Color(0xFF2B619C),),
            opacity: disabled ? 0.5 : 1,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.height * 0.80,
              padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: GoogleFonts.yantramanav(
                      color: disabled
                          ? const Color(0xFFBABABA)
                          : const Color(0xFF636564),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                      message,
                      overflow:
                      TextOverflow.ellipsis,
                      maxLines: 4,
                      style: GoogleFonts.yantramanav(
                        color: disabled
                            ? const Color(0xFFD5D5D5)
                            : const Color(0xFF636564),
                        fontSize: 14,

                      ),

                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
