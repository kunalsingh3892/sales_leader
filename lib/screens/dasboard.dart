import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glen_lms/screens/dashboard_screens/my_attendance.dart';
import 'package:glen_lms/screens/dashboard_screens/my_tours.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'dashboard_screens/my_leads.dart';
import 'dashboard_screens/profile_screen.dart';
import 'dashboard_screens/tours.dart';
import 'home_screen.dart';

class Dashboard extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Dashboard> {
  int _currentIndex = 0;
  var flag;
  bool checkValue;
  var _userId="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUser();

  }
  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    //  _userCheck();
    });
  }

  Future _userCheck() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
    };
    var response = await http.post(URL+"dashboard",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
        "user_id":_userId
      },
      headers: headers,

    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      SharedPreferences prefs =
      await SharedPreferences.getInstance();
      if(data['user_login']!=true){

        prefs.clear();
        Navigator.pushReplacementNamed(context, '/login');
      }



      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }
  final List<Widget> _children = [
    HomePage(),
    MyLeads(argument: {"member_id": ""}),
    AllTours(argument: {"member_id": ""}),
    ProfilePage()

  ];
  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text("Are you sure",),
        content: new Text("Do you want to exit an App"),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text("No",style: TextStyle(  color: Color(0xff9b56ff),),),
          ),
          new FlatButton(
            onPressed: () {

              exit(0);

            },
            child: new Text("Yes",style: TextStyle(  color: Color(0xff9b56ff))),
          ),
        ],
      ),
    )) ?? false;
  }
  final _selectedItemColor = Colors.white;
  final _unselectedItemColor = Color(0xff9b56ff);
  final _selectedBgColor = Color(0xff9b56ff);
  final _unselectedBgColor = Colors.white;
  Color _getBgColor(int index) =>
      _currentIndex == index ? _selectedBgColor : _unselectedBgColor;

  Color _getItemColor(int index) =>
      _currentIndex == index ? _selectedItemColor : _unselectedItemColor;
  Widget _buildIcon(String iconData, String text, int index) => Container(
    width: double.infinity,
    height: kBottomNavigationBarHeight,
    child: Material(
      color: _getBgColor(index),
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage(iconData),
              height: 20.0,
              color: _getItemColor(index),
            ),
            Text(text,
                style: TextStyle(fontSize: 12, color: _getItemColor(index))),
          ],
        ),
        onTap: () => onTabTapped(index),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _children[_currentIndex],

        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: _buildIcon("assets/images/home.png","Home", 0),
              title: SizedBox.shrink(),
            ),
            BottomNavigationBarItem(
              icon: _buildIcon("assets/images/leads.png", "Leads", 1),
              title: SizedBox.shrink(),
            ),
            BottomNavigationBarItem(
              icon: _buildIcon("assets/images/tours.png", "Tours", 2),
              title: SizedBox.shrink(),
            ),
            BottomNavigationBarItem(
              icon: _buildIcon("assets/images/user.png", "Profile", 3),
              title: SizedBox.shrink(),
            ),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: _selectedItemColor,
          unselectedItemColor: _unselectedItemColor,
        ),


      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
