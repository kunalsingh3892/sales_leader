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

class UpdateLead extends StatefulWidget {
  final Object argument;
  const UpdateLead({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<UpdateLead> {
  bool _loading = false;
  bool addOrder = false;
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final cmtController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final followDateController = TextEditingController();
  final format = DateFormat("yyyy-MM-dd HH:mm");
  AutovalidateMode autoValidateMode = AutovalidateMode.onUserInteraction;
  DateTime value = DateTime.now();
  int savedCount = 0;
  int changedCount = 0;
  List<Region> _region = [];
  Future _stateData;
  String catData = "";
  String selectedRegion;
  var _type="";
  var _cmt;
  var finalDate, finalDate2;
  var _userId;
  String type = "";
  List<City> _city = [];
  Future _cityData;
  String selectedCity;
  String cityData = "";
  var lead_id;
  var subject;

  String name="Select Month";
  String _dropdownValue="Select Month";
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    lead_id = data['lead_id'];
    subject = data['subject'];
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      type = prefs.getString('type');

      _stateData = _getStateCategories();
    });
  }

  Future _getStateCategories() async {
    var response = await http.post(
      URL+"getleadstatuslist",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "parent_id":"0"
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['lead_status_list'];
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

        });
      }

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }
  Future _getCityCategories(type) async {
    var response = await http.post(
      URL+"getleadstatuslist",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "parent_id":"6"
      },
      headers: {
        "Accept": "application/json",
      },
    );
    print(jsonEncode({
      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      "parent_id":"0"
    }));
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      var data = json.decode(response.body);
      var result = data['lead_status_list'];
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

          var response = await http.post(
            URL + "leadstatuschange",
            body: {
              "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
              "id": _userId.toString(),
              "lead_id": lead_id,
              "followup_date": DateFormat('yyyy-MM-dd HH:mm:ss').format(value),
              "status": selectedRegion == "Closed"
                  ? selectedCity
                  : selectedRegion,
              "comments": cmtController.text,
              "login_type": type
            },
            headers: {
              "Accept": "application/json",
            },
          );
          print(jsonEncode({
            "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
            "id": _userId.toString(),
            "lead_id": lead_id,
            "followup_date": DateFormat('yyyy-MM-dd HH:mm:ss').format(value),
            "status": selectedRegion,
            "comments": cmtController.text,
            "login_type": type
          }));
          if (response.statusCode == 200) {
            setState(() {
              _loading = false;
            });
            var data = json.decode(response.body);
            print(data);
            Fluttertoast.showToast(
                msg: 'Message: ' + data['message'].toString());
            if (type == "users") {
              Navigator.pushReplacementNamed(
                context,
                '/dashboard',
              );
            }
            else {
              Navigator.pushReplacementNamed(
                  context, '/home-screen');
            }
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
  Widget _submitButton2() {
    return InkWell(
      onTap: (){
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
          if (expenseDateController.text != "") {
            Navigator.pushNamed(
              context,
              '/add-order',
              arguments: <String, String>{
                'lead_id': lead_id.toString(),
                'subject': subject.toString(),
                'status': selectedCity,
                'month': expenseDateController.text,
                'comments': cmtController.text
              },
            );
          }
          else {
            Fluttertoast.showToast(msg: 'Please select date');
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
          'ADD ORDER',
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
                hintText: "Comment"),
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


  void callDatePicker() async {
    var order = await getDate();
    setState(() {
      finalDate = order;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(finalDate);
      print(formatted);
      expenseDateController.text = formatted.toString();
    });
  }

  Future<DateTime> getDate() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate:  DateTime(3000),
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
        color: Colors.grey,
      ));

  final expenseDateController = TextEditingController();
  Widget _expenseDate(){
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      height: 40,
      child: Align(
        alignment: Alignment.topLeft,
        child: Theme(
          data: Theme.of(context).copyWith(
            cursorColor: Color(0xFF000000),
            hintColor: Colors.transparent,
          ),
          child: InkWell(
            onTap: () {
              //  if(selectedDealer!="") {
              callDatePicker();

              FocusScope.of(context)
                  .requestFocus(new FocusNode());
            },
            child: TextFormField(
              enabled: false,
              textAlign: TextAlign.left,
              controller: expenseDateController,
              style: new TextStyle(
                  fontSize: 16
              ),
              decoration: InputDecoration(
                  focusedBorder: border,
                  border: border,
                  contentPadding:
                  EdgeInsets.fromLTRB(
                      10, 5, 5, 0),
                  disabledBorder: border,
                  enabledBorder: border,
                  suffixIcon: Icon(Icons.calendar_today,size: 16,color: Color(0xff9b56ff),),

                  filled: true,
                  fillColor: Color(0xFFffffff),
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontFamily: "WorkSansLight"),
                  hintText: 'Select Date'),
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
    );
  }


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Update Lead Status',
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
                          "UPDATE STATUS",
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
                          "SELECT STATUS",
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
                              "Select Status",
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
                                if(selectedRegion=="Closed") {
                                  _cityData = _getCityCategories(_type);
                                }
                                else{
                                  addOrder=false;
                                }
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

                    selectedRegion=="Closed"?   Column(
                      children: <Widget>[
                        SizedBox(
                        height: 20,
                      ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Text(
                              "SELECT SUB STATUS",
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
                                hint: new Text("Select Sub Status",
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
                                    print(selectedCity);
                                    if(selectedCity.contains("Glen Purchase")){
                                      addOrder=true;
                                    }
                                    else{
                                      addOrder=false;
                                    }
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
                      ]
                    ):Container(),



                    selectedRegion=="Follow up"?Column(
                      children: <Widget>[ SizedBox(
                        height: 20,
                      ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Text(
                              "FOLLOW-UP DATE",
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
                          // width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 15, right: 15),
                          height: 40,
                          // padding: EdgeInsets.all(8),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1.0,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                          ),
                          child:  Theme(
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
                                hintText: 'Follow-up date',
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                                suffixIcon: Icon(
                                  Icons.date_range,
                                  color: Color(0xff9b56ff),
                                  size: 14,
                                ),),
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100));
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
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
                                print(DateFormat('yyyy-MM-dd HH:mm a').format(value));
                                changedCount++;
                              }),
                              onSaved: (date) => setState(() {
                                value = date;
                                //  startTimeController.text =DateFormat('yyyy-MM-dd – kk:mm').format(date) ;
                                print(DateFormat('yyyy-MM-dd HH:mm a').format(value));
                                savedCount++;
                              }),
                            ),
                          ),

                        )
                      ]
                    ):Container(),


                    addOrder?   Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                         /* Container(
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
                                  color: Color(0xff9b56ff),
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    _dropdownValue = newValue;
                                    if (_dropdownValue == "Jan") {
                                      name = "Jan";
                                    } else if(_dropdownValue == "Feb"){
                                      name = "Feb";
                                    }
                                    else if(_dropdownValue == "Mar"){
                                      name = "Mar";
                                    }
                                    else if(_dropdownValue == "Apr"){
                                      name = "Apr";

                                    }
                                    else if(_dropdownValue == "May"){
                                      name = "May";
                                    }
                                    else if(_dropdownValue == "Jun"){
                                      name = "Jun";
                                    }
                                    else if(_dropdownValue == "Jul"){
                                      name = "Jul";
                                    }
                                    else if(_dropdownValue == "Aug"){
                                      name = "Aug";

                                    }
                                    else if(_dropdownValue == "Sep"){
                                      name = "Sep";

                                    }
                                    else if(_dropdownValue == "Oct"){
                                      name = "Oct";

                                    }
                                    else if(_dropdownValue == "Nov"){
                                      name = "Nov";

                                    }
                                    else if(_dropdownValue == "Dec"){
                                      name = "Dec";

                                    }
                                    print(_dropdownValue);
                                    print(name);
                                  });
                                },
                                items: <String>[
                                  'Select Month',
                                  'Jan',
                                  'Feb',
                                  'Mar',
                                  'Apr',
                                  'May',
                                  'Jun',
                                  'Jul',
                                  'Aug',
                                  'Sep',
                                  'Oct',
                                  'Nov',
                                  'Dec',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child:  new Text(value,
                                        style: new TextStyle(color: Colors.black,fontSize: 16)),

                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),*/

                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: Text(
                                "PURCHASE DATE",
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

                          _expenseDate(),
                        ]
                    ):Container(),


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
                    addOrder?_submitButton2():  _submitButton()
                  ]),
            ),

          ],
          ),
            ),
          ),
        );


  }
}

class Region {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;

  Region({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME});

  factory Region.fromJson(Map<String, dynamic> json) {
    return new Region(
        THIRD_LEVEL_ID: json['id'].toString(),
        THIRD_LEVEL_NAME: json['name']);
  }
}

class City {
  final String FOURTH_LEVEL_ID;
  final String FOURTH_LEVEL_NAME;

  City({this.FOURTH_LEVEL_ID, this.FOURTH_LEVEL_NAME});

  factory City.fromJson(Map<String, dynamic> json) {
    return new City(
        FOURTH_LEVEL_ID: json['id'].toString(),
        FOURTH_LEVEL_NAME: json['name']);
  }
}
