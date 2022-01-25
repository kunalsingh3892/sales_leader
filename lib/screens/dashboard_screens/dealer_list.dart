import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class DealerList extends StatefulWidget {
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<DealerList>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  TabController controller;
  var _userId;
  Future<dynamic> _leads;
  String type = "Pending";
  String _dropdownValue = 'Pending';
  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: 3);
    _getUser();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future _leadData(String type) async {
    var response = await http.post(
      URL+"tempdealerlists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
        "status":type

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
      _leads = _leadData(type);
    });
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
                    height: 20.0,
                  ),
                  _dropDown(),
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
  Widget _dropDown() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(left: 15, right: 15, top: 0),
        padding: EdgeInsets.all(8),
        decoration: ShapeDecoration(
          /*   gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[Color(0xFFfef1a1), Color(0xFFfdc601)]),*/
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1.0,
              color: Colors.grey,
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
                  color: Color(0xff9e54f8),
                ),
                onChanged: (String newValue) {
                  setState(() {
                    _dropdownValue = newValue;
                    if (_dropdownValue == "Pending") {
                      setState(() {
                        type="Pending";
                      });
                      _leads = _leadData(type);
                    }
                    else if (_dropdownValue == "Approved"){
                      setState(() {

                        type="Approved";
                      });
                      _leads = _leadData(type);
                    }
                    else if (_dropdownValue == "Rejected"){
                      setState(() {

                        type="Rejected";
                      });
                      _leads = _leadData(type);
                    }

                  });
                },
                items: <String>['Pending', 'Approved', 'Rejected']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value,
                        style: new TextStyle(color: Colors.black)),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text('NO RECORDS FOUND!')),
    );
  }
  Widget leadList(Size deviceSize) {
    return FutureBuilder(
      future: _leads,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if(snapshot.data['dealer_list'].length!=0) {
          return Container(
            // color: Colors.red,
            // height: deviceSize.height,
            child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: snapshot.data['dealer_list'].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: Material(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      elevation: 3.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/dealer-detail',
                              arguments: <String, String>{
                                'dealer_id': snapshot.data['dealer_list'][index]['id'].toString(),

                              },
                            );
                          },
                          child: Container(
                          //  height: deviceSize.height * 0.10,
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
                                        snapshot.data['dealer_list'][index]
                                        ['firm_name'][0].toUpperCase(),
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
                                            Text(
                                              snapshot.data['dealer_list'][index]
                                              ['firm_name'],
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
                                                  snapshot.data['dealer_list']
                                                  [index]['dealer_code'],
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
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            snapshot.data['dealer_list'][index]
                                            ['dealer_type']==1?Text(
                                              'Type : ' +
                                                 "Distributor",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12.0,
                                              ),
                                            ):Text(
                                              'Type : ' +
                                                  "Dealer",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              'Status : ' +
                                                  snapshot.data['dealer_list']
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
                                        Row(children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.mobile,
                                            size: 12.0,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            'Mobile No : ' +
                                                snapshot.data['dealer_list']
                                                [index]['dealer_phone'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ]),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.mailBulk,
                                            size: 12.0,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          snapshot.data['dealer_list'][index]
                                          ['dealer_email'] !=
                                              null
                                              ? Expanded(
                                            child: Text(
                                              snapshot.data['dealer_list']
                                              [index]['dealer_email'],
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
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Container(child: CircularProgressIndicator()));
        } else {
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
