import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glen_lms/components/bezierContainer.dart';
import 'package:glen_lms/components/general.dart';

import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';

import '../constants.dart';
class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();
  bool _loading = false;
  String _deviceId="";
  final FirebaseMessaging _fcm = FirebaseMessaging();
  Future id;
  String _dropdownValue = 'Company User';
  String type = "users";
  bool show=true;
  String appName,packageName,version,buildNumber;
  String fcmToken="";
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      print(buildNumber);
      print(version);
    id= _getId();

  });

  }

  Future<void> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      setState(() {
        _deviceId =  iosDeviceInfo.identifierForVendor; // unique ID on iOS
      });

    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      setState(() {
        _deviceId =  androidDeviceInfo.androidId; // unique ID on Android
      });

      print(_deviceId.toString());
    }
  }

  Widget _entryField(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              controller: mobileController,
              maxLength: 10,
              keyboardType: TextInputType.number,
              cursorColor: Color(0xff9b56ff),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter 10 digit mobile number';
                } else if (value.length < 10) {
                  return 'Please enter 10 digit mobile number';
                } else if (value.length > 10) {
                  return 'Please enter 10 digit mobile number';
                }
                return null;
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: "",
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }
  Widget _deviceIdField(String title) {
    return FutureBuilder(
        future: id,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _deviceId));
                      Fluttertoast.showToast(msg: 'Device Id Copied');
                    },
                    child: TextFormField(
                        initialValue: _deviceId.toString(),
                        keyboardType: TextInputType.text,
                        cursorColor: Color(0xff9b56ff),
                        textCapitalization: TextCapitalization.sentences,
                        enabled: false,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            suffixIcon: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(Icons.copy, size: 20, color: Color(
                                    0xff9b56ff),),
                              ),
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 20,
                              minHeight: 15,
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true)),
                  )
                ],
              ),
            );
          }
          else {
            return Center(child: Container(child: CircularProgressIndicator()));
          }
        });


  }
  Widget _dropDown(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),

         Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 50,
          color: Color(0xfff3f3f4),
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.all(8),

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
                      if (_dropdownValue == "Company User") {
                        setState(() {
                          type = "users";
                          show=true;
                        });
                      } else if (_dropdownValue == "OCP") {
                        setState(() {
                          type = "dealer";
                          show=false;
                        });
                      }
                    });
                  },
                  items: <String>[
                    'Company User',
                    'OCP',
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
      )
        ],
      ),
    );
  }
  _saveDeviceToken() async {
    // Get the current user
    String uid = 'jeffd23';
    // FirebaseUser user = await _auth.currentUser();


    fcmToken = await _fcm.getToken();

  }
  Widget _submitButton() {
    return InkWell(
      onTap: () async {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            setState(() {
              _loading = true;
            });
            var response = await http.post(URL+"app_login",
              body: {
                "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
                "mobile_no": mobileController.text,
                "otp":"",
                "device_id":_deviceId,
                "type":type,
                "devicetokenkey":fcmToken
              },
              headers: {
                "Accept": "application/json",

              },
            );
            print(jsonEncode({
              "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
              "mobile_no": mobileController.text,
              "otp":"",
              "device_id":_deviceId,
              "type":type,
              "devicetokenkey":fcmToken
            }));
            var data = json.decode(response.body);
            print(data);
            if (response.statusCode == 200) {
              setState(() {
                _loading = false;
              });

              print(data);
              Fluttertoast.showToast(msg: 'OTP: ' + data['OTP'].toString());
              Navigator.pushNamed(
                context,
                '/otp-screen',
                arguments: <String, String>{
                  'mobile': mobileController.text,
                  'device_id': _deviceId,
                  'type': type,
                },

              );
             print(data);

            }
            else{
              setState(() {
                _loading = false;
              });
              showAlertDialog(context, ALERT_DIALOG_TITLE, data['message']);
            }
          }

      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
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
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return  SizedBox(
      width: 110,
      height: 110,
      child: Image.asset("assets/images/glen_logo.png"),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _dropDown("Select User"),
        _entryField("Mobile No."),
        show?_deviceIdField("Device Id"):Container()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Container(
            height: height,
            child: Stack(
              children: <Widget>[
                Positioned(
                    top: -height * .20,
                    right: -MediaQuery.of(context).size.width * .4,
                    child: BezierContainer()),
                Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: height * .20),
                          _title(),
                          SizedBox(height: 40),
                          Text(
                           "Login",
                            style:
                            Theme.of(context).textTheme.headline4.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Access to our dashboard",
                            style: Theme.of(context).textTheme.headline6.copyWith( color: Colors.grey.shade400,),
                          ),
                          SizedBox(height: 40),
                          _emailPasswordWidget(),
                          SizedBox(height: 20),
                          _submitButton(),
                         /* Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.centerRight,
                            child: Text('Forgot Password ?',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                          ),*/
                        //  _createAccountLabel(),
                        ],
                      ),
                    ),
                  ),
                ),
               /* Positioned(top: 40, left: 0, child: _backButton()),*/
              ],
            ),
          ),
        ));
  }
}