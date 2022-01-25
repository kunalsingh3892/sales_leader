import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:badges/badges.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:glen_lms/components/category.dart';
import 'package:glen_lms/components/heading.dart';

import 'package:glen_lms/components/profile_image.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

import '../constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _userId, sapId, dept, role;
  String _name = "";
  String type = "";
  String total_pending_tour = "";
  String total_pending_expense = "";
  String total_lead_follow_assigned = "";
  String _mobile_number;


  final FirebaseMessaging _fcm = FirebaseMessaging();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    _getUser();
    initialize();
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
      else{
        setState(() {
          total_lead_follow_assigned=data['total_lead_follow_assigned'].toString();
          prefs.setString('total_lead_follow_assigned', data['total_lead_follow_assigned'].toString());
          prefs.setString('total_pending_tour', data['total_pending_tour'].toString());
          prefs.setString('total_pending_expense', data['total_pending_expense'].toString());
        });

      }

      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }
  void initialize() async {
    AndroidInitializationSettings android = new AndroidInitializationSettings(
        '@mipmap/ic_launcher'); //@mipmap/ic_launcher
    IOSInitializationSettings ios = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initSettings = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initSettings);
    _fcm.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    _fcm.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    showNotification();
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  showNotification() async {
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    var androidPlatformChannelSpecifies = new AndroidNotificationDetails(
        "CA", "Courier Alliance", "Courier Alliance",
        importance: Importance.Max,
        groupKey: 'iex',
        groupAlertBehavior: GroupAlertBehavior.All,
        priority: Priority.High,
        color: Colors.blue,
        autoCancel: true,
        enableLights: true,
        vibrationPattern: vibrationPattern,
        styleInformation: BigTextStyleInformation(''),
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        icon: '@mipmap/ic_launcher',
        playSound: true,
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
       );
    var iOSPlatformChannelSpecifics =
    new IOSNotificationDetails(presentAlert: true, presentSound: true);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifies, iOSPlatformChannelSpecifics);
    _fcm.configure(
      onLaunch: (Map<String, dynamic> msg)async {
        print(" onLaunch called ${(msg)}");
        Wakelock.enable();
        String val = '';
        String val2 = '';
        val = msg['notification']['title'];
        val2 = msg['notification']['body'];
        await flutterLocalNotificationsPlugin.show(
            0, val, val2, platformChannelSpecifics,
            payload: 'CA');
      },
      onResume: (Map<String, dynamic> msg) async{
        print(" onResume called ${(msg)}");
        Wakelock.enable();
        String val = '';
        String val2 = '';

        val = msg['notification']['title'];
        val2 = msg['notification']['body'];
        await flutterLocalNotificationsPlugin.show(
            0, val, val2, platformChannelSpecifics,
            payload: 'CA');
      },
      onMessage: (Map<String, dynamic> msg) async {
        print(" onMessage called ${msg}");
        String val = '';
        Wakelock.enable();
        String val2 = '';
        val = msg['notification']['title'];
        val2 = msg['notification']['body'];
        await flutterLocalNotificationsPlugin.show(
            0, val, val2, platformChannelSpecifics,
            payload: 'CA');
      },

    );
  }
  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      dept = prefs.getString('dept').toString();
      role = prefs.getString('role').toString();
      sapId = prefs.getString('sap_id').toString();
      _name = prefs.getString('name');
      type = prefs.getString('type');
      _mobile_number = prefs.getString('mobile_number');
    //  if(type!="users") {
        _userCheck();
     // }
    });
  }

  Widget _buildAccountDetail() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
          left: 15.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _name.toUpperCase(),
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'SAP ID : ',
                  style: TextStyle(
                    fontSize: 17.0,
                    color: primaryColorLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 3.0,
                ),
                Text(
                  sapId.toString(),
                  style: TextStyle(
                    fontSize: 20.0,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),

              ],
            ),
            Text(
              _mobile_number.toString(),
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topInfo(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(
       // horizontal: deviceSize.width * 0.03,
        vertical: deviceSize.height * 0.02,
      ),
      child: Container(
        margin: EdgeInsets.only(left:deviceSize.width * 0.1, ),
        alignment: Alignment.centerLeft,
        height: deviceSize.height * 0.15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ProfileImage(),
                _buildAccountDetail(),
              ],
            ),
           /* Container(
              height: 8.0,
              width: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
            ),*/
          ],
        ),
      ),
    );
  }
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
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              buildUserInfo(context),
              buildDrawerItem(),
            ],
          ),
        ),
        appBar: buildAppBar(),
        body: Stack(
          children: <Widget>[
            Container(
              color: primaryColor,
              height: deviceSize.height * 0.1,
            ),
            Container(

              margin: EdgeInsets.symmetric(
                horizontal: deviceSize.width * 0.03,
              ),
              child: Column(
                children: <Widget>[
                  _topInfo(context),
                 type=="users"? Flexible(
                    fit: FlexFit.tight,
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            Heading(
                              title: 'would you like to?',
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                // primary: true,
                                children: categories
                                    .map((item) => InkWell(
                                  onTap: (){
                                    if(item['title']=="Leads"){
                                      if(role=="Sales Executive"){
                                        Navigator.pushNamed(
                                          context,
                                          '/my-leads',
                                          arguments: <String, String>{
                                            'member_id':"",

                                          },
                                        );
                                      }
                                      else if(role=="Sales Promoter"){
                                        Navigator.pushNamed(
                                          context,
                                          '/my-leads',
                                          arguments: <String, String>{
                                            'member_id':"",

                                          },
                                        );
                                      }
                                      else{
                                        Navigator.pushNamed(
                                          context,
                                          '/sub-dashboard',
                                          arguments: <String, String>{
                                            'image': item['image'],
                                            'sub_name': item['title'].toString(),
                                            'semi_name':'Leads'

                                          },
                                        );
                                      }

                                   }
                                   else if(item['title']=='Visits'){
                                      if(role=="Sales Executive"){
                                        Navigator.pushNamed(
                                          context,
                                          '/my-visits',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );
                                      }
                                      else if(role=="Sales Promoter"){
                                        Navigator.pushNamed(
                                          context,
                                          '/my-visits',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );
                                      }
                                      else{
                                        Navigator.pushNamed(
                                          context,
                                          '/sub-dashboard',
                                          arguments: <String, String>{
                                            'image': item['image'],
                                            'sub_name': item['title'].toString(),
                                            'semi_name':'Visits'

                                          },
                                        );

                                      }

                                   }
                                    else if(item['title']=='My Dealer/Dist.'){
                                      if(role=="Sales Executive"){
                                        Navigator.pushNamed(
                                          context,
                                          '/my-dealers',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );

                                      }
                                     else if(role=="Sales Promoter"){
                                        Navigator.pushNamed(
                                          context,
                                          '/my-dealers',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );

                                      }
                                      else{
                                        Navigator.pushNamed(
                                          context,
                                          '/sub-dashboard',
                                          arguments: <String, String>{
                                            'image': item['image'],
                                            'sub_name': "Dealers/Distributors",
                                            'semi_name':'Dealers/Distributors'

                                          },
                                        );
                                      }

                                    }
                                   else if(item['title']=='Tours'){
                                      if(role=="Sales Executive"){
                                        Navigator.pushNamed(
                                          context,
                                          '/tours',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );

                                      }
                                     else if(role=="Sales Promoter"){
                                        Navigator.pushNamed(
                                          context,
                                          '/tours',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );

                                      }
                                      else{

                                        Navigator.pushNamed(
                                          context,
                                          '/sub-dashboard',
                                          arguments: <String, String>{
                                            'image': item['image'],
                                            'sub_name': item['title'].toString(),
                                            'semi_name':'Tours'

                                          },
                                        );
                                      }

                                   }
                                 /*  else if(item['title']=='My Attendance'){
                                     Navigator.pushNamed(context, '/my-attendance');
                                   }*/
                                   else if(item['title']=='Add Contact'){
                                     Navigator.pushNamed(context, '/dealer-list');
                                   }
                                   else if(item['title']=='Company Promotion'){
                                     Navigator.pushNamed(context, '/glen-promotionlist');
                                   }
                                   else if(item['title']=='Competition Promotion'){
                                     Navigator.pushNamed(context, '/competitor-promotionlist');
                                   }
                                    else if(item['title']=='Attendance'){
                                      Navigator.pushNamed(context, '/da-list');
                                    }
                                    else if(item['title']=='Orders'){
                                      if(role=="Sales Executive"){
                                        Navigator.pushNamed(
                                          context,
                                          '/order-list',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );
                                      }
                                      else if(role=="Sales Promoter"){
                                        Navigator.pushNamed(
                                          context,
                                          '/order-list',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );
                                      }
                                      else{
                                        Navigator.pushNamed(
                                          context,
                                          '/sub-dashboard',
                                          arguments: <String, String>{
                                            'image': item['image'],
                                            'sub_name': item['title'].toString(),
                                            'semi_name':'Orders'

                                          },
                                        );
                                      }

                                    }
                                    else if(item['title']=='Sales Target'){
                                      if(role=="Sales Executive"){
                                        Navigator.pushNamed(
                                          context,
                                          '/view-salestarget',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );

                                      }
                                      else if(role=="Sales Promoter"){
                                        Navigator.pushNamed(
                                          context,
                                          '/view-salestarget',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );

                                      }
                                      else{
                                        Navigator.pushNamed(
                                          context,
                                          '/sub-dashboard',
                                          arguments: <String, String>{
                                            'image': item['image'],
                                            'sub_name': item['title'].toString(),
                                            'semi_name':'Sales Target'

                                          },
                                        );
                                      }

                                    }
                                    else if(item['title']=='Target Achievement'){
                                      if(role=="Sales Executive"){
                                        Navigator.pushNamed(
                                          context,
                                          '/target-achievement',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );

                                      }
                                      else if(role=="Sales Promoter"){
                                        Navigator.pushNamed(
                                          context,
                                          '/target-achievement',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );

                                      }
                                      else{
                                        Navigator.pushNamed(
                                          context,
                                          '/sub-dashboard',
                                          arguments: <String, String>{
                                            'image': item['image'],
                                            'sub_name': item['title'].toString(),
                                            'semi_name':'Target Achievement'

                                          },
                                        );
                                      }

                                    }


                                   else if(item['title']=='Expense Reimbursements'){
                                      if(role=="Sales Executive"){
                                        Navigator.pushNamed(
                                          context,
                                          '/expense',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );

                                      }
                                     else if(role=="Sales Promoter"){
                                        Navigator.pushNamed(
                                          context,
                                          '/expense',
                                          arguments: <String, String>{
                                            'member_id': "",

                                          },
                                        );

                                      }
                                      else{
                                        Navigator.pushNamed(
                                          context,
                                          '/sub-dashboard',
                                          arguments: <String, String>{
                                            'image': item['image'],
                                            'sub_name': item['title'].toString(),
                                            'semi_name':'Expense'

                                          },
                                        );

                                      }

                                   }

                                  },
                                      child:item['title']=="Leads"? Badge(
                                        padding: EdgeInsets.all(7),
                                        badgeColor: Colors.red,
                                        position: BadgePosition.topEnd(top: 1, end: 15),
                                        animationDuration: Duration(milliseconds: 300),
                                        animationType: BadgeAnimationType.fade,
                                        badgeContent: Text(total_lead_follow_assigned.toString(),style: TextStyle(color: Colors.white),),
                                        child: Category(
                                  title: item['title'],
                                  image: item['image'],
                                ),
                                      ):Category(
                                        title: item['title'],
                                        image: item['image'],
                                      ),
                                    ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ):Flexible(
                   fit: FlexFit.tight,
                   child: ListView(
                     physics: BouncingScrollPhysics(),
                     shrinkWrap: true,
                     children: <Widget>[
                       Column(
                         mainAxisSize: MainAxisSize.min,
                         children: <Widget>[
                           SizedBox(
                             height: 10.0,
                           ),
                           Heading(
                             title: 'would you like to?',
                           ),
                           SizedBox(
                             height: 25.0,
                           ),
                           Flexible(
                             fit: FlexFit.loose,
                             child: GridView.count(
                               crossAxisCount: 3,
                               shrinkWrap: true,
                               physics: NeverScrollableScrollPhysics(),
                               // primary: true,
                               children: categories1
                                   .map((item) => InkWell(
                                 onTap: (){

                                       Navigator.pushNamed(
                                         context,
                                         '/my-leads',
                                         arguments: <String, String>{
                                           'member_id':"",

                                         },
                                       );

                                 },
                                 child: Badge(
                                   padding: EdgeInsets.all(7),
                                   badgeColor: Colors.red,
                                   position: BadgePosition.topEnd(top: 0, end: 15),
                                   animationDuration: Duration(milliseconds: 300),
                                   animationType: BadgeAnimationType.slide,
                                   badgeContent: Text(total_lead_follow_assigned,style: TextStyle(color: Colors.white),),
                                   child: Category(
                                     title: item['title'],
                                     image: item['image'],
                                   ),
                                 ),
                               ))
                                   .toList(),
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                 )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem(){
    if(type=="users"){
      return Flexible(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (Draw item in drawerItems)
                    InkWell(
                      onTap: (){
                        /*if(item.title=="Orders"){
                        Navigator.pop(context);

                        Navigator.pushNamed(
                          context,
                          '/order-list',
                          arguments: <String, String>{
                            'member_id': "",

                          },
                        );
                      }
                      else
                      if(item.title=="Sales Targets"){
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/view-salestarget',
                          arguments: <String, String>{
                            'member_id': "",

                          },
                        );
                      }*/
                        /*else
                      if(item.title=="Expensive Reimbursements"){
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/expense',
                          arguments: <String, String>{
                            'member_id': "",

                          },
                        );
                      }*/

                        if(item.title=="Company Promotion"){
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/glen-promotionlist');
                        }
                        else
                        if(item.title=="Competition Promotion"){
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/competitor-promotionlist');
                        }
                      },
                      child: ListTile(
                        leading: Image(
                          image: AssetImage(item.icon),
                          height: 20.0,
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                              color: Color(0xff9b56ff)
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              InkWell(
                onTap: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  //prefs.remove('logged_in');
                  prefs.clear();
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: ListTile(
                  leading: Icon(
                    Icons.lock,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    else{
      return Flexible(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              InkWell(
                onTap: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  //prefs.remove('logged_in');
                  prefs.clear();
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: ListTile(
                  leading: Icon(
                    Icons.lock,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

  }

  buildUserInfo(context) => Container(
        color: drawerColoPrimary,
        //height: deviceSize.height * 0.3,
        padding: EdgeInsets.only(bottom: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
              },
              leading: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
           /* Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Hlo!',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  _name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),*/
            SizedBox(
              height: 15.0,
            ),
            ProfileImage(
              color: Colors.white,
              height: 70.0,
              width: 70.0,
            ),
            SizedBox(
              height: 15.0,
            ),
            Text(
              _name,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            )
          ],
        ),
      );

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0.0,
      // centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'Welcome!',
            
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              _name.toUpperCase(),
              
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
       actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.notifications),

          onPressed: () {
           Navigator.pushNamed(context, '/notification-list');
          },
        ),
      ],
    );
  }
}
