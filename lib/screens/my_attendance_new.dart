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

class LocalDAListNew extends StatefulWidget {

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<LocalDAListNew>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  var member_id;
  var _userId;
  String _localDA="";
  Future<dynamic> _leads;

  String name="";
  String name1="";
  String _dropdownValue="";
  String _dropdownValue1="";

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

  var arr=[];
  var arr1=[];
  List<String> start_time=[];
  List<String> end_time=[];
  int total_fixed_price=0;

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      _localDA = prefs.getString('local_da_price').toString();
      print(_localDA.toString());

      if(_localDA=="Per Km") {
        _leads = _leadData(name, name1);
      }
      else if(_localDA=="Fixed"){
        _leads = _leadData1(name, name1);
      }
      else{
        _leads = _leadData2(name, name1);
      }
    });
  }

  Future _leadData(String mon,String year ) async {
    var response = await http.post(
     URL+"localDAKm_wise",
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
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }
  Future _leadData1(String mon,String year ) async {
    var response = await http.post(
       URL+"localDAFixed_wise",
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

        setState(() {
          for (int i = 0; i < data['local_DA_list'].length; i++) {
            total_fixed_price=total_fixed_price+data['local_DA_list'][i]['amount'];
          }
        });


      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }
  Future _leadData2(String mon,String year ) async {
    var response = await http.post(
      URL+"attadence",
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

      return data;
    } else {
      throw Exception('Something went wrong');
    }
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

                    child: AutoSizeText(result['attendence_status'].toString(),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: TextStyle(color: Colors.black,
                        )))),
          ),
        ),
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

                child: AutoSizeText("\u20B9 " +result['amount'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['visit_start_time'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['visit_end_time'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['total_hours'].toString()+":"+result['total_minut'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        InkWell(
          onTap: (){

           Navigator.pushNamed(
              context,
              '/attendance',
              arguments: <String, String>{
                'visit_date': result['visit_date'].toString(),
                'da_type': "Per km",

              },
            );
          },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
              alignment: Alignment.center,
              child: Container(

                  child: AutoSizeText("DETAILS",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(color: Colors.blue,
                          fontSize: 12,
                          decoration: TextDecoration.underline,fontWeight: FontWeight.w500)))),
        ),

      ],
    );
  }
  TableRow _getDataRow(result, data) {
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
        Container(child: AutoSizeText(result['attendence_status'].toString(),
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
                fontWeight: FontWeight.w500,color: Colors.black)),),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText("\u20B9 " +result['amount'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),

        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['visit_start_time'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['visit_end_time'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['total_hours'].toString()+":"+result['total_minut'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        InkWell(
          onTap: (){

            Navigator.pushNamed(
              context,
              '/attendance',
              arguments: <String, String>{
                'visit_date': result['visit_date'].toString(),
                'da_type': "Fixed",

              },
            );

          },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
              alignment: Alignment.center,
              child: Container(

                  child: AutoSizeText("DETAILS",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(color: Colors.blue,
                          fontSize: 12,
                          decoration: TextDecoration.underline,fontWeight: FontWeight.w500)))),
        ),

      ],
    );
  }
  TableRow _getDataRow2(result, data) {
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

       Container(child: AutoSizeText(result['attendence_status'].toString(),
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
                fontWeight: FontWeight.w500,color: Colors.black)),),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['visit_start_time'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['visit_end_time'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
            alignment: Alignment.center,
            child: Container(

                child: AutoSizeText(result['total_hours'].toString()+":"+result['total_minut'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(color: Colors.black)))),
      /*  InkWell(
          onTap: (){

           Navigator.pushNamed(
              context,
              '/attendance',
              arguments: <String, String>{
                'visit_date': result['visit_date'].toString(),
                'da_type': "",

              },
            );

          },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 2),
              alignment: Alignment.center,
              child: Container(

                  child: AutoSizeText("DETAILS",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(color: Colors.blue,
                          fontSize: 12,
                          decoration: TextDecoration.underline,fontWeight: FontWeight.w500)))),
        ),*/

      ],
    );
  }
  Widget leadList(Size deviceSize) {
    if(_localDA=="Per Km") {
      return FutureBuilder(
        future: _leads,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // var errorCode = snapshot.data['dealerlist'];
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
                                                .data['user_Km_price'] != null
                                                ? Text(
                                                "Per Km Price: " +
                                                    "\u20B9 " + snapshot
                                                    .data['user_Km_price']
                                                    .toString(),
                                                overflow:
                                                TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: normalText
                                            )
                                                : Text(
                                                "Per Km Price: " + "",
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
                                                "Total Distance: " +
                                                    snapshot
                                                        .data['total_km_distance']
                                                        .toString(),
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
                                                "Total Amount: " +
                                                    "\u20B9 " + snapshot
                                                    .data['total_amount']
                                                    .toString(),
                                                overflow:
                                                TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: normalText
                                            ),
                                          ),

                                        ]),

                                      ],
                                    )
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    child: Table(
                      border: TableBorder.symmetric(
                          inside: BorderSide(width: 1, color: Colors.grey[300]),
                          outside: BorderSide(
                              width: 1, color: Colors.grey[300])),
                      // defaultColumnWidth: FixedColumnWidth(130),
                      defaultVerticalAlignment:
                      TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                            decoration:
                            BoxDecoration(color: Color(0xff9b56ff)),
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Date',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Attn.',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Distance',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),

                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Amount',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Start Time',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('End Time',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Total Time',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                            ]),
                      ],
                    ),
                  ),
                  snapshot.data['local_DA_list']
                      .length != 0 ? Container(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Table(
                      border: TableBorder.symmetric(
                          inside: BorderSide(width: 1, color: Colors.grey[300]),
                          outside: BorderSide(
                              width: 1, color: Colors.grey[300])),
                      defaultVerticalAlignment:
                      TableCellVerticalAlignment.middle,
                      //  columnWidths: {0: FractionColumnWidth(.4)},
                      children:
                      List.generate(
                          snapshot.data['local_DA_list'].length,
                              (index) =>
                              _getDataRow1(
                                  snapshot.data['local_DA_list'][index],

                                  snapshot.data['local_DA_list']))
                      ,
                    ),
                  ) : _emptyOrders()
                ]
            );
          } else {
            return Center(child: Container(child: CircularProgressIndicator()));
          }
        },
      );
    }
    else if(_localDA=="Fixed"){
      return FutureBuilder(
        future: _leads,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // var errorCode = snapshot.data['dealerlist'];
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

                                  SizedBox(
                                    width: 12.0,
                                  ),
                                  Expanded(
                                    child:  Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[

                                        Row(children: <Widget>[
                                          Expanded(
                                            child: snapshot
                                                .data['user_fixed_price'] !=
                                                null ? Text(
                                                "Total Fixed Price: " +
                                                    "₹" + total_fixed_price
                                                    .toString(),
                                                overflow:
                                                TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: normalText
                                            ) : Container(),
                                          ),

                                        ]),
                                        SizedBox(
                                          height: 5.0,
                                        ),

                                        Row(children: <Widget>[
                                          Expanded(
                                            child: Text(
                                                "Total Fixed time: " +
                                                    snapshot
                                                        .data['total_fixed_time']
                                                        .toString(),
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
                    height: 10.0,
                  ),
                  Container(
                    child: Table(
                      border: TableBorder.symmetric(
                          inside: BorderSide(width: 1, color: Colors.grey[300]),
                          outside: BorderSide(
                              width: 1, color: Colors.grey[300])),
                      // defaultColumnWidth: FixedColumnWidth(130),
                      defaultVerticalAlignment:
                      TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                            decoration:
                            BoxDecoration(color: Color(0xff9b56ff)),
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Date',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                child: AutoSizeText('Attn.',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Amount',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))) ,

                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Start Time',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('End Time',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Total Time',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                            ]),
                      ],
                    ),
                  ),
                   snapshot.data['local_DA_list'].length !=
                      0 ? Container(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Table(
                      border: TableBorder.symmetric(
                          inside: BorderSide(width: 1, color: Colors.grey[300]),
                          outside: BorderSide(
                              width: 1, color: Colors.grey[300])),
                      defaultVerticalAlignment:
                      TableCellVerticalAlignment.middle,
                      //  columnWidths: {0: FractionColumnWidth(.4)},
                      children:
                      List.generate(
                          snapshot.data['local_DA_list'].length,
                              (index) =>
                              _getDataRow(
                                  snapshot.data['local_DA_list'][index],

                                  snapshot.data['local_DA_list']))
                      ,
                    ),
                  ) : _emptyOrders(),
                ]
            );
          } else {
            return Center(child: Container(child: CircularProgressIndicator()));
          }
        },
      );
    }
    else{
      return FutureBuilder(
        future: _leads,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // var errorCode = snapshot.data['dealerlist'];
            return Column(
                children: <Widget>[

                  SizedBox(
                    height: 10.0,
                  ),
                Container(
                    child: Table(
                      border: TableBorder.symmetric(
                          inside: BorderSide(width: 1, color: Colors.grey[300]),
                          outside: BorderSide(
                              width: 1, color: Colors.grey[300])),
                      // defaultColumnWidth: FixedColumnWidth(130),
                      defaultVerticalAlignment:
                      TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                            decoration:
                            BoxDecoration(color: Color(0xff9b56ff)),
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Date',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Attn.',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),

                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Start Time',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('End Time',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('Total Time',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),
                            /*  Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: AutoSizeText('',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))),*/
                            ]),
                      ],
                    ),
                  ),

                  snapshot.data['local_DA_list']
                      .length != 0 ? Container(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Table(
                      border: TableBorder.symmetric(
                          inside: BorderSide(width: 1, color: Colors.grey[300]),
                          outside: BorderSide(
                              width: 1, color: Colors.grey[300])),
                      defaultVerticalAlignment:
                      TableCellVerticalAlignment.middle,
                      //  columnWidths: {0: FractionColumnWidth(.4)},
                      children:
                      List.generate(
                          snapshot.data['local_DA_list'].length,
                              (index) =>
                                  _getDataRow2(
                                  snapshot.data['local_DA_list'][index],

                                  snapshot.data['local_DA_list']))
                      ,
                    ),
                  ) : _emptyOrders()
                ]
            );
          } else {
            return Center(child: Container(child: CircularProgressIndicator()));
          }
        },
      );
    }
  }

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return mainWidget(deviceSize);
  }
}
