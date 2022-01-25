import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class MyOrders extends StatefulWidget {
  final Object argument;

  const MyOrders({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<MyOrders>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  var _userId;
  var member_id;
  Future<dynamic> _leads;
  String type = "";
  String role = "";
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    member_id = data['member_id'];
    _getUser();
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  Future _leadData(String name, String fromDate,String toDate) async {
    var response = await http.post(
      URL+"getorderlist",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id":member_id!="" ?member_id:_userId,
        "login_type":type,
        "from_date":fromDate,
        "to_date":toDate,
        "status":name

      },
      headers: {
        "Accept": "application/json",
      },
    );

    print(jsonEncode({
      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      "id": _userId,
      "login_type":type,
      "from_date":fromDate,
      "to_date":toDate,
      "status":name

    }));
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
      type = prefs.getString('type');
      role = prefs.getString('role').toString();
      print(role);
      print(_userId.toString());
      var now = new DateTime.now();
      var firstDate = DateTime.utc(now.year, now.month, 1);
      var lastDate = DateTime.utc(now.year, now.month, 31);
      var formatter = new DateFormat('dd-MM-yyyy');
      formattedDate1 = formatter.format(lastDate);
      formattedDate2 = formatter.format(firstDate);
      fromDateController.text=formattedDate2;
      toDateController.text=formattedDate1;
      _leads = _leadData(name,formattedDate2,formattedDate1);
    });
  }
  String _dropdownValue = 'Select Status';
  String name = "";
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  var finalDate, finalDate2;
  String formattedDate1="";
  String formattedDate2="";

  void callDatePicker() async {
    var order = await getDate();
    setState(() {
      finalDate = order;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(finalDate);
      print(formatted);
      fromDateController.text = formatted.toString();
    });
  }

  Future<DateTime> getDate() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
              primaryColor: Color(0xff9b56ff),
              accentColor: Color(0xff9b56ff),
              primarySwatch: MaterialColor(0xff9b56ff, const <int, Color>{
                50: const Color(0xff9b56ff),
                100: const Color(0xff9b56ff),
                200: const Color(0xff9b56ff),
                300: const Color(0xff9b56ff),
                400: const Color(0xff9b56ff),
                500: const Color(0xff9b56ff),
                600: const Color(0xff9b56ff),
                700: const Color(0xff9b56ff),
                800: const Color(0xff9b56ff),
                900: const Color(0xff9b56ff),
              },)),
          child: child,
        );
      },
    );
  }

  void callDatePicker2() async {
    var order = await getDate2();
    setState(() {
      finalDate2 = order;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(finalDate2);
      print(formatted);
      toDateController.text = formatted.toString();
      _leads = _leadData(name,fromDateController.text,toDateController.text);
    });
  }
  Future<DateTime> getDate2() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
              primaryColor: Color(0xff9b56ff),
              accentColor: Color(0xff9b56ff),
              primarySwatch: MaterialColor(0xff9b56ff, const <int, Color>{
                50: const Color(0xff9b56ff),
                100: const Color(0xff9b56ff),
                200: const Color(0xff9b56ff),
                300: const Color(0xff9b56ff),
                400: const Color(0xff9b56ff),
                500: const Color(0xff9b56ff),
                600: const Color(0xff9b56ff),
                700: const Color(0xff9b56ff),
                800: const Color(0xff9b56ff),
                900: const Color(0xff9b56ff),
              },)),
          child: child,
        );
      },
    );
  }

  final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      borderSide: BorderSide(
        color: Colors.black54,
      ));
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
                   child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: 5),
                                  height: 40,
                                  width:
                                  MediaQuery.of(context).size.width * 0.26,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        cursorColor: Color(0xFF000000),
                                        hintColor: Colors.transparent,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          callDatePicker();
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                        },
                                        child: TextFormField(
                                          enabled: false,
                                          controller: fromDateController,
                                          style: new TextStyle(
                                              fontSize: 14
                                          ),
                                          decoration: InputDecoration(
                                              focusedBorder: border,
                                              border: border,
                                              contentPadding:
                                              EdgeInsets.fromLTRB(
                                                  10, 5, 5, 0),
                                              disabledBorder: border,
                                              enabledBorder: border,
                                              suffixIcon: Icon(Icons.calendar_today,size: 14,color: Colors.black54,),
                                              hintStyle: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  fontFamily: "WorkSansLight"),
                                              filled: true,
                                              fillColor: Color(0xFFffffff),
                                              hintText: 'From Date'),
                                          keyboardType: TextInputType.text,
                                          cursorColor: Color(0xFF000000),
                                          textCapitalization:
                                          TextCapitalization.none,

                                          /*onSaved: (String value) {
                                                          quantity = value;
                                                        },*/
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                        Expanded(
                          child: Container(
                                  height: 40,
                                  width:
                                  MediaQuery.of(context).size.width * 0.26,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        cursorColor: Color(0xFF000000),
                                        hintColor: Colors.transparent,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (finalDate != null) {
                                            callDatePicker2();
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                'Please select from date first');
                                          }
                                        },
                                        child: TextFormField(
                                          enabled: false,
                                          controller: toDateController,
                                          style: new TextStyle(
                                              fontSize: 14
                                          ),
                                          decoration: InputDecoration(
                                              focusedBorder: border,
                                              border: border,
                                              contentPadding:
                                              EdgeInsets.fromLTRB(
                                                  10, 5, 5, 0),
                                              disabledBorder: border,
                                              enabledBorder: border,
                                              hintStyle: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  fontFamily: "WorkSansLight"),
                                              filled: true,
                                              suffixIcon: Icon(Icons.calendar_today,size: 14,color: Colors.black54,),

                                              fillColor: Color(0xFFffffff),
                                              hintText: 'To Date'),
                                          keyboardType: TextInputType.text,
                                          cursorColor: Color(0xFF000000),
                                          textCapitalization:
                                          TextCapitalization.none,

                                          /*onSaved: (String value) {
                                                          quantity = value;
                                                        },*/
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(

                    child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(

                            ),
                          ),
                          SizedBox(
                            width: 5.0,
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
                                    color: Colors.black54,
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
                                        color: Colors.black54,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _dropdownValue = newValue;
                                          if (_dropdownValue == "Select Status") {
                                            name = "";

                                            if(fromDateController.text=="" && toDateController.text==""){
                                              _leads = _leadData(name,formattedDate2,formattedDate1);
                                            }else{
                                              _leads = _leadData(name,fromDateController.text,toDateController.text);
                                            }


                                          }
                                          if (_dropdownValue == "Approved") {
                                            name = "Approved";

                                            if(fromDateController.text=="" && toDateController.text==""){
                                              _leads = _leadData(name,formattedDate2,formattedDate1);
                                            }else{
                                              _leads = _leadData(name,fromDateController.text,toDateController.text);
                                            }


                                          } else if(_dropdownValue == "Pending Approval"){
                                            name = "Pending Approval";
                                            if(fromDateController.text=="" && toDateController.text==""){
                                              _leads = _leadData(name,formattedDate2,formattedDate1);
                                            }else{
                                              _leads = _leadData(name,fromDateController.text,toDateController.text);
                                            }


                                          }
                                          else if(_dropdownValue == "Rejected"){
                                            name = "Rejected";
                                            if(fromDateController.text=="" && toDateController.text==""){
                                              _leads = _leadData(name,formattedDate2,formattedDate1);
                                            }else{
                                              _leads = _leadData(name,fromDateController.text,toDateController.text);
                                            }

                                          }

                                          print(_dropdownValue);
                                          print(name);
                                        });
                                      },
                                      items: <String>[
                                        'Select Status',
                                        'Approved',
                                        'Pending Approval',
                                        'Rejected'
                                      ].map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child:  new Text(value,
                                              style: new TextStyle(color: Colors.black54,fontSize: 14)),

                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                  ),
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
  TextStyle normalText = GoogleFonts.robotoSlab(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  TextStyle normalText1 = GoogleFonts.robotoSlab(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text('NO ORDER FOUND!')),
    );
  }
  Widget leadList(Size deviceSize) {
    return FutureBuilder(
      future: _leads,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if(snapshot.data['orderlist'].length!=0) {
            return Container(
              // color: Colors.red,
              // height: deviceSize.height,
              child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: snapshot.data['orderlist'].length,
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
                                '/order-details',
                                arguments: <String, String>{
                                  'order_id': snapshot.data['orderlist'][index]['id'].toString(),
                                  'type':'',
                                 'member_id': member_id,
                                  'subject':type,
                                },
                              );
                            },
                            child: Container(
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
                                        child:  snapshot.data['orderlist'][index]
                                        ['dealer_name']!=null?Text(
                                          snapshot.data['orderlist'][index]
                                          ['dealer_name'][0].toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 30.0,
                                              color: Colors.white),
                                        ):Text(
                                          "",
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
                                              snapshot.data['orderlist'][index]
                                              ['dealer_name']!=null? Text(
                                                snapshot.data['orderlist'][index]
                                                ['dealer_name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14.0,
                                                ),
                                              ):Text(
                                                "",
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
                                                    snapshot.data['orderlist']
                                                    [index]['total_amount'],
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
                                          Row(children: <Widget>[
                                            Icon(
                                              FontAwesomeIcons.calendar,
                                              size: 12.0,
                                              color: Colors.black54,
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              'Created Date : ' +
                                                  snapshot.data['orderlist']
                                                  [index]['created_at'],
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
                                              FontAwesomeIcons.mobile,
                                              size: 12.0,
                                              color: Colors.black54,
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            snapshot.data['orderlist'][index]
                                            ['dealer_phone'] !=
                                                null
                                                ? Expanded(
                                              child: Text(
                                                snapshot.data['orderlist']
                                                [index]['dealer_phone'],
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
                                          Row(children: <Widget>[
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            snapshot.data['orderlist'][index]
                                            ['status'] !=
                                                null
                                                ? Expanded(
                                              child: Text("Status: "+
                                                  snapshot.data['orderlist']
                                                  [index]['status'],
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: normalText
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
                                              width: 5.0,
                                            ),
                                            member_id==""? Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: (){
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/order-details',
                                                    arguments: <String, String>{
                                                      'order_id': snapshot.data['orderlist'][index]['id'].toString(),
                                                      'type':'edit',
                                                      'subject':type,
                                                      'member_id': member_id,
                                                    },
                                                  );
                                                },
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    width: deviceSize.height * 0.06,
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 8, horizontal: 10),
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
                                                            style:normalText1
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(),
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add-order',
            arguments: <String, String>{
              'lead_id':"",
              'subject':type,
              'status':'',
              'month': '',
              'comments':''
            },
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(
          'Past Orders',
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
