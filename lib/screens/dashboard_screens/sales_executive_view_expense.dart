import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class SalesExecutivePendingDetails extends StatefulWidget {
  final Object argument;

  const SalesExecutivePendingDetails({Key key, this.argument})
      : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<SalesExecutivePendingDetails>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  TabController controller;
  var _userId;
  Future<dynamic> _leads;
  String created_by_id = "";
  String tourid = "";

  bool show = false;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    created_by_id = data['created_by_id'];
    tourid = data['tourid'];
    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _leadData() async {
    var response = await http.post(
      URL + "exlistbytouruserid",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
        "user_id": created_by_id,
        "tour_id": tourid
      },
      headers: {
        "Accept": "application/json",
      },
    );
    print({
      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      "id": _userId,
      "user_id": created_by_id,
      "tour_id": tourid
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      if (data['approved_button'] != 'false') {
        setState(() {
          show = true;
        });
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
      _leads = _leadData();
    });
  }

  Widget _emptyOrders() {
    return Center(
      child: Container(child: Text('NO EXPENSE FOUND!')),
    );
  }

  Widget mainWidget(Size deviceSize) {
    return ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
            child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Expanded(
                child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: deviceSize.width * 0.03,
                    ),
                    child: leadList(deviceSize))),
          ],
        )));
  }

  TextStyle smallText1 = GoogleFonts.robotoSlab(
      fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black87);
  TextStyle smallText2 = GoogleFonts.robotoSlab(
      fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black);
  TextStyle smallText = GoogleFonts.robotoSlab(
      fontSize: 12, fontWeight: FontWeight.normal, color: Color(0xff9b56ff));
  TextStyle normalText = GoogleFonts.robotoSlab(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  TextStyle normalText1 = GoogleFonts.robotoSlab(
    fontSize: 26,
    fontWeight: FontWeight.w600,
  );

  Widget leadList(Size deviceSize) {
    return FutureBuilder(
      future: _leads,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text("",
                          style:
                              TextStyle(color: Colors.black45, fontSize: 12.0)),
                    ),
                    Text(
                        "Total: " +
                            "\u20B9 " +
                            (snapshot.data['total'])
                                .toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 16.0)),
                  ]),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 0.0),
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(0.0)),
                elevation: 3.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      //  height: deviceSize.height * 0.14,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    Expanded(
                                      child: snapshot.data['tour_id'] != null
                                          ? Text(
                                              "Tour ID: " +
                                                  snapshot.data['tour_id']
                                                      .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText)
                                          : Text("Tour ID: " + "",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText),
                                    ),
                                  ]),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(children: <Widget>[
                                    Expanded(
                                      child: snapshot.data['tour_tittle'] !=
                                              null
                                          ? Text(
                                              "Title: " +
                                                  snapshot.data['tour_tittle']
                                                      .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText)
                                          : Text("Title" + "",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText),
                                    ),
                                  ]),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(children: <Widget>[
                                    Expanded(
                                      child: Text(
                                          "Start Date: " +
                                              snapshot.data['start_date_time']
                                                  .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: normalText),
                                    ),
                                  ]),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(children: <Widget>[
                                    Expanded(
                                      child: Text(
                                          "End Date: " +
                                              snapshot.data['end_date_time']
                                                  .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: normalText),
                                    ),
                                  ]),
                                  /*   SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(children: <Widget>[
                                          Expanded(
                                            child: Text(
                                                "DA Amount: " +
                                                    snapshot
                                                        .data['tourdaamount'].toString(),
                                                overflow:
                                                TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: normalText
                                            ),
                                          ),

                                        ]),*/
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    Expanded(
                                      child: snapshot.data['da_price'] != null
                                          ? Text(
                                              "User DA Price: " +
                                                  "₹ " +
                                                  snapshot.data['da_price']
                                                      .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText)
                                          : Text("User DA Price: " + "",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText),
                                    ),
                                  ]),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(children: <Widget>[
                                    Expanded(
                                      child: snapshot.data['user_grade'] != null
                                          ? Text(
                                              "User Grade: " +
                                                  "₹ " +
                                                  snapshot.data['user_grade']
                                                      .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText)
                                          : Text("User Grade: " + "",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: normalText),
                                    ),
                                  ]),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(children: <Widget>[
                                    Expanded(
                                      child: Text(
                                          "Total Days: " +
                                              snapshot.data['days'].toString(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: normalText),
                                    ),
                                  ]),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(children: <Widget>[
                                    Expanded(
                                      child: Text(
                                          "Total Hours: " +
                                              snapshot.data['hours'].toString(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: normalText),
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
            Padding(
              padding: EdgeInsets.only(bottom: 0.0),
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(0.0)),
                elevation: 3.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      //  height: deviceSize.height * 0.14,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                "DA Amount: " +
                                    snapshot.data['tourdaamount'].toString(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: normalText1),
                          ]),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            snapshot.data['expense_list'].length != 0
                ? SingleChildScrollView(
                    child: Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: snapshot.data['expense_list'].length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 15.0),
                              child: Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                child: Material(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  elevation: 3.0,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/expense-details',
                                          arguments: <String, String>{
                                            'expense_id': snapshot
                                                .data['expense_list'][index]
                                                    ['id']
                                                .toString(),
                                          },
                                        );
                                      },
                                      child: Container(
                                        // height: deviceSize.height * 0.10,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 10),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              CircleAvatar(
                                                backgroundColor:
                                                    (index % 2) != 0
                                                        ? Color(0xff9b56ff)
                                                        : Color(0xFFfe4c64),
                                                radius: 28,
                                                child: Center(
                                                  child: Text(
                                                    snapshot
                                                        .data['expense_list']
                                                            [index]['category']
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
                                                          'Category : ' +
                                                              snapshot.data[
                                                                          'expense_list']
                                                                      [index]
                                                                  ['category'],
                                                          style: smallText2,
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                          'Status : ' +
                                                              snapshot.data[
                                                                      'expense_list']
                                                                  [
                                                                  index]['status'],
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Text(
                                                          'Ex.Date : ' +
                                                              snapshot.data[
                                                                          'expense_list']
                                                                      [index]
                                                                  ['ex_date'],
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                      snapshot.data['expense_list']
                                                                      [index][
                                                                  'created_at'] !=
                                                              null
                                                          ? Expanded(
                                                              child: Text(
                                                                "Created Date: " +
                                                                    snapshot.data['expense_list']
                                                                            [
                                                                            index]
                                                                        [
                                                                        'created_at'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      14.0,
                                                                ),
                                                              ),
                                                            )
                                                          : Text(
                                                              "",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 10.0,
                                                              ),
                                                            ),
                                                    ]),
                                                    SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    Row(children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                            "Amount: " +
                                                                snapshot.data[
                                                                            'expense_list']
                                                                        [index]
                                                                    ['amount'],
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14.0,
                                                            )),
                                                      ),
                                                      SizedBox(
                                                        width: 5.0,
                                                      ),
                                                     Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          onTap: (){
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/edit-expense',
                                                              arguments: <String, String>{
                                                                'expense_id': snapshot.data['expense_list'][index]['id'].toString(),
                                                                'tour_id': snapshot.data['expense_list'][index]['tourID'].toString(),
                                                                'tour_tittle': snapshot.data['expense_list'][index]['key'].toString(),

                                                              },
                                                            );
                                                          },
                                                          child: Align(
                                                            alignment: Alignment.topRight,
                                                            child: Container(
                                                              width: deviceSize.height * 0.06,
                                                              padding: EdgeInsets.symmetric(
                                                                  vertical: 7, horizontal: 9),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  border: Border.all(color:Color(0xff9b56ff) ),
                                                                  color: Colors.transparent

                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: <Widget>[
                                                                  /* Icon(
                                                      Icons.edit, size: 10, color: Colors.white,),
                                                    SizedBox(
                                                      width: 5,
                                                    ),*/
                                                                  Text(
                                                                      "Edit",
                                                                      // snapshot.data['cart_quantity'] > 0 ? 'Go to Basket' : 'Add to Basket',
                                                                      style: smallText
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
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
                                secondaryActions: <Widget>[
                                  snapshot.data[
                                  'expense_list']
                                  [
                                  index]['status']=="Pending"?  Material(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    elevation: 3.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          left: 5,
                                        ),
                                        child: IconSlideAction(
                                          caption: 'Delete',
                                          color: Color(0xff9b56ff),
                                          icon: Icons.delete,
                                          onTap: () {
                                            showConfirmDialog(
                                                snapshot.data['expense_list'][index]
                                                ['id'],
                                                'Cancel',
                                                'Remove',
                                                'Remove Item',
                                                'Are you sure want to remove this item?');
                                          },
                                        ),
                                      ),
                                    ),
                                  ):Container(),
                                ],
                              ),
                            );
                          }),
                    ),
                  )
                : _emptyOrders(),
          ]);
        } else {
          return Center(child: Container(child: CircularProgressIndicator()));
        }
      },
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
        _deleteData(id);

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

    // Show the Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  void _deleteData(cartId) async {
    var response = await http.post(
      URL+"deleteexpensereimbursments",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "expense_id":cartId.toString()
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      setState(() {

        _leads = _leadData();
      });
    } else {
      throw Exception('Something went wrong');
    }
  }
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Tour Expenses',
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
