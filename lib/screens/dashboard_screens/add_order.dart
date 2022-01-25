import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:glen_lms/modal/order_json.dart';

import 'package:glen_lms/modal/product_helper.dart';
import 'package:glen_lms/modal/product_modal.dart';
import 'package:glen_lms/screens/dashboard_screens/product_list.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';

import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:group_button/group_button.dart';
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

class AddOrder extends StatefulWidget {
  final Object argument;

  const AddOrder({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<AddOrder> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final cmtController = TextEditingController();
  Axis direction = Axis.horizontal;
  List<OrderJson> xmlList = new List();
  bool show = false;
  String _address = "";
  List items = new List();
  DatabaseHelper2 db1 = new DatabaseHelper2();
  int _total = 0;
  var dealerData;
  var _cmt;
  String type = "";
  String role = "";

  var _userId;
  var dealerJson;
  Future _dealerData;
  String selectedDealer = "";
  var status = "success";
  var lead_id;
  var subject="";
  var comments="";
  var leadStatus="";
  String month="";
  List<TextEditingController> _controllers = new List();
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    lead_id = data['lead_id'];
    print(",,,,,,,,,,,,,,"+lead_id);
    subject = data['subject'];
    leadStatus = data['status'];
    comments = data['subject'];
    month = data['month'];
    print(subject);
    _getUser();
    db1.getAllProducts().then((products) {
      setState(() {
        products.forEach((product) {
          items.add(ProductModal.fromMap(product));
        });
        _total=0;
        print(subject);
        for (int i = 0; i < items.length; i++) {
          if(subject=="users") {
            if(role=="Sales Promoter"){
              _total = _total + (int.parse(items[i].mop) *
                  int.parse(items[i].quantity));
            }
            else{
              _total = _total + (int.parse(items[i].current_price) *
                  int.parse(items[i].quantity));
            }

          }
          else{
            _total = _total + (int.parse(items[i].mop) *
                int.parse(items[i].quantity));
          }
        }

      });
    });



  }


  @override
  void dispose() {
    db1.deleteAllProduct();
    super.dispose();
  }
  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      type = prefs.getString('type');
      role = prefs.getString('role').toString();
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
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
        "type":"Dealer"
      },
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
            if (items.length != 0) {
              print(selectedDealer);
              for (int i = 0; i < items.length; i++) {
                OrderJson xmljson = new OrderJson();
                xmljson.product_id = items[i].product_id;
                xmljson.sap_id = items[i].sap_id;
                xmljson.category_id = items[i].category_id;
                xmljson.sub_category_id = items[i].sub_category_id;
                xmljson.product_name = items[i].product_name;
                xmljson.model_no = items[i].model_no;
                if (subject == "users") {
                  if (type == "Sales Promoter") {
                    xmljson.current_price = items[i].mop;
                  }
                  else {
                    xmljson.current_price = items[i].current_price;
                  }
                }
                else {
                  xmljson.current_price = items[i].mop;
                }
                xmljson.quantity = items[i].quantity;
                xmljson.image = items[i].image;
                xmljson.mrp = items[i].mrp;
                xmlList.add(xmljson);
                // _total = _total + int.parse(items[i].current_price);
              }


              if (subject != "users") {

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
                  "total_amount": _total.toString(),
                  "lead_id": lead_id,
                  "login_type": type,
                  "type": "lead",
                  "month": month,
                  "status": leadStatus,
                  "comments": comments,
                  "product": xmlList,
                });

                var response = await http.post(
                  URL + "add_order",
                  body: msg,
                  headers: headers,
                );

                print(jsonEncode({
                  "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
                  "id": _userId,
                  "connect_id": selectedDealer,
                  "total_amount": _total.toString(),
                  "lead_id": lead_id,
                  "login_type": type,
                  "type": "lead",
                  "month": month,
                  "status": leadStatus,
                  "comments": comments,
                  "product": xmlList,
                }));

                if (response.statusCode == 200) {
                  setState(() {
                    _loading = false;
                  });
                  var data = json.decode(response.body);
                  Fluttertoast.showToast(
                      msg: 'Message: ' + data['message'].toString());
                  db1.deleteAllProduct();
                  if (subject == "users") {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      '/order-list',
                      arguments: <String, String>{
                        'member_id': "",

                      },
                    );
                  }
                  else {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      '/order-list',
                      arguments: <String, String>{
                        'member_id': "",

                      },
                    );
                  }
                  print(data);
                } else {
                  setState(() {
                    _loading = false;
                  });
                  print(response.body);

                  Fluttertoast.showToast(msg: 'Error');
                }
              }
              else {
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
                  "total_amount": _total.toString(),
                  "lead_id": lead_id,
                  "login_type": type,
                  "type": subject == "users" ? "order" : "lead",
                  "month": month,
                  "status": leadStatus,
                  "comments": comments,
                  "product": xmlList,
                });

                var response = await http.post(
                  URL + "add_order",
                  body: msg,
                  headers: headers,
                );

                print(jsonEncode({
                  "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
                  "id": _userId,
                  "connect_id": selectedDealer,
                  "total_amount": _total.toString(),
                  "lead_id": lead_id,
                  "login_type": type,
                  "type": subject == "users" ? "order" : "lead",
                  "month": month,
                  "status": leadStatus,
                  "comments": comments,
                  "product": xmlList,
                }));

                if (response.statusCode == 200) {
                  setState(() {
                    _loading = false;
                  });
                  var data = json.decode(response.body);
                  Fluttertoast.showToast(
                      msg: 'Message: ' + data['message'].toString());
                  db1.deleteAllProduct();
                  if (subject == "users") {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      '/order-list',
                      arguments: <String, String>{
                        'member_id': "",

                      },
                    );
                  }
                  else {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      '/order-list',
                      arguments: <String, String>{
                        'member_id': "",

                      },
                    );
                  }
                  print(data);
                } else {
                  setState(() {
                    _loading = false;
                  });
                  print(response.body);

                  Fluttertoast.showToast(msg: 'Error');
                }
              }
                else{
                  Fluttertoast.showToast(msg: "Please Select Contact First");
                }
            }


            }else {
              print(dealerData);
              Fluttertoast.showToast(msg: "Please Select Products");
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


  Widget _networkImage(url) {
    return Image(
      image: CachedNetworkImageProvider(url),
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
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  TextStyle mediumText = GoogleFonts.robotoSlab(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );




  final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      borderSide: BorderSide(
        color: Color(0xff9b56ff),
      ));


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
            'Add Order',
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
                          "ADD ORDERS",
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
                    lead_id==""?Container(
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
                    ):Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 15),
                      child: DropDownField(
                          value: subject,
                          required: false,
                          hintText: 'Select Dealer',
                          items: cities,
                          textStyle: normalText,

                          enabled: false,
                          strict: false,
                          onValueChanged: (value){


                          },
                          setter: (dynamic newValue) {
                            formData['tour_tittle'] = newValue;
                          }),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "ADD PRODUCT AND QUANTITY",
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
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topRight,
                            child: ClipOval(
                              child: Material(
                                color: Color(0xff9b56ff), // button color
                                child: InkWell(
                                  splashColor: Color(0xfffb4d6d),
                                  // inkwell color
                                  child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      )),
                                  onTap: () async {
                                    FocusScopeNode currentFocus = FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                    _onFormSaved();
                                    SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                    if(subject=="users") {
                                      if (selectedDealer != "") {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        prefs.setString('orderType', "order");
                                        _createNewNote(context);
                                      } else {
                                        print(selectedDealer);
                                        Fluttertoast.showToast(
                                            msg: "Please Select Contact First");
                                      }
                                    }
                                    else{
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      prefs.setString('orderType', "lead_order");
                                      _createNewNote(context);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: ListView.builder(
                          itemCount: items.length,
                          shrinkWrap: true,
                          primary: false,
                          padding: const EdgeInsets.all(15.0),
                          itemBuilder: (context, position) {
                            _controllers.add(new TextEditingController());
                            return Stack(
                              children: <Widget>[
                                // Divider(height: 5.0),
                                Container(
                                  //width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFfae3e2).withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ]),
                                  child: Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 5,
                                            top: 10,
                                            bottom: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            /*Container(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Center(
                                                  child: _networkImage(
                                                    items[position].image,
                                                  ),
                                                ),
                                              ),
                                            ),*/
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                          '${items[position].product_name}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                          style: mediumText,
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                   subject=="users"? type=="Sales Promoter"?Container(
                                                     padding: EdgeInsets.only(right: 10),
                                                     child: Text(
                                                       "₹ " + '${(int.parse(items[position].mop)*
                                                           int.parse(items[position].quantity)).toString()}',
                                                       overflow: TextOverflow
                                                           .ellipsis,
                                                       maxLines: 1,
                                                       style: mediumText,
                                                       textAlign:
                                                       TextAlign.left,
                                                     ),
                                                   ): Container(
                                                       padding: EdgeInsets.only(right: 10),
                                                       child: Text(
                                                         "₹ " + '${(int.parse(items[position].current_price)*
                                                             int.parse(items[position].quantity)).toString()}',
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            maxLines: 1,
                                                            style: mediumText,
                                                            textAlign:
                                                            TextAlign.left,
                                                          ),
                                                     ):Container(
                                                     padding: EdgeInsets.only(right: 10),
                                                     child: Text(
                                                       "₹ " + '${(int.parse(items[position].mop)*
                                                           int.parse(items[position].quantity)).toString()}',
                                                       overflow: TextOverflow
                                                           .ellipsis,
                                                       maxLines: 1,
                                                       style: mediumText,
                                                       textAlign:
                                                       TextAlign.left,
                                                     ),
                                                   ),

                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  subject=="users"?type=="Sales Promoter"?Align(
                                                    alignment:
                                                    Alignment.topLeft,
                                                    child: Container(
                                                      child: Text(
                                                        'MOP: ₹ ' +

                                                            '${items[position].mop}',
                                                        style: smallText,
                                                        textAlign:
                                                        TextAlign.left,
                                                      ),
                                                    ),
                                                  ) : Container(
                                                    child: Text(
                                                      'Average Unit Price: ₹ ' +
                                                          '${items[position].current_price}',
                                                      style: smallText,
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ):

                                                  Align(
                                                    alignment:
                                                    Alignment.topLeft,
                                                    child: Container(
                                                      child: Text(
                                                        'MOP: ₹ ' +

                                                            '${items[position].mop}',
                                                        style: smallText,
                                                        textAlign:
                                                        TextAlign.left,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  /*Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Container(
                                                      child: Text(
                                                        'Stock: ' +
                                                            '${items[position].stock}',
                                                        style: smallText,
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    ),
                                                  ),*/

                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: <Widget>[
                                                        Container(
                                                          margin: EdgeInsets.only(right: 5),
                                                          height: 30,
                                                          width: MediaQuery.of(context).size.width * 0.18,
                                                          child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Theme(
                                                              data: Theme.of(context).copyWith(
                                                                cursorColor: Color(0xff9b56ff),
                                                                hintColor: Colors.transparent,
                                                              ),
                                                              child: TextFormField(
                                                                enabled: true,
                                                                initialValue: items[position].quantity,
                                                                maxLines: 1,
                                                                decoration: InputDecoration(
                                                                    focusedBorder: border,
                                                                    border: border,
                                                                    contentPadding: EdgeInsets.fromLTRB(10,5,5,0),
                                                                    disabledBorder: border,
                                                                    enabledBorder: border,

                                                                    filled: true,
                                                                    fillColor: Color(0xFFffffff),
                                                                    hintText: ''),
                                                                keyboardType: TextInputType.number,
                                                                cursorColor: Color(0xFF000000),
                                                                style: normalText,
                                                                textCapitalization: TextCapitalization.none,
                                                                validator: (value) {
                                                                  if (value.isEmpty) {
                                                                    return 'Please enter quantity';
                                                                  }
                                                                  return null;
                                                                },
                                                                onSaved: (String value) {
                                                                  _controllers[position]
                                                                      .text = value;
                                                                },
                                                                onChanged:
                                                                    (String value) {
                                                                  _controllers[position]
                                                                      .text = value;
                                                                  print(_controllers[
                                                                  position]
                                                                      .text);

                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 6,
                                                        ),
                                                        Align(
                                                          alignment: Alignment.center,
                                                          child: InkWell(
                                                            onTap: (){
                                                          //  if(int.parse(_controllers[position].text)<=int.parse(items[position].stock)) {
                                                              setState(() {
                                                                _loading = true;
                                                              });
                                                              db1.updateNote(
                                                                  ProductModal
                                                                      .fromMap({
                                                                    'id': items[position]
                                                                        .id,
                                                                    'product_id': items[position]
                                                                        .product_id,
                                                                    'category_id': items[position]
                                                                        .category_id,
                                                                    'sub_category_id': items[position]
                                                                        .sub_category_id,
                                                                    'sap_id': items[position]
                                                                        .sap_id,
                                                                    'product_name': items[position]
                                                                        .product_name,
                                                                    'model_no': items[position]
                                                                        .model_no,
                                                                    'current_price': items[position]
                                                                        .current_price,
                                                                    'mop': items[position]
                                                                        .mop,
                                                                    'image': items[position]
                                                                        .image,
                                                                    'quantity': _controllers[position]
                                                                        .text,
                                                                    'stock': items[position].stock,
                                                                    'mrp': items[position].mrp,
                                                                  }));

                                                              setState(() {
                                                                db1
                                                                    .getAllProducts()
                                                                    .then((
                                                                    notes) {
                                                                  setState(() {
                                                                    items
                                                                        .clear();
                                                                    notes
                                                                        .forEach((
                                                                        note) {
                                                                      items.add(
                                                                          ProductModal
                                                                              .fromMap(
                                                                              note));
                                                                    });
                                                                    _total=0;
                                                                    print(subject);
                                                                    for (int i = 0; i < items.length; i++) {
                                                                      if(subject=="users") {
                                                                        if(role=="Sales Promoter"){
                                                                          _total = _total + (int.parse(items[i].mop) *
                                                                              int.parse(items[i].quantity));
                                                                        }
                                                                        else{
                                                                          _total = _total + (int.parse(items[i].current_price) *
                                                                              int.parse(items[i].quantity));
                                                                        }

                                                                      }
                                                                      else{
                                                                        _total = _total + (int.parse(items[i].mop) *
                                                                            int.parse(items[i].quantity));
                                                                      }
                                                                    }
                                                                  });
                                                                });
                                                              });
                                                              setState(() {
                                                                _loading =
                                                                false;
                                                              });
                                                           /* }
                                                            else{
                                                              setState(() {
                                                                _loading =
                                                                false;
                                                              });
                                                              Fluttertoast.showToast(msg: 'Please enter quantity less than stock.');
                                                            }*/

                                                            },
                                                            child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                    vertical: 8, horizontal: 15),
                                                                margin: EdgeInsets.symmetric(
                                                                   horizontal: 10),
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(5),
                                                                    color: Color(0xff9b56ff)

                                                                ),
                                                                child:
                                                                Text(
                                                                  "UPDATE",
                                                                  // snapshot.data['cart_quantity'] > 0 ? 'Go to Basket' : 'Add to Basket',
                                                                  style: smallText2,
                                                                )

                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                  /*Container(
                                                    child: Text(
                                                      '${items[position].quantity}',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color:
                                                              Color(0xFF3a3a3b),
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),*/
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _total=0;
                                        print(subject);
                                        for (int i = 0; i < items.length; i++) {
                                          if(subject=="users") {
                                            if(role=="Sales Promoter"){
                                              _total = _total + (int.parse(items[i].mop) *
                                                  int.parse(items[i].quantity));
                                            }
                                            else{
                                              _total = _total + (int.parse(items[i].current_price) *
                                                  int.parse(items[i].quantity));
                                            }

                                          }
                                          else{
                                            _total = _total + (int.parse(items[i].mop) *
                                                int.parse(items[i].quantity));
                                          }

                                        }
                                        deleteProduct(
                                            context,
                                            items[position],
                                            position);
                                      });

                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(right: 0, top: 0),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(4)),
                                          color: Color(0xff9b56ff),),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    items.length!=0?Container(
                      padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: Text(
                                "TOTAL PRICE",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  // fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                            Divider(
                              height: 12,
                            ),
                              ListTile(
                                leading: Text("Total",style: mediumText,),
                                trailing: Text("\u20B9 " + _total.toString(),style: mediumText,),
                              ),
                          ],
                        ),
                      ),
                    ):Container(),
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

  void deleteProduct(
      BuildContext context, ProductModal modal, int position) async {
    db1.deleteProduct(modal.id).then((notes) {
      setState(() {
        items.removeAt(position);
      });
    });
  }



  void _createNewNote(BuildContext context) async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ProductList( )),
    );

    if (result == 'save') {
      db1.getAllProducts().then((notes) {
        setState(() {
          items.clear();
          notes.forEach((note) {
            items.add(ProductModal.fromMap(note));
          });
          _total=0;
          print(subject);
          for (int i = 0; i < items.length; i++) {
            if(subject=="users") {
              if(role=="Sales Promoter"){
                _total = _total + (int.parse(items[i].mop) *
                    int.parse(items[i].quantity));
              }
              else{
                _total = _total + (int.parse(items[i].current_price) *
                    int.parse(items[i].quantity));
              }

            }
            else{
              _total = _total + (int.parse(items[i].mop) *
                  int.parse(items[i].quantity));
            }
          }
        });
      });
    }
  }
}
