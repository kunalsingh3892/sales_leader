import 'dart:io';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:glen_lms/components/image_upload.dart';
import 'package:glen_lms/modal/user.dart';
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


import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

import '../../constants.dart';
class AddExpense extends StatefulWidget {
  final Object argument;
  const AddExpense({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<AddExpense> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final expenseDateController = TextEditingController();
  final fromCityController = TextEditingController();
  final toCityController = TextEditingController();
  final hotelNameDateController = TextEditingController();
  final hotelCityController = TextEditingController();
  final hotelNightController = TextEditingController();

  final format = DateFormat("yyyy-MM-dd HH:mm");
  final initialValue = DateTime.now();


  AutovalidateMode autoValidateMode = AutovalidateMode.onUserInteraction;
  AutovalidateMode autoValidateMode2 = AutovalidateMode.onUserInteraction;
  AutovalidateMode autoValidateMode3 = AutovalidateMode.onUserInteraction;

  DateTime value = DateTime.now();
  DateTime value2 = DateTime.now();
  DateTime value3 = DateTime.now();

  int changedCount = 0;
  int changedCount2 = 0;
  int changedCount3 = 0;

  bool isShow=true;
  int savedCount = 0;
  int savedCount2 = 0;
  int savedCount3 = 0;

  final cmtController = TextEditingController();
  Axis direction = Axis.horizontal;

  String _dropdownValue = 'Select Visit Type';
  bool suggest = false;
  bool show = false;
  String _address="";

  Future _stateData;
  Future _cityData;
  Future _dealerData;
  List<Region> _region = [];
  List<City> _city = [];
  String selectedRegion="";

  String selectedCity;
  String selectedDealer = "";
  String selectedCities = "";
  String selectedDateStart = "";
  String selectedDateEnd = "";
  DateTime calenderDateStart ;
  DateTime calenderDateEnd ;
  String catData = "";

  String cityData = "";


  List<District> _district = [];
  String selectedDistrict;
  String districtData = "";
  String _type2="";
  Future _districtData;
  var dealerData;
  var _cmt;
  var finalDate, finalDate2,finalDate3;
  var _userId;
  var dealerJson;
  String type = "Select Visit Type";
  var ocp=1;
  var _type="1";
  var _type1;
  String visitTo="";
  String contact="";
  List <int> contact_arr = [];
  bool showContact=false;
  var con;
  List<Object> images1 = List<Object>();
  Future<File> _imageFile;
   String tour_tittle;
   String category;
  var status="success";


  AutoCompleteTextField searchTextField;
  AutoCompleteTextField searchTextField1;
  GlobalKey<AutoCompleteTextFieldState<User>> key = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<User>> key1 = new GlobalKey();
  static List<User> users = new List<User>();


  @override
  void initState() {
    super.initState();

    if(widget.argument!=null){
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    selectedDealer = data['tour_id'];
    tour_tittle = data['tour_tittle'];
    selectedRegion = data['category'];
    selectedDateStart = data['created_at'];
    selectedDateEnd = data['created_end'];
    print(selectedDateStart);
    print(selectedDateEnd);
    if(selectedDateStart!=null) {
      DateFormat format = DateFormat("dd.MM.yyyy");
      calenderDateStart = format.parse(selectedDateStart.replaceAll('-', '.'));
      calenderDateEnd = format.parse(selectedDateEnd.replaceAll('-', '.'));
      print(calenderDateStart);
      print(calenderDateEnd);
    }
    print(selectedDealer);
    print(tour_tittle);
    }
    setState(() {
      images.length=11;
      images1.add("Add Image");

    });
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      _stateData = _getStateCategories();
      _dealerData = _gettourCategories();
      getUsers();
    });
  }

  Future _onAddImageClick(int index) async {
    setState(() {
      _imageFile = ImagePicker.pickImage(source: ImageSource.camera,  imageQuality:1,
          maxHeight: 640,
          maxWidth: 480);
      if(_imageFile!=null)
      getFileImage(index);
    });
  }
  Future _onAddImageClick1(int index) async {
    setState(() {
      _imageFile = ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 600,
          maxWidth: 800,
          imageQuality: 30);

      if(_imageFile!=null)
      getFileImage(index);
    });
  }
  List<File> files = [];
  void getFileImage(int index) async {
//    var dir = await path_provider.getTemporaryDirectory();


  if(images1.length!=11) {
    _imageFile.then((file) async {
      setState(() {
        print(index.toString());
        ImageUploadModel imageUpload = new ImageUploadModel();
        imageUpload.isUploaded = false;
        imageUpload.uploading = false;
        imageUpload.imageFile = file;
        imageUpload.imageUrl = '';
        images1.replaceRange(index + 1, index + 1, [imageUpload]);


        if(imageUpload.imageFile!=null)
        files.add(imageUpload.imageFile);
        print(files);
      });
    });
  }else{
    Fluttertoast.showToast(msg:  "You can add only 10 images");
  }
  }
  void _showPicker2(context,int index) {
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
                        _onAddImageClick1( index);
                        Navigator.of(context).pop();
                      }),
                 /* new ListTile(
                    leading: new Icon(Icons.photo_camera,color: Color(0xff9b56ff),),
                    title: new Text('Camera',style:TextStyle(color: Color(0xff9b56ff)),),
                    onTap: () {
                      _onAddImageClick(index);
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
                uploadModel.imageFile!=null?Image.file(
                  uploadModel.imageFile,
                  width: 300,
                  height: 300,
                ):Container(),
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
                        images1.replaceRange(index-1, index + 1, ['Add Image']);
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
              icon: Icon(Icons.add_circle,color:Color(0xff9e54f8) ,),
              onPressed: () {
                if(images1.length!=11) {
                  print(index.toString());
                  _showPicker2(context, index);
                }
                else{
                  Fluttertoast.showToast(msg:  "You can add only 10 images");
                }
              },
            ),
          );
        }
      }),
    );
  }
  Future _getStateCategories() async {
    var response = await http.post(
      URL+"expensecategory",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['expense_category_list'];
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

                return map.THIRD_LEVEL_ID;
              }
            }
          }).toList();
          if (selectedRegion == null) {
            selectedRegion = _region[0].THIRD_LEVEL_NAME;
            _type = _region[0].THIRD_LEVEL_ID;
          }
          if(_type!="")
            _cityData = _getCityCategories(_type);
          _getTour();
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
      URL+"expensetype",
      body: {"auth_key": "VrdoCRJjhZMVcl3PIsNdM", "category_id": type.toString()},
      headers: {
        "Accept": "application/json",
      },
    );
    print(jsonEncode({"auth_key": "VrdoCRJjhZMVcl3PIsNdM", "category_id": type}));
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      var data = json.decode(response.body);
      var result = data['expense_type_list'];
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

  var result;
  List<String> cities=[];
  List<String> cities1=[];
  List<String> dates=[];
  List<String> dates1=[];
  Map<String, dynamic> formData=new Map();

  Future _gettourCategories() async {
    var response = await http.post(
      URL+"tourplanlists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id":_userId,
        "status":"Approved"
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
       result = data['tour_plan_list'];
      if (mounted) {
        setState(() {
          for(int i=0;i<result.length;i++){
            cities.add(result[i]['key']);
            cities1.add(result[i]['id'].toString());
            dates.add(result[i]['start_date_time1'].toString());
            dates1.add(result[i]['end_date_time1'].toString());
            if(tour_tittle  !="")
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
  List<String> citiess=[];
  List<String> citiess1=[];
  Map<String, dynamic> formData1=new Map();
  void getUsers() async {
    try {
      final response = await http.post(
        URL+"getcitymaster",
        body: {
          "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
          "search":""
        },
        headers: {
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        setState(() {
          users = loadUsers(jsonEncode(data['city_list']));
          for(int i=0;i<data['city_list'].length;i++){
            citiess.add(data['city_list'][i]['city_name']);
            citiess1.add(data['city_list'][i]['id'].toString());
            //formData1=data['city_list'][i];
          }




        });
      } else {
        print("Error getting users.");
      }
    } catch (e) {
      print("Error getting users.");
    }
  }

  static List<User> loadUsers(String jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }
  void _getTour() async {
    var response = await http.post(
      URL+"travelmode",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['travel_mode_list'];
      if (mounted) {
        setState(() {
          districtData = jsonEncode(result);

          final json = JsonDecoder().convert(districtData);
          _district =
              (json).map<District>((item) => District.fromJson(item)).toList();
          List<String> item = _district.map((District map) {
            for (int i = 0; i < _district.length; i++) {
              if (selectedDistrict == map.FIFTH_LEVEL_NAME) {
                _type2 = map.FIFTH_LEVEL_ID;

                print(selectedDistrict);
                return map.FIFTH_LEVEL_ID;
              }
            }
          }).toList();
          if (selectedDistrict == "") {
            selectedDistrict = _district[0].FIFTH_LEVEL_NAME;
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



              var uri = Uri.parse(
                 URL+'save_expense_reimbursments');
              final uploadRequest = http.MultipartRequest('POST', uri);
              for (int i = 0; i < files.length; i++) {
                print(files[i].path);
                final mimeTypeData =
                lookupMimeType(files[i].path, headerBytes: [0xFF, 0xD8]).split('/');

                final file = await http.MultipartFile.fromPath('images[$i]', files[i].path,
                    contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
                uploadRequest.files.add(file);
              }
              if(selectedCity=="Fare"){
                uploadRequest.fields['auth_key'] = "VrdoCRJjhZMVcl3PIsNdM";
                uploadRequest.fields['id'] = _userId;
                uploadRequest.fields['category'] = selectedCity.toString();
                uploadRequest.fields['type'] = selectedRegion.toString();
                uploadRequest.fields['amount'] = amountController.text;
                uploadRequest.fields['expense_date'] = expenseDateController.text;
                uploadRequest.fields['travel_mode'] = selectedDistrict.toString();
                uploadRequest.fields['from_date'] = fromDateController.text;
                uploadRequest.fields['to_date'] =toDateController.text;
                uploadRequest.fields['from_city'] = searchTextField.textField.controller.text;
                uploadRequest.fields['to_city'] = searchTextField1.textField.controller.text;
                uploadRequest.fields['hotel_name'] = hotelNameDateController.text;
                uploadRequest.fields['city'] =  selectedCities;
                uploadRequest.fields['no_of_night'] =  hotelNightController.text;
                uploadRequest.fields['tour'] = selectedDealer.toString();
                uploadRequest.fields['comments'] =cmtController.text!=null? cmtController.text:"";
                print(jsonEncode(uploadRequest.fields));

              }
              else{
                uploadRequest.fields['auth_key'] = "VrdoCRJjhZMVcl3PIsNdM";
                uploadRequest.fields['id'] = _userId;
                uploadRequest.fields['category'] = selectedCity.toString();
                uploadRequest.fields['type'] = selectedRegion.toString();
                uploadRequest.fields['amount'] = amountController.text;
                uploadRequest.fields['expense_date'] = expenseDateController.text;
                uploadRequest.fields['travel_mode'] = selectedDistrict.toString();
                uploadRequest.fields['from_date'] = fromDateController.text;
                uploadRequest.fields['to_date'] =toDateController.text;
                uploadRequest.fields['from_city'] = "";
                uploadRequest.fields['to_city'] = "";
                uploadRequest.fields['hotel_name'] = hotelNameDateController.text;
                uploadRequest.fields['city'] =  selectedCities;
                uploadRequest.fields['no_of_night'] =  hotelNightController.text;
                uploadRequest.fields['tour'] = selectedDealer.toString();
                uploadRequest.fields['comments'] =cmtController.text!=null? cmtController.text:"";
                print(jsonEncode(uploadRequest.fields));
              }


              try {
                final streamedResponse = await uploadRequest.send();
                final response =
                await http.Response.fromStream(streamedResponse);
                var data = json.decode(response.body);
                if (response.statusCode == 200) {
                  setState(() {
                    _loading = false;
                  });

                  Fluttertoast.showToast(msg: 'Message: ' + data['message'].toString());
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.pushNamed(
                    context,
                    '/expense',
                    arguments: <String, String>{
                      'member_id': "",

                    },
                  );
                }
                else{
                  setState(() {
                    _loading = false;
                  });
                  Fluttertoast.showToast(msg: 'Message: ' + data['message'].toString());
                }
              } catch (e) {
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



  Widget _amountTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      // height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: amountController,
          maxLength: 20,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Amount.';
            }

            return null;
          },
          onSaved: (String value) {
            amountController.text = value;
          },
          decoration: InputDecoration(
            counterText: "",
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
            hintStyle:
            TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Enter Amount",
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
  void callDatePicker() async {
    var order = await getDate();
    setState(() {
      finalDate = order;
      var formatter = new DateFormat('dd-MMM-yyyy');
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
      initialDate: calenderDateStart!=null?
      calenderDateStart:DateTime.now(),
      firstDate:calenderDateStart!=null?calenderDateStart:DateTime(2020),
      lastDate:calenderDateEnd!=null?calenderDateEnd:DateTime(2022),
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
  Widget row(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            user.name,
            style: TextStyle(fontSize: 16.0),
          ),

        ],
      ),
    );
  }
  void callDatePicker2() async {
    var order = await getDate2();
    setState(() {
      finalDate2 = order;
      var formatter = new DateFormat('dd-MMM-yyyy');
      String formatted = formatter.format(finalDate2);
      print(formatted);
      fromDateController.text = formatted.toString();
    });
  }

  Future<DateTime> getDate2() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
  void callDatePicker3() async {
    var order = await getDate3();
    setState(() {
      finalDate3 = order;
      var formatter = new DateFormat('dd-MMM-yyyy');
      String formatted = formatter.format(finalDate3);
      print(formatted);
      toDateController.text = formatted.toString();
    });
  }

  Future<DateTime> getDate3() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
             /* }
              else{
                Fluttertoast.showToast(msg:  "Please select tour");

              }*/
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
                  hintText: 'Expense Date'),
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
  Widget _hotelTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      //  height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: hotelNameDateController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Hotel Name';
            }
            return null;
          },
          onSaved: (String value) {
            hotelNameDateController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
            hintStyle:
            TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Hotel Name",
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

  Widget _typeWidgets(){
    if(selectedCity=="Fare")
      {
        return Column(children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Text(
                "MODE OF TRAVEL",
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
                  hint: new Text("Select Travel Mode",
                      style: TextStyle(color: Colors.grey[400])),
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xff9b56ff),
                    ),
                  ),
                  value: selectedDistrict,
                  isDense: true,
                  onChanged: (String newValue) {
                    setState(() {
                      selectedDistrict = newValue;
                      List<String> item = _district.map((District map) {
                        for (int i = 0; i < _district.length; i++) {
                          if (selectedDistrict == map.FIFTH_LEVEL_NAME) {
                            _type2 = map.FIFTH_LEVEL_ID;
                            return map.FIFTH_LEVEL_ID;
                          }
                        }
                      }).toList();
                    });
                  },
                  items: _district.map((District map) {
                    return new DropdownMenuItem<String>(
                      value: map.FIFTH_LEVEL_NAME,
                      child: new Text(map.FIFTH_LEVEL_NAME,
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
                        "FROM CITY",
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
                        "TO CITY",
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
                    child:

              searchTextField  =     AutoCompleteTextField<User>(
                            key: key,
                            clearOnSubmit: false,
                            suggestions: users,
                            style: TextStyle(color: Colors.black, fontSize: 16.0),
                        decoration: InputDecoration(
                          /* labelText: 'Title',
              labelStyle: TextStyle(color: Colors.black),*/
                          contentPadding:
                          EdgeInsets.fromLTRB(10, 10, 0, 10),
                          isDense: true,
                          hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: "WorkSansLight"),
                          hintText: "Enter From City",
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
                            itemFilter: (item, query) {
                              return item.name
                                  .toLowerCase()
                                  .startsWith(query.toLowerCase());
                            },
                            itemSorter: (a, b) {
                              return a.name.compareTo(b.name);
                            },
                            itemSubmitted: (item) {
                              setState(() {
                                searchTextField.textField.controller.text = item.name;
                              });
                            },
                            itemBuilder: (context, item) {
                              // ui for the autocompelete row
                              return row(item);
                            },
                          ),


                  ),
                  SizedBox(
                    width: 5,
                  ),

                  Expanded(
                    child:

                    searchTextField1=     AutoCompleteTextField<User>(
                      key: key1,
                      clearOnSubmit: false,
                      suggestions: users,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                      decoration: InputDecoration(
                        /* labelText: 'Title',
              labelStyle: TextStyle(color: Colors.black),*/
                        contentPadding:
                        EdgeInsets.fromLTRB(10, 10, 0, 10),
                        isDense: true,
                        hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: "WorkSansLight"),
                        hintText: "Enter To City",
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
                      itemFilter: (item, query) {
                        return item.name
                            .toLowerCase()
                            .startsWith(query.toLowerCase());
                      },
                      itemSorter: (a, b) {
                        return a.name.compareTo(b.name);
                      },
                      itemSubmitted: (item) {
                        setState(() {
                          searchTextField1.textField.controller.text = item.name;
                          print("<>>>>>>>>>>>>>>>>>>>"+searchTextField1.textField.controller.text);
                        });
                      },
                      itemBuilder: (context, item) {
                        // ui for the autocompelete row
                        return row(item);
                      },
                    ),


                  ),
                ],
              ),
            ]),
          ),

        ],);
      }
    else if(selectedCity=="Hotel"){
      return Column(children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            child: Text(
              "HOTEL NAME",
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
        _hotelTextBox(),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
             margin: EdgeInsets.only(left: 15,right: 15),
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
          //  height: 40,
          margin: new EdgeInsets.only(left: 15, right: 15),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.0,
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
          child: DropDownField(

              value:  formData1['city_name'],
              required: false,
              hintText: 'Select City',
              hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontFamily: "WorkSansLight"),
              items: citiess,
              textStyle: normalText,
              strict: false,
              onValueChanged: (value){
                setState(() {
                  for(int i=0;i<citiess.length;i++){
                    if(value==citiess[i]){
                      selectedCities=citiess[i];

                    }
                  }
                });
                print(selectedCities);

              },
              setter: (dynamic newValue) {
                formData1['city_name'] = newValue;
              }),
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
             margin: EdgeInsets.only(left: 15,right: 15),
            child: Text(
              "NO. OF NIGHTS",
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
          margin: new EdgeInsets.only(left: 15, right: 15),

          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: hotelNightController,
              textCapitalization:
              TextCapitalization.sentences,
              keyboardType: TextInputType.number,
              cursorColor: Color(0xff9b56ff),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please Enter No. Of Nights';
                }
                return null;
              },
              onSaved: (String value) {
                hotelNightController.text = value;
              },
              decoration: InputDecoration(
                /* labelText: 'Title',
              labelStyle: TextStyle(color: Colors.black),*/
                contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
                isDense: true,
                hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontFamily: "WorkSansLight"),
                hintText: "",
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
        ),

        SizedBox(
          height: 20,
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
                      "FROM",
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
                      "TO",
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
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    child:  Theme(
                      data: Theme.of(context).copyWith(
                        cursorColor: Color(0xFF000000),
                        hintColor: Colors.transparent,
                      ),
                      child: InkWell(
                        onTap: () {
                          callDatePicker2();
                          FocusScope.of(context)
                              .requestFocus(new FocusNode());
                        },
                        child: TextFormField(
                          enabled: false,
                          textAlign: TextAlign.center,
                          controller: fromDateController,
                          style: new TextStyle(
                              fontSize: 16
                          ),
                          decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.fromLTRB(
                                  5, 5, 5, 0),
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              suffixIcon: Icon(Icons.calendar_today,size: 16,color: Color(0xff9b56ff),),

                              filled: true,
                              fillColor: Color(0xFFffffff),
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontFamily: "WorkSansLight"),
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
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    child:  Theme(
                      data: Theme.of(context).copyWith(
                        cursorColor: Color(0xFF000000),
                        hintColor: Colors.transparent,
                      ),
                      child: InkWell(
                        onTap: () {
                          callDatePicker3();
                          FocusScope.of(context)
                              .requestFocus(new FocusNode());
                        },
                        child: TextFormField(
                          enabled: false,
                          textAlign: TextAlign.center,
                          controller: toDateController,
                          style: new TextStyle(
                              fontSize: 16
                          ),
                          decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.fromLTRB(
                                  5, 5, 5, 0),
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              suffixIcon: Icon(Icons.calendar_today,size: 16,color: Color(0xff9b56ff),),

                              filled: true,
                              fillColor: Color(0xFFffffff),
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontFamily: "WorkSansLight"),
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
              ],
            ),
          ]),
        ),
      ],);
    }
    else{
      return Column(children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            child: Text(
              "MODE OF TRAVEL",
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
                hint: new Text("Select Travel Mode",
                    style: TextStyle(color: Colors.grey[400])),
                icon: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xff9b56ff),
                  ),
                ),
                value: selectedDistrict,
                isDense: true,
                onChanged: (String newValue) {
                  setState(() {
                    selectedDistrict = newValue;
                    List<String> item = _district.map((District map) {
                      for (int i = 0; i < _district.length; i++) {
                        if (selectedDistrict == map.FIFTH_LEVEL_NAME) {
                          _type2 = map.FIFTH_LEVEL_ID;
                          return map.FIFTH_LEVEL_ID;
                        }
                      }
                    }).toList();
                  });
                },
                items: _district.map((District map) {
                  return new DropdownMenuItem<String>(
                    value: map.FIFTH_LEVEL_NAME,
                    child: new Text(map.FIFTH_LEVEL_NAME,
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
                      "FROM",
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
                      "TO",
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
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    child:  Theme(
                      data: Theme.of(context).copyWith(
                        cursorColor: Color(0xFF000000),
                        hintColor: Colors.transparent,
                      ),
                      child: InkWell(
                        onTap: () {
                          callDatePicker2();
                          FocusScope.of(context)
                              .requestFocus(new FocusNode());
                        },
                        child: TextFormField(
                          enabled: false,
                          textAlign: TextAlign.center,
                          controller: fromDateController,
                          style: new TextStyle(
                              fontSize: 16
                          ),
                          decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.fromLTRB(
                                  5, 5, 5, 0),
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              suffixIcon: Icon(Icons.calendar_today,size: 16,color: Color(0xff9b56ff),),

                              filled: true,
                              fillColor: Color(0xFFffffff),
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontFamily: "WorkSansLight"),
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
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    child:  Theme(
                      data: Theme.of(context).copyWith(
                        cursorColor: Color(0xFF000000),
                        hintColor: Colors.transparent,
                      ),
                      child: InkWell(
                        onTap: () {
                          callDatePicker3();
                          FocusScope.of(context)
                              .requestFocus(new FocusNode());
                        },
                        child: TextFormField(
                          enabled: false,
                          textAlign: TextAlign.center,
                          controller: toDateController,
                          style: new TextStyle(
                              fontSize: 16
                          ),
                          decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.fromLTRB(
                                  5, 5, 5, 0),
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              suffixIcon: Icon(Icons.calendar_today,size: 16,color: Color(0xff9b56ff),),

                              filled: true,
                              fillColor: Color(0xFFffffff),
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontFamily: "WorkSansLight"),
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
              ],
            ),
          ]),
        ),
      ],);
    }


  }
  TextStyle normalText = GoogleFonts.robotoSlab(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  String selectedValue;
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

    setState(()  {
      images = resultList;


    });
  }

  TextEditingController controller;
  final List<DropdownMenuItem> items = [];
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
            'Add Expense',
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
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "EXPENSE CATEGORY",
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
                              "Select Category",
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
                                print(selectedRegion);
                                print(_type);
                                if(selectedRegion=="Miscellaneous "){
                                  setState(() {
                                    isShow=false;
                                  });

                                }
                                else{
                                  setState(() {
                                    isShow=true;
                                  });
                                }


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
                          "EXPENSE TYPE",
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
                            hint: new Text("Select Expense Type",
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
                    isShow?  Column(
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
                        tour_tittle  ==""?  Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 15),
                          child: DropDownField(
                              value:  formData['key'],
                              required: false,
                              hintText: 'Select Tour',
                              items: cities,
                              textStyle: normalText,
                              strict: false,
                              onValueChanged: (value){
                                setState(() {
                                  for(int i=0;i<cities.length;i++){
                                    if(value==cities[i]){
                                      selectedDealer=cities1[i];
                                      selectedDateStart=dates[i];
                                      selectedDateEnd=dates1[i];
                                      DateFormat format = DateFormat("dd.MM.yyyy");
                                      calenderDateStart= format.parse(selectedDateStart.replaceAll('-', '.'));
                                      calenderDateEnd= format.parse(selectedDateEnd.replaceAll('-', '.'));
                                    }
                                  }
                                });
                                print(selectedDealer);

                              },
                              setter: (dynamic newValue) {
                                formData['key'] = newValue;
                              }),
                        ):Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 15),
                          child: DropDownField(
                              value:  tour_tittle,
                              required: false,
                              hintText: 'Select Tour',
                              items: cities,
                              textStyle: normalText,

                              enabled: false,
                              strict: false,
                              //  enabled: false,
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
                      ]
                    ):Container(),




                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "AMOUNT",
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

                    _amountTextBox(),

                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "EXPENSE DATE",
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
                    isShow?Column(children: [
                      SizedBox(
                        height: 20,
                      ),
                      _typeWidgets(),
                    ],):Container(),


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
                    Container( padding: const EdgeInsets.only(left: 16,right: 16),child: buildGridView()),

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
class District {
  final String FIFTH_LEVEL_ID;
  final String FIFTH_LEVEL_NAME;

  District({this.FIFTH_LEVEL_ID, this.FIFTH_LEVEL_NAME});

  factory District.fromJson(Map<String, dynamic> json) {
    return new District(
        FIFTH_LEVEL_ID: json['id'].toString(),
        FIFTH_LEVEL_NAME: json['name']);
  }
}