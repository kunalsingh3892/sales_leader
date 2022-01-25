import 'dart:io';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:glen_lms/components/image_upload.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';

import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:group_button/group_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

import 'package:mime/mime.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../constants.dart';

class AssignOCP extends StatefulWidget {
  final Object argument;
  const AssignOCP({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<AssignOCP> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final cmtController = TextEditingController();
  Axis direction = Axis.horizontal;

  String _dropdownValue = 'Select Visit Type';
  bool suggest = false;
  bool show = false;
  String _address="";

  var lead_id;
  String cityData = "";
  var dealerData;
  var _cmt;
  var finalDate, finalDate2;
  var _userId;
  var dealerJson;
  Future _dealerData;
  String selectedDealer="";
  var status="success";
  List<Object> images1 = List<Object>();
  Future<File> _imageFile;
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    lead_id = data['lead_id'];
    _getUser();
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
      URL+"dealerocplists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id":_userId
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      result = data['dealer_ocp_list'];
      if (mounted) {
        setState(() {
          for(int i=0;i<result.length;i++){

            cities.add(result[i]['firm_name']);
            cities1.add(result[i]['id'].toString());
            formData=result[i];
            print(cities1);
          }
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
          setState(() {
            _loading = true;
          });

          var response = await http.post(
            URL+"lead_assign_ocp",
            body: {
              "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
              "id": _userId.toString(),
              "lead_id":lead_id.toString(),
              "dealer_id":selectedDealer.toString(),
              "comments":cmtController.text
            },
            headers: {
              "Accept": "application/json",
            },
          );
          print(jsonEncode({
            "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
            "id": _userId.toString(),
            "lead_id":lead_id.toString(),
            "dealer_id":selectedDealer.toString(),
            "comments":cmtController.text
          }));
          if (response.statusCode == 200) {
            setState(() {
              _loading = false;
            });
            var data = json.decode(response.body);
            Fluttertoast.showToast(msg: 'Message: ' + data['message'].toString());
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
            validator: (value) {
              if (value.isEmpty) {
                return "Please Enter Comment";
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
  TextStyle normalText = GoogleFonts.robotoSlab(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );



  Widget build(BuildContext context) {
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
          title: Text(
            'ASSIGN OCP ',
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
                      height: 20,
                    ),

                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "ASSIGN TO OCP",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color(0xfffb4d6d),
                              fontSize: 20,

                              wordSpacing: 1,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "SELECT",
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
                      height: 4,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 15),
                      child: DropDownField(
                          value: formData['firm_name'],
                          required: false,
                          hintText: 'Select OCP',
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
                            formData['firm_name'] = newValue;
                          }),
                    ),



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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            // fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    _commentTextBox(),


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
      ),
    );
  }


}


