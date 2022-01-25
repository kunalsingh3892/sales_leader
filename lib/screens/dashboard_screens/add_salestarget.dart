
import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:glen_lms/modal/order_json.dart';

import 'package:glen_lms/modal/product_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';

import 'package:mime/mime.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../constants.dart';

class AddSalesTarget extends StatefulWidget {
  final Object argument;

  const AddSalesTarget({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<AddSalesTarget> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final targetController = TextEditingController();
  final targetController1 = TextEditingController();
  final cmtController = TextEditingController();
  final cmtController1 = TextEditingController();
  Axis direction = Axis.horizontal;
  List<OrderJson> xmlList = new List();
  bool showData = false;

  DatabaseHelper2 db1 = new DatabaseHelper2();

  var dealerData;
  var _cmt;
  var _cmt1;
  var target_id;
  var target_amount;
  String type="";
  String dealer_name="";
  var _userId;
  var dealerJson;
  Future _dealerData;
  String selectedDealer = "";
  var status = "success";
  var now;
  var firstDate;
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    target_id = data['target_id'];
    type = data['type'];
    target_amount = data['target_amount'];
    dealer_name = data['dealer_name'];
    _getUser();
  }
  String formattedDate1="";
  String formattedDate2="";
  var current_mon;
  var next_mon;

  @override
  void dispose() {
    db1.deleteAllProduct();
    super.dispose();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {


      _userId = prefs.getInt('user_id').toString();
      _dealerData = _getDealerCategories();
    });
  }

  var result;
  List<String> cities=[];
  List<String> cities1=[];
  Map<String, dynamic> formData=new Map();

  Future _getDealerCategories() async {
    var response = await http.post(
      URL+"getdealerlists",
      body: {"auth_key": "VrdoCRJjhZMVcl3PIsNdM", "id": _userId,  "type":"Dealer"},
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      result = data['dealer_list'];
      if (mounted) {
        setState(() {
          for(int i=0;i<result.length;i++){

            cities.add(result[i]['firm_name']);
            cities1.add(result[i]['id'].toString());
            formData=result[i];
            print(cities1);
          }
          var dealersData = jsonEncode(result);

          dealerJson = JsonDecoder().convert(dealersData);
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

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
          if (selectedDealer != "") {

            setState(() {
              _loading = true;
            });
            Map<String, String> headers = {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            };
            final msg = jsonEncode({
              "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
              "id": _userId,
              "connect_id": selectedDealer,
              "target_amount": targetController.text,
              "comments": cmtController.text,
            });

            var response = await http.post(
              URL+"sales_target_add",
              body: msg,
              headers: headers,
            );


            print(msg);
            var data = json.decode(response.body);
            if (response.statusCode == 200) {
              setState(() {
                _loading = false;
              });

              Fluttertoast.showToast(
                  msg: 'Message: ' + data['message'].toString());
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                '/view-salestarget',
                arguments: <String, String>{
                  'member_id': "",

                },
              );
              print(data);
            } else {
              setState(() {
                _loading = false;
              });
              print(response.body);

              Fluttertoast.showToast(msg: data['message'].toString());
            }
          } else {
            print(dealerData);
            Fluttertoast.showToast(msg: "Please Select Contact First");
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
  Widget _submitButton2() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();


            setState(() {
              _loading = true;
            });
            Map<String, String> headers = {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            };
            final msg = jsonEncode({
              "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
              "id": _userId,
              "target_id": target_id,
              "old_target_amount": target_amount,
              "new_target_amount": targetController1.text,
              "comments": cmtController1.text,
            });

            var response = await http.post(
              URL+"sales_target_edit",
              body: msg,
              headers: headers,
            );


            print(msg);
          var data = json.decode(response.body);
            if (response.statusCode == 200) {
              setState(() {
                _loading = false;
              });

              Fluttertoast.showToast(
                  msg: 'Message: ' + data['message'].toString());
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                '/view-salestarget',
                arguments: <String, String>{
                  'member_id': "",

                },
              );
              print(data);
            } else {
              setState(() {
                _loading = false;
              });
              print(response.body);

              Fluttertoast.showToast(msg: data['message'].toString());
            }
          } else {
            print(dealerData);
            Fluttertoast.showToast(msg: "Please Select Contact First");
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


  TextStyle smallText = GoogleFonts.robotoSlab(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  TextStyle smallText2 = GoogleFonts.robotoSlab(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.white
  );

  TextStyle normalText = GoogleFonts.robotoSlab(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  TextStyle mediumText = GoogleFonts.robotoSlab(
    fontSize: 16,
    color: Color(0xfffb4d6d),
    fontWeight: FontWeight.w600,
  );

  TextStyle mediumText2 = GoogleFonts.robotoSlab(
    fontSize: 16,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
  );





  Widget _commentTextBox() {
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
                hintText: "Enter Comment"),
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
  Widget _commentTextBox2() {
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
                hintText: "Enter Comment"),
            controller: cmtController1,
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
              _cmt1 = value;
            },
          ),
        ),
      ),
    );
  }
  Widget _targetTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Theme(
          data: Theme.of(context).copyWith(
            cursorColor: Color(0xff9b56ff),
            hintColor: Colors.transparent,
          ),
          child: TextFormField(
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
                hintText: "Enter Your Target Amount"),
            controller: targetController,

            //Normal textInputField will be displayed
            cursorColor: Color(0xff9b56ff),
            keyboardType: TextInputType.number,
            textCapitalization: TextCapitalization.none,
            validator: (value) {
              if (value.isEmpty) {
                return "Please Enter Your Target Amount";
              }
              return null;
            },
            onSaved: (String value) {
              _cmt = value;
            },
          ),
        ),
      ),
    );
  }
  Widget _targetTextBox1(target_amount) {
  return Container(
    height: 60,
    margin: new EdgeInsets.only(left: 15, right: 15),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Theme(
        data: Theme.of(context).copyWith(
          cursorColor: Color(0xff9b56ff),
          hintColor: Colors.transparent,
        ),
        child: TextFormField(
          maxLines: 4,
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
              hintText: "Enter Your Target Amount"),
          initialValue: target_amount,
          minLines: 2,
          //Normal textInputField will be displayed
          cursorColor: Color(0xff9b56ff),
          keyboardType: TextInputType.number,
          textCapitalization: TextCapitalization.none,
          validator: (value) {
            if (value.isEmpty) {
              return "Please Enter Your Target Amount";
            }
            return null;
          },
          onSaved: (String value) {
            targetController1.text = value;
          },
        ),
      ),
    ),
  );
}

  Widget build(BuildContext context) {
    now = new DateTime.now();
    firstDate = DateTime.utc(now.year, now.month, 4);
    var nextDate = DateTime.utc(now.year, now.month+1, 1);
    var formatter = new DateFormat('MMMM');

    print(now.isBefore(firstDate));
    formattedDate1 = formatter.format(firstDate);
    formattedDate2 = formatter.format(nextDate);
    print(formattedDate1);
    print(now.year);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title:  type==""?Text(
            'Add Sales Target',
            style: TextStyle(color: Colors.white),
          ):Text(
            'Edit Sales Target',
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
              type==""?Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    now.isBefore(firstDate)? Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 14, right: 10),
                        child: Text(
                            "SALES TARGET FOR ${formattedDate1.toUpperCase()} ${now.year}",
                            textAlign: TextAlign.left,
                            style: mediumText
                        ),
                      ),
                    ):Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 14, right: 10),
                        child: Text(
                            "SALES TARGET FOR ${formattedDate2.toUpperCase()} ${now.year}",
                            textAlign: TextAlign.left,
                            style: mediumText
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                   /* Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: new MultiSelect(
                              autovalidate: true,
                              initialValue: [],
                              titleText: 'Dealer',
                              titleTextColor: Color(0xff9b56ff),
                              maxLength: 1,
                              // optional
                              validator: (dynamic value) {
                                if (value == null) {
                                  return 'Please select one or more option(s)';
                                }
                                return null;
                              },

                              // errorText: 'Please select one or more option(s)',
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
                              cancelButtonColor: Theme.of(context).primaryColor,
                              cancelButtonTextColor: Colors.white,
                              clearButtonColor: Theme.of(context).primaryColor,
                              clearButtonTextColor: Colors.white,
                              buttonBarColor: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          *//*RaisedButton(
                            child: Text('Save'),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              _onFormSaved();
                            },
                          )*//*
                        ],
                      ),
                    ),*/
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                            "SELECT",
                            textAlign: TextAlign.left,
                            style: normalText
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 15),
                      child: DropDownField(
                          value: formData['tour_tittle'],
                          required: false,
                          hintText: 'Select Dealer',
                          items: cities,
                          textStyle: normalText,

                          strict: false,
                          onValueChanged: (value){
                            setState(() {
                              for(int i=0;i<cities.length;i++){
                                if(value==cities[i]){
                                  selectedDealer=cities1[i];
                                }
                              }
                            });
                            print(selectedDealer);

                          },
                          setter: (dynamic newValue) {
                            formData['tour_tittle'] = newValue;
                          }),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    Column(
                      children: <Widget>[
                        Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                              "SALES TARGET",
                              textAlign: TextAlign.left,
                              style: normalText
                          ),
                        ),
                      ),
                        SizedBox(
                          height: 4,
                        ),
                        _targetTextBox(),
                        SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Text(
                                "COMMENTS",
                                textAlign: TextAlign.left,
                                style: normalText
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                      ]
                    ),

                    _commentTextBox(),

                    SizedBox(
                      height: 30,
                    ),
                    _submitButton()
                  ],
                ),
              ):
              Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    now.isBefore(firstDate)? Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 14, right: 10),
                        child: Text(
                            "SALES TARGET FOR ${formattedDate1.toUpperCase()} ${now.year}",
                            textAlign: TextAlign.left,
                            style: mediumText
                        ),
                      ),
                    ):Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 14, right: 10),
                        child: Text(
                            "SALES TARGET FOR ${formattedDate2.toUpperCase()} ${now.year}",
                            textAlign: TextAlign.left,
                            style: mediumText
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 14, right: 10),
                        child: Text(
                            "Name: "+dealer_name,
                            textAlign: TextAlign.left,
                            style: mediumText2
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: Text(
                                  "SALES TARGET",
                                  textAlign: TextAlign.left,
                                  style: normalText
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          _targetTextBox1(target_amount),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: Text(
                                  "COMMENTS",
                                  textAlign: TextAlign.left,
                                  style: normalText
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                        ]
                    ),

                    _commentTextBox2(),

                    SizedBox(
                      height: 30,
                    ),
                    _submitButton2()
                  ],
                ),
              ),
            ]),
          ),
          // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ),
    );
  }

  void _onFormSaved() {
    final FormState form = _formKey.currentState;
    form.save();
  }



}
