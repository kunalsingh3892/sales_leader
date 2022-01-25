import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class MyDistributorList extends StatefulWidget {
  final String recordName;
  MyDistributorList(this.recordName);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<MyDistributorList>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  var _userId;
  Future<dynamic> _leads;
  String type = "Pending";
  String _dropdownValue = 'Pending';
  List<UserDetails> _userDetails = [];
  List<UserDetails> _searchResult = [];
  final completeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future _leadData() async {
    _searchResult.clear();
    _userDetails.clear();
    completeController.text = "";
    var response = await http.post(
      URL+"mydealer_distributorlist",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id":widget.recordName!=""?widget.recordName:_userId,
        "type":"Distributor"

      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);

      var result = data['dealer_list'];
      setState(() {
        for (Map user in result) {
          _userDetails.add(UserDetails.fromJson(user));
        }
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
      _leads = _leadData();
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
                    height: 10.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: new TextField(
                        enabled: true,
                        controller: completeController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color(0xff9b56ff),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color(0xff9b56ff),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color(0xff9b56ff),
                            ),
                          ),
                          counterText: "",
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color(0xff9b56ff),
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color:Color(0xff9b56ff),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xff9b56ff),
                            size: 24,
                          ),
                          hintStyle: TextStyle(
                              color: Color(0xff9b56ff),
                              fontFamily: "WorkSansLight"),
                          hintText: 'Search: name, firm name, code ',
                        ),
                        style: TextStyle(
                          color: Color(0xff9b56ff),
                        ),
                        keyboardType: TextInputType.text,
                        cursorColor:Color(0xff9b56ff),
                        textCapitalization: TextCapitalization.none,
                        onChanged: onSearchTextChanged,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  leadList(deviceSize),

                ],
              )
            ],
          ),
        ));
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
            return  _searchResult.length != 0 ||
                completeController.text.isNotEmpty
                ? Container(
              // color: Colors.red,
              // height: deviceSize.height,
              child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: _searchResult.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        elevation: 3.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          child: InkWell(

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
                                          _searchResult[index].owner_name[0].toUpperCase(),
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
                                                _searchResult[index].owner_name,
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
                                                    _searchResult[index].dealer_code,
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
                                              Text(
                                                'Firm Name : ' +
                                                    _searchResult[index].firm_name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.0,
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
                                                  _searchResult[index].dealer_phone,
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
                                            _searchResult[index].dealer_email !=
                                                null
                                                ? Expanded(
                                              child: Text(
                                                _searchResult[index].dealer_email,
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
            ):
              Container(
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
                                          ['owner_name'][0].toUpperCase(),
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
                                                ['owner_name'],
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
                                              Text(
                                                'Firm Name : ' +
                                                    snapshot.data['dealer_list']
                                                    [index]['firm_name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.0,
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
  onSearchTextChanged(String text) async {
    print(text);
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _userDetails.forEach((userDetail) {
      if (userDetail.owner_name
          .toString()
          .toLowerCase()
          .contains(text.toLowerCase()) ||
          userDetail.dealer_code
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          userDetail.firm_name
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase())) _searchResult.add(userDetail);
    });
    print(_searchResult);

    setState(() {});
  }
}

class UserDetails {
  final String id,
      owner_name,
      dealer_code,
      firm_name,
      dealer_phone,
      dealer_email;

  UserDetails(
      {this.id,
        this.owner_name,
        this.dealer_code,
        this.firm_name,
        this.dealer_phone,
        this.dealer_email
      });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return new UserDetails(
        id: json['id'].toString(),
        owner_name: json['owner_name'],
        dealer_code: json['dealer_code'],
        firm_name: json['firm_name'],
        dealer_phone: json['dealer_phone'],
        dealer_email: json['dealer_email']);
  }
}