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

class AddTour extends StatefulWidget {
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<AddTour> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final cmtController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  List<Region> _region = [];
  List<Dealer> _dealer = [];
  List<City> _city = [];
  Future _stateData;
  Future _cityData;
  Future _dealerData;
  String selectedRegion;
  String selectedCity;
  String selectedDealer = "";
  String catData = "";
  var _type = "";
  String cityData = "";
  var dealerData;
  var _cmt;
  var finalDate, finalDate2;
  var _userId;
  var dealerJson;

  final format = DateFormat("yyyy-MM-dd HH:mm");
  final format1 = DateFormat("yyyy-MM-dd HH:mm");
  final initialValue = DateTime.now();
  final initialValue1 = DateTime.now();

  AutovalidateMode autoValidateMode = AutovalidateMode.onUserInteraction;
  AutovalidateMode autoValidateMode1 = AutovalidateMode.onUserInteraction;
  DateTime value = DateTime.now();
  DateTime value1 = DateTime.now();
  int changedCount = 0;
  int changedCount1 = 0;
  int savedCount = 0;
  int savedCount1 = 0;
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      // _stateData = _getStateCategories();
      _dealerData = _getDealerCategories();
    });
  }

  Future _getStateCategories() async {
    var response = await http.post(
      "http://dev.techstreet.in/glen/public/api/getstatelist",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['state_list'];
      if (mounted) {
        setState(() {
          catData = jsonEncode(result);

          final json = JsonDecoder().convert(catData);
          _region =
              (json).map<Region>((item) => Region.fromJson(item)).toList();
          List<String> item = _region.map((Region map) {
            for (int i = 0; i < _region.length; i++) {
              if (selectedRegion == map.THIRD_LEVEL_NAME) {
                _type = map.THIRD_LEVEL_ID;

                print(selectedRegion);
                return map.THIRD_LEVEL_ID;
              }
            }
          }).toList();
          if (selectedRegion == "") {
            selectedRegion = _region[0].THIRD_LEVEL_NAME;
          }
          if (_type != "") _cityData = _getCityCategories(_type);
        });
      }

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future _getDealerCategories() async {
    var response = await http.post(
      URL + "getdealerlists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
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

  Future _getCityCategories(type) async {
    setState(() {
      _loading = true;
    });
    var response = await http.post(
      URL + "getcitylist",
      body: {"auth_key": "VrdoCRJjhZMVcl3PIsNdM", "state_id": type.toString()},
      headers: {
        "Accept": "application/json",
      },
    );
    print(jsonEncode({"auth_key": "VrdoCRJjhZMVcl3PIsNdM", "state_id": type}));
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      var data = json.decode(response.body);
      var result = data['city_list'];
      setState(() {
        cityData = jsonEncode(result);

        final json = JsonDecoder().convert(cityData);
        _city = (json).map<City>((item) => City.fromJson(item)).toList();
        List<String> item = _city.map((City map) {
          for (int i = 0; i < _city.length; i++) {
            if (selectedCity == map.FOURTH_LEVEL_NAME) {
              // _type = map.FOURTH_LEVEL_ID;
              if (selectedCity == "" || selectedCity == null) {
                selectedCity = _city[0].FOURTH_LEVEL_NAME;
              }

              return map.FOURTH_LEVEL_ID;
            }
          }
        }).toList();
        //  if(selectedCity==""||selectedCity==null){
        selectedCity = _city[0].FOURTH_LEVEL_NAME;
        // }
      });

      return result;
    } else {
      setState(() {
        _loading = false;
      });
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
          _onFormSaved();
          for (int i = 0; i < dealerData.length; i++) {
            if (i == (dealerData.length - 1)) {
              selectedDealer = selectedDealer + dealerData[i].toString();
            } else {
              selectedDealer = selectedDealer + dealerData[i].toString() + ",";
            }
          }
          print(selectedDealer);
          var response = await http.post(
            URL + "addtour",
            body: {
              "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
              "id": _userId.toString(),
              "tittle": titleController.text,
              "state": "No",
              "city": "No",
              "start_time": DateFormat('dd-MM-yyyy HH:mm:ss').format(value),
              "end_time": DateFormat('dd-MM-yyyy HH:mm:ss').format(value1),
              "dealer_id": selectedDealer,
              "comments": cmtController.text != null ? cmtController.text : ""
            },
            headers: {
              "Accept": "application/json",
            },
          );
          print(jsonEncode({
            "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
            "id": _userId.toString(),
            "tittle": titleController.text,
            "state": "No",
            "city": "No",
            "start_time": DateFormat('dd-MM-yyyy HH:mm:ss').format(value),
            "end_time": DateFormat('dd-MM-yyyy HH:mm:ss').format(value1),
            "dealer_id": selectedDealer,
            "comments": cmtController.text
          }));
          var data = json.decode(response.body);
          if (response.statusCode == 200) {
            setState(() {
              _loading = false;
            });

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
            print(data);
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
            /* validator: (value) {
              if (value.isEmpty) {
                return "Please Enter Comment";
              }
              return null;
            },*/
            onSaved: (String value) {
              _cmt = value;
            },
          ),
        ),
      ),
    );
  }

  Widget _titleTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      //  height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: titleController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Title';
            }
            return null;
          },
          onSaved: (String value) {
            titleController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Add Title",
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
          'Add Tours',
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
                        "SEND FOR APPROVAL",
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
                      margin: EdgeInsets.only(left: 15, right: 13),
                      child: Text(
                        "TITLE",
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
                  _titleTextBox(),
                  SizedBox(
                    height: 20,
                  ),
                  /* Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "STATE",
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
                    margin: EdgeInsets.only(left: 15, right: 15),
                    padding: EdgeInsets.all(8),

                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.0,
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Padding(
                        padding: EdgeInsets.only(right: 0, left: 3),
                        child: new DropdownButton<String>(
                          isExpanded: true,
                          hint: new Text(
                            "Select State",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xff9b56ff),
                            ),
                          ),
                          value: selectedRegion,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              selectedRegion = newValue;
                              List<String> item = _region.map((Region map) {
                                for (int i = 0; i < _region.length; i++) {
                                  if (selectedRegion == map.THIRD_LEVEL_NAME) {
                                    _type = map.THIRD_LEVEL_ID;
                                    return map.THIRD_LEVEL_ID;
                                  }
                                }
                              }).toList();
                              _cityData = _getCityCategories(_type);
                            });
                          },
                          items: _region.map((Region map) {
                            return new DropdownMenuItem<String>(
                              value: map.THIRD_LEVEL_NAME,
                              child: new Text(map.THIRD_LEVEL_NAME,
                                  style: new TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                        ),
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
                        "CITY",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          //  fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 15, right: 15),
                    height: 40,
                    padding: EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.0,
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Padding(
                        padding: EdgeInsets.only(right: 0, left: 3),
                        child: new DropdownButton<String>(
                          isExpanded: true,
                          hint: new Text("Select City",
                              style: TextStyle(color: Colors.grey[400])),
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xff9b56ff),
                            ),
                          ),
                          value: selectedCity,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              selectedCity = newValue;
                              List<String> item = _city.map((City map) {
                                for (int i = 0; i < _city.length; i++) {
                                  if (selectedCity == map.FOURTH_LEVEL_NAME) {
                                    _type = map.FOURTH_LEVEL_ID;
                                    return map.FOURTH_LEVEL_ID;
                                  }
                                }
                              }).toList();
                            });
                          },
                          items: _city.map((City map) {
                            return new DropdownMenuItem<String>(
                              value: map.FOURTH_LEVEL_NAME,
                              child: new Text(map.FOURTH_LEVEL_NAME,
                                  style: new TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),*/
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
                                "START TIME",
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
                            width: 5,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              // margin: EdgeInsets.only(left: 15,right: 15),
                              child: Text(
                                "END TIME",
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
                        height: 4,
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
                                    hintText: 'From Time',
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
                                        firstDate: DateTime.now(),
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
                          SizedBox(
                            width: 5,
                          ),
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
                                  format: format1,
                                  controller: endTimeController,
                                  /*style: TextStyle(fontSize: 16),*/

                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontFamily: "WorkSansLight"),
                                    hintText: 'End Time',
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
                                        firstDate: DateTime.now(),
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
                                  autovalidateMode: autoValidateMode1,
                                  // validator: (date) => date == null ? 'Invalid date' : null,
                                  onChanged: (date) => setState(() {
                                    value1 = date;
                                    //endTimeController.text =DateFormat('yyyy-MM-dd – kk:mm').format(date) ;
                                    print(DateFormat('yyyy-MM-dd HH:mm a')
                                        .format(value1));
                                    changedCount1++;
                                  }),
                                  onSaved: (date) => setState(() {
                                    value1 = date;
                                    // endTimeController.text =DateFormat('yyyy-MM-dd – kk:mm').format(date) ;
                                    print(DateFormat('yyyy-MM-dd HH:mm a')
                                        .format(value1));
                                    savedCount1++;
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
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 15, right: 15),
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
                            errorText: 'Please select one or more option(s)',
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

  void _onFormSaved() {
    final FormState form = _formKey.currentState;
    form.save();
  }
}

class Region {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;

  Region({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME});

  factory Region.fromJson(Map<String, dynamic> json) {
    return new Region(
        THIRD_LEVEL_ID: json['id'].toString(),
        THIRD_LEVEL_NAME: json['state_name']);
  }
}

class Dealer {
  final String id;
  final String firm_name;

  Dealer({this.id, this.firm_name});

  factory Dealer.fromJson(Map<String, dynamic> json) {
    return new Dealer(id: json['id'].toString(), firm_name: json['firm_name']);
  }
}

class City {
  final String FOURTH_LEVEL_ID;
  final String FOURTH_LEVEL_NAME;

  City({this.FOURTH_LEVEL_ID, this.FOURTH_LEVEL_NAME});

  factory City.fromJson(Map<String, dynamic> json) {
    return new City(
        FOURTH_LEVEL_ID: json['id'].toString(),
        FOURTH_LEVEL_NAME: json['city_name']);
  }
}
