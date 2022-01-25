import 'package:auto_size_text/auto_size_text.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class TeamLeadDetails extends StatefulWidget {
  final Object argument;
  const TeamLeadDetails({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<TeamLeadDetails> {
  bool _loading = false;
  TabController controller;
  var _userId;
  Future<dynamic> _leads;
  var _lead_id;
  List<RawPhoneEvent> _rawEvents;
  List<PhoneCallEvent> _phoneEvents;
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _lead_id = data['lead_id'];
    print(_lead_id);
    _phoneEvents = _accumulate(FlutterPhoneState.phoneCallEvents);
    _rawEvents = _accumulate(FlutterPhoneState.rawPhoneEvents);
    _getUser();
  }
  List<R> _accumulate<R>(Stream<R> input) {
    final items = <R>[];
    input.forEach((item) {
      if (item != null) {
        setState(() {
          items.add(item);
        });
      }
    });
    return items;
  }
  Iterable<PhoneCall> get _completedCalls =>
      Map.fromEntries(_phoneEvents.reversed.map((PhoneCallEvent event) {
        return MapEntry(event.call.id, event.call);
      })).values.where((c) => c.isComplete).toList();

  Future _leadData() async {
    var response = await http.post(URL+"leaddetails",
      body: {
        "auth_key":"VrdoCRJjhZMVcl3PIsNdM",
        "lead_id": _lead_id.toString(),
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

      _leads = _leadData();
    });
  }
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Lead Details',
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

  Stack _buildWikiCategory(IconData icon, String label, Color color) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20.0),
          alignment: Alignment.centerRight,
          child: Opacity(
              opacity: 0.05,
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              )),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 5.0),
              Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: Text(
                  label,
                  maxLines: 2,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
  _launchPhoneURL(String phoneNumber) async {
    String url = 'tel:' + phoneNumber;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<String> waitForCompletion(PhoneCall phoneCall) async {
    await phoneCall.done;

    print("Call is completed");
    print("c<><>>>>>>>>>>>>><<<<<<<<<<<<<"+phoneCall.duration.toString());
    return phoneCall.duration.toString();

  }
  _initiateCall(_phoneNumber) {
    if (_phoneNumber?.isNotEmpty == true) {
      setState(() {
        final phoneCall=  FlutterPhoneState.startPhoneCall(_phoneNumber);
        print(phoneCall.duration);
      });

    }
  }


  Widget leadDetails(Size deviceSize)
  {
    return FutureBuilder(
      future: _leads,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Subject : "+snapshot.data['lead_details'][0]['subject'],
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10.0),
                        Text("Customer Name : "+snapshot.data['lead_details'][0]['customer_name']),
                        SizedBox(height: 5.0),
                        Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.phone,
                              size: 12.0,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              snapshot.data['lead_details'][0]['customer_phone'],
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.locationArrow,
                              size: 12.0,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 10.0),
                            snapshot.data['lead_details'][0]['location']!=null? Text(
                              snapshot.data['lead_details'][0]['location'],
                              style: TextStyle(color: Colors.black54),
                            ):Text(
                              "",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.mailBulk,
                              size: 12.0,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 10.0),
                            snapshot.data['lead_details'][0]['email_id']!=null? Text(
                              snapshot.data['lead_details'][0]['email_id'],
                              style: TextStyle(color: Colors.black54),
                            ):Text(
                              "",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Description : "+snapshot.data['lead_details'][0]['description']),
                ),
                SizedBox(height: 5.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Priority : "+snapshot.data['lead_details'][0]['priority']),
                ),
                SizedBox(height: 5.0),
                Container(
                  width: MediaQuery.of(context).size.height * 0.80,
                  margin: const EdgeInsets.only(left: 16,right: 16),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Text(
                      "Status : "+snapshot.data['lead_details'][0]['status'],
                      style: TextStyle(color: Colors.black87,)),
                ),
                SizedBox(height: 20.0),
                Container(
                  margin: const EdgeInsets.only(left: 20,right: 20),
                  child: Row(
                    children: <Widget>[
                    /*  Expanded(
                        child: InkWell(
                          onTap: (){
                            Navigator.pushNamed(
                              context,
                              '/add-visits',
                              arguments: <String, String>{
                                'visit_to': 'lead',
                                'contact':snapshot.data['lead_details'][0]['id'].toString(),
                                'contact_name':snapshot.data['lead_details'][0]['customer_name'].toString(),
                                'tour_title':"",
                                'tour_name':"",
                              },
                            );
                          },
                          child: _buildWikiCategory(Icons.add_circle,
                              "Add Visit", Color(0xff9b56ff)),
                        ),
                      ),*/

                     /* const SizedBox(width: 16.0),*/
                      Container(
                        width: 100,
                        height: 100,
                        child: InkWell(
                          onTap: (){
                            Navigator.pushNamed(
                              context,
                              '/lead-history',
                              arguments: <String, String>{
                                'id':snapshot.data['lead_details'][0]['id'].toString(),
                                'lead_id':snapshot.data['lead_details'][0]['lead_id'].toString(),
                                'subject':snapshot.data['lead_details'][0]['subject'].toString()
                              },
                            );
                          },
                          child: _buildWikiCategory(FontAwesomeIcons.history,
                              "Lead History", Color(0xff9b56ff)),
                        ),
                      ),
                    ],
                  ),
                ),
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
class _CallCard extends StatelessWidget {
  final PhoneCall phoneCall;

  const _CallCard({Key key, this.phoneCall}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          dense: true,
          trailing: FutureBuilder<PhoneCall>(
            builder: (context, snap) {
              if (snap.hasData && snap.data?.isComplete == true) {
                return Text("${phoneCall.duration?.inSeconds ?? '?'}s");
              } else {
                return CircularProgressIndicator();
              }
            },
            future: Future.value(phoneCall.done),
          )),
    );
  }
}