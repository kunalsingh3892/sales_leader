import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class OtpScreen extends StatefulWidget {
  final Object argument;
  const OtpScreen({Key key, this.argument}) : super(key: key);
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  var _mobile;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  String fcmToken="";
  String device_id,type;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      //  fcmSubscribe();

      setState(() {
        _saveDeviceToken();
      });

    }
    _mobile = data['mobile'];
    device_id = data['device_id'];
    type = data['type'];
  }
  _saveDeviceToken() async {
    // Get the current user
    String uid = 'jeffd23';
    // FirebaseUser user = await _auth.currentUser();


    fcmToken = await _fcm.getToken();

  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff9b56ff),
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
          child: ListView(
            padding: const EdgeInsets.only(top: 100, left: 30, right: 30),
            children: <Widget>[
              Container(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Verification Code',
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Please enter the one time password sent to $_mobile',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 50,bottom: 5),
                decoration: BoxDecoration(
                  //color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: VerificationCode(
                    textStyle: TextStyle(fontSize: 20.0, color: Colors.white),
                    keyboardType: TextInputType.number,
                    underlineColor: Colors.white ,
                    autofocus: false,
                    length: 4,

                    onCompleted: (String value) async {
                      setState(() {
                        _loading = true;
                      });
                      var response =await http.post(URL+"app_login",
                        body: {
                          "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
                          "mobile_no": _mobile,
                          "otp":value,
                          "device_id":device_id,
                          "type":type,
                          "devicetokenkey":fcmToken
                        },
                        headers: {
                          "Accept": "application/json",
                        },
                      );
                      print({
                        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
                        "mobile_no": _mobile,
                        "otp":value,
                        "device_id":device_id,
                        "type":type,
                        "devicetokenkey":fcmToken
                      });
                      var data = json.decode(response.body);
                      print(data);
                      if (response.statusCode == 200) {
                        setState(() {
                          _loading = false;
                        });


                        if (data['success'] == true) {
                          setState(() {
                            _loading = false;
                          });
                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          prefs.setBool('logged_in', true);

                          prefs.setInt('user_id', data['id']);
                          prefs.setString('dept', data['Department']);
                          prefs.setString('role', data['role']);
                          prefs.setString('name', data['name']);
                          prefs.setString('type', data['type']);
                          if(data['local_da_price']!=null) {
                            prefs.setString(
                                'local_da_price', data['local_da_price']);
                          }
                          else{
                            prefs.setString(
                                'local_da_price', "");
                          }
                          prefs.setString(
                              'mobile_number', data['mobile_number']);
                          prefs.setString('sap_id', data['SAP_ID']);
                          if(data['type']=="users") {
                            Navigator.pushReplacementNamed(
                                context, '/dashboard');
                          }
                          else{
                            Navigator.pushReplacementNamed(
                                context, '/home-screen');
                          }
                        }
                        else{
                          setState(() {
                            _loading = false;
                          });
                          Fluttertoast.showToast(msg: data['message']);
                        }
                      }
                      else{
                        setState(() {
                          _loading = false;
                        });
                        Fluttertoast.showToast(msg: data['message']);
                      }
                    },
                    onEditing: (bool value) {},
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () async{
                      setState(() {
                        _loading = true;
                      });
                      var response = await http.post(URL+"app_login",
                          body: {
                            "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
                            "mobile_no": _mobile,
                            "otp":"",
                          },
                          headers: {
                            "Accept": "application/json",
                          });
                      if (response.statusCode == 200) {
                        setState(() {
                          _loading = false;
                        });
                        var data = json.decode(response.body);
                      //  Fluttertoast.showToast(msg: 'OTP: ' + data['OTP'].toString());
                        print(data);
                      }
                      else{
                        setState(() {
                          _loading = false;
                        });
                        Fluttertoast.showToast(msg: 'Error');
                      }
                    },
                    child: Text(
                      'Resend OTP',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0, color: Colors.white,decoration: TextDecoration.underline,),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
