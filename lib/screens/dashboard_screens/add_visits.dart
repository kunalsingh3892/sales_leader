import 'dart:io';
import 'package:dropdownfield/dropdownfield.dart';
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
import 'package:mime/mime.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

import '../../constants.dart';

class AddVisits extends StatefulWidget {
  final Object argument;

  const AddVisits({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<AddVisits> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final firmNameController = TextEditingController();
  final ownerFNameController = TextEditingController();
  final ownerLNameController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final pinCodeController = TextEditingController();
  final otherContactController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final suggestedDistributorController = TextEditingController();
  final cmtController = TextEditingController();
  Axis direction = Axis.horizontal;

  String _dropdownValue = 'Select Visit Type';
  bool suggest = false;
  bool show = false;
  String _address = "";
  List<Region> _region = [];
  List<Region2> _region2 = [];
  List<Region3> _region3 = [];
  List<Region4> _region4 = [];
  List<Region5> _region5 = [];
  Future _stateData;
  String _dropdownValue1 = 'Select Sub Type';
  String sub_type="Home";
  Future _cityData;
  Future _dealerData;
  Future _addressData;
  String selectedRegion = "";
  String selectedRegion2 = "";
  String selectedRegion3 = "";
  String selectedPin = "";
  String selectedRegion4 = "";
  String selectedRegion5;
  String selectedCity;
  String selectedDealer = "";
  String selectedDealer1 = "";
  String catData = "";
  String catData1 = "";

  String cityData = "";
  var dealerData;
  var _cmt;
  var finalDate, finalDate2;
  var _userId;
  var dealerJson;
  String type = "Select Visit Type";
  var ocp = 1;
  var _type;
  var _type1;
  String visitTo = "";
  String contact = "";
  List<int> contact_arr = [];
  bool showContact = false;
  var con;

  var tour_name = "";

  var customer_name = "";
  var status = "success";

  String areaPin = "";
  String lat="";
  String long="";

  bool showLocationName=false;
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    visitTo = data['visit_to'];
    print(visitTo);
    selectedDealer = data['contact'];
    customer_name = data['contact_name'];
    selectedRegion2 = data['tour_title'];
    tour_name = data['tour_name'];
    selectedPin = data['pinCode'];
    getUserLocation();
    print(visitTo);
    print(contact);
    print(selectedPin);
    setState(() {
      images.length = 11;
      images1.add("Add Image");
    });

  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();

      if (visitTo != "") {
        setState(() {
          if (visitTo == "Tour") {
            _dropdownValue = "Tour";
          } else {
            _dropdownValue = "Lead";
          }

          type = visitTo;
        });
        _stateData = _getContactCategories(type);
      }
    });
  }

  List<String> cities = [];
  List<String> cities1 = [];
  List<String> pinCodes = [];
  Map<String, dynamic> formData = new Map();

  Future _getContactCategories(type) async {
    var response = await http.post(
      URL+"connecttypelists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId.toString(),
        "type": type.toString(),
        "lat":lat,
        "long":long
      },
      headers: {
        "Accept": "application/json",
      },
    );

    print(jsonEncode({
      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      "id": _userId.toString(),
      "type": type.toString(),
      "lat":lat,
      "long":long
    }));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['dropdown_list'];
      if (mounted) {
        if (type == "Lead") {
          cities.clear();
          cities1.clear();
          setState(() {
            for (int i = 0; i < result.length; i++) {
              cities.add(result[i]['search_key']);
              cities1.add(result[i]['id'].toString());
              pinCodes.add(result[i]['pincode'].toString());
              formData = result[i];
              print(cities1);
            }
            dealerData = jsonEncode(result);
            dealerJson = JsonDecoder().convert(dealerData);
            print(dealerJson.toString());
          });
        } else if (type == "Tour") {
          setState(() {
            List uniqueList = new List();
            for (var jsonElement in result) {
              bool isPresent = false;
              for (var uniqueEle in uniqueList) {
                if (uniqueEle['tour_tittle'] == jsonElement['tour_tittle'])
                  isPresent = true;
              }
              if (!isPresent) uniqueList.add(jsonElement);
            }

            catData = jsonEncode(uniqueList);
            final json = JsonDecoder().convert(catData);
            _region2 =
                (json).map<Region2>((item) => Region2.fromJson(item)).toList();
            List<String> item = _region2.map((Region2 map) {
              for (int i = 0; i < _region2.length; i++) {
                if (selectedRegion2 == map.THIRD_LEVEL_NAME) {
                  _type = map.THIRD_LEVEL_ID;

                  print(selectedRegion2);
                  return map.THIRD_LEVEL_ID;
                }
              }
            }).toList();
            if (selectedRegion2 == "") {
              selectedRegion2 = _region2[0].THIRD_LEVEL_NAME;
              _type = _region2[0].THIRD_LEVEL_ID;
            }
          });
          _dealerData = _getContactCategories2(_type);
          print(_type);
        } else if (type == "Dealer/distributor") {
          setState(() {
            List uniqueList = new List();
            for (var jsonElement in result) {
              bool isPresent = false;
              for (var uniqueEle in uniqueList) {
                if (uniqueEle['firm_name'] == jsonElement['firm_name'])
                  isPresent = true;
              }
              if (!isPresent) uniqueList.add(jsonElement);
            }
            print(uniqueList);
            catData = jsonEncode(uniqueList);
            print("dvfvf" + catData);
            final json = JsonDecoder().convert(catData);
            _region3 =
                (json).map<Region3>((item) => Region3.fromJson(item)).toList();
            List<String> item = _region3.map((Region3 map) {
              for (int i = 0; i < _region3.length; i++) {
                if (selectedRegion3 == map.THIRD_LEVEL_NAME) {
                  _type = map.THIRD_LEVEL_ID;

                  print(selectedRegion3);

                  return map.THIRD_LEVEL_ID;
                }
              }
            }).toList();
            if (selectedRegion3 == "") {
              selectedRegion3 = _region3[0].THIRD_LEVEL_NAME;
              _type = _region3[0].THIRD_LEVEL_ID;
              selectedPin = _region3[0].pincode;
              print("<<<<<<<<<<<<<<" + selectedPin);
            }
            // _cityData = _getCityCategories(_type);
          });
        } else {
          setState(() {
            List uniqueList = new List();
            for (var jsonElement in result) {
              bool isPresent = false;
              for (var uniqueEle in uniqueList) {
                if (uniqueEle['firm_name'] == jsonElement['firm_name'])
                  isPresent = true;
              }
              if (!isPresent) uniqueList.add(jsonElement);
            }
            print(uniqueList);
            catData = jsonEncode(uniqueList);
            print("dvfvf" + catData);
            final json = JsonDecoder().convert(catData);
            _region4 =
                (json).map<Region4>((item) => Region4.fromJson(item)).toList();
            List<String> item = _region4.map((Region4 map) {
              for (int i = 0; i < _region4.length; i++) {
                if (selectedRegion4 == map.THIRD_LEVEL_NAME) {
                  _type = map.THIRD_LEVEL_ID;

                  print(selectedRegion4);
                  return map.THIRD_LEVEL_ID;
                }
              }
            }).toList();
            if (selectedRegion4 == "") {
              selectedRegion4 = _region4[0].THIRD_LEVEL_NAME;
              _type = _region4[0].THIRD_LEVEL_ID;
              selectedPin = _region3[0].pincode;
            }
            // _cityData = _getCityCategories(_type);
          });
        }
      }

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future _getAddressCategories(type) async {
    var response = await http.post(
      URL+"typewiselocation",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId.toString(),
        "type": type.toString(),
        "lat":lat,
        "long":long
      },
      headers: {
        "Accept": "application/json",
      },
    );

    print(jsonEncode({
      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      "id": _userId.toString(),
      "type": type.toString(),
      "lat":lat,
      "long":long
    }));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['location_dropdown_list'];
      if (mounted) {
        setState(() {
          catData1 = jsonEncode(result);

          final json = JsonDecoder().convert(catData1);
          _region5 =
              (json).map<Region5>((item) => Region5.fromJson(item)).toList();
          List<String> item = _region5.map((Region5 map) {
            for (int i = 0; i < _region5.length; i++) {
              if (selectedRegion5 == map.THIRD_LEVEL_ID) {
                selectedRegion5 = map.THIRD_LEVEL_ID;

                print(selectedRegion5);
                return map.THIRD_LEVEL_ID;
              }
            }
          }).toList();
          if (selectedRegion5 == "") {
            selectedRegion5 = _region5[0].THIRD_LEVEL_ID;
          }
        });
      }

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }
  var result2;
  List<String> cities2 = [];
  List<String> cities3 = [];
  List<String> pinCodes3 = [];
  Map<String, dynamic> formData2 = new Map();

  Future _getContactCategories2(type) async {
    var response = await http.post(
      URL+"tourplandetails",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "tour_id": type.toString(),
      },
      headers: {
        "Accept": "application/json",
      },
    );
    print(jsonEncode({
      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      "tour_id": type.toString(),
    }));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['dealerlist'];
      if (mounted) {
        cities2.clear();
        cities3.clear();
        setState(() {
          for (int i = 0; i < result.length; i++) {
            cities2.add(result[i]['dealer_name']);
            cities3.add(result[i]['id'].toString());
            pinCodes3.add(result[i]['pincode'].toString());
            formData2 = result[i];
            print(cities2);
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
          if (type != "Select Visit Type") {
            if (type != "Lead")
            {
              if(type=="Other Visit")
              {
                setState(() {
                  _loading = true;
                });
                  var uri = Uri.parse(
                      URL+'addvisit');
                  final uploadRequest = http.MultipartRequest('POST', uri);
                  for (int i = 0; i < files.length; i++) {
                    final mimeTypeData =
                    lookupMimeType(files[i].path, headerBytes: [0xFF, 0xD8])
                        .split('/');

                    final file = await http.MultipartFile.fromPath(
                        'images[$i]', files[i].path,
                        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
                    uploadRequest.files.add(file);
                  }
                  uploadRequest.fields['auth_key'] = "VrdoCRJjhZMVcl3PIsNdM";
                  uploadRequest.fields['id'] = _userId;
                  uploadRequest.fields['link_visit'] = type.toString();
                  uploadRequest.fields['connect_id'] = "";
                  uploadRequest.fields['dealer_id'] = "";
                  uploadRequest.fields['location'] = addressController.text;
                  uploadRequest.fields['status'] = status.toString();
                  uploadRequest.fields['lat'] = lat.toString();
                  uploadRequest.fields['long'] = long.toString();
                  uploadRequest.fields['locationtype'] = sub_type;
                  uploadRequest.fields['locationaddress'] = sub_type!="Other Visit"?selectedRegion5:addressController.text;
                  uploadRequest.fields['comments'] = cmtController.text != null ? cmtController.text : "";
                  print(uploadRequest);
                  try {
                    final streamedResponse = await uploadRequest.send();
                    final response =
                    await http.Response.fromStream(streamedResponse);
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
                    }
                  } catch (e) {
                    print(e);
                  }
              }
              else if(type=="Tour"){
                setState(() {
                  _loading = true;
                });
                if (selectedDealer1!="") {
                  var uri = Uri.parse(
                      URL+'addvisit');
                  final uploadRequest = http.MultipartRequest('POST', uri);
                  for (int i = 0; i < files.length; i++) {
                    final mimeTypeData =
                    lookupMimeType(files[i].path, headerBytes: [0xFF, 0xD8])
                        .split('/');

                    final file = await http.MultipartFile.fromPath(
                        'images[$i]', files[i].path,
                        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
                    uploadRequest.files.add(file);
                  }

                  uploadRequest.fields['auth_key'] = "VrdoCRJjhZMVcl3PIsNdM";
                  uploadRequest.fields['id'] = _userId;
                  uploadRequest.fields['link_visit'] = type.toString();
                  uploadRequest.fields['connect_id'] = _type.toString();
                  uploadRequest.fields['dealer_id'] = selectedDealer1.toString();
                  print("weferfwerw" + _type.toString());
                  uploadRequest.fields['location'] = addressController.text;
                  uploadRequest.fields['status'] = status.toString();
                  uploadRequest.fields['lat'] = lat.toString();
                  uploadRequest.fields['long'] = long.toString();
                  uploadRequest.fields['comments'] =
                  cmtController.text != null ? cmtController.text : "";
                print(uploadRequest.fields);
                  try {
                    final streamedResponse = await uploadRequest.send();
                    final response =
                    await http.Response.fromStream(streamedResponse);
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
                    }
                  } catch (e) {
                    print(e);
                  }
                } else {
                  setState(() {
                    _loading = false;
                  });
                  Fluttertoast.showToast(msg: "Please select dealer.");
                }
              }

              else {
                setState(() {
                  _loading = true;
                });

                  var uri = Uri.parse(
                      URL+'addvisit');
                  final uploadRequest = http.MultipartRequest('POST', uri);
                  for (int i = 0; i < files.length; i++) {
                    final mimeTypeData =
                    lookupMimeType(files[i].path, headerBytes: [0xFF, 0xD8])
                        .split('/');

                    final file = await http.MultipartFile.fromPath(
                        'images[$i]', files[i].path,
                        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
                    uploadRequest.files.add(file);
                  }

                  uploadRequest.fields['auth_key'] = "VrdoCRJjhZMVcl3PIsNdM";
                  uploadRequest.fields['id'] = _userId;
                  uploadRequest.fields['link_visit'] = type.toString();
                  uploadRequest.fields['connect_id'] = _type.toString();
                  uploadRequest.fields['dealer_id'] = selectedDealer1.toString();
                  print("weferfwerw" + _type.toString());
                  uploadRequest.fields['location'] = addressController.text;
                  uploadRequest.fields['status'] = status.toString();
                  uploadRequest.fields['lat'] = lat.toString();
                  uploadRequest.fields['long'] = long.toString();
                  uploadRequest.fields['comments'] =
                  cmtController.text != null ? cmtController.text : "";
                  print(uploadRequest.fields);
                  try {
                    final streamedResponse = await uploadRequest.send();
                    final response =
                    await http.Response.fromStream(streamedResponse);
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
                    }
                  } catch (e) {
                    print(e);
                  }

              }
            }
            else
              {
              setState(() {
                _loading = true;
              });
              if (selectedDealer!="") {
                if(selectedPin == areaPin){
                var uri = Uri.parse(
                    URL+'addvisit');
                final uploadRequest = http.MultipartRequest('POST', uri);
                for (int i = 0; i < files.length; i++) {
                  final mimeTypeData =
                      lookupMimeType(files[i].path, headerBytes: [0xFF, 0xD8])
                          .split('/');

                  final file = await http.MultipartFile.fromPath(
                      'images[$i]', files[i].path,
                      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
                  uploadRequest.files.add(file);
                }
                uploadRequest.fields['auth_key'] = "VrdoCRJjhZMVcl3PIsNdM";
                uploadRequest.fields['id'] = _userId;
                uploadRequest.fields['link_visit'] = type.toString();
                uploadRequest.fields['connect_id'] = selectedDealer.toString();
                uploadRequest.fields['dealer_id'] = "";
                uploadRequest.fields['location'] = addressController.text;
                uploadRequest.fields['status'] = status.toString();
                uploadRequest.fields['lat'] = lat.toString();
                uploadRequest.fields['long'] = long.toString();
                uploadRequest.fields['comments'] =
                    cmtController.text != null ? cmtController.text : "";
                print(uploadRequest.fields);
                try {
                  final streamedResponse = await uploadRequest.send();
                  final response =
                      await http.Response.fromStream(streamedResponse);
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
                  }
                } catch (e) {
                  print(e);
                }
              }
                else {
                  setState(() {
                    _loading = false;
                  });

                  Fluttertoast.showToast(msg: "Pin Codes are not matching.");
                }
              } else {
                setState(() {
                  _loading = false;
                });
                Fluttertoast.showToast(msg: "Please select lead.");
              }
            }
          } else {
            setState(() {
              _loading = false;
            });
            Fluttertoast.showToast(msg: "Please Select Visit Type");
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

  /* _getCurrentLocation() async {
    Position position =
    await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placeMarks[0];
    setState(() {
      _address =
          place.name +
              ', ' +
              place.subLocality +
              ', ' +
              place.locality +
              ' - ' +
              place.postalCode;

      addressController.text=_address;
      latitudeController.text=position.latitude.toString();
      longitudeController.text=position.longitude.toString();
    });

  }*/
  getUserLocation() async {
    //call this async method from whereever you need

    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
      myLocation = null;
    }
    //  currentLocation = myLocation;
    final coordinates =
        new Coordinates(myLocation.latitude, myLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
/*    print('${first.addressLine},');
    print('${"<>>>>>>>>>>>>" + first.postalCode},');*/
    addressController.text = first.addressLine.toString();
    areaPin = first.postalCode;
    setState(() {
      lat=myLocation.latitude.toString();
      long=myLocation.longitude.toString();
      print(lat);
      print(long);
    });
    _getUser();
    return first;
  }

  Widget _addressTextBox() {
    return Container(
      // height: 80,
      margin: new EdgeInsets.only(left: 15, right: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Theme(
          data: Theme.of(context).copyWith(
            cursorColor: Color(0xff9b56ff),
            hintColor: Colors.transparent,
          ),
          child: InkWell(
            onTap: () {
              print("fkrwkrj");
              getUserLocation();
            },
            child: TextFormField(
              maxLines: 4,
              enabled: false,
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
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
                  disabledBorder: OutlineInputBorder(
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.gps_fixed,
                      color: Color(0xff9b56ff),
                      size: 16,
                    ),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontFamily: "WorkSansLight"),
                  hintText: "Enter Address"),
              controller: addressController,
              minLines: 1,
              //Normal textInputField will be displayed
              cursorColor: Color(0xff9b56ff),

              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if (value.isEmpty) {
                  return "Please Enter Address";
                }
                return null;
              },
              onSaved: (String value) {
                _cmt = value;
              },
            ),
          ),
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

  Widget _dropDown() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(left: 15, right: 15, top: 0),
        padding: EdgeInsets.all(8),
        decoration: ShapeDecoration(
          /*   gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[Color(0xFFfef1a1), Color(0xFFfdc601)]),*/
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
                  color: Color(0xff9e54f8),
                ),
                onChanged: (String newValue) {
                  setState(() {
                    _dropdownValue = newValue;
                    if (_dropdownValue == "Lead") {
                      setState(() {
                        type = "Lead";
                      });
                      _stateData = _getContactCategories(type);
                    } else if (_dropdownValue == "Tour") {
                      setState(() {
                        type = "Tour";
                      });
                      _stateData = _getContactCategories(type);
                    } else if (_dropdownValue == "Dealer/Distributor") {
                      setState(() {
                        type = "Dealer/distributor";
                      });
                      _stateData = _getContactCategories(type);
                    } else if (_dropdownValue == "Influencer") {
                      setState(() {
                        type = "Influencer";
                      });
                      _stateData = _getContactCategories(type);
                    }
                    else if (_dropdownValue == "Other Visit") {
                      setState(() {
                        type = "Other Visit";
                      });

                    }
                  });
                },
                items: <String>[
                  'Select Visit Type',
                  'Lead',
                  'Tour',
                  'Dealer/Distributor',
                  'Influencer',
                  'Other Visit'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value,
                        style: new TextStyle(color: Colors.black)),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle normalText = GoogleFonts.robotoSlab(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  Widget _dropdownSelect() {
    if (type == "Lead") {
      return customer_name == ""
          ? Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 15),
              child: DropDownField(
                  value: formData['tour_tittle'],
                  required: false,
                  hintText: 'Select Lead',
                  items: cities,
                  textStyle: normalText,
                  strict: false,
                  onValueChanged: (value) {
                    setState(() {
                      for (int i = 0; i < cities.length; i++) {
                        if (value == cities[i]) {
                          selectedDealer = cities1[i];
                          selectedPin = pinCodes[i];
                          print("<<<<<<<<<<<<<<<<" + selectedPin);
                        }
                      }
                    });
                    print(selectedDealer);
                  },
                  setter: (dynamic newValue) {
                    formData['tour_tittle'] = newValue;
                  }),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 15),
              child: DropDownField(
                  value: customer_name,
                  required: false,
                  hintText: 'Select Lead',
                  items: cities,
                  textStyle: normalText,
                  enabled: false,
                  strict: false,
                  onValueChanged: (value) {
                    setState(() {
                      for (int i = 0; i < cities.length; i++) {
                        if (value == cities[i]) {
                          selectedDealer = cities1[i];
                        }
                      }
                    });
                    print(selectedDealer);
                  },
                  setter: (dynamic newValue) {
                    formData['tour_tittle'] = newValue;
                  }),
            );
    } else if (type == "Tour") {
      return Container(
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
                "Select Tour",
                style: TextStyle(color: Colors.grey[400]),
              ),
              icon: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xff9b56ff),
                ),
              ),
              value: selectedRegion2,
              isDense: true,
              onChanged: (String newValue) {
                setState(() {
                  selectedRegion2 = newValue;
                  List<String> item = _region2.map((Region2 map) {
                    for (int i = 0; i < _region2.length; i++) {
                      if (selectedRegion2 == map.THIRD_LEVEL_NAME) {
                        _type = map.THIRD_LEVEL_ID;
                        return map.THIRD_LEVEL_ID;
                      }
                    }
                  }).toList();
                  _dealerData = _getContactCategories2(_type);
                });
              },
              items: _region2.map((Region2 map) {
                return new DropdownMenuItem<String>(
                  value: map.THIRD_LEVEL_NAME,
                  child: new Text(map.THIRD_LEVEL_NAME,
                      style: new TextStyle(color: Colors.black)),
                );
              }).toList(),
            ),
          ),
        ),
      );
    } else if (type == "Dealer/distributor") {
      return Container(
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
                "Select Contact",
                style: TextStyle(color: Colors.grey[400]),
              ),
              icon: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xff9b56ff),
                ),
              ),
              value: selectedRegion3,
              isDense: true,
              onChanged: (String newValue) {
                setState(() {
                  selectedRegion3 = newValue;
                  List<String> item = _region3.map((Region3 map) {
                    for (int i = 0; i < _region3.length; i++) {
                      if (selectedRegion3 == map.THIRD_LEVEL_NAME) {
                        _type = map.THIRD_LEVEL_ID;
                        selectedPin = map.pincode;
                        print("<<<<<<<<<<<<<<" + selectedPin);
                        return map.THIRD_LEVEL_ID;
                      }
                    }
                  }).toList();
                });
              },
              items: _region3.map((Region3 map) {
                return new DropdownMenuItem<String>(
                  value: map.THIRD_LEVEL_NAME,
                  child: new Text(map.THIRD_LEVEL_NAME,
                      style: new TextStyle(color: Colors.black)),
                );
              }).toList(),
            ),
          ),
        ),
      );
    } else {
      return Container(
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
                "Select Contact",
                style: TextStyle(color: Colors.grey[400]),
              ),
              icon: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xff9b56ff),
                ),
              ),
              value: selectedRegion4,
              isDense: true,
              onChanged: (String newValue) {
                setState(() {
                  selectedRegion4 = newValue;
                  List<String> item = _region4.map((Region4 map) {
                    for (int i = 0; i < _region4.length; i++) {
                      if (selectedRegion4 == map.THIRD_LEVEL_NAME) {
                        _type = map.THIRD_LEVEL_ID;
                        selectedPin = map.pincode;
                        print("<<<<<<<<<<<<<<" + selectedPin);
                        return map.THIRD_LEVEL_ID;
                      }
                    }
                  }).toList();
                });
              },
              items: _region4.map((Region4 map) {
                return new DropdownMenuItem<String>(
                  value: map.THIRD_LEVEL_NAME,
                  child: new Text(map.THIRD_LEVEL_NAME,
                      style: new TextStyle(color: Colors.black)),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }
  }

  Widget _dropdown2Select() {
    return tour_name == ""
        ? Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 15),
            child: DropDownField(
                value: formData2['dealer_name'],
                required: false,
                hintText: 'Select Dealer',
                items: cities2,
                textStyle: normalText,
                strict: false,
                onValueChanged: (value) {
                  setState(() {
                    for (int i = 0; i < cities2.length; i++) {
                      if (value == cities2[i]) {
                        selectedDealer1 = cities3[i];
                        selectedPin = pinCodes3[i];
                        print("<<<<<<<<<<<<<<<<" + selectedPin);
                      }
                    }
                  });
                  print(selectedDealer1);
                },
                setter: (dynamic newValue) {
                  formData2['dealer_name'] = newValue;
                }),
          )
        : Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 15),
            child: DropDownField(
                value: tour_name,
                required: false,
                hintText: 'Select Dealer',
                items: cities2,
                textStyle: normalText,
                enabled: false,
                strict: false,
                onValueChanged: (value) {
                  setState(() {
                    for (int i = 0; i < cities2.length; i++) {
                      if (value == cities2[i]) {
                        selectedDealer1 = cities3[i];
                      }
                    }
                  });
                  print(selectedDealer1);
                },
                setter: (dynamic newValue) {
                  formData2['dealer_name'] = newValue;
                }),
          );
  }

  List<Asset> images = List<Asset>();

  Future<void> pickImages() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarTitle: "Add Visits",
          useDetailsView: true,
        ),
      );
    } on Exception catch (e) {
      print(e);
    }

    setState(() {
      images = resultList;
    });
  }

  Future _onAddImageClick(int index) async {
    setState(() {
      _imageFile = ImagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 1,
          maxHeight: 640,
          maxWidth: 480);
      if (_imageFile != null) getFileImage(index);
    });
  }

  Future _onAddImageClick1(int index) async {
    setState(() {
      _imageFile = ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 600,
          maxWidth: 800,
          imageQuality: 30);

      if (_imageFile != null) getFileImage(index);
    });
  }

  List<File> files = [];
  List<Object> images1 = List<Object>();
  Future<File> _imageFile;

  void getFileImage(int index) async {
//    var dir = await path_provider.getTemporaryDirectory();

    if (images1.length != 11) {
      _imageFile.then((file) async {
        setState(() {
          print(index.toString());
          ImageUploadModel imageUpload = new ImageUploadModel();
          imageUpload.isUploaded = false;
          imageUpload.uploading = false;
          imageUpload.imageFile = file;
          imageUpload.imageUrl = '';
          images1.replaceRange(index + 1, index + 1, [imageUpload]);

          if (imageUpload.imageFile != null) files.add(imageUpload.imageFile);
          print(files);
        });
      });
    } else {
      Fluttertoast.showToast(msg: "You can add only 10 images");
    }
  }

  void _showPicker2(context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(
                        Icons.photo_library,
                        color: Color(0xff9b56ff),
                      ),
                      title: new Text(
                        'Photo Library',
                        style: TextStyle(color: Color(0xff9b56ff)),
                      ),
                      onTap: () {
                        _onAddImageClick1(index);
                        Navigator.of(context).pop();
                      }),
                /*  new ListTile(
                    leading: new Icon(
                      Icons.photo_camera,
                      color: Color(0xff9b56ff),
                    ),
                    title: new Text(
                      'Camera',
                      style: TextStyle(color: Color(0xff9b56ff)),
                    ),
                    onTap: () {
                      _onAddImageClick(index);
                      Navigator.of(context).pop();
                    },
                  ),*/
                ],
              ),
            ),
          );
        });
  }

  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      primary: false,
      childAspectRatio: 1,
      children: List.generate(images1.length, (index) {
        if (images1[index] is ImageUploadModel) {
          ImageUploadModel uploadModel = images1[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                uploadModel.imageFile != null
                    ? Image.file(
                        uploadModel.imageFile,
                        width: 300,
                        height: 300,
                      )
                    : Container(),
                Positioned(
                  right: 5,
                  top: 5,
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      size: 20,
                      color: Color(0xff9e54f8),
                    ),
                    onTap: () {
                      setState(() {
                        images1
                            .replaceRange(index - 1, index + 1, ['Add Image']);
                        files.remove(uploadModel.imageFile);
                        print(files);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Card(
            child: IconButton(
              icon: Icon(
                Icons.add_circle,
                color: Color(0xff9e54f8),
              ),
              onPressed: () {
                if (images1.length != 11) {
                  print(index.toString());
                  _showPicker2(context, index);
                } else {
                  Fluttertoast.showToast(msg: "You can add only 10 images");
                }
              },
            ),
          );
        }
      }),
    );
  }

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
            'Add Visits',
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
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "LOCATION",
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
                    _addressTextBox(),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "VISIT TYPE",
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
                    _dropDown(),
                    SizedBox(
                      height: 20,
                    ),
                    type != "Other Visit"?  Column(
                      children: <Widget>[ Align(
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
                        _dropdownSelect(),
                        SizedBox(
                          height: 20,
                        ),
                        type == "Tour"
                            ? Column(children: <Widget>[
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
                          _dropdown2Select(),
                          SizedBox(
                            height: 20,
                          ),
                        ])
                            : Container(),
                      ]
                    ):Container(),


                  /*  SizedBox(
                      height: 20,
                    ),*/
                  type!="Other Visit"?  Column(
                      children: <Widget>[ Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "STATUS",
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
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GroupButton(
                              spacing: 30,
                              direction: direction,
                              selectedColor: Color(0xff9b56ff),
                              unselectedColor: Colors.grey[200],
                              selectedTextStyle: TextStyle(color: Colors.white),
                              onSelected: (index, isSelected) {
                                if (index == 0) {

                                  setState(() {
                                    status = "success";
                                  });
                                  print(status);
                                } else if (index == 1) {
                                  setState(() {
                                    status = "ok";
                                  });
                                  print(status);
                                } else if (index == 2) {
                                  setState(() {
                                    status = "fail";
                                  });
                                  print(status);
                                }
                              },
                              buttons: [
                                "Success",
                                "Ok",
                                "Fail",
                              ],
                            //  selectedButtons:0,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ]
                    ):Container(),


                    type=="Other Visit"?Column( children: <Widget>[

                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "SELECT SUB TYPE",
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
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 15, right: 15, top: 0),
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

                              child: DropdownButtonHideUnderline(
                                child: new DropdownButton<String>(
                                  isExpanded: true,
                                  value: _dropdownValue1,
                                  isDense: true,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xff9e54f8),
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      _dropdownValue1 = newValue;
                                      if (_dropdownValue1 == "Select Sub Type") {
                                        setState(() {
                                          sub_type="";
                                          showLocationName=false;
                                        });
                                      }
                                      else if (_dropdownValue1 == "Home") {
                                        setState(() {
                                          sub_type="Home";
                                          showLocationName=true;
                                          selectedRegion5=null;
                                        });

                                        _addressData = _getAddressCategories("Home");
                                      }
                                      else if(_dropdownValue1 == "Bus Stand") {
                                        setState(() {
                                          sub_type="Bus Stand";
                                          showLocationName=true;
                                          selectedRegion5=null;
                                        });
                                        _addressData = _getAddressCategories("Bus Stand");
                                      }
                                      else if(_dropdownValue1 == "Railway Station") {
                                        setState(() {
                                          sub_type="Railway Station";
                                          showLocationName=true;
                                          selectedRegion5=null;
                                        });
                                        _addressData = _getAddressCategories("Railway Station");
                                      }
                                      else if(_dropdownValue1 == "Airport") {
                                        setState(() {
                                          sub_type="Airport";
                                          showLocationName=true;
                                          selectedRegion5=null;
                                        });
                                        _addressData = _getAddressCategories("Airport");
                                      }
                                      else if(_dropdownValue1 == "Other Visit") {
                                        setState(() {
                                          sub_type="Other Visit";
                                          showLocationName=false;

                                        });
                                      }
                                    });
                                  },
                                  items: <String>['Select Sub Type','Home', 'Bus Stand', 'Railway Station', 'Airport','Other Visit']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value,
                                          style: new TextStyle(color: Colors.black)),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                     showLocationName? Column(
                        children: <Widget>[

                          Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Text(
                              "SELECT LOCATION",
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
                                    "Select Location",
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  icon: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xff9b56ff),
                                    ),
                                  ),
                                  value: selectedRegion5,
                                  isDense: true,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      selectedRegion5= newValue;
                                      List<String> item = _region5.map((Region5 map) {
                                        for (int i = 0; i < _region5.length; i++) {
                                          if (selectedRegion5 == map.THIRD_LEVEL_ID) {
                                            selectedRegion5 = map.THIRD_LEVEL_ID;

                                            return map.THIRD_LEVEL_ID;
                                          }
                                        }
                                      }).toList();
                                    });
                                  },
                                  items: _region5.map((Region5 map) {
                                    return new DropdownMenuItem<String>(
                                      value: map.THIRD_LEVEL_ID,
                                      child: new Text(map.THIRD_LEVEL_ID,
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
                        ]
                      ):Container(),

                    ]):Container(),
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
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "ATTACHMENT",
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
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: buildGridView()),
                    /* Container(
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        children: <Widget>[
                          ClipOval(
                            child: Material(
                              color:Color(0xff9b56ff),// button color
                              child: InkWell(
                                splashColor:Color(0xfffb4d6d), // inkwell color
                                child: SizedBox(width: 56, height: 56, child: Icon(Icons.camera_alt,color: Colors.white,)),
                                onTap: () {
                                  show =true;
                                  pickImages();
                                },
                              ),
                            ),
                          ),
                          show?GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            padding: EdgeInsets.all(5),
                            children: List.generate(images.length, (index) {
                              Asset asset = images[index];
                              return AssetThumb(
                                asset: asset,
                                width: 300,
                                height: 300,
                              );
                            }),
                          ):Container(),

                        ],
                      ),
                    ),*/

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

  void _onFormSaved() {
    final FormState form = _formKey.currentState;
    form.save();
  }
}

class Region {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;
  final String THIRD_LEVEL_PHONE;

  Region({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME, this.THIRD_LEVEL_PHONE});

  factory Region.fromJson(Map<String, dynamic> json) {
    return new Region(
        THIRD_LEVEL_ID: json['id'].toString(),
        THIRD_LEVEL_NAME: json['customer_name'],
        THIRD_LEVEL_PHONE: json['customer_phone']);
  }
}

class Region2 {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;

  Region2({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME});

  factory Region2.fromJson(Map<String, dynamic> json) {
    return new Region2(
        THIRD_LEVEL_ID: json['id'].toString(),
        THIRD_LEVEL_NAME: json['tour_tittle']);
  }
}

class Region3 {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;
  final String pincode;

  Region3({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME, this.pincode});

  factory Region3.fromJson(Map<String, dynamic> json) {
    return new Region3(
      THIRD_LEVEL_ID: json['id'].toString(),
      THIRD_LEVEL_NAME: json['firm_name'],
      pincode: json['pincode'],
    );
  }
}

class Region4 {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;
  final String pincode;

  Region4({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME, this.pincode});

  factory Region4.fromJson(Map<String, dynamic> json) {
    return new Region4(
      THIRD_LEVEL_ID: json['id'].toString(),
      THIRD_LEVEL_NAME: json['firm_name'],
      pincode: json['pincode'],
    );
  }
}


class Region5 {
  final String THIRD_LEVEL_ID;


  Region5({this.THIRD_LEVEL_ID});

  factory Region5.fromJson(Map<String, dynamic> json) {
    return new Region5(
      THIRD_LEVEL_ID: json['address'].toString(),


    );
  }
}
