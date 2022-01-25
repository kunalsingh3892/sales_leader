import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ProfilePage> {
  static final String path = "lib/src/pages/profile/profile8.dart";
  var user_id;
  String name="";
  String mobile_number="";
  String sap_id="";
  Future _profileData;

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getInt('user_id').toString();
     /* dept = prefs.getString('dept').toString();
      role = prefs.getString('role').toString();*/
      name = prefs.getString('name').toString();
      mobile_number = prefs.getString('mobile_number').toString();
      sap_id = prefs.getString('sap_id').toString();
   //   _profileData = _myProfileData();
    });
  }

/*  Future _myProfileData() async {
    var response =
    await http.get("https://learnbyfun.com/api/myprofile/" + api_token);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }*/

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  /*Widget _profileBuilder() {
    return FutureBuilder(
      future: _profileData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return  ListView(
            children: <Widget>[
              ProfileHeader(
                avatar:  CachedNetworkImageProvider(snapshot.data['image']),
                coverImage: CachedNetworkImageProvider(introIllus[0]),
                title: snapshot.data['name'],
                subtitle: snapshot.data['city'],
                actions: <Widget>[
                  MaterialButton(
                    color: Colors.white,
                    shape: CircleBorder(),
                    elevation: 0,
                    child: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                  )
                ],
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                      alignment: Alignment.topLeft,
                      child: Text(
                        AppTranslations.of(context).text("User Information") ,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Card(
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                ...ListTile.divideTiles(
                                  color: Color(0xFF20c7c8),
                                  tiles: [
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      leading: Icon(
                                        Icons.my_location,
                                        color: Color(0xFF20c7c8),
                                      ),
                                      title: Text(AppTranslations.of(context).text('Location')),
                                      subtitle: Text(
                                        snapshot.data['location'],
                                        style: TextStyle(
                                          color: Color(0xFF000000),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.email,
                                        color: Color(0xFF20c7c8),
                                      ),
                                      title: Text(AppTranslations.of(context).text('Email')),
                                      subtitle: Text(snapshot.data['email'],
                                          style: TextStyle(
                                            color: Color(0xFF000000),
                                            fontSize: 14,
                                          )),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.phone,
                                        color: Color(0xFF20c7c8),
                                      ),
                                      title: Text(AppTranslations.of(context).text('Phone')),
                                      subtitle: Text( snapshot.data['mobile'], style: TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 14,
                                      )),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.tag,
                                        color: Color(0xFF20c7c8),
                                      ),
                                      title: Text(AppTranslations.of(context).text('Tags')),
                                      subtitle: Text(
                                          snapshot.data['tags'],style: TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 14,
                                      )),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          );

        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf5f6fa),
      // extendBodyBehindAppBar: true,
      //  extendBody: true,
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          height: 100,
          color: Color(0xff9b56ff),
        ),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
                onPressed: () {
                  //Navigator.pushNamed(context, '/notifications');
                }),
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Colors.transparent,
      ),
      body:  Center(
        child: Container(
          child: ListView(
            children: <Widget>[
              ProfileHeader(
                avatar:  AssetImage('assets/images/profile.png'),
                title: name,
                subtitle: sap_id,
                actions: <Widget>[
                  /*MaterialButton(
                    color: Colors.white,
                    shape: CircleBorder(),
                    elevation: 0,
                    child: Icon(Icons.edit),
                  *//*  onPressed: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },*//*
                  )*/
                ],
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                      alignment: Alignment.topLeft,
                      child: Text(
                        "User Information" ,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Card(
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                ...ListTile.divideTiles(
                                  color: Color(0xff9b56ff),
                                  tiles: [
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      leading: Icon(
                                        Icons.phone_android,
                                        color: Color(0xff9b56ff),
                                      ),
                                      title: Text('Mobile No.'),
                                      subtitle: Text(
                                        mobile_number,
                                        style: TextStyle(
                                          color: Color(0xFF000000),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.perm_identity,
                                        color: Color(0xff9b56ff),
                                      ),
                                      title: Text('Sap Id'),
                                      subtitle: Text(sap_id,
                                          style: TextStyle(
                                            color: Color(0xFF000000),
                                            fontSize: 14,
                                          )),
                                    ),
//                                    ListTile(
//                                      leading: Icon(
//                                        Icons.phone,
//                                        color: Color(0xFF20c7c8),
//                                      ),
//                                      title: Text(AppTranslations.of(context).text('Phone')),
//                                      subtitle: Text( snapshot.data['mobile'], style: TextStyle(
//                                        color: Color(0xFF000000),
//                                        fontSize: 14,
//                                      )),
//                                    ),
//                                    ListTile(
//                                      leading: Icon(
//                                        Icons.tag,
//                                        color: Color(0xFF20c7c8),
//                                      ),
//                                      title: Text(AppTranslations.of(context).text('Tags')),
//                                      subtitle: Text(
//                                          snapshot.data['tags'],style: TextStyle(
//                                        color: Color(0xFF000000),
//                                        fontSize: 14,
//                                      )),
//                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ),
      ),

    );
  }
}


class ProfileHeader extends StatelessWidget {
  final ImageProvider<dynamic> avatar;
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const ProfileHeader(
      {Key key,
        @required this.avatar,
        @required this.title,
        this.subtitle,
        this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Ink(
          height: 0,
          decoration: BoxDecoration(
            color: Color(0xFFfe4c64).withOpacity(0.20),
          ),
        ),
        if (actions != null)
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.only(bottom: 0.0, right: 0.0),
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
          ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 30),
          child: Column(
            children: <Widget>[
              Avatar(
                image: avatar,
                radius: 40,
                backgroundColor: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 4.0,
              ),
              Text(
                title,
               // style: Theme.of(context).textTheme.title,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5.0),
                Text(
                  subtitle,
                 // style: Theme.of(context).textTheme.subtitle,
                ),
              ]
            ],
          ),
        )
      ],
    );
  }
}

class Avatar extends StatelessWidget {
  final ImageProvider<dynamic> image;
  final Color borderColor;
  final Color backgroundColor;
  final double radius;
  final double borderWidth;

  const Avatar(
      {Key key,
        @required this.image,
        this.borderColor = Colors.blueAccent,
        this.backgroundColor,
        this.radius = 30,
        this.borderWidth = 5})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius + borderWidth,
      backgroundColor: borderColor,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor != null
            ? backgroundColor
            : Theme.of(context).primaryColor,
        child: CircleAvatar(
          radius: radius - borderWidth,
          backgroundImage: image,
        ),
      ),
    );
  }
}
