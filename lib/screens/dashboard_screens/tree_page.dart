import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class MyTeams extends StatefulWidget {
  final Object argument;

  const MyTeams({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<MyTeams>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  var _userId;
  Future<dynamic> _leads;
  var sub_name;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    sub_name = data['sub_name'];
    print(sub_name);
    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _leadData() async {
    var response = await http.post(
      URL+"manage_tree_second",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
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
      _leads = _leadData();
    });
  }

  Widget mainWidget(Size deviceSize) {
    return ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: deviceSize.width * 0.01,
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
                  leadList(deviceSize),
                ],
              )
            ],
          ),
        ));
  }

  Widget _emptyOrders() {
    return Center(
      child: Container(child: Text('NO TEAMS FOUND!')),
    );
  }

  Widget leadList(Size deviceSize) {
    return FutureBuilder(
      future: _leads,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['child'].length != 0) {
            return Container(
              // color: Colors.red,
              // height: deviceSize.height,
              child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: snapshot.data['child'].length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: deviceSize.width * 0.01, vertical: 15),
                      decoration: BoxDecoration(
                          color: Colors.white60,
                          boxShadow: [
                            //background color of box
                            BoxShadow(
                              color: Color(0xffdadada),
                              blurRadius: 25.0, // soften the shadow
                              spreadRadius: 10.0, //extend the shadow
                              offset: Offset(
                                5.0, // Move to right 10  horizontally
                                5.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          )),
                      child: InkWell(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                onTap: (){
                                  if(sub_name=="Leads"){
                                    Navigator.pushNamed(
                                      context,
                                      '/my-leads',
                                      arguments: <String, String>{
                                        'member_id': snapshot.data['child'][index]['id'].toString(),

                                      },
                                    );
                                  }
                                  else if(sub_name=='Visits'){
                                    Navigator.pushNamed(
                                      context,
                                      '/my-visits',
                                      arguments: <String, String>{
                                        'member_id': snapshot.data['child'][index]['id'].toString(),

                                      },
                                    );
                                  }
                                  else if(sub_name=='Dealers/Distributors'){
                                    Navigator.pushNamed(
                                      context,
                                      '/my-dealers',
                                      arguments: <String, String>{
                                        'member_id': snapshot.data['child'][index]['id'].toString(),

                                      },
                                    );
                                  }
                                  else if(sub_name=='Sales Target'){
                                    Navigator.pushNamed(
                                      context,
                                      '/view-salestarget',
                                      arguments: <String, String>{
                                        'member_id': snapshot.data['child'][index]['id'].toString(),

                                      },
                                    );
                                  }
                                  else if(sub_name=='Orders'){
                                    Navigator.pushNamed(
                                      context,
                                      '/order-list',
                                      arguments: <String, String>{
                                        'member_id': snapshot.data['child'][index]['id'].toString(),

                                      },
                                    );
                                  }
                                  else if(sub_name=='Tours'){
                                    Navigator.pushNamed(
                                      context,
                                      '/tours',
                                      arguments: <String, String>{
                                        'member_id': snapshot.data['child'][index]['id'].toString(),

                                      },
                                    );
                                  }
                                  else if(sub_name=='Expense Reimbursements'){
                                    Navigator.pushNamed(
                                      context,
                                      '/expense',
                                      arguments: <String, String>{
                                        'member_id': snapshot.data['child'][index]['id'].toString(),

                                      },
                                    );
                                  }
                                  else if(sub_name=='Orders'){
                                    Navigator.pushNamed(
                                      context,
                                      '/order-list',
                                      arguments: <String, String>{
                                        'member_id': snapshot.data['child'][index]['id'].toString(),

                                      },
                                    );
                                  }
                                  else if(sub_name=='Target Achievement'){
                                    Navigator.pushNamed(
                                      context,
                                      '/target-achievement',
                                      arguments: <String, String>{
                                        'member_id': snapshot.data['child'][index]['id'].toString(),

                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xff9b56ff),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomLeft: Radius.circular(0),
                                      topRight: Radius.circular(5),
                                      bottomRight: Radius.circular(0),
                                    ),
                                  ),
                                  height: 50,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              child: Text(
                                                snapshot.data['child'][index]['sap_id']+" - "+ snapshot.data['child'][index]['username'],
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(  child:Icon(
                                            Icons.chevron_right,
                                            size: 12.0,
                                            color: Colors.white,
                                          ),),
                                        ]),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Column(children: <Widget>[
                                  ExpandChild(
                                    arrowPadding:
                                        EdgeInsets.only(top: 10, bottom: 5),
                                    icon: Icons.arrow_drop_down,
                                    arrowSize: 16,
                                    expandedHint: "Show Less",
                                    collapsedHint: "Show More",
                                    //  hideArrowOnExpanded: true,
                                    hintTextStyle: TextStyle(
                                        color: Colors.black54, fontSize: 12),
                                    expandArrowStyle: ExpandArrowStyle.both,
                                    child: Column(
                                      children: <Widget>[
                                        ListView.builder(
                                            shrinkWrap: true,
                                            primary: false,
                                            itemCount: snapshot.data['child'][index]['children'].length,
                                            itemBuilder: (context, index1) {
                                              return Column(
                                                  children: <Widget>[
                                                    InkWell(
                                                      onTap: (){
                                                        if(sub_name=="Leads"){
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/my-leads',
                                                            arguments: <String, String>{
                                                              'member_id': snapshot.data['child'][index]['children'][index1]['id'].toString(),

                                                            },
                                                          );
                                                        }
                                                        else if(sub_name=='Visits'){
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/my-visits',
                                                            arguments: <String, String>{
                                                              'member_id': snapshot.data['child'][index]['children'][index1]['id'].toString(),

                                                            },
                                                          );
                                                        }
                                                        else if(sub_name=='Dealers/Distributors'){
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/my-dealers',
                                                            arguments: <String, String>{
                                                              'member_id': snapshot.data['child'][index]['children'][index1]['id'].toString(),

                                                            },
                                                          );
                                                        }
                                                        else if(sub_name=='Tours'){
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/tours',
                                                            arguments: <String, String>{
                                                              'member_id': snapshot.data['child'][index]['children'][index1]['id'].toString(),

                                                            },
                                                          );
                                                        }
                                                        else if(sub_name=='Expense Reimbursements'){
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/expense',
                                                            arguments: <String, String>{
                                                              'member_id': snapshot.data['child'][index]['children'][index1]['id'].toString(),

                                                            },
                                                          );
                                                        }
                                                        else if(sub_name=='Orders'){
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/order-list',
                                                            arguments: <String, String>{
                                                              'member_id': snapshot.data['child'][index]['children'][index1]['id'].toString(),

                                                            },
                                                          );
                                                        }
                                                        else if(sub_name=='Sales Target'){
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/view-salestarget',
                                                            arguments: <String, String>{
                                                              'member_id': snapshot.data['child'][index]['children'][index1]['id'].toString(),

                                                            },
                                                          );
                                                        }
                                                        else if(sub_name=='Target Achievement'){
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/target-achievement',
                                                            arguments: <String, String>{
                                                              'member_id': snapshot.data['child'][index]['children'][index1]['id'].toString(),

                                                            },
                                                          );
                                                        }
                                                      },
                                                      child: Card(
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Color(0xFFd8d8d8)),
                                                        color: Color(0xFFf5f6f8),
                                                      ),
                                                      padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Container(
                                                              child: Text(
                                                                snapshot.data['child'][index]['children'][index1]['sap_id']+" - "+  snapshot.data['child'][index]['children'][index1]['username'],
                                                                style: TextStyle(
                                                                  color: Colors.black54,
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(  child:Icon(
                                                            Icons.chevron_right,
                                                            size: 12.0,
                                                            color: Colors.black,
                                                          ),),
                                                        ],
                                                      ),
                                                  ),
                                                ),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(bottom: 10),
                                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                                      child: Column(children: <Widget>[
                                                        ExpandChild(
                                                          arrowPadding:
                                                          EdgeInsets.only(top: 10, bottom: 5),
                                                          icon: Icons.arrow_drop_down,
                                                          arrowSize: 16,
                                                          expandedHint: "Show Less",
                                                          collapsedHint: "Show More",
                                                          //  hideArrowOnExpanded: true,
                                                          hintTextStyle: TextStyle(
                                                              color: Colors.black54, fontSize: 12),
                                                          expandArrowStyle: ExpandArrowStyle.both,
                                                          child: Column(
                                                            children: <Widget>[
                                                              ListView.builder(
                                                                  shrinkWrap: true,
                                                                  primary: false,
                                                                  itemCount: snapshot.data['child'][index]['children'][index1]
                                                                      ['children'].length,
                                                                  itemBuilder: (context, index2) {
                                                                    return Column(
                                                                        children: <Widget>[ InkWell(
                                                                          onTap: (){
                                                                            if(sub_name=="Leads"){
                                                                              Navigator.pushNamed(
                                                                                context,
                                                                                '/my-leads',
                                                                                arguments: <String, String>{
                                                                                  'member_id': snapshot.data['child'][index]['children'][index1]
                                                                                  ['children'][index2]['id'].toString(),

                                                                                },
                                                                              );
                                                                            }
                                                                            else if(sub_name=='Visits'){
                                                                              Navigator.pushNamed(
                                                                                context,
                                                                                '/my-visits',
                                                                                arguments: <String, String>{
                                                                                  'member_id': snapshot.data['child'][index]['children'][index1]
                                                                                  ['children'][index2]['id'].toString(),

                                                                                },
                                                                              );
                                                                            }
                                                                            else if(sub_name=='Dealers/Distributors'){
                                                                              Navigator.pushNamed(
                                                                                context,
                                                                                '/my-dealers',
                                                                                arguments: <String, String>{
                                                                                  'member_id': snapshot.data['child'][index]['children'][index1]
                                                                                  ['children'][index2]['id'].toString(),
                                                                                },
                                                                              );
                                                                            }
                                                                            else if(sub_name=='Tours'){
                                                                              Navigator.pushNamed(
                                                                                context,
                                                                                '/tours',
                                                                                arguments: <String, String>{
                                                                                  'member_id': snapshot.data['child'][index]['children'][index1]
                                                                                  ['children'][index2]['id'].toString(),

                                                                                },
                                                                              );
                                                                            }
                                                                            else if(sub_name=='Expense Reimbursements'){
                                                                              Navigator.pushNamed(
                                                                                context,
                                                                                '/expense',
                                                                                arguments: <String, String>{
                                                                                  'member_id': snapshot.data['child'][index]['children'][index1]
                                                                                  ['children'][index2]['id'].toString(),

                                                                                },
                                                                              );
                                                                            }
                                                                            else if(sub_name=='Orders'){
                                                                              Navigator.pushNamed(
                                                                                context,
                                                                                '/order-list',
                                                                                arguments: <String, String>{
                                                                                  'member_id': snapshot.data['child'][index]['children'][index1]
                                                                                  ['children'][index2]['id'].toString(),

                                                                                },
                                                                              );
                                                                            }
                                                                            else if(sub_name=='Sales Target'){
                                                                              Navigator.pushNamed(
                                                                                context,
                                                                                '/view-salestarget',
                                                                                arguments: <String, String>{
                                                                                  'member_id': snapshot.data['child'][index]['children'][index1]
                                                                                  ['children'][index2]['id'].toString(),

                                                                                },
                                                                              );
                                                                            }
                                                                            else if(sub_name=='Target Achievement'){
                                                                              Navigator.pushNamed(
                                                                                context,
                                                                                '/target-achievement',
                                                                                arguments: <String, String>{
                                                                                  'member_id':  snapshot.data['child'][index]['children'][index1]
                                                                                  ['children'][index2]['id'].toString(),
                                                                                },
                                                                              );
                                                                            }
                                                                          },
                                                                          child: Card(
                                                                            child: Container(
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(color: Color(0xFFd8d8d8)),
                                                                                color: Color(0xFFf5f6f8),
                                                                              ),

                                                                              padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: <Widget>[
                                                                                  Expanded(
                                                                                    child: Container(
                                                                                      child: Text(
                                                                                        snapshot.data['child'][index]['children'][index1]
                                                                                        ['children'][index2]['sap_id']+" - "+  snapshot.data['child'][index]['children'][index1]
                                                                                        ['children'][index2]['username'],
                                                                                        style: TextStyle(
                                                                                          color: Colors.black54,
                                                                                          fontSize: 15,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Container(  child:Icon(
                                                                                    Icons.chevron_right,
                                                                                    size: 12.0,
                                                                                    color: Colors.black,
                                                                                  ),),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                          Container(
                                                                            padding: EdgeInsets.only(bottom: 10),
                                                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                                                            child: Column(children: <Widget>[
                                                                              ExpandChild(
                                                                                arrowPadding:
                                                                                EdgeInsets.only(top: 10, bottom: 5),
                                                                                icon: Icons.arrow_drop_down,
                                                                                arrowSize: 16,
                                                                                expandedHint: "Show Less",
                                                                                collapsedHint: "Show More",
                                                                                //  hideArrowOnExpanded: true,
                                                                                hintTextStyle: TextStyle(
                                                                                    color: Colors.black54, fontSize: 12),
                                                                                expandArrowStyle: ExpandArrowStyle.both,
                                                                                child: Column(
                                                                                  children: <Widget>[
                                                                                    ListView.builder(
                                                                                        shrinkWrap: true,
                                                                                        primary: false,
                                                                                        itemCount: snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                        ['children'].length,
                                                                                        itemBuilder: (context, index3) {
                                                                                          return Column(
                                                                                              children: <Widget>[ InkWell(
                                                                                                onTap: (){
                                                                                                  if(sub_name=="Leads"){
                                                                                                    Navigator.pushNamed(
                                                                                                      context,
                                                                                                      '/my-leads',
                                                                                                      arguments: <String, String>{
                                                                                                        'member_id': snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                                        ['children'][index3]['id'].toString(),

                                                                                                      },
                                                                                                    );
                                                                                                  }
                                                                                                  else if(sub_name=='Visits'){
                                                                                                    Navigator.pushNamed(
                                                                                                      context,
                                                                                                      '/my-visits',
                                                                                                      arguments: <String, String>{
                                                                                                        'member_id': snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                                        ['children'][index3]['id'].toString(),

                                                                                                      },
                                                                                                    );
                                                                                                  }
                                                                                                  else if(sub_name=='Dealers/Distributors'){
                                                                                                    Navigator.pushNamed(
                                                                                                      context,
                                                                                                      '/my-dealers',
                                                                                                      arguments: <String, String>{
                                                                                                        'member_id': snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                                        ['children'][index3]['id'].toString(),
                                                                                                      },
                                                                                                    );
                                                                                                  }
                                                                                                  else if(sub_name=='Tours'){
                                                                                                    Navigator.pushNamed(
                                                                                                      context,
                                                                                                      '/tours',
                                                                                                      arguments: <String, String>{
                                                                                                        'member_id': snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                                        ['children'][index3]['id'].toString(),

                                                                                                      },
                                                                                                    );
                                                                                                  }
                                                                                                  else if(sub_name=='Expense Reimbursements'){
                                                                                                    Navigator.pushNamed(
                                                                                                      context,
                                                                                                      '/expense',
                                                                                                      arguments: <String, String>{
                                                                                                        'member_id': snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                                        ['children'][index3]['id'].toString(),

                                                                                                      },
                                                                                                    );
                                                                                                  }
                                                                                                  else if(sub_name=='Orders'){
                                                                                                    Navigator.pushNamed(
                                                                                                      context,
                                                                                                      '/order-list',
                                                                                                      arguments: <String, String>{
                                                                                                        'member_id': snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                                        ['children'][index3]['id'].toString(),
                                                                                                      },
                                                                                                    );
                                                                                                  }
                                                                                                  else if(sub_name=='Sales Target'){
                                                                                                    Navigator.pushNamed(
                                                                                                      context,
                                                                                                      '/view-salestarget',
                                                                                                      arguments: <String, String>{
                                                                                                        'member_id': snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                                        ['children'][index3]['id'].toString(),
                                                                                                      },
                                                                                                    );
                                                                                                  }

                                                                                                  else if(sub_name=='Target Achievement'){
                                                                                                    Navigator.pushNamed(
                                                                                                      context,
                                                                                                      '/target-achievement',
                                                                                                      arguments: <String, String>{
                                                                                                        'member_id':  snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                                        ['children'][index3]['id'].toString(),
                                                                                                      },
                                                                                                    );
                                                                                                  }
                                                                                                },
                                                                                                child: Card(
                                                                                                  child: Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      border: Border.all(color: Color(0xFFd8d8d8)),
                                                                                                      color: Color(0xFFf5f6f8),
                                                                                                    ),

                                                                                                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                                                                                                    child: Row(
                                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                                      children: <Widget>[
                                                                                                        Expanded(
                                                                                                          child: Container(
                                                                                                            child: Text(
                                                                                                              snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                                              ['children'][index3]['sap_id']+" - "+  snapshot.data['child'][index]['children'][index1]['children'][index2]
                                                                                                              ['children'][index3]['username'],
                                                                                                              style: TextStyle(
                                                                                                                color: Colors.black54,
                                                                                                                fontSize: 15,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                        Container(  child:Icon(
                                                                                                          Icons.chevron_right,
                                                                                                          size: 12.0,
                                                                                                          color: Colors.black,
                                                                                                        ),),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              ]
                                                                                          );
                                                                                        }),

                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ]),
                                                                          ),
                                                                        ]
                                                                    );
                                                                  }),

                                                            ],
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                  ]
                                              );
                                            }),

                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            );
          } else {
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'My Teams',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[],
        //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: mainWidget(deviceSize),
    );
  }
}
