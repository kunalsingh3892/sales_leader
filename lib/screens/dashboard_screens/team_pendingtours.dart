import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class TeamPendingTours extends StatefulWidget {

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<TeamPendingTours>  with SingleTickerProviderStateMixin{
  bool _loading = false;
  TabController controller;
  var _userId;
  Future<dynamic> _leads;
  final cmtController = TextEditingController();
  @override
  void initState() {
    super.initState();

    _getUser();
  }


  Future _leadData() async {
    var response = await http.post(URL+"allleveltourplanlists",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
        "status":"Pending",
      },
      headers: {
        "Accept": "application/json",
      },
    );
    print({
      "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
      "id": _userId,
      "status":"Pending",
    });
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
  Widget mainWidget(Size deviceSize){
    return ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: deviceSize.width * 0.03,
          ),
          child: ListView(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  /* Heading(
                      title: 'Last Leads',
                    ),*/
                  SizedBox(
                    height: 25.0,
                  ),
                  leadList(deviceSize),
                ],
              )
            ],
          ),

        )
    );
  }

  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text('NO TOURS FOUND!')),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<void> showInformationDialog(BuildContext context, tourId) async {
    return await showDialog(
        context: context,
        builder: (context) {
          bool isChecked = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                height: 80,
                                margin: new EdgeInsets.only(left: 15, right: 15),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      cursorColor: Color(0xff9b56ff),
                                      hintColor: Colors.transparent,
                                    ),
                                    child: TextFormField(
                                      maxLines: 10,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          hintStyle: TextStyle(
                                              color: Colors.grey[400], fontFamily: "WorkSansLight"),
                                          hintText: "Post Comment"),
                                      controller: cmtController,
                                      minLines: 10,
                                      //Normal textInputField will be displayed
                                      cursorColor: Color(0xff9b56ff),
                                      keyboardType: TextInputType.text,
                                      textCapitalization: TextCapitalization.none,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "Please Enter Comment";
                                        }
                                        return null;
                                      },
                                      onSaved: (String value) {
                                        cmtController.text = value;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            /* RaisedButton(
                          child: Text('Save'),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            _onFormSaved();
                          },
                        )*/
                          ],
                        ),
                      ),
                    ],
                  )),
              title: Center(
                  child: Text(
                    'REJECT TOUR',
                    style: TextStyle(color: Color(0xff9b56ff)),
                  )),
              actions: <Widget>[
                InkWell(
                  child: Container(

                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.shade200,
                              offset: Offset(2, 4),
                              blurRadius: 5,
                              spreadRadius: 2)
                        ],
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff9e54f8), Color(0xfffb4d6d)])),
                    child: Center(
                      child: Text('REJECT',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  onTap: () async {

                    if(cmtController.text!="") {
                      var response = await http.post(
                        URL+"tourstatuschanged",
                        body: {
                          "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
                          "id": _userId,
                          "tour_id": tourId,
                          "status": "Rejected",
                          "comments": cmtController.text
                        },
                        headers: {
                          "Accept": "application/json",
                        },
                      );
                      var data = json.decode(response.body);
                      if (response.statusCode == 200) {
                        setState(() {
                          _loading = false;
                        });

                        Fluttertoast.showToast(
                            msg: 'Message: ' + data['message'].toString());
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        setState(() {
                          _leads = _leadData();
                        });
                        print(data);
                      } else {
                        setState(() {
                          _loading = false;
                        });
                        Fluttertoast.showToast(msg: "" +
                            data['message'].toString());
                      }
                    }
                    else{
                      Fluttertoast.showToast(msg: "" +
                          "Please enter comment");
                    }
                  },
                ),
              ],
            );
          });
        });
  }

  Widget leadList(Size deviceSize){
    return FutureBuilder(
      future: _leads,
      builder: (context, snapshot) {
        if (snapshot.hasData)
        {
          if(snapshot.data['all_level_tour_plan_list'].length!=0) {
            return  Container(
              // color: Colors.red,
              //  height: deviceSize.height ,
              child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: snapshot.data['all_level_tour_plan_list'].length,
                  itemBuilder: (context,  index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        elevation: 3.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          child: InkWell(
                            onTap: (){

                              /*Navigator.pushNamed(
                                context,
                                '/tour-details',
                                arguments: <String, String>{
                                  'tour_id': snapshot.data['tour_plan_list'][index]['id'].toString(),
                                  'member_id': widget.recordName,
                                },
                              );*/
                            },
                            child: Container(
                              //  height: deviceSize.height * 0.10,
                              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                              decoration: (index % 2) != 0
                                  ? BoxDecoration(  /*border: Border(
                              left: BorderSide(
                                width: 10.0,
                                color: primaryColor,
                              ),
                            )*/color: Color(0xFFf6f6f6))
                                  : BoxDecoration(  /*border: Border(
                              left: BorderSide(
                                width: 10.0,
                                color: primaryColor,
                              ),
                            ),*/color: Colors.white),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor:  (index % 2) != 0 ? Color(0xff9b56ff):Color(0xFFfe4c64),

                                      radius: 28,
                                      child: Center(
                                        child: Text(
                                          snapshot.data['all_level_tour_plan_list'][index]['tour_tittle'][0].toUpperCase(),
                                          style: TextStyle(fontSize: 30.0,color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12.0,
                                    ),
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
                                                snapshot.data['all_level_tour_plan_list'][index]['tour_tittle'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              Text(
                                                'TOUR ID : ' + snapshot.data['all_level_tour_plan_list'][index]['tour_id'],
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
                                                  'Start Date : ' +snapshot.data['all_level_tour_plan_list'][index]['start_date_time'],
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
                                                  FontAwesomeIcons.calendar,
                                                  size: 12.0,
                                                  color: Colors.black54,
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  'End Date : ' +snapshot.data['all_level_tour_plan_list'][index]['end_date_time'],
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
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    "Created by: " +snapshot.data['all_level_tour_plan_list'][index]['created_by'],
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Status : ' +snapshot.data['all_level_tour_plan_list'][index]['status'],
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
                                             Expanded(
                                               child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () async {
                                                    var response = await http.post(
                                                      URL+"tourstatuschanged",
                                                      body: {
                                                        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
                                                        "id": _userId.toString(),
                                                        "tour_id": snapshot.data['all_level_tour_plan_list'][index]['id'].toString(),
                                                        "status":"Approved",
                                                        "comments":""
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
                                                        _leads = _leadData();
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
                                                      width: deviceSize.height * 0.12,
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: 5, horizontal: 5),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          color: Color(0xff9b56ff)

                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[

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
                                            ),
                                             ),
                                             Expanded(
                                               child: Material(
                                                 color: Colors.transparent,
                                                 child: InkWell(
                                                   onTap: () async {
                                                     await showInformationDialog(context,
                                                         snapshot.data['all_level_tour_plan_list'][index]['id'].toString());
                                                   },
                                                   child: Align(
                                                     alignment: Alignment.topRight,
                                                     child: Container(
                                                       width: deviceSize.height * 0.12,
                                                       padding: EdgeInsets.symmetric(
                                                           vertical: 5, horizontal: 5),
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
                                                             "Reject",
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
                                               ),
                                             ),
                                           ]

                                         ),
                                        ],
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

              ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: Text(
          'Team Pending for Approval Tours',
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
