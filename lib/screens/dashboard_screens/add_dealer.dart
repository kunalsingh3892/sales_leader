import 'dart:io';

import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/material.dart';

import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
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

class AddDealer extends StatefulWidget {
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<AddDealer> {
  bool _loading = false;
  bool show = false;
  bool show1 = false;
  bool show2 = false;
  final _formKey = GlobalKey<FormState>();
  final firmNameController = TextEditingController();
  final ownerFNameController = TextEditingController();
  final locationNameController = TextEditingController();
  final ownerLNameController = TextEditingController();
  final addressController = TextEditingController();
  final addressController1 = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final pinCodeController = TextEditingController();
  final otherContactController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final latitudeController = TextEditingController();
  final latitudeController1 = TextEditingController();
  final longitudeController = TextEditingController();
  final longitudeController1 = TextEditingController();
  final suggestedDistributorController = TextEditingController();
  final cmtController = TextEditingController();

  String _dropdownValue = 'Select Contact Type';
  String _dropdownValue1 = 'Home';
  String sub_type="Home";
  bool suggest = false;
  String _address="";
  List<Region> _region = [];
  List<City> _city = [];
  Future _stateData;
  Future _cityData;
  Future _dealerData;
  Future _pinData;
  String selectedRegion;
  String selectedCity;
  String selectedDealer = "";
  String catData = "";

  bool showLocation=false;
  String cityData = "";
  var dealerData;
  var _cmt;
  var finalDate, finalDate2;
  var _userId;
  var dealerJson;
  String type = "Select User Type";
  var ocp=1;
  var _type;
  String _type1="1";
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
       _stateData = _getStateCategories();
    });
  }

  Future _getStateCategories() async {
    var response = await http.post(
      URL+"getstatelist",
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
            selectedRegion = _region[0].THIRD_LEVEL_ID;
          }
          _cityData = _getCityCategories(_type);
          _pinData = _getPinCategories();
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
      URL+"getcitylist",
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
               _type1 = map.FOURTH_LEVEL_ID;
              if (selectedCity == "" || selectedCity == null) {
                selectedCity = _city[0].FOURTH_LEVEL_ID;
              }

              return map.FOURTH_LEVEL_ID;
            }
          }
        }).toList();
        //  if(selectedCity==""||selectedCity==null){
        selectedCity = _city[0].FOURTH_LEVEL_NAME;
        _type1 = _city[0].FOURTH_LEVEL_ID;

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
  List<Asset> images = List<Asset>();
  Future<void> pickImages() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarTitle: "Add Dealers",
          useDetailsView: false,
        ),
      );
    } on Exception catch (e) {
      print(e);
    }

    setState(()  {
      images = resultList;


    });
  }
  List<Asset> images1 = List<Asset>();
  Future<void> pickImages1() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
        selectedAssets: images1,
        materialOptions: MaterialOptions(
          actionBarTitle: "Add Dealers",
          useDetailsView: false,
        ),
      );
    } on Exception catch (e) {
      print(e);
    }

    setState(()  {
      images1 = resultList;


    });
  }
  Widget _submitButton() {
    return InkWell(
      onTap: () async {

        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
          if (type != "Select User Type") {
            setState(() {
              _loading = true;
            });

            final mimeTypeData =
            lookupMimeType(_image1.path, headerBytes: [0xFF, 0xD8]).split('/');
            final mimeTypeData1 =
            lookupMimeType(_image2.path, headerBytes: [0xFF, 0xD8]).split('/');
            var uri = Uri.parse(
               URL+'adddealer');
            final uploadRequest = http.MultipartRequest('POST', uri);
            final file = await http.MultipartFile.fromPath('visiting_card_image', _image1.path,
                contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
            final file1 = await http.MultipartFile.fromPath('visiting_card_back',_image2.path,
                contentType: MediaType(mimeTypeData1[0], mimeTypeData1[1]));
            uploadRequest.fields['auth_key'] = "VrdoCRJjhZMVcl3PIsNdM";
            uploadRequest.fields['id'] = _userId.toString();
            uploadRequest.fields['type'] = type.toString();
            print("<<<<<<<<<<<"+type);
            uploadRequest.fields['firm_name'] = firmNameController.text;
            uploadRequest.fields['owner_name'] =ownerFNameController.text;
            uploadRequest.fields['dealer_phone'] = contactController.text;
            uploadRequest.fields['dealer_email'] = emailController.text;
            uploadRequest.fields['country_id'] ="1";
            uploadRequest.fields['state_id'] = _type;
            uploadRequest.fields['city_id'] = _type1;
            print("<<<<<<<<<<<"+_type);
            print("<<<<<<<<<<<"+_type1);
            uploadRequest.fields['address_first'] = addressController.text;
            uploadRequest.fields['address_second'] = "1";
            uploadRequest.fields['pincode'] = selectedDealer;
            uploadRequest.fields['other_contact'] = otherContactController.text;
            uploadRequest.fields['latitude'] = latitudeController.text;
            uploadRequest.fields['longitude'] = longitudeController.text;
            uploadRequest.fields['sugested_distributor'] = suggestedDistributorController.text!=null?suggestedDistributorController.text:"";
            uploadRequest.fields['comments'] = cmtController.text;
            uploadRequest.files.add(file);
            uploadRequest.files.add(file1);
            print(uploadRequest.fields);

            final streamedResponse = await uploadRequest.send();
            final response =
            await http.Response.fromStream(streamedResponse);

            try {
              print("><>>>>>>>>>>>"+response.statusCode.toString());
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
              } else {
                setState(() {
                  _loading = false;
                });

                Fluttertoast.showToast(msg: "Error");
              }
            }
            catch (e) {
              print(e);
            }
          }else {
            setState(() {
              _loading = false;
            });
            Fluttertoast.showToast(msg: "Please Select Contact Type");
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
          var uri = Uri.parse(
              URL + 'addlocation');
          final uploadRequest = http.MultipartRequest('POST', uri);
            if(_image3!=null) {
              final mimeTypeData =
              lookupMimeType(_image3.path, headerBytes: [0xFF, 0xD8]).split(
                  '/');


              final file = await http.MultipartFile.fromPath(
                  'image', _image3.path,
                  contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

              uploadRequest.fields['auth_key'] = "VrdoCRJjhZMVcl3PIsNdM";
              uploadRequest.fields['id'] = _userId.toString();
              uploadRequest.fields['type'] = sub_type.toString();
              print("<<<<<<<<<<<" + sub_type);
              uploadRequest.fields['address'] = locationNameController.text;
              uploadRequest.fields['locationauto'] = addressController1.text;
              uploadRequest.fields['lat'] = latitudeController1.text;
              uploadRequest.fields['long'] = longitudeController1.text;

              uploadRequest.files.add(file);
              print(uploadRequest.fields);
            }
            else{


              uploadRequest.fields['auth_key'] = "VrdoCRJjhZMVcl3PIsNdM";
              uploadRequest.fields['id'] = _userId.toString();
              uploadRequest.fields['type'] = sub_type.toString();
              print("<<<<<<<<<<<" + sub_type);
              uploadRequest.fields['address'] = locationNameController.text;
              uploadRequest.fields['locationauto'] = addressController1.text;
              uploadRequest.fields['lat'] = latitudeController1.text;
              uploadRequest.fields['long'] = longitudeController1.text;

              print(uploadRequest.fields);
            }
            final streamedResponse = await uploadRequest.send();
            final response =
            await http.Response.fromStream(streamedResponse);

            try {
              print("><>>>>>>>>>>>"+response.statusCode.toString());
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
              } else {
                setState(() {
                  _loading = false;
                });

                Fluttertoast.showToast(msg: "Error");
              }
            }
            catch (e) {
              print(e);
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

  Widget _firmTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
    //  height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: firmNameController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Firm Name';
            }
            return null;
          },
          onSaved: (String value) {
            firmNameController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Add Firm Name",
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

  Widget _ownerFNameTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
    //  height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: ownerFNameController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Owner Name';
            }
            return null;
          },
          onSaved: (String value) {
            ownerFNameController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Enter Owner Name",
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
  Widget _locationNameTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      //  height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: locationNameController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Location Name';
            }
            return null;
          },
          onSaved: (String value) {
            locationNameController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            hintStyle:
            TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Enter Location Name",
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

  Widget _suggestedTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
    //  height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: suggestedDistributorController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Suggested Distributor';
            }
            return null;
          },
          onSaved: (String value) {
            suggestedDistributorController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Enter Suggested Distributor",
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

  Widget _ownerLNameTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
     // height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: ownerLNameController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Last Name';
            }
            return null;
          },
          onSaved: (String value) {
            ownerLNameController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Enter Last Name",
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

  Widget _dealerPhoneTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
     // height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: contactController,
          maxLength: 10,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Mobile No.';
            }
            else if (value.length < 10) {
              return 'Please enter 10 digit mobile number';
            } else if (value.length > 10) {
              return 'Please enter 10 digit mobile number';
            }
            return null;
          },
          onSaved: (String value) {
            contactController.text = value;
          },
          decoration: InputDecoration(
            counterText: "",
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Enter Mobile No. 1",
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

  Widget _dealerEmailTextBox(RegExp regex) {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
    //  height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: emailController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Email Address';
            }
            else if(!regex.hasMatch(value)){
              return "Enter Valid Email";
            }
            return null;
          },
          onSaved: (String value) {
            emailController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Enter Email",
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

  var result;
  List<String> cities=[];
  List<String> cities1=[];
  Map<String, dynamic> formData=new Map();
  TextStyle normalText = GoogleFonts.robotoSlab(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  Future _getPinCategories() async {
    var response = await http.post(
      URL+"getzipcodelist",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "state_id":_type
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      result = data['zipcode_list'];
      if (mounted) {
        setState(() {
          for(int i=0;i<result.length;i++){

            cities.add(result[i]['pincode']);
            cities1.add(result[i]['id'].toString());
            formData=result[i];
            print(cities1);
          }
          var dealersData = jsonEncode(result);

          dealerJson = JsonDecoder().convert(dealersData);
          print(dealerJson.toString());

        });
      }

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _pinCodeTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15),
     // height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: DropDownField(
              value: formData['pincode'],
              required: false,
              hintText: 'Select Pin Code',
              items: cities,
              textStyle: normalText,
              strict: false,
              onValueChanged: (value){
                setState(() {
                  for(int i=0;i<cities.length;i++){
                    if(value==cities[i]){
                      selectedDealer=cities[i];
                    }
                  }
                });
                print(selectedDealer);

              },
              setter: (dynamic newValue) {
                formData['pincode'] = newValue;
              }),
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
            onTap: (){
              print("fkrwkrj");
              getUserLocation();
            },
            child: TextFormField(
              maxLines: 4,
              minLines: 1,
              enabled: false,
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
                    /*onPressed: () {
                      print("fkrwkrj");
                      getUserLocation();
                     // _getCurrentLocation();
                    },*/
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontFamily: "WorkSansLight"),
                  hintText: "Enter Address"),
              controller: addressController,
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
  Widget _addressTextBox1() {
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
            onTap: (){
              print("fkrwkrj");
              getUserLocation1();
            },
            child: TextFormField(
              maxLines: 4,
              minLines: 1,
              enabled: false,
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
                    /*onPressed: () {
                      print("fkrwkrj");
                      getUserLocation();
                     // _getCurrentLocation();
                    },*/
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontFamily: "WorkSansLight"),
                  hintText: "Enter Address"),
              controller: addressController1,
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

 /* Widget _stateTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: stateController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter State';
            }
            return null;
          },
          onSaved: (String value) {
            stateController.text = value;
          },
          decoration: InputDecoration(
            *//* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*//*
            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Enter State",
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
  }*/

  /*Widget _cityTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: cityController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter City';
            }
            return null;
          },
          onSaved: (String value) {
            cityController.text = value;
          },
          decoration: InputDecoration(
            *//* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*//*
            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Enter City",
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
  }*/

  Widget _alternateContactTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
     // height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: otherContactController,
          maxLength: 10,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          keyboardType: TextInputType.number,
       /*   validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Mobile No. 2';
            }
            if (value.length < 10) {
              return 'Please enter 10 digit mobile number';
            } else if (value.length > 10) {
              return 'Please enter 10 digit mobile number';
            }
            return null;
          },*/
          onSaved: (String value) {
            otherContactController.text = value;
          },
          decoration: InputDecoration(
            counterText: "",
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Enter Mobile No. 2",
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

  Widget _latitudeTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: latitudeController,
          enabled: false,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          /* validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Title';
            }
            return null;
          },*/
          onSaved: (String value) {
            latitudeController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
             hintStyle:
            TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Latitude",

            border: OutlineInputBorder(
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
  Widget _latitudeTextBox1() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: latitudeController1,
          enabled: false,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          /* validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Title';
            }
            return null;
          },*/
          onSaved: (String value) {
            latitudeController1.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            hintStyle:
            TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Latitude",

            border: OutlineInputBorder(
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

  Widget _longitudeTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: longitudeController,
          enabled: false,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          /*  validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Title';
            }
            return null;
          },*/
          onSaved: (String value) {
            longitudeController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
             hintStyle:
            TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Longitude",
            border: OutlineInputBorder(
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
  Widget _longitudeTextBox1() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: longitudeController1,
          enabled: false,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          /*  validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Title';
            }
            return null;
          },*/
          onSaved: (String value) {
            longitudeController1.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            hintStyle:
            TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Longitude",
            border: OutlineInputBorder(
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
                    if (_dropdownValue == "Dealer") {
                      setState(() {
                        suggest = true;
                        showLocation = false;
                        type="2";
                      });
                      _dealerData = _getDealerCategories();
                    }
                    else if(_dropdownValue == "Distributor") {
                      setState(() {
                        suggest = false;
                        showLocation = false;
                        type="1";
                      });
                    }
                    else if(_dropdownValue == "Influencer") {
                      setState(() {
                        suggest = true;
                        showLocation = false;
                        type="3";
                      });
                    }
                    else if(_dropdownValue == "Location") {
                      setState(() {

                        showLocation = true;

                      });
                    }
                  });
                },
                items: <String>['Select Contact Type', 'Distributor', 'Dealer', 'Influencer','Location']
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
    );
  }
  Future _getDealerCategories() async {
    var response = await http.post(
      URL+"getdistributorlists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['distributor_list'];
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

  getUserLocation() async {//call this async method from whereever you need

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
    final coordinates = new Coordinates(
        myLocation.latitude, myLocation.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        coordinates);
    var first = addresses.first;
    print( '${first.addressLine},');
    addressController.text= first.addressLine.toString();
    latitudeController.text=myLocation.latitude.toString();
    longitudeController.text=myLocation.longitude.toString();

    return first;
  }
  getUserLocation1() async {//call this async method from whereever you need

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
    final coordinates = new Coordinates(
        myLocation.latitude, myLocation.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        coordinates);
    var first = addresses.first;
    print( '${first.addressLine},');
    addressController1.text= first.addressLine.toString();
    latitudeController1.text=myLocation.latitude.toString();
    longitudeController1.text=myLocation.longitude.toString();

    return first;
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library,color: Color(0xff9b56ff),),
                      title: new Text('Photo Library',style:TextStyle(color: Color(0xff9b56ff)),),
                      onTap: () {
                        _imgFromGallery1();
                        Navigator.of(context).pop();
                      }),
                 /* new ListTile(
                    leading: new Icon(Icons.photo_camera,color: Color(0xff9b56ff),),
                    title: new Text('Camera',style:TextStyle(color: Color(0xff9b56ff)),),
                    onTap: () {
                      _imgFromCamera1();
                      Navigator.of(context).pop();
                    },
                  ),*/
                ],
              ),
            ),
          );
        }
    );
  }
  void _showPicker2(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library,color: Color(0xff9b56ff),),
                      title: new Text('Photo Library',style:TextStyle(color: Color(0xff9b56ff)),),
                      onTap: () {
                        _imgFromGallery2();
                        Navigator.of(context).pop();
                      }),
                  /*new ListTile(
                    leading: new Icon(Icons.photo_camera,color: Color(0xff9b56ff),),
                    title: new Text('Camera',style:TextStyle(color: Color(0xff9b56ff)),),
                    onTap: () {
                      _imgFromCamera2();
                      Navigator.of(context).pop();
                    },
                  ),*/
                ],
              ),
            ),
          );
        }
    );
  }
  void _showPicker3(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library,color: Color(0xff9b56ff),),
                      title: new Text('Photo Library',style:TextStyle(color: Color(0xff9b56ff)),),
                      onTap: () {
                        _imgFromGallery3();
                        Navigator.of(context).pop();
                      }),
                  /*new ListTile(
                    leading: new Icon(Icons.photo_camera,color: Color(0xff9b56ff),),
                    title: new Text('Camera',style:TextStyle(color: Color(0xff9b56ff)),),
                    onTap: () {
                      _imgFromCamera2();
                      Navigator.of(context).pop();
                    },
                  ),*/
                ],
              ),
            ),
          );
        }
    );
  }

  File _image1;
  File _image2;
  File _image3;
  _imgFromCamera1() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera,  imageQuality:1,
        maxHeight: 640,
        maxWidth: 480
    );

    setState(() {
      _image1 = image;
    });
  }

  _imgFromGallery1() async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery,  maxHeight: 600,
        maxWidth: 800,
        imageQuality: 30
    );
    setState(() {
      _image1 = image;
    });

  }
  _imgFromCamera2() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera,   imageQuality:1,
        maxHeight: 640,
        maxWidth: 480
    );

    setState(() {
      _image3 = image;
    });
  }

  _imgFromGallery2() async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery,  maxHeight: 600,
        maxWidth: 800,
        imageQuality: 30
    );
    setState(() {
      _image2 = image;
    });

  }
  _imgFromGallery3() async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery,  maxHeight: 600,
        maxWidth: 800,
        imageQuality: 30
    );
    setState(() {
      _image3 = image;
    });

  }
  Widget build(BuildContext context) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
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
            'Add Contact',
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
                    _dropDown(),
                    showLocation==false?
                    Column( children: <Widget>[

                      suggest==true?
                      Column(
                          children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Text(
                              "SUGGESTED DISTRIBUTOR",
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

                        _suggestedTextBox()

                      ]):Container(),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "FIRM NAME",
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
                      _firmTextBox(),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "OWNER NAME",
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
                      _ownerFNameTextBox(),

                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "EMAIL ID",
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
                      _dealerEmailTextBox(regex),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "MOBILE NO.",
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
                      _dealerPhoneTextBox(),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "ALTERNATE MOBILE NO.(OPTIONAL)",
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
                      _alternateContactTextBox(),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "ADDRESS",
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
                        height: 10,
                      ),
                      _latitudeTextBox(),
                      SizedBox(
                        height: 10,
                      ),
                      _longitudeTextBox(),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
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
                                  _pinData = _getPinCategories();
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
                                        _type1 = map.FOURTH_LEVEL_ID;
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
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "PIN CODE",
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
                      _pinCodeTextBox(),
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
                        height: 20,
                      ),

                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "ATTACHMENT (VISITING CARD PIC)",
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
                        height: 10,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  children: <Widget>[

                                    ClipOval(
                                      child: Material(
                                        color:Color(0xff9b56ff),// button color
                                        child: InkWell(
                                          splashColor:Color(0xfffb4d6d), // inkwell color
                                          child: SizedBox(width: 56, height: 56, child: Icon(Icons.add_circle,color: Colors.white,)),
                                          onTap: () {
                                            show =true;
                                            _showPicker(context);
                                          },
                                        ),
                                      ),
                                    ),
                                    show && _image1!=null?Image.file(
                                      _image1,
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    ):Container(),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 15, right: 15),
                                      child: Text(
                                        "Front Image",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          // fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  children: <Widget>[

                                    ClipOval(
                                      child: Material(
                                        color:Color(0xff9b56ff),// button color
                                        child: InkWell(
                                          splashColor:Color(0xfffb4d6d), // inkwell color
                                          child: SizedBox(width: 56, height: 56, child: Icon(Icons.add_circle,color: Colors.white,)),
                                          onTap: () {
                                            show1 =true;
                                            _showPicker2(context);
                                          },
                                        ),
                                      ),
                                    ),
                                    show1 && _image2!=null?Image.file(
                                      _image2,
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    ):Container(),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 15, right: 15),
                                      child: Text(
                                        "Back Image",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          // fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]
                      ),


                      SizedBox(
                        height: 30,
                      ),
                      _submitButton()
                    ]):
                    Column( children: <Widget>[

                      SizedBox(
                        height: 20,
                      ),
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
                                if (_dropdownValue1 == "Home") {
                                  setState(() {
                                    sub_type="Home";
                                  });
                                }
                                else if(_dropdownValue1 == "Bus Stand") {
                                  setState(() {
                                    sub_type="Bus Stand";
                                  });
                                }
                                else if(_dropdownValue1 == "Railway Station") {
                                  setState(() {
                                    sub_type="Railway Station";
                                  });
                                }
                                else if(_dropdownValue1 == "Airport") {
                                  setState(() {
                                    sub_type="Airport";


                                  });
                                }
                              });
                            },
                            items: <String>['Home', 'Bus Stand', 'Railway Station', 'Airport']
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "LOCATION NAME",
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
                      _locationNameTextBox(),

                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Text(
                            "LOCATION (ADDRESS)",
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
                      _addressTextBox1(),

                      SizedBox(
                        height: 10,
                      ),
                      _latitudeTextBox1(),
                      SizedBox(
                        height: 10,
                      ),
                      _longitudeTextBox1(),
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
                        height: 10,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only( right: 15,top: 10),
                                child: Column(
                                  children: <Widget>[

                                    ClipOval(
                                      child: Material(
                                        color:Color(0xff9b56ff),// button color
                                        child: InkWell(
                                          splashColor:Color(0xfffb4d6d), // inkwell color
                                          child: SizedBox(width: 56, height: 56, child: Icon(Icons.add_circle,color: Colors.white,)),
                                          onTap: () {
                                            _showPicker3(context);
                                          },
                                        ),
                                      ),
                                    ),
                                   _image3!=null?Image.file(
                                      _image3,
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    ):Container(),

                                  ],
                                ),
                              ),
                            ),

                            Expanded(
                              child: Container(

                              ),
                            ),
                          ]
                      ),


                      SizedBox(
                        height: 30,
                      ),
                      _submitButton2()
                    ]),


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

  Region({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME});

  factory Region.fromJson(Map<String, dynamic> json) {
    return new Region(
        THIRD_LEVEL_ID: json['id'].toString(),
        THIRD_LEVEL_NAME: json['state_name']);
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
