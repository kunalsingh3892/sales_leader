import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/full_image.dart';
import 'package:glen_lms/components/heading.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class ExpenseDetails extends StatefulWidget {
  final Object argument;
  const ExpenseDetails({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<ExpenseDetails> {
  bool _loading = false;
  var _userId;
  Future<dynamic> _visits;
  var expense_id,link_visit;
  final TextStyle stats = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white);
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    expense_id = data['expense_id'];

    _getUser();
  }


  Future _leadData() async {
    var response = await http.post(URL+"expensereimbursments_view",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
        "expense_id": expense_id.toString(),
        "id": _userId.toString(),
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      //var result = data['Response'];
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      print(_userId.toString());
      _visits = _leadData();
    });
  }


  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Expense Details',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[

        ],
        //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: leadDetails(deviceSize),
    );
  }
  TextStyle smallText = GoogleFonts.robotoSlab(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.black
  );
  Widget leadDetails(Size deviceSize) {

      return FutureBuilder(
        future: _visits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 30.0),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20.0),
                      CircleAvatar(

                        backgroundColor:  Color(0xff9b56ff),

                        radius: 28,
                        child: Center(
                          child: Text(
                            snapshot.data['expense_details'][0]['category'][0].toUpperCase(),
                            style: TextStyle(
                                fontSize: 30.0,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Container(
                        width: deviceSize.width * 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Type: "+snapshot.data['expense_details'][0]['type'],
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10.0),

                            Container(
                              width: deviceSize.width * 0.7,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.calendar,
                                    size: 12.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      "Ex. Date : "+snapshot.data['expense_details'][0]['ex_date'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Container(
                              width: deviceSize.width * 0.8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "",
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                Text(
                                      snapshot.data['expense_details'][0]['status'],
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.black87,fontSize: 15,fontWeight: FontWeight.w500),
                                    ),


                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  /*SizedBox(height: 20.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Amount : "+snapshot.data['expense_details'][0]['leadsubject']),
                  ),*/
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                        "Ex. Date: "+snapshot.data['expense_details'][0]['ex_date'],style: smallText,),
                  ),
                  SizedBox(height: 5.0),
                  snapshot.data['expense_details'][0]['from_city']!=null?Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Row(
                        children: <Widget>[ Expanded(
                          child: Text(
                            "From City : "+snapshot.data['expense_details'][0]['from_city'],style: smallText,),
                        ),
                          
                          Expanded(
                            child: Text(
                                "To City : "+snapshot.data['expense_details'][0]['to_city'],style: smallText,),
                          ),
                        ]
                    ),
                  ):Container(),
                /*  SizedBox(height: 5.0),
                  snapshot.data['expense_details'][0]['from_date']!=null? Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Row(
                        children: <Widget>[ Expanded(
                          child: Text(
                            "From Date : "+snapshot.data['expense_details'][0]['from_date'],style: smallText,),
                        ),

                          Expanded(
                            child: Text(
                              "To Date : "+snapshot.data['expense_details'][0]['to_date'],style: smallText,),
                          ),
                        ]
                    ),
                  ):Container(),*/
                  SizedBox(height: 5.0),
                  snapshot.data['expense_details'][0]['travel_mode']!=null? Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                      "Travel Mode: "+snapshot.data['expense_details'][0]['travel_mode'],style: smallText,),
                  ):Container(),
                  SizedBox(height: 5.0),
                  snapshot.data['expense_details'][0]['hotel_name']!=null? Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                      "Hotel Name: "+snapshot.data['expense_details'][0]['hotel_name'],style: smallText,),
                  ):Container(),
                  SizedBox(height: 5.0),
                  snapshot.data['expense_details'][0]['city']!=null? Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                      "City: "+snapshot.data['expense_details'][0]['city'],style: smallText,),
                  ):Container(),
                  SizedBox(height: 5.0),
                  snapshot.data['expense_details'][0]['no_of_night']!=null?Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                      "No. Of Nights: "+snapshot.data['expense_details'][0]['no_of_night'].toString(),style: smallText,),
                  ):Container(),
                  SizedBox(height: 5.0),
                  snapshot.data['expense_details'][0]['comments']!=null? Container(
                    width: MediaQuery.of(context).size.height * 0.80,
                    margin: const EdgeInsets.only(left: 16,right: 16),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Text(
                      "Comments: "+snapshot.data['expense_details'][0]['comments'],style: smallText,),
                  ):Container(),
                  SizedBox(height: 10.0),
                  snapshot.data['upload_photo'].length!=0? GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    children: List.generate( snapshot.data['upload_photo'].length, (index) {
                      return InkWell(
                        onTap: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                                return FullScreenImage(
                                  imageUrl:
                                  snapshot.data['attachment_url']+
                                      snapshot.data['upload_photo'][index]['image'],
                                  tag: "generate_a_unique_tag",
                                );
                              }));
                        },
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(snapshot.data['attachment_url']+
                                  snapshot.data['upload_photo'][index]['image']),
                              fit: BoxFit.fill,
                            ),

                          ),
                        ),
                      );
                    }),
                  ):Container(),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );


  }





}
