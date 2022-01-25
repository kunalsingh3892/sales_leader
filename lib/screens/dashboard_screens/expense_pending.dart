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

class ExpensePending extends StatefulWidget {
  final String recordName;
  ExpensePending(this.recordName);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<ExpensePending>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  TabController controller;
  var _userId;
  Future<dynamic> _leads;

  @override
  void initState() {
    super.initState();
    print("<<>>>>>>>"+widget.recordName);
    controller = TabController(vsync: this, length: 3);
    _getUser();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future _leadData() async {
    var response = await http.post(
      URL+"expensereimbursmentslists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id":widget.recordName!=""?widget.recordName:_userId,
        "status":"Pending"
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

  Widget rowWidget(data){
    return data['from_city'] !=
        null
        ? Column(

      children: <Widget>[
        SizedBox(
          height: 5.0,
        ),
        Row(children: <Widget>[
        data
        ['from_city'] !=
            null
            ? Expanded(
          child: Text(
            "From City: "+data['from_city'],
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
        SizedBox(
          width: 10.0,
        ),
        data
        ['to_city'] !=
            null
            ? Expanded(
          child: Text(
            "To City: "+data['to_city'],
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
      ]),]
    ):Container();


  }
  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text('NO EXPENSE FOUND!')),
    );
  }
  Widget rowWidget1(data){
    return Row(children: <Widget>[
      data
      ['from_date'] !=
          null
          ? Expanded(
        child: Text(
          "From Date: "+data['from_date'],
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
      SizedBox(
        width: 10.0,
      ),
      data
      ['to_date'] !=
          null
          ? Expanded(
        child: Text(
          "To Date: "+data['to_date'],
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
    ]);


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
                  leadList(deviceSize),

                ],
              )
            ],
          ),
        ));
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
                      child: Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        child: Material(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          elevation: 3.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/expense-details',
                                  arguments: <String, String>{
                                    'expense_id': snapshot.data['expense_list'][index]['id'].toString(),


                                  },
                                );
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
                                            ['type'][0].toUpperCase(),
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
                                                Text("Type: "+
                                                    snapshot.data['expense_list'][index]
                                                    ['type'],
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
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Category : ' +
                                                      snapshot.data['expense_list']
                                                      [index]['category'],
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

                                            rowWidget(snapshot.data['expense_list'][index]),
                                          //  rowWidget1(snapshot.data['expense_list'][index]),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            Row(children: <Widget>[

                                              Expanded(
                                                child: Text("Tour: "+
                                                    snapshot.data['expense_list'][index]['key'],
                                                    style:smallText1
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              widget.recordName==""?Material(
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
                                              ):Container(),

                                            ]),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            widget.recordName!=""?  Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () async {
                                                  var response = await http.post(
                                                    URL+"expensestatuschange",
                                                    body: {
                                                      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
                                                      "id": widget.recordName.toString(),
                                                      "expense_id": snapshot.data['expense_list'][index]['id'].toString(),
                                                      "status":"Approved"
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
                                            ):Container(),
                                          ],
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                        secondaryActions: <Widget>[
                          Material(
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
                          ),
                        ],
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
