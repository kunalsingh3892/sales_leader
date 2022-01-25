import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';
import 'package:glen_lms/screens/dashboard_screens/pending_tours.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import 'all_leads.dart';
import 'approved_tours.dart';
import 'completed_leads.dart';
import 'completed_tours.dart';
import 'dealer_list.dart';
import 'follow_leads.dart';
import 'influencer_list.dart';
import 'my_tours.dart';

class AllDealers extends StatefulWidget {
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<AllDealers>  with SingleTickerProviderStateMixin{
  bool _loading = false;
  TabController controller;
  var _userId;
  Future<dynamic> _leads;
  var member_id;
  @override
  void initState() {
    super.initState();

    controller = TabController(vsync: this, length: 2);
    _getUser();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }


  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      print(_userId.toString());
    });
  }

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        floatingActionButton:FloatingActionButton(
          onPressed: () {

            Navigator.pushNamed(
              context,
              '/add-dealer',
            );
          },
          child: Icon(Icons.add),
        ),
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 100.0),
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color:  Color(0xff9b56ff),
                offset: Offset(0, 2.0),
                blurRadius: 10.0,
              )
            ]),
            child:AppBar(
              title: Text("My Dealers",style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),),
              actions: <Widget>[
             /*   IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                      if(controller.index.toString()=="0"){
                      showSearch(context: context, delegate: ProductSearch(_userId,"Assigned"),query:'');
                    }
                    else if(controller.index.toString()=="1"){
                      showSearch(context: context, delegate: ProductSearch(_userId,"Follow up"),query:'');
                    }
                    if(controller.index.toString()=="2"){
                      showSearch(context: context, delegate: ProductSearch(_userId,"Closed"),query:'');
                    }

                    print(controller.index.toString());
                  },
                )*/
              ],
              bottom: TabBar(
                isScrollable: true,
                controller: controller,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: new BubbleTabIndicator(
                  indicatorHeight: 25.0,
                  indicatorColor: Colors.white,
                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                  indicatorRadius: 5,
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                tabs: <Widget>[
                  Tab(
                    text: "Dealers/Distributors",
                  ),
                  Tab(
                    text: "Influencer",
                  ),
                ],
                onTap: (int val) {

                },
              ),
            ),
          ),
        ),
        body:  TabBarView(
          controller: controller,
          children: <Widget>[

            DealerList(),
            InfluencerList(),
          ],
        )

    );
  }
}

class ProductSearch extends SearchDelegate<String> {
  var _userId;
  var _type;
  ProductSearch(this._userId,this._type);

  final recentproducts = [];

  Future _productList(query) async {
    var response = await http.post(URL+"getleadlist",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
        "id": _userId,
        "status":_type,
        "search_key":query,
      },
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }
  Widget _networkImage(url) {
    return Image(
      image: CachedNetworkImageProvider(url),
    );
  }
  @override
  Widget buildResults(BuildContext context) {
    if (query.length<3) {
      return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            showResults(context);
          },
          leading: Icon(Icons.person_search,color:Color(0xff9b56ff)),
          title: Text(
            recentproducts[index],
            style:
            TextStyle(color: Color(0xff9b56ff), fontWeight: FontWeight.bold),
          ),
        ),
        itemCount: recentproducts.length,
      );
    } else {
      return FutureBuilder(
        future: _productList(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/lead-details',
                    arguments: <String, String>{
                      'lead_id':
                      snapshot.data['lead_list'][index]['id'].toString(),
                      'type':''

                    },
                  );
                },
                leading:Icon(Icons.person_search,color:Color(0xff9b56ff)) ,
                title: Text(
                  snapshot.data['success'] == true
                      ? snapshot.data['lead_list'][index]['customer_name']
                      : recentproducts,
                  style: TextStyle(
                      color: Color(0xff9b56ff), fontWeight: FontWeight.bold),
                ),
              ),
              itemCount: snapshot.data['success'] == true
                  ? snapshot.data['lead_list'].length
                  : recentproducts.length,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    if (query.length<3) {
      return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            showResults(context);
          },
          leading: Icon(Icons.person_search,color:Color(0xff9b56ff)),
          title: Text(
            recentproducts[index],
            style:
            TextStyle(color: Color(0xff9b56ff), fontWeight: FontWeight.bold),
          ),
        ),
        itemCount: recentproducts.length,
      );
    } else {
      return FutureBuilder(
        future: _productList(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/lead-details',
                    arguments: <String, String>{
                      'lead_id':
                      snapshot.data['lead_list'][index]['id'].toString(),
                      'type':''

                    },
                  );
                },
                leading:Icon(Icons.person_search,color: Color(0xff9b56ff),),
                title: Text(
                  snapshot.data['success'] == true
                      ? snapshot.data['lead_list'][index]['customer_name']
                      : recentproducts,
                  style: TextStyle(
                      color: Color(0xff9b56ff), fontWeight: FontWeight.bold),
                ),
              ),
              itemCount: snapshot.data['success'] == true
                  ? snapshot.data['lead_list'].length
                  : recentproducts.length,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    }
  }
}
