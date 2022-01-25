import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class ExtendTour extends StatefulWidget {
  final Object argument;
  const ExtendTour({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<ExtendTour> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  var _tour_id;
  final cmtController = TextEditingController();
  final startTimeController = TextEditingController();
  var _userId;
  var _cmt;
  final format = DateFormat("yyyy-MM-dd HH:mm");
  AutovalidateMode autoValidateMode = AutovalidateMode.onUserInteraction;

  DateTime value = DateTime.now();
  int changedCount = 0;
  int savedCount = 0;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _tour_id = data['tour_id'];

    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
          setState(() {
            _loading = true;
          });

          var response = await http.post(
            URL+"addtourextend",
            body: {
              "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
              "id": _userId.toString(),
              "tour_id": _tour_id.toString(),
              "extend_date_time":
                  DateFormat('dd-MM-yyyy HH:mm:ss').format(value),
              "comments": cmtController.text != null ? cmtController.text : ""
            },
            headers: {
              "Accept": "application/json",
            },
          );
          print(jsonEncode({
            "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
            "id": _userId.toString(),
            "tour_id": _tour_id.toString(),
            "extend_date_time":
            DateFormat('dd-MM-yyyy HH:mm:ss').format(value),
            "comments": cmtController.text != null ? cmtController.text : ""
          }));
          if (response.statusCode == 200) {
            setState(() {
              _loading = false;
            });
            var data = json.decode(response.body);
            Fluttertoast.showToast(
                msg: 'Message: ' + data['message'].toString());
            Navigator.pushNamed(
              context,
              '/dashboard',
            );
            print(data);
          } else {
            setState(() {
              _loading = false;
            });
            Fluttertoast.showToast(msg: 'Error');
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.all(15),
        alignment: Alignment.center,
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
        child: Text(
          'SUBMIT',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _queryTextbox() {
    return Container(
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

            onSaved: (String value) {
              _cmt = value;
            },
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Extend Tour',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[],
        //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "EXTEND TOUR DATE FOR APPROVAL",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color(0xfffb4d6d),
                            fontSize: 18,
                            wordSpacing: 1,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: Column(children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              // margin: EdgeInsets.only(left: 15,right: 15),
                              child: Text(
                                "EXTENDED TILL",
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
                        height: 5,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              // width: MediaQuery.of(context).size.width,
                              //margin: EdgeInsets.only(left: 15, right: 15),
                              height: 40,
                              // padding: EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1.0,
                                    color: Colors.grey,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                ),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  cursorColor: Color(0xFF000000),
                                  hintColor: Colors.transparent,
                                ),
                                child: DateTimeField(
                                  format: format,
                                  controller: startTimeController,
                                  /*style: TextStyle(fontSize: 16),*/

                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontFamily: "WorkSansLight"),
                                    hintText: 'Extended Till',
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 5, 0, 5),
                                    suffixIcon: Icon(
                                      Icons.date_range,
                                      color: Color(0xff9b56ff),
                                      size: 14,
                                    ),
                                  ),
                                  onShowPicker: (context, currentValue) async {
                                    final date = await showDatePicker(
                                        context: context,
                                        firstDate: DateTime(1900),
                                        initialDate:
                                            currentValue ?? DateTime.now(),
                                        lastDate: DateTime(2100));
                                    if (date != null) {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                            currentValue ?? DateTime.now()),
                                      );
                                      return DateTimeField.combine(date, time);
                                    } else {
                                      return currentValue;
                                    }
                                  },
                                  autovalidateMode: autoValidateMode,
                                  // validator: (date) => date == null ? 'Invalid date' : null,
                                  onChanged: (date) => setState(() {
                                    value = date;
                                    // startTimeController.text =DateFormat('yyyy-MM-dd – kk:mm').format(date) ;
                                    print(DateFormat('yyyy-MM-dd HH:mm a')
                                        .format(value));
                                    changedCount++;
                                  }),
                                  onSaved: (date) => setState(() {
                                    value = date;
                                    //  startTimeController.text =DateFormat('yyyy-MM-dd – kk:mm').format(date) ;
                                    print(DateFormat('yyyy-MM-dd HH:mm a')
                                        .format(value));
                                    savedCount++;
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "COMMENTS",
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
                    height: 5,
                  ),
                  _queryTextbox(),
                  SizedBox(
                    height: 30,
                  ),
                  _submitButton()
                ],
              ),
            ),
          ]),
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
