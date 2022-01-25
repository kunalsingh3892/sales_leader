import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class TourDetails extends StatefulWidget {
  final Object argument;
  const TourDetails({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<TourDetails> {
  bool _loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _userId;
  Future<dynamic> _tours;
  var _tour_id, member_id;
  var dealerJson;
  var dealerData;
  Future _dealerData;
  String selectedDealer = "";
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _tour_id = data['tour_id'];
    member_id = data['member_id'];

    print(member_id);
    _getUser();
  }

  Future _leadData() async {
    var response = await http.post(
      URL + "tourplandetails",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "tour_id": _tour_id.toString(),
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
      _tours = _leadData();
      _dealerData = _getDealerCategories();
    });
  }

  Future _getDealerCategories() async {
    var response = await http.post(
      URL + "getdealerlists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": member_id != "" ? member_id : _userId,
        "type": "Both"
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['dealer_list'];
      if (mounted) {
        setState(() {
          dealerData = jsonEncode(result);

          dealerJson = JsonDecoder().convert(dealerData);
          /* _dealer =
              (json).map<Dealer>((item) => Dealer.fromJson(item)).toList();*/
          print(dealerJson.toString());
          /*   List<String> item = _dealer.map((Dealer map) {
            for (int i = 0; i < _dealer.length; i++) {
              if (selectedDealer == map.firm_name) {
                _type = map.id;

                print(selectedDealer);
                return map.id;
              }
            }
          }).toList();
          if (selectedDealer == "") {
            selectedDealer = _dealer[0].firm_name;
          }*/
        });
      }

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

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
                              child: new MultiSelect(
                                // autovalidate: true,
                                initialValue: [],
                                titleText: 'Dealer',
                                titleTextColor: Color(0xff9b56ff),
                                // maxLength: 1, // optional
                                validator: (dynamic value) {
                                  if (value == null) {
                                    return 'Please select one or more option(s)';
                                  }
                                  return null;
                                },
                                errorText:
                                    'Please select one or more option(s)',
                                dataSource: dealerJson,
                                textField: 'firm_name',
                                valueField: 'id',
                                filterable: true,

                                required: false,
                                onSaved: (value) {
                                  setState(() {
                                    dealerData = value;
                                  });
                                },

                                selectIcon: Icons.arrow_drop_down_circle,
                                saveButtonColor: Theme.of(context).primaryColor,
                                saveButtonTextColor: Colors.white,
                                checkBoxColor: Theme.of(context).primaryColor,
                                cancelButtonColor:
                                    Theme.of(context).primaryColor,
                                cancelButtonTextColor: Colors.white,
                                clearButtonColor:
                                    Theme.of(context).primaryColor,
                                clearButtonTextColor: Colors.white,
                                buttonBarColor: Colors.white,
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
                'ADD DEALER',
                style: TextStyle(color: Color(0xff9b56ff)),
              )),
              actions: <Widget>[
                InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      child: Text('ADD', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  onTap: () async {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        _loading = true;
                      });
                      _onFormSaved();
                      for (int i = 0; i < dealerData.length; i++) {
                        if (i == (dealerData.length - 1)) {
                          selectedDealer =
                              selectedDealer + dealerData[i].toString();
                        } else {
                          selectedDealer =
                              selectedDealer + dealerData[i].toString() + ",";
                        }
                      }
                      Map<String, String> headers = {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                      };
                      final msg = jsonEncode({
                        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
                        "id": _userId,
                        "tour_id": tourId,
                        "dealer_id": selectedDealer
                      });
                      var response = await http.post(
                        URL + "touragaindealeradd",
                        body: msg,
                        headers: headers,
                      );
                      print(jsonEncode(msg));
                      var data = json.decode(response.body);
                      if (response.statusCode == 200) {
                        setState(() {
                          _loading = false;
                        });

                        Fluttertoast.showToast(
                            msg: 'Message: ' + data['message'].toString());
                        /* setState(() {
                          _tours = _leadData();
                        });*/

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          '/tours',
                          arguments: <String, String>{
                            'member_id': "",
                          },
                        );
                      } else {
                        setState(() {
                          _loading = false;
                        });
                        print(response.body);

                        Fluttertoast.showToast(msg: data['message'].toString());
                      }
                    }
                  },
                ),
              ],
            );
          });
        });
  }

  void _onFormSaved() {
    final FormState form = _formKey.currentState;
    form.save();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Tour Details',
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

  showConfirmDialog(id, cancel, done, title, content) {
    print(id);
    // Set up the Button
    Widget cancelButton = FlatButton(
      child: Text(cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget doneButton = FlatButton(
      child: Text(done),
      onPressed: () {
        Navigator.of(context).pop();

        _cancelTour(id);
      },
    );

    // Set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        cancelButton,
        doneButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _cancelTour(tourId) async {
    var response = await http.post(
      URL + "tourstatuschanged",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
        "tour_id": tourId,
        "status": "Cancelled",
        "comments": ""
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      Navigator.of(context).pop();
      Navigator.pushNamed(
        context,
        '/tours',
        arguments: <String, String>{
          'member_id': "",
        },
      );
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget leadDetails(Size deviceSize) {
    return FutureBuilder(
      future: _tours,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 30.0),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: <Widget>[
                        Expanded(
                          child: Text(
                            "Tour Title : " +
                                snapshot.data['tour_plan_details'][0]
                                    ['tour_tittle'],
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        member_id == ""
                            ? snapshot.data['canclebuttonshow'] == "true"
                                ? snapshot.data['tour_plan_details'][0]
                                            ['status'] !=
                                        "Cancelled"
                                    ? Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            showConfirmDialog(
                                                snapshot
                                                    .data['tour_plan_details']
                                                        [0]['id']
                                                    .toString(),
                                                'No',
                                                'Yes',
                                                'Cancel Tour',
                                                'Are you sure want to Cancel this tour?');
                                          },
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(right: 20),
                                              width: deviceSize.height * 0.10,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 7, horizontal: 7),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Color(0xff9b56ff)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    "Cancel Tour",
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
                                      )
                                    : Container()
                                : Container()
                            : Container(),
                      ]),
                      SizedBox(height: 5.0),
                      Text(
                        'TOUR ID : ' +
                            snapshot.data['tour_plan_details'][0]['tour_id'],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.calendar,
                            size: 12.0,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 10.0),
                          snapshot.data['tour_plan_details'][0]
                                      ['start_date_time'] !=
                                  null
                              ? Text(
                                  'Start Date : ' +
                                      snapshot.data['tour_plan_details'][0]
                                          ['start_date_time'],
                                  style: TextStyle(color: Colors.black54),
                                )
                              : Text(
                                  "",
                                  style: TextStyle(color: Colors.black54),
                                ),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.calendar,
                            size: 12.0,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 10.0),
                          snapshot.data['tour_plan_details'][0]
                                      ['end_date_time'] !=
                                  null
                              ? Text(
                                  'End Date : ' +
                                      snapshot.data['tour_plan_details'][0]
                                          ['end_date_time'],
                                  style: TextStyle(color: Colors.black54),
                                )
                              : Text(
                                  "",
                                  style: TextStyle(color: Colors.black54),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text("Comments : " +
                      snapshot.data['tour_plan_details'][0]['comments']),
                ),
                SizedBox(height: 5.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Status : " +
                          snapshot.data['tour_plan_details'][0]['status'],
                      style: TextStyle(
                        color: Colors.black87,
                      )),
                ),
                SizedBox(height: 20.0),
                member_id == ""
                    ? snapshot.data['tour_plan_details'][0]['status'] ==
                            "Approved"
                        ? snapshot.data['show_expensebutton'] == "true"
                            ? Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/add-expense',
                                        arguments: <String, String>{
                                          'tour_id': snapshot
                                              .data['tour_plan_details'][0]
                                                  ['id']
                                              .toString(),
                                          'tour_tittle': snapshot
                                              .data['tour_plan_details'][0]
                                                  ['key']
                                              .toString(),
                                          'created_at': snapshot
                                              .data['tour_plan_details'][0]
                                                  ['start_date_time1']
                                              .toString(),
                                          'created_end': snapshot
                                              .data['tour_plan_details'][0]
                                                  ['end_date_time1']
                                              .toString(),
                                          "category": "Tour"
                                        },
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      height: deviceSize.height * 0.05,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xff9b56ff),
                                            blurRadius:
                                                5.0, // has the effect of softening the shadow
                                            //spreadRadius: 1.0, // has the effect of extending the shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        "ADD EXPENSE",
                                                        style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Icon(Icons.chevron_right,
                                                color: Color(0xff9b56ff))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: Text(
                                  "Expense filing window for this Tour is passed.",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xfffb4d6d),
                                      fontSize: 18,
                                      wordSpacing: 1,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                        : Container()
                    : Container(),
                SizedBox(height: 20.0),
                member_id == ""
                    ? Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/sales-executive-view-expense',
                                arguments: <String, String>{
                                  'tourid': snapshot.data['tour_plan_details']
                                          [0]['id']
                                      .toString(),
                                  'created_by_id': _userId
                                },
                              );
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 20, right: 20),
                              height: deviceSize.height * 0.05,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xff9b56ff),
                                    blurRadius:
                                        5.0, // has the effect of softening the shadow
                                    //spreadRadius: 1.0, // has the effect of extending the shadow
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  10.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(left: 15.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "VIEW EXPENSE",
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Icon(Icons.chevron_right,
                                        color: Color(0xff9b56ff))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(height: 20.0),
                Row(children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: snapshot.data['tour_plan_details'][0]
                                ['extend_tour'] !=
                            "Yes"
                        ? Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Text(
                              "DEALER INFORMATION",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xfffb4d6d),
                                  fontSize: 20,
                                  wordSpacing: 1,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Text(
                              "TOUR EXTENDED LIST",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xfffb4d6d),
                                  fontSize: 20,
                                  wordSpacing: 1,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                  ),

                  //_addDealer(snapshot.data['tour_plan_details'][0]['status'],snapshot.data['tour_plan_details'][0]['extend_tour']),

                  snapshot.data['tour_plan_details'][0]['status'] != "Rejected"
                      ? snapshot.data['tour_plan_details'][0]['extend_tour'] !=
                              "Yes"
                          ? Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 15, right: 15),
                                      child: Text(
                                        "Add Dealer",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          // fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    ClipOval(
                                      child: Material(
                                        color:
                                            Color(0xff9b56ff), // button color
                                        child: InkWell(
                                          splashColor: Color(
                                              0xfffb4d6d), // inkwell color
                                          child: SizedBox(
                                              width: 56,
                                              height: 56,
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              )),
                                          onTap: () async {
                                            await showInformationDialog(
                                                context,
                                                snapshot
                                                    .data['tour_plan_details']
                                                        [0]['id']
                                                    .toString());
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container()
                      : Container(),
                ]),
                SizedBox(
                  height: 10,
                ),
                snapshot.data['tour_plan_details'][0]['extend_tour'] != "Yes"
                    ? snapshot.data['dealerlist'].length != 0
                        ? Container(
                            margin: const EdgeInsets.only(left: 16, right: 16),
                            child: ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                itemCount: snapshot.data['dealerlist'].length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 15.0),
                                    child: InkWell(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              CircleAvatar(
                                                backgroundColor:
                                                    Color(0xff9b56ff),
                                                radius: 28,
                                                child: Center(
                                                  child: Text(
                                                    snapshot.data['dealerlist']
                                                            [index]
                                                            ['dealer_name'][0]
                                                        .toUpperCase(),
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Text(
                                                            snapshot.data[
                                                                        'dealerlist']
                                                                    [index]
                                                                ['dealer_name'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14.0,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                          'Dealer Code : ' +
                                                              snapshot.data[
                                                                          'dealerlist']
                                                                      [index][
                                                                  'dealer_code'],
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                                        FontAwesomeIcons.phone,
                                                        size: 12.0,
                                                        color: Colors.black54,
                                                      ),
                                                      SizedBox(
                                                        width: 5.0,
                                                      ),
                                                      Text(
                                                        'Mobile No. : ' +
                                                            snapshot.data[
                                                                        'dealerlist']
                                                                    [index][
                                                                'dealer_phone'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 10.0,
                                                        ),
                                                      ),
                                                    ]),
                                                    SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    Row(children: <Widget>[
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .mailBulk,
                                                        size: 12.0,
                                                        color: Colors.black54,
                                                      ),
                                                      SizedBox(
                                                        width: 5.0,
                                                      ),
                                                      Text(
                                                        'Email Id : ' +
                                                            snapshot.data[
                                                                        'dealerlist']
                                                                    [index][
                                                                'dealer_email'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 10.0,
                                                        ),
                                                      ),
                                                    ]),
                                                    SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    member_id == ""
                                                        ? snapshot.data['tour_plan_details']
                                                                        [0][
                                                                    'status'] ==
                                                                "Approved"
                                                            ? Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .pushNamed(
                                                                      context,
                                                                      '/add-visits',
                                                                      arguments: <
                                                                          String,
                                                                          String>{
                                                                        'visit_to':
                                                                            'Tour',
                                                                        'contact':
                                                                            "",
                                                                        'contact_name':
                                                                            "",
                                                                        'tour_title': snapshot
                                                                            .data['tour_plan_details'][0]['tour_tittle']
                                                                            .toString(),
                                                                        'tour_name':
                                                                            snapshot.data['dealerlist'][index]['dealer_name'],
                                                                        'pinCode':
                                                                            snapshot.data['dealerlist'][index]['pincode'],
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    child:
                                                                        Container(
                                                                      width: deviceSize
                                                                              .height *
                                                                          0.12,
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              7,
                                                                          horizontal:
                                                                              7),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              5),
                                                                          color:
                                                                              Color(0xff9b56ff)),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          /* Icon(
                                                      Icons.edit, size: 10, color: Colors.white,),
                                                    SizedBox(
                                                      width: 5,
                                                    ),*/
                                                                          Text(
                                                                            "Add Visit",
                                                                            // snapshot.data['cart_quantity'] > 0 ? 'Go to Basket' : 'Add to Basket',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container()
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                      ),
                                    ),
                                  );
                                }),
                          )
                        : Container()
                    : snapshot.data['touragainextendlists'].length != 0
                        ? Container(
                            margin: const EdgeInsets.only(left: 16, right: 16),
                            child: ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                itemCount: snapshot
                                    .data['touragainextendlists'].length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 15.0),
                                    child: InkWell(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              CircleAvatar(
                                                backgroundColor:
                                                    Color(0xff9b56ff),
                                                radius: 28,
                                                child: Center(
                                                  child: Text(
                                                    snapshot.data[
                                                            'tour_plan_details']
                                                            [0]['tour_tittle']
                                                            [0]
                                                        .toUpperCase(),
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          snapshot.data[
                                                                  'tour_plan_details']
                                                              [
                                                              0]['tour_tittle'],
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14.0,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                          'Tour Id : ' +
                                                              snapshot.data[
                                                                      'tour_plan_details']
                                                                  [
                                                                  0]['tour_id'],
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                                        FontAwesomeIcons
                                                            .calendar,
                                                        size: 12.0,
                                                        color: Colors.black54,
                                                      ),
                                                      SizedBox(
                                                        width: 5.0,
                                                      ),
                                                      Text(
                                                        'Extend Date: ' +
                                                            snapshot.data[
                                                                        'touragainextendlists']
                                                                    [index][
                                                                'end_date_time'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 10.0,
                                                        ),
                                                      ),
                                                    ]),
                                                    SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    Row(children: <Widget>[
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .comment,
                                                        size: 12.0,
                                                        color: Colors.black54,
                                                      ),
                                                      SizedBox(
                                                        width: 5.0,
                                                      ),
                                                      Text(
                                                        'Comments: ' +
                                                            snapshot.data[
                                                                    'touragainextendlists']
                                                                [
                                                                index]['comments'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 10.0,
                                                        ),
                                                      ),
                                                    ]),
                                                    SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    member_id != ""
                                                        ? snapshot.data['touragainextendlists']
                                                                        [index][
                                                                    'status'] ==
                                                                "No Action"
                                                            ? Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    var response =
                                                                        await http
                                                                            .post(
                                                                      URL +
                                                                          "tourextendedstatuschange",
                                                                      body: {
                                                                        "auth_key":
                                                                            "VrdoCRJjhZMVcl3PIsNdM",
                                                                        "id": member_id
                                                                            .toString(),
                                                                        "extended_id": snapshot
                                                                            .data['touragainextendlists'][index]['id']
                                                                            .toString(),
                                                                      },
                                                                      headers: {
                                                                        "Accept":
                                                                            "application/json",
                                                                      },
                                                                    );

                                                                    if (response
                                                                            .statusCode ==
                                                                        200) {
                                                                      setState(
                                                                          () {
                                                                        _loading =
                                                                            false;
                                                                      });
                                                                      var data =
                                                                          json.decode(
                                                                              response.body);
                                                                      Fluttertoast.showToast(
                                                                          msg: 'Message: ' +
                                                                              data['message'].toString());

                                                                      setState(
                                                                          () {
                                                                        _tours =
                                                                            _leadData();
                                                                      });
                                                                      print(
                                                                          data);
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        _loading =
                                                                            false;
                                                                      });
                                                                      Fluttertoast
                                                                          .showToast(
                                                                              msg: 'Error');
                                                                    }
                                                                  },
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    child:
                                                                        Container(
                                                                      width: deviceSize
                                                                              .height *
                                                                          0.12,
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              7,
                                                                          horizontal:
                                                                              7),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              5),
                                                                          color:
                                                                              Color(0xff9b56ff)),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          /* Icon(
                                                      Icons.edit, size: 10, color: Colors.white,),
                                                    SizedBox(
                                                      width: 5,
                                                    ),*/
                                                                          Text(
                                                                            "Approve",
                                                                            // snapshot.data['cart_quantity'] > 0 ? 'Go to Basket' : 'Add to Basket',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container()
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                      ),
                                    ),
                                  );
                                }),
                          )
                        : Container()
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
