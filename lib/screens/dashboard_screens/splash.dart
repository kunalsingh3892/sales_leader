import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glen_lms/components/bezierContainer.dart';

import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:store_redirect/store_redirect.dart';

import '../../constants.dart';
import '../dasboard.dart';
import '../home_screen.dart';
import '../login.dart';


class SplashScreen extends StatefulWidget {
  final Color backgroundColor = Colors.white;
  final TextStyle styleTextUnderTheLoader = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loggedIn = false;
  final splashDelay = 1;

  String user_type="";
  String appName,packageName,version,buildNumber;
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;

      print(appName);
      print(packageName);
      print(version);
      print(buildNumber);

    });
  //  _versionCheck();
    _checkLoggedIn();
    _loadWidget();
  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => homeOrLog()));
  }
  Widget homeOrLog() {
    if(this._loggedIn){
      if(user_type=="users"){
        return Dashboard();
      }
      else{
        return HomePage();
      }

    }
    else{
      return LoginPage();
    }
  }

  _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _isLoggedIn = prefs.getBool('logged_in');
    String userType = prefs.getString('type');
    if (_isLoggedIn == true) {
      setState(() {
        _loggedIn = _isLoggedIn;
        user_type=userType;
      });
    }
    else{
      setState(() {
        _loggedIn = false;


      });
    }

  }
  Future _versionCheck() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
    };
    var response = await http.post(URL+"getversion",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM"
      },
      headers: headers,

    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);

      if(int.parse(data['GetVersion']['Android_version'])<int.parse(buildNumber)){


      }
      else if(int.parse(data['GetVersion']['Android_version'])==int.parse(buildNumber)){
        _showCompulsoryUpdateDialog(
          context,
          "Please update the app to continue to version ${data['GetVersion']['Android_version'] ?? ""}",
        );
      }
      else{
        _showCompulsoryUpdateDialog(
          context,
          "Please update the app to continue to version ${data['GetVersion']['Android_version'] ?? ""}",
        );
      }

      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }
  _showCompulsoryUpdateDialog(context, String message) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "App Update Available";
        String btnLabel = "Update Now";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                btnLabel,
              ),
              isDefaultAction: true,
              onPressed: _onUpdateNowClicked,
            ),
          ],
        )
            : new AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontSize: 22),
          ),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: _onUpdateNowClicked,
            ),
          ],
        );
      },
    );
  }

  _onUpdateNowClicked() {
    StoreRedirect.redirect(
        androidAppId: packageName,
        iOSAppId: packageName);
  }
  Widget _title() {
    return  SizedBox(
      width: 110,
      height: 110,
      child: Image.asset("assets/images/glen_logo.png"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body:Stack(
          children: <Widget>[
            Positioned(
                top: -height * .20,
                right: -MediaQuery.of(context).size.width * .4,
                child: BezierContainer()),
            Center(
          child: Container(

             child: _title(),


    ),
        ),
          ]
      ));
  }
}