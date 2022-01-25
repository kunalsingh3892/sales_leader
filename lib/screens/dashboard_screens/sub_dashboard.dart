import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glen_lms/components/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubHomePage extends StatefulWidget {
  final Object argument;

  const SubHomePage({Key key, this.argument}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<SubHomePage> {
  var _userId;
  var image;
  var sub_name;
  var semi_name;
  String total_pending_tour = "";
  String total_pending_expense = "";

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    image = data['image'];
    sub_name = data['sub_name'];
    semi_name = data['semi_name'];
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      total_pending_tour = prefs.getString('total_pending_tour').toString();
      total_pending_expense =
          prefs.getString('total_pending_expense').toString();
      print(_userId.toString());
    });
  }

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
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.notifications,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: buildAppBar(),
        body: Stack(
          children: <Widget>[
            ClipPath(
              clipper: WaveClipperTwo(),
              child: Container(
                decoration: BoxDecoration(color: Color(0xff9b56ff)),
                height: 200,
              ),
            ),
            CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 38.0),
                    child: Text(
                      "Select a category ",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildCategoryItem(context),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildCategoryItem(BuildContext context) {
    if (sub_name == "Tours") {
      return Column(children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: MaterialButton(
              elevation: 1.0,
              highlightElevation: 1.0,
              onPressed: () {
                if (sub_name == "Leads") {
                  Navigator.pushNamed(
                    context,
                    '/my-leads',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Visits') {
                  Navigator.pushNamed(
                    context,
                    '/my-visits',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Dealers/Distributors') {
                  Navigator.pushNamed(
                    context,
                    '/my-dealers',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Tours') {
                  Navigator.pushNamed(
                    context,
                    '/tours',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Expense Reimbursements') {
                  Navigator.pushNamed(
                    context,
                    '/expense',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Orders') {
                  Navigator.pushNamed(
                    context,
                    '/order-list',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Sales Target') {
                  Navigator.pushNamed(
                    context,
                    '/view-salestarget',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              textColor: Color(0xff9b56ff),
              child: Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          image,
                          color: Color(0xff9b56ff),
                        )),
                    SizedBox(height: 10.0),
                    Text(
                      "My " + sub_name,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: MaterialButton(
              elevation: 1.0,
              highlightElevation: 1.0,
              onPressed: () {
                if (sub_name == "Leads") {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Visits') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Dealers/Distributors') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Tours') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Expense Reimbursements') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Orders') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Sales Target') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              textColor: Color(0xff9b56ff),
              child: Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          "assets/images/people.png",
                        )),
                    SizedBox(height: 10.0),
                    Text(
                      "My Teams " + semi_name,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
        SizedBox(
          height: 10,
        ),
        Row(children: <Widget>[
          Expanded(
              child: Badge(
            padding: EdgeInsets.all(8),
            badgeColor: Colors.red,
            position: BadgePosition.topEnd(top: 1, end: 20),
            animationDuration: Duration(milliseconds: 300),
            animationType: BadgeAnimationType.fade,
            badgeContent: Text(
              total_pending_tour.toString(),
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            child: MaterialButton(
              elevation: 1.0,
              highlightElevation: 1.0,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/pending-for-approval-tour',
                  arguments: <String, String>{
                    'member_id': "",
                  },
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              textColor: Color(0xff9b56ff),
              child: Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          "assets/images/pending_tours.png",
                          color: Color(0xff9b56ff),
                        )),
                    SizedBox(height: 10.0),
                    Text(
                      "Pending for Approval",
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          )),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: MaterialButton(
              elevation: 1.0,
              highlightElevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              textColor: Color(0xff9b56ff),
              child: Container(
                height: 150,
              ),
            ),
          ),
        ]),
      ]);
    } else if (sub_name == "Expense Reimbursements") {
      return Column(children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: MaterialButton(
              elevation: 1.0,
              highlightElevation: 1.0,
              onPressed: () {
                if (sub_name == "Leads") {
                  Navigator.pushNamed(
                    context,
                    '/my-leads',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Visits') {
                  Navigator.pushNamed(
                    context,
                    '/my-visits',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Dealers/Distributors') {
                  Navigator.pushNamed(
                    context,
                    '/my-dealers',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Tours') {
                  Navigator.pushNamed(
                    context,
                    '/tours',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Expense Reimbursements') {
                  Navigator.pushNamed(
                    context,
                    '/expense',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Orders') {
                  Navigator.pushNamed(
                    context,
                    '/order-list',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                } else if (sub_name == 'Sales Target') {
                  Navigator.pushNamed(
                    context,
                    '/view-salestarget',
                    arguments: <String, String>{
                      'member_id': "",
                    },
                  );
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              textColor: Color(0xff9b56ff),
              child: Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(image, color: Color(0xff9b56ff))),
                    SizedBox(height: 10.0),
                    Text(
                      "My " + sub_name,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: MaterialButton(
              elevation: 1.0,
              highlightElevation: 1.0,
              onPressed: () {
                if (sub_name == "Leads") {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Visits') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Dealers/Distributors') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Tours') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Expense Reimbursements') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Orders') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                } else if (sub_name == 'Sales Target') {
                  Navigator.pushNamed(
                    context,
                    '/tree-page',
                    arguments: <String, String>{
                      'sub_name': sub_name,
                    },
                  );
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              textColor: Color(0xff9b56ff),
              child: Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          "assets/images/people.png",
                        )),
                    SizedBox(height: 10.0),
                    Text(
                      "My Teams " + semi_name,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
        SizedBox(
          height: 10,
        ),
        Row(children: <Widget>[
          Expanded(
              child: Badge(
            padding: EdgeInsets.all(8),
            badgeColor: Colors.red,
            position: BadgePosition.topEnd(top: 1, end: 20),
            animationDuration: Duration(milliseconds: 300),
            animationType: BadgeAnimationType.fade,
            badgeContent: Text(
              total_pending_expense.toString(),
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            child: MaterialButton(
              elevation: 1.0,
              highlightElevation: 1.0,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/pending-tour-expense',
                  arguments: <String, String>{
                    'member_id': "",
                  },
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              textColor: Color(0xff9b56ff),
              child: Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          "assets/images/group.png",
                          color: Color(0xff9b56ff),
                        )),
                    SizedBox(height: 10.0),
                    Text(
                      "Pending for Approval",
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          )),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: MaterialButton(
              elevation: 1.0,
              highlightElevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              textColor: Color(0xff9b56ff),
              child: Container(
                height: 150,
              ),
            ),
          ),
        ]),
      ]);
    } else {
      return Row(children: <Widget>[
        Expanded(
          child: MaterialButton(
            elevation: 1.0,
            highlightElevation: 1.0,
            onPressed: () {
              if (sub_name == "Leads") {
                Navigator.pushNamed(
                  context,
                  '/my-leads',
                  arguments: <String, String>{
                    'member_id': "",
                  },
                );
              } else if (sub_name == 'Visits') {
                Navigator.pushNamed(
                  context,
                  '/my-visits',
                  arguments: <String, String>{
                    'member_id': "",
                  },
                );
              } else if (sub_name == 'Dealers/Distributors') {
                Navigator.pushNamed(
                  context,
                  '/my-dealers',
                  arguments: <String, String>{
                    'member_id': "",
                  },
                );
              } else if (sub_name == 'Tours') {
                Navigator.pushNamed(
                  context,
                  '/tours',
                  arguments: <String, String>{
                    'member_id': "",
                  },
                );
              } else if (sub_name == 'Expense Reimbursements') {
                Navigator.pushNamed(
                  context,
                  '/expense',
                  arguments: <String, String>{
                    'member_id': "",
                  },
                );
              } else if (sub_name == 'Orders') {
                Navigator.pushNamed(
                  context,
                  '/order-list',
                  arguments: <String, String>{
                    'member_id': "",
                  },
                );
              } else if (sub_name == 'Sales Target') {
                Navigator.pushNamed(
                  context,
                  '/view-salestarget',
                  arguments: <String, String>{
                    'member_id': "",
                  },
                );
              } else if (sub_name == 'Target Achievement') {
                //Fluttertoast.showToast(msg: "Under Construction");
                Navigator.pushNamed(
                  context,
                  '/target-achievement',
                  arguments: <String, String>{
                    'member_id': "",
                  },
                );
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.white,
            textColor: Color(0xff9b56ff),
            child: Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      height: 60,
                      width: 60,
                      child: Image.asset(image, color: Color(0xff9b56ff))),
                  SizedBox(height: 10.0),
                  Text(
                    "My " + sub_name,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: MaterialButton(
            elevation: 1.0,
            highlightElevation: 1.0,
            onPressed: () {
              if (sub_name == "Leads") {
                Navigator.pushNamed(
                  context,
                  '/tree-page',
                  arguments: <String, String>{
                    'sub_name': sub_name,
                  },
                );
              } else if (sub_name == 'Visits') {
                Navigator.pushNamed(
                  context,
                  '/tree-page',
                  arguments: <String, String>{
                    'sub_name': sub_name,
                  },
                );
              } else if (sub_name == 'Dealers/Distributors') {
                Navigator.pushNamed(
                  context,
                  '/tree-page',
                  arguments: <String, String>{
                    'sub_name': sub_name,
                  },
                );
              } else if (sub_name == 'Tours') {
                Navigator.pushNamed(
                  context,
                  '/tree-page',
                  arguments: <String, String>{
                    'sub_name': sub_name,
                  },
                );
              } else if (sub_name == 'Expense Reimbursements') {
                Navigator.pushNamed(
                  context,
                  '/tree-page',
                  arguments: <String, String>{
                    'sub_name': sub_name,
                  },
                );
              } else if (sub_name == 'Orders') {
                Navigator.pushNamed(
                  context,
                  '/tree-page',
                  arguments: <String, String>{
                    'sub_name': sub_name,
                  },
                );
              } else if (sub_name == 'Sales Target') {
                Navigator.pushNamed(
                  context,
                  '/tree-page',
                  arguments: <String, String>{
                    'sub_name': sub_name,
                  },
                );
              } else if (sub_name == 'Target Achievement') {
                // Fluttertoast.showToast(msg: "Under Construction");
                Navigator.pushNamed(
                  context,
                  '/tree-page',
                  arguments: <String, String>{
                    'sub_name': sub_name,
                  },
                );
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.white,
            textColor: Color(0xff9b56ff),
            child: Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      height: 60,
                      width: 60,
                      child: Image.asset(
                        "assets/images/people.png",
                      )),
                  SizedBox(height: 10.0),
                  Text(
                    "My Teams " + semi_name,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ]);
    }
  }
}
