import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class Miscellaneous extends StatefulWidget {
  final String recordName;
  Miscellaneous(this.recordName);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<Miscellaneous>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  var _userId;
  Future<dynamic> _leads;


  String status="Pending";
  String name="";
  String name1="";
  String _dropdownValue="";
  String _dropdownValue2="Pending";
  String _dropdownValue1="";
  var total=0;
  String approvedButton="";

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


  Future _leadData(String name,String mon,String year) async {
    var response = await http.post(
      URL+"expensereimbursmentstypewiselists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id":widget.recordName!=""?widget.recordName:_userId,
        "type":"Miscellaneous",
        "month":mon,
        "year":year,
        "status":name
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        total=data['total'];
        approvedButton=data['approved_button'];
      });

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
      _leads = _leadData(status,name,name1);
    });
  }


  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text('NO EXPENSE FOUND!')),
    );
  }
  TextStyle mediumText = GoogleFonts.robotoSlab(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xff9b56ff)
  );

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
                    height: 15.0,
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
                          SizedBox(
                            width: 5,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              // margin: EdgeInsets.only(left: 15,right: 15),
                              child: Text(
                                "Status",
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
                                            _leads = _leadData(status,name,name1);
                                          } else if(_dropdownValue == "Feb"){
                                            name = "Feb";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue == "Mar"){
                                            name = "Mar";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue == "Apr"){
                                            name = "Apr";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue == "May"){
                                            name = "May";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue == "Jun"){
                                            name = "Jun";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue == "Jul"){
                                            name = "Jul";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue == "Aug"){
                                            name = "Aug";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue == "Sep"){
                                            name = "Sep";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue == "Oct"){
                                            name = "Oct";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue == "Nov"){
                                            name = "Nov";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue == "Dec"){
                                            name = "Dec";
                                            _leads = _leadData(status,name,name1);
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
                            width: 5,
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
                                            _leads = _leadData(status,name,name1);
                                          } else if(_dropdownValue1 == "2016"){
                                            name1 = "2016";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue1 == "2017"){
                                            name1 = "2017";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue1 == "2018"){
                                            name1 = "2018";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue1 == "2019"){
                                            name1 = "2019";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue1 == "2020"){
                                            name1 = "2020";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue1 == "2021"){
                                            name1 = "2021";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue1 == "2022"){
                                            name1 = "2022";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue1 == "2023"){
                                            name1 = "2023";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue1 == "2024"){
                                            name1 = "2024";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue1 == "2025"){
                                            name1 = "2025";
                                            _leads = _leadData(status,name,name1);
                                          }
                                          else if(_dropdownValue1 == "2026"){
                                            name1 = "2026";
                                            _leads = _leadData(status,name,name1);
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
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(5),

                              decoration: ShapeDecoration(
                                color: Colors.grey.shade100,
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
                                      value: _dropdownValue2,
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black54,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _dropdownValue2 = newValue;

                                          if (_dropdownValue2 == "Pending") {
                                            status = "Pending";

                                            if(name=="" && name1==""){
                                              _leads = _leadData(status,name,name1);
                                            }else{
                                              _leads = _leadData(status,name,name1);
                                            }


                                          }
                                          else if(_dropdownValue2 == "Approved"){
                                            status = "Approved";
                                            if(name=="" && name1==""){
                                              _leads = _leadData(status,name,name1);
                                            }else{
                                              _leads = _leadData(status,name,name1);
                                            }

                                          }

                                          print(_dropdownValue2);
                                          print(status);
                                        });
                                      },
                                      items: <String>[
                                        'Pending',
                                        'Approved'
                                      ].map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child:  new Text(value,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              maxLines: 1,
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
                    height: 15.0,
                  ),
                  Container(

                    child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Total: "+total.toString(),
                                style: mediumText,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Expanded(
                            child: Container(
                             child: widget.recordName!=""?
                             approvedButton!="false"?
                             Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    var response = await http.post(
                                      URL+"monthwisestatuschanged",
                                      body: {
                                        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
                                        "id": widget.recordName.toString(),
                                        "user_id":_userId,
                                        "type":"Miscellaneous",
                                        "month":name,
                                        "year":name1
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
                                        _leads = _leadData(status,name,name1);
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
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Color(0xff9b56ff)

                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          /*  Icon(
                                                      Icons.edit, size: 10, color: Colors.white,),*/
                                          SizedBox(
                                            width: 5,
                                          ),
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
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  leadList(deviceSize),

                ],
              )
            ],
          ),
        ));
  }

  TextStyle smallText1 = GoogleFonts.robotoSlab(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.black87
  );
  TextStyle smallText = GoogleFonts.robotoSlab(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xff9b56ff)
  );
  Widget leadList(Size deviceSize) {
    return FutureBuilder(
      future: _leads,
      builder: (context, snapshot) {

        if (snapshot.hasData) {
          if(snapshot.data['expense_list'].length!=0) {
            return Container(
              // color: Colors.red,
              // height: deviceSize.height,
              child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: snapshot.data['expense_list'].length,
                  itemBuilder: (context, index) {
                    return  Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child:  Material(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          elevation: 3.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            child: InkWell(
                              onTap: () {
                             /*   Navigator.pushNamed(
                                  context,
                                  '/expense-details',
                                  arguments: <String, String>{
                                    'expense_id': snapshot.data['expense_list'][index]['id'].toString(),


                                  },
                                );*/
                              },
                              child: Container(
                                // height: deviceSize.height * 0.10,
                                padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                                decoration: (index % 2) != 0
                                    ? BoxDecoration(
                                  /*border: Border(
                                  left: BorderSide(
                                    width: 10.0,
                                    color: primaryColor,
                                  ),
                                )*/
                                    color: Color(0xFFf6f6f6))
                                    : BoxDecoration(
                                  /*border: Border(
                                  left: BorderSide(
                                    width: 10.0,
                                    color: primaryColor,
                                  ),
                                ),*/
                                    color: Colors.white),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      CircleAvatar(
                                        backgroundColor: (index % 2) != 0
                                            ? Color(0xff9b56ff)
                                            : Color(0xFFfe4c64),
                                        radius: 28,
                                        child: Center(
                                          child: Text(
                                            snapshot.data['expense_list'][index]
                                            ['category'][0].toUpperCase(),
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
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text("Category: "+
                                                    snapshot.data['expense_list'][index]
                                                    ['category'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  'Amount : ' +
                                                      snapshot.data['expense_list']
                                                      [index]['amount'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            Row(children: <Widget>[
                                              Icon(
                                                FontAwesomeIcons.calendar,
                                                size: 12.0,
                                                color: Colors.black54,
                                              ),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              snapshot.data['expense_list'][index]
                                              ['ex_date'] !=
                                                  null
                                                  ? Expanded(
                                                child: Text(
                                                  "Ex. Date: "+snapshot.data['expense_list']
                                                  [index]['ex_date'],
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10.0,
                                                  ),
                                                ),
                                              )
                                                  : Text(
                                                "",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                            ]),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                   "Created at: " +snapshot.data['expense_list'][index]['created_at'],
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10.0,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  'Status : ' +
                                                      snapshot.data['expense_list']
                                                      [index]['status'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        ),


                    );
                  }),
            );
          }
          else{
            return _emptyOrders();
          }

        }
        else {
          return Center(child: Container(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return mainWidget(deviceSize);
  }
}
