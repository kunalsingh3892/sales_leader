import 'package:auto_size_text/auto_size_text.dart';
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

import '../../constants.dart';

class TourDAList extends StatefulWidget {

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<TourDAList>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  var member_id;
  var _userId;
  Future<dynamic> _leads;

  String name="";
  String name1="";
  String _dropdownValue="";
  String _dropdownValue1="";

  int _total = 0;

  @override
  void initState() {
    super.initState();
    var now = new DateTime.now();
    var firstDate = DateTime.utc( now.month);
    var formatter = new DateFormat('MMM');
    var formatter1 = new DateFormat('yyyy');
    _dropdownValue = formatter.format(now);
    _dropdownValue1 = formatter1.format(now);
    name = formatter.format(now);
    name1 = formatter1.format(now);
    print(_dropdownValue1);

    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future _leadData(String mon,String year ) async {
    var response = await http.post(
      URL+"tourDA",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id":_userId,
        "month": mon,
        "year":year
      },
      headers: {
        "Accept": "application/json",
      },
    );

    print({
      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      "id":_userId,
      "month": mon,
      "year":year
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      for (int i = 0; i < data['tour_list'].length; i++) {

          _total = _total + (data['tour_list'][i]['total_amount']);

      }
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
      _leads = _leadData(name,name1);
    });
  }


  Widget _emptyOrders() {
    return Center(
      child: Container(
          margin: EdgeInsets.only(top: 100),

          child: Text('NO RECORD FOUND!')),
    );
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
                    height: 10.0,
                  ),
                  Container(
                    child: Column(children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              // margin: EdgeInsets.only(left: 15,right: 15),
                              child: Text(
                                "MONTH",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  // fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              // margin: EdgeInsets.only(left: 15,right: 15),
                              child: Text(
                                "YEAR",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  // fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child:  Container(
                              padding: EdgeInsets.only(left: 15,right: 10,bottom: 5,top: 5
                              ),
                              decoration: ShapeDecoration(
                                color: Colors.grey[100],

                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1.0,
                                    color:  Color(0xffbfbfbf),
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  //  margin: EdgeInsets.only(left:20,),
                                  child: DropdownButtonHideUnderline(
                                    child: new DropdownButton<String>(
                                      isExpanded: true,
                                      value: _dropdownValue,
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _dropdownValue = newValue;
                                          if (_dropdownValue == "Jan") {
                                            name = "Jan";
                                            _leads = _leadData(name,name1);
                                          } else if(_dropdownValue == "Feb"){
                                            name = "Feb";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue == "Mar"){
                                            name = "Mar";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue == "Apr"){
                                            name = "Apr";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue == "May"){
                                            name = "May";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue == "Jun"){
                                            name = "Jun";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue == "Jul"){
                                            name = "Jul";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue == "Aug"){
                                            name = "Aug";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue == "Sep"){
                                            name = "Sep";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue == "Oct"){
                                            name = "Oct";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue == "Nov"){
                                            name = "Nov";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue == "Dec"){
                                            name = "Dec";
                                            _leads = _leadData(name,name1);
                                          }
                                          print(_dropdownValue);
                                          print(name);
                                        });
                                      },
                                      items: <String>[
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec',
                                      ].map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child:  new Text(value,
                                              style: new TextStyle(color: Colors.black,fontSize: 14)),

                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child:  Container(
                              padding: EdgeInsets.only(left: 15,right: 10,bottom: 5,top: 5
                              ),

                              decoration: ShapeDecoration(
                                color: Colors.grey[100],
                                /*   gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[Color(0xFFfef1a1), Color(0xFFfdc601)]),*/
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1.0,
                                    color:  Color(0xffbfbfbf),
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  //  margin: EdgeInsets.only(left:20,),
                                  child: DropdownButtonHideUnderline(
                                    child: new DropdownButton<String>(
                                      isExpanded: true,
                                      value: _dropdownValue1,
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _dropdownValue1 = newValue;
                                          if (_dropdownValue1 == "2015") {
                                            name1 = "2015";
                                            _leads = _leadData(name,name1);
                                          } else if(_dropdownValue1 == "2016"){
                                            name1 = "2016";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue1 == "2017"){
                                            name1 = "2017";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue1 == "2018"){
                                            name1 = "2018";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue1 == "2019"){
                                            name1 = "2019";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue1 == "2020"){
                                            name1 = "2020";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue1 == "2021"){
                                            name1 = "2021";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue1 == "2022"){
                                            name1 = "2022";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue1 == "2023"){
                                            name1 = "2023";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue1 == "2024"){
                                            name1 = "2024";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue1 == "2025"){
                                            name1 = "2025";
                                            _leads = _leadData(name,name1);
                                          }
                                          else if(_dropdownValue1 == "2026"){
                                            name1 = "2026";
                                            _leads = _leadData(name,name1);
                                          }
                                          print(_dropdownValue1);
                                          print(name1);
                                        });
                                      },
                                      items: <String>[
                                        '2015',
                                        '2016',
                                        '2017',
                                        '2018',
                                        '2019',
                                        '2020',
                                        '2021',
                                        '2022',
                                        '2023',
                                        '2024',
                                        '2025',
                                        '2026',
                                      ].map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child:  new Text(value,
                                              style: new TextStyle(color: Colors.black,fontSize: 14)),

                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  leadList(deviceSize),

                ],
              )
            ],
          ),
        ));
  }
  TextStyle normalText = GoogleFonts.robotoSlab(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  TableRow _getDataRow1(result, data) {
    var index = data.indexOf(result);

    return TableRow(
      decoration: (index % 2) != 0
          ? BoxDecoration(color: Colors.blue[50],)
          : BoxDecoration(color: Colors.white),
      children: [
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['visit_date'],
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        Material(
          color: Colors.transparent,
          child: InkWell(

            child: Container(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
                alignment: Alignment.center,
                child: Container(

                    child: AutoSizeText(result['distance'].toString(),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: TextStyle(color: Colors.black,
                        )))),
          ),
        ),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['amount'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        InkWell(
          onTap: (){

          },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
              alignment: Alignment.center,
              child: Container(

                  child: AutoSizeText("DETAILS",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(color: Colors.blue,
                          decoration: TextDecoration.underline,fontWeight: FontWeight.w500)))),
        ),

      ],
    );
  }
  Widget leadList(Size deviceSize) {
    return FutureBuilder(
      future: _leads,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
           var response =  snapshot.data['tour_list'];
          return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 0.0),
                  child: Material(
                    borderRadius: BorderRadius.all(Radius.circular(0.0)),
                    elevation: 3.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      child: InkWell(
                        onTap: () {

                        },
                        child: Container(
                          //  height: deviceSize.height * 0.14,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          decoration:
                          BoxDecoration(

                              color: Colors.white),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Color(0xff9b56ff),

                                  radius: 28,
                                  child: Center(
                                    child: Text(
                                      "T"[0].toUpperCase(),
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

                                      Row(children: <Widget>[
                                        Expanded(
                                          child: snapshot
                                              .data['user_da_price']!=null?Text(
                                              "User DA Price: " +
                                                  "₹ "+snapshot
                                                  .data['user_da_price'].toString(),
                                              overflow:
                                              TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText
                                          ):Text(
                                              "User DA Price: " + "",
                                              overflow:
                                              TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText
                                          ),
                                        ),

                                      ]),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                          child: snapshot
                                              .data['user_grade']!=null?Text(
                                              "User Grade: " +
                                                  "₹ "+snapshot
                                                  .data['user_grade'].toString(),
                                              overflow:
                                              TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText
                                          ):Text(
                                              "User Grade: " + "",
                                              overflow:
                                              TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText
                                          ),
                                        ),

                                      ]),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                          child: Text(
                                              "Total Days: " +
                                                  snapshot
                                                      .data['total_days'].toString(),
                                              overflow:
                                              TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText
                                          ),
                                        ),

                                      ]),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                          child: Text(
                                              "Total Hours: " +
                                                  snapshot
                                                  .data['total_hours'].toString(),
                                              overflow:
                                              TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText
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
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5, right: 5),
                  child: Row(
                     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Expanded(
                          child: Text("", style: TextStyle(
                              color: Colors.black45,

                              fontSize: 12.0)),
                        ),
                        Text("Total: "+"\u20B9 " +_total.toString(), style: TextStyle(
                              color: Colors.black,

                              fontWeight: FontWeight.w800,
                              fontSize: 16.0)),

                      ]),
                ),
                snapshot.data['tour_list'].length!=0?  SingleChildScrollView(
                  child: Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snapshot.data['tour_list'].length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[

                        SizedBox(height: 5),
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.only(top: 10, left: 5, right: 5,bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, bottom: 5),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(response[index]['tour_tittle'],
                                              overflow:
                                              TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                              color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                              fontSize: 15.0)),
                                        ]),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Created At: '+response[index]['created_at'], style: TextStyle(
                                              color: Colors.black54,

                                              fontSize: 12.0)),
                                          Text("Amount: "+"\u20B9 " +response[index]['total_amount'].toString(), style: TextStyle(
                                              color: Colors.black,

                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.0)),
                                        ]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Start Date: '+response[index]['start_date_time'], style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12.0)),
                                          Text("Days: " +response[index]['days'].toString(), style: TextStyle(
                                              color: Colors.black,

                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.0)),
                                        ]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("End Date: " +response[index]['end_date_time'], style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12.0)),
                                          Text("Hours: "+response[index]['hours'].toString(), style: TextStyle(
                                              color: Colors.black,

                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.0)),
                                        ]),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ):_emptyOrders()
              ]
          );

        }  else {
          return Center(child: Container(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Container(
      color: Colors.grey[200],
        child: mainWidget(deviceSize));
  }
}
