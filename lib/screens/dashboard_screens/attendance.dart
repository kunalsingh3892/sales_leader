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

class TodayVisit extends StatefulWidget {
  final Object argument;
  const TodayVisit({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<TodayVisit>
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
  var finalDate2;
      String formattedDate2="";
      String visit_date="";
      String da_type="";
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    visit_date = data['visit_date'];
    da_type = data['da_type'];
    print(visit_date);
    print(da_type);
    _getUser();
  }
/*  final toDateController = TextEditingController();
  void callDatePicker2() async {
    var order = await getDate2();
    setState(() {
      finalDate2 = order;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(finalDate2);
      print(formatted);
      toDateController.text = formatted.toString();
      leads = _leadData(toDateController.text);
    });
  }
  Future<DateTime> getDate2() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
              primaryColor: Color(0xff9b56ff),
              accentColor: Color(0xff9b56ff),
              primarySwatch: MaterialColor(0xff9b56ff, const <int, Color>{
                50: const Color(0xff9b56ff),
                100: const Color(0xff9b56ff),
                200: const Color(0xff9b56ff),
                300: const Color(0xff9b56ff),
                400: const Color(0xff9b56ff),
                500: const Color(0xff9b56ff),
                600: const Color(0xff9b56ff),
                700: const Color(0xff9b56ff),
                800: const Color(0xff9b56ff),
                900: const Color(0xff9b56ff),
              },)),
          child: child,
        );
      },
    );
  }*/
  @override
  void dispose() {
    super.dispose();
  }

  Future _leadData() async {
    var response = await http.post(
      da_type=="Per km"? URL+"localDAKm_wise_details":URL+"localDAfixed_wise_details",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
        "date": visit_date
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
    /*  var now = new DateTime.now();
      var formatter = new DateFormat('dd-MM-yyyy');
      formattedDate2 = formatter.format(now);*/
    //  toDateController.text=formattedDate2;

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
            'DA Details',
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

                  leadList(),
                ],
              )
            ],
          ),


        )
    );
  }
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      borderSide: BorderSide(
        color: Colors.black54,
      ));
  Widget header(String distance,String amount) {
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
        child:Container(

          child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Total Distance',
                        style: GoogleFonts.yantramanav(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        distance,
                        style: GoogleFonts.yantramanav(
                          color: const Color(0xff9b56ff),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Total Amount',
                        style: GoogleFonts.yantramanav(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "\u20B9 " +amount,
                        style: GoogleFonts.yantramanav(
                          color: const Color(0xff9b56ff),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
  Widget header1(String time,String amount) {
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
        child:Container(

          child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Total Hours',
                        style: GoogleFonts.yantramanav(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.yantramanav(
                          color: const Color(0xff9b56ff),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Total Amount',
                        style: GoogleFonts.yantramanav(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "₹"+amount,
                        style: GoogleFonts.yantramanav(
                          color: const Color(0xff9b56ff),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget _emptyOrders() {
    return Center(
      child: Container(child: Text('NO VISIT FOUND!')),
    );
  }

  Widget leadList() {
    return FutureBuilder(
      future: leads,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['local_DA_list'].length != 0) {
            return Column(
                children: <Widget>[
                  da_type=="Per km"?  header(snapshot.data['total_km_distance'].toString(),snapshot.data['total_amount'].toString()):
                  header1(snapshot.data['total_hours'].toString(),snapshot.data['total_amount'].toString()),
                  SizedBox(
                    height: 25.0,
                  ),
                  Container(
                // color: Colors.red,
                // height: deviceSize.height ,
                child: ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: snapshot.data['local_DA_list'].length,
                    itemBuilder: (context, index) {
                      return Container(
                        // padding: EdgeInsets.only(bottom: 15.0),
                        child: Container(
                          child:
                          da_type=="Per km"?  TimelineTile(
                            alignment: TimelineAlign.manual,
                            lineXY: 0.1,
                            isFirst: index==0?true:false,
                            isLast:index ==(snapshot.data['local_DA_list'].length-1)?true:false,
                            indicatorStyle: const IndicatorStyle(
                              width: 20,
                              color:  Color(0xff9b56ff),
                              padding: EdgeInsets.all(6),
                            ),
                            endChild:  _RightChild(
                              asset: 'assets/images/visits.png',
                              title: snapshot.data['local_DA_list'][index]['visit_type']+"       Distance: "+snapshot.data['local_DA_list'][index]['distance'],
                              subtitle: "Visit Date: "+snapshot.data['local_DA_list'][index]['visit_date'],
                              message:snapshot.data['local_DA_list'][index]['location'],
                            ),
                            beforeLineStyle: const LineStyle(
                              color:Color(0xff9b56ff),
                            ),

                          ):TimelineTile(
                            alignment: TimelineAlign.manual,
                            lineXY: 0.1,
                            isFirst: index==0?true:false,
                            isLast:index ==(snapshot.data['local_DA_list'].length-1)?true:false,
                            indicatorStyle: const IndicatorStyle(
                              width: 20,
                              color:  Color(0xff9b56ff),
                              padding: EdgeInsets.all(6),
                            ),
                            endChild:  _RightChild(
                              asset: 'assets/images/visits.png',
                              title: snapshot.data['local_DA_list'][index]['visit_type']+"       Time: "+snapshot.data['local_DA_list'][index]['distance'],
                              subtitle: "Visit Date: "+snapshot.data['local_DA_list'][index]['visit_date'],
                              message:snapshot.data['local_DA_list'][index]['location'],
                            ),
                            beforeLineStyle: const LineStyle(
                              color:Color(0xff9b56ff),
                            ),

                          )
                          ,

                        ),
                      );
                    }

                ),
              ),
                ]
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
    this.subtitle,
    this.message,
    this.disabled = false,
  }) : super(key: key);

  final String asset;
  final String title;
  final String subtitle;
  final String message;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Opacity(
            child: Image.asset(asset, height: 20,color:  Color(0xff9b56ff),),
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
                    subtitle,
                    style: GoogleFonts.yantramanav(
                      color: disabled
                          ? const Color(0xFFBABABA)
                          : const Color(0xFF636564),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w400,

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
