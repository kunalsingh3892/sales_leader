import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';
import 'package:glen_lms/modal/order_json.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class OrderDetails extends StatefulWidget {
  final Object argument;

  const OrderDetails({Key key, this.argument}) : super(key: key);

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<OrderDetails> {
  bool _loading = false;
  var _userId,role;
  Future<dynamic> _visits;
  var order_id,member_id;
  String type="";
  String subject = "";
  int _total = 0;
  List<OrderJson> xmlList = new List();
  List<String> quantityList = new List();
  final TextStyle stats = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white);
  List<TextEditingController> _controllers = new List();
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    order_id = data['order_id'];
    type = data['type'];
    member_id = data['member_id'];
    subject = data['subject'];
    _getUser();
  }

  void _deleteData(cartId, order_id) async {
    var response = await http.post(
      URL+"deleteorder",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "cart_id":cartId.toString(),
        "order_id":order_id.toString(),
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.pushNamed(
        context,
        '/order-list',
      );
    } else {
      throw Exception('Something went wrong');
    }
  }
  Future _leadData() async {
    var response = await http.post(
      URL+"order_details",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "order_id": order_id.toString(),
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      quantityList.length=data['orderpproductlist'].length;

      for (int i = 0; i < data['orderpproductlist'].length; i++) {
        quantityList[i]=data['orderpproductlist'][i]['quantity'].toString();
        print(quantityList[i]);
        _total = _total + (int.parse(data['orderpproductlist'][i]['current_price'])*
            int.parse(quantityList[i]));
        print(_total.toString());
      }
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }
  TextStyle smallText = GoogleFonts.robotoSlab(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  TextStyle smallText2 = GoogleFonts.robotoSlab(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.white
  );

  TextStyle normalText = GoogleFonts.robotoSlab(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  TextStyle mediumText = GoogleFonts.robotoSlab(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      role = prefs.getString('role').toString();

      print(_userId.toString());
      _visits = _leadData();
    });
  }
  showConfirmDialog(id,order_id, cancel, done, title, content) {
    print(id);
    // Set up the Button
    Widget cancelButton = FlatButton(
      child: Text(cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget doneButton = FlatButton(
      child: Text(done),
      onPressed: () {
        Navigator.of(context).pop();
        _deleteData(id,order_id);

      },
    );

    // Set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        cancelButton,
        doneButton,
      ],
    );

    // Show the Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:type=="edit"?Text(
          'Edit Order',
          style: TextStyle(color: Colors.white),
        ): Text(
          'Order Details',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[],
        //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: leadDetails(deviceSize),
    );
  }
  Widget _networkImage(url) {
    return Container(
      margin: EdgeInsets.only(
        right: 8,
        left: 8,
      ),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(10)),
        //color: Colors.blue.shade200,
        image: DecorationImage(
            image: CachedNetworkImageProvider(
                url),
            fit: BoxFit.cover
        ),
      ),
    );
  }
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      borderSide: BorderSide(
        color: Color(0xff9b56ff),
      ));
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
                      backgroundColor: Color(0xff9b56ff),
                      radius: 28,
                      child: Center(
                        child: snapshot.data['orderlist'][0]['dealer_name']!=null?Text(
                          snapshot.data['orderlist'][0]['dealer_name'][0]
                              .toUpperCase(),
                          style: TextStyle(fontSize: 30.0, color: Colors.white),
                        ):Text(
                          "",
                          style: TextStyle(fontSize: 30.0, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Container(
                      width: deviceSize.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          snapshot.data['orderlist'][0]['dealer_name']!=null?Text(
                            "Name : " +
                                snapshot.data['orderlist'][0]['dealer_name'],
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ):Text(
                            "Name : " ,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
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
                                    "Created at : " +
                                        snapshot.data['orderlist'][0]
                                            ['created_at'],
                                    overflow: TextOverflow.ellipsis,
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
                                Icon(
                                  FontAwesomeIcons.mobile,
                                  size: 12.0,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  child:snapshot.data['orderlist'][0]
                                  ['dealer_phone']!=null?Text(
                                    snapshot.data['orderlist'][0]
                                    ['dealer_phone'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: TextStyle(color: Colors.black54),
                                  ): Text(
                                    "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10.0),
                type=="edit"? Container(
                  padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 15, left: 10, right: 10),
                          child: Text(
                            "PRODUCT DETAILS",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Color(0xfffb4d6d),
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Divider(
                          height: 20,
                        ),
                        ListView.builder(
                            itemCount: snapshot.data['orderpproductlist'].length,
                            shrinkWrap: true,
                            primary: false,
                            padding: const EdgeInsets.all(15.0),
                            itemBuilder: (context, i) {
                              _controllers.add(new TextEditingController());

                              return  Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                child: Container(
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFfae3e2).withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ]),
                                  child: Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 5,
                                            top: 5,
                                            bottom:5),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: <Widget>[
                                           /* Container(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Center(
                                                  child: _networkImage(
                                                    snapshot.data['orderpproductlist'][i]['image'],
                                                  ),
                                                ),
                                              ),
                                            ),*/
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                          '${ snapshot.data['orderpproductlist'][i]['product_name']}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 3,
                                                          style: mediumText,
                                                          textAlign:
                                                          TextAlign.left,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      _controllers[i].text==""?Container(
                                                        padding: EdgeInsets.only(right: 10),
                                                        child: Text(
                                                          "₹ " + '${(int.parse( snapshot.data['orderpproductlist'][i]['current_price'])*
                                                                  snapshot.data['orderpproductlist'][i]['quantity']).toString()}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style: mediumText,
                                                          textAlign:
                                                          TextAlign.left,
                                                        ),
                                                      ):Container(
                                                        padding: EdgeInsets.only(right: 10),
                                                        child: Text(
                                                          "₹ " + '${(int.parse( snapshot.data['orderpproductlist'][i]['current_price'])*
                                                              int
                                                                  .parse(
                                                                  quantityList[i])).toString()}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style: mediumText,
                                                          textAlign:
                                                          TextAlign.left,
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  subject=="users"? Container(
                                                    child: Text(
                                                      'Average Unit Price: ₹ ' +
                                                          '${ snapshot.data['orderpproductlist'][i]['current_price']}',
                                                      style: smallText,
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ): Container(
                                                    child: Text(
                                                      'MOP: ₹ ' +
                                                          '${ snapshot.data['orderpproductlist'][i]['current_price']}',
                                                      style: smallText,
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),

                                                  SizedBox(
                                                    height: 5,
                                                  ),

                                                  Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: <Widget>[
                                                        Container(),
                                                        Spacer(),
                                                        Container(
                                                          margin: EdgeInsets.only(right: 5),
                                                          height: 30,
                                                          width: MediaQuery.of(context).size.width * 0.15,
                                                          child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Theme(
                                                              data: Theme.of(context).copyWith(
                                                                cursorColor: Color(0xff9b56ff),
                                                                hintColor: Colors.transparent,
                                                              ),
                                                              child: TextFormField(
                                                                enabled: true,
                                                                initialValue: snapshot.data['orderpproductlist'][i]['quantity'].toString(),
                                                                maxLines: 1,
                                                                decoration: InputDecoration(
                                                                    focusedBorder: border,
                                                                    border: border,
                                                                    contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                                                                    disabledBorder: border,
                                                                    enabledBorder: border,

                                                                    filled: true,
                                                                    fillColor: Color(0xFFffffff),
                                                                    hintText: ''),
                                                                keyboardType: TextInputType.number,
                                                                cursorColor: Color(0xFF000000),
                                                                style: normalText,
                                                                textCapitalization: TextCapitalization.none,
                                                                validator: (value) {
                                                                  if (value.isEmpty) {
                                                                    return 'Please enter quantity';
                                                                  }
                                                                  return null;
                                                                },
                                                                onSaved: (String value) {
                                                                  _controllers[i]
                                                                      .text = value;
                                                                },
                                                                onChanged:
                                                                    (String value) {
                                                                  _controllers[i]
                                                                      .text = value;
                                                                  setState(() {
                                                                    quantityList[i]=_controllers[i]
                                                                        .text;
                                                                  });

                                                                  setState(() {
                                                                    _total=0;
                                                                    for (int i = 0; i < quantityList.length; i++) {
                                                                      _total = _total + (int.parse(snapshot.data['orderpproductlist'][i]['current_price'])*
                                                                          int.tryParse(quantityList[i]));
                                                                      print(_total.toString());
                                                                    }
                                                                  });

                                                                  print(quantityList[i]);
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        /*SizedBox(
                                                          width: 6,
                                                        ),
                                                        Align(
                                                          alignment: Alignment.center,
                                                          child: InkWell(
                                                            onTap: (){
                                                              setState(() {

                                                                _total=0;
                                                                for (int i = 0; i < snapshot.data['orderpproductlist'].length; i++) {
                                                                  print(_controllers[i].text);
                                                                  if( _controllers[i].text!="") {
                                                                    _total = _total + (int
                                                                        .parse(
                                                                        snapshot
                                                                            .data['orderpproductlist'][i]['current_price']) *
                                                                        int
                                                                            .parse(
                                                                            quantityList[i]));
                                                                    print(_total.toString());
                                                                  }
                                                                  else{
                                                                    _total = _total + (int.parse(snapshot.data['orderpproductlist'][i]['current_price'])
                                                                        * 0);
                                                                  }
                                                                }
                                                              });

                                                            },
                                                            child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                    vertical: 5, horizontal: 10),
                                                                margin: EdgeInsets.symmetric(
                                                                    horizontal: 10),
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(5),
                                                                    color: Color(0xff9b56ff)

                                                                ),
                                                                child:
                                                                Text(
                                                                  "UPDATE",
                                                                  // snapshot.data['cart_quantity'] > 0 ? 'Go to Basket' : 'Add to Basket',
                                                                  style: smallText2,
                                                                )

                                                            ),
                                                          ),
                                                        ),*/
                                                      ]
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                                secondaryActions: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 5,
                                        right: 5,
                                        top: 5,
                                        bottom:5),
                                    child: IconSlideAction(
                                      caption: 'Delete',
                                      color: Color(0xff9b56ff),
                                      icon: Icons.delete,
                                      onTap: () {
                                        showConfirmDialog(
                                            snapshot.data['orderpproductlist'][i]['id'],
                                            snapshot.data["orderlist"][0]['id'],
                                            'Cancel',
                                            'Remove',
                                            'Remove Item',
                                            'Are you sure want to remove this item?');
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                        /*ListTile(
                            leading: _networkImage(i['image']),
                            title: Text(i['product_name'],style: mediumText,),
                            subtitle: Text('Quantity: ' + i['quantity'].toString(),style: smallText,),
                            trailing: Text("\u20B9 " + (int.parse(i['current_price'])*i['quantity']).toString(),style: normalText,),
                          ),*/


                      ],
                    ),
                  ),
                ):
                Container(
                  padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 15, left: 10, right: 10),
                          child: Text(
                            "PRODUCT DETAILS",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Color(0xfffb4d6d),
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Divider(
                          height: 20,
                        ),
                        for (var i in  snapshot.data['orderpproductlist'])
                          Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            child: Container(
                              decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFfae3e2).withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(0, 1),
                                  ),
                                ]),
                                child: Card(
                                    color: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 5,
                                          top: 5,
                                          bottom:5),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                         /* Container(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Center(
                                                child: _networkImage(
                                                  i['image'],
                                                ),
                                              ),
                                            ),
                                          ),*/
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(
                                                        '${i['product_name']}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        style: mediumText,
                                                        textAlign:
                                                        TextAlign.left,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(right: 10),
                                                      child: Text(
                                                        "₹ " + '${(int.parse(i['current_price'])*
                                                            i['quantity']).toString()}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: mediumText,
                                                        textAlign:
                                                        TextAlign.left,
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                subject=="users"? Container(
                                                  child: Text(
                                                    'Average Unit Price: ₹ ' +
                                                        '${i['current_price']}',
                                                    style: smallText,
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ): Container(
                                                  child: Text(
                                                    'MOP: ₹ ' +
                                                        '${i['current_price']}',
                                                    style: smallText,
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),

                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Align(
                                                  alignment:
                                                  Alignment.topLeft,
                                                  child: Container(
                                                    child: Text(
                                                      'Quantity: ' +
                                                          '${i['quantity'].toString()}',
                                                      style: normalText,
                                                      textAlign:
                                                      TextAlign.left,
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                              ),
                            secondaryActions: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    left: 5,
                                    right: 5,
                                    top: 5,
                                    bottom:5),
                                child: IconSlideAction(
                                  caption: 'Delete',
                                  color: Color(0xff9b56ff),
                                  icon: Icons.delete,
                                  onTap: () {
                                    showConfirmDialog(
                                        i['id'],
                                        snapshot.data["orderlist"][0]['id'],
                                        'Cancel',
                                        'Remove',
                                        'Remove Item',
                                        'Are you sure want to remove this item?');
                                  },
                                ),
                              ),
                            ],
                          ),
                          /*ListTile(
                            leading: _networkImage(i['image']),
                            title: Text(i['product_name'],style: mediumText,),
                            subtitle: Text('Quantity: ' + i['quantity'].toString(),style: smallText,),
                            trailing: Text("\u20B9 " + (int.parse(i['current_price'])*i['quantity']).toString(),style: normalText,),
                          ),*/
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),


                type=="edit"? Column(
                    children: [
                      Container(
                    padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Text(
                              "TOTAL PRICE",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                // fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                          Divider(
                            height: 12,
                          ),
                          ListTile(
                            leading: Text("Total",style: mediumText,),
                            trailing: Text("\u20B9 " + _total.toString(),style: mediumText,),
                          ),
                        ],
                      ),
                    ),
                  ),
                      SizedBox(
                        height: 30,
                      ),
                      _submitButton(snapshot.data['orderpproductlist'])
                    ]
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
  Widget _submitButton(data) {
    return InkWell(
      onTap: () async {

        _total=0;
        for (int i = 0; i < data.length; i++) {
              OrderJson xmljson = new OrderJson();
              xmljson.product_id = data[i]['product_id'].toString();
              xmljson.sap_id =  data[i]['sap_id'];
              xmljson.category_id = data[i]['category_id'];
              xmljson.sub_category_id =  data[i]['sub_category_id'];
              xmljson.product_name =  data[i]['product_name'];
              xmljson.model_no =  data[i]['model_no'];
              xmljson.current_price =  data[i]['current_price'];
              xmljson.quantity =  quantityList[i].toString();
              xmljson.image =  data[i]['image'];
              xmljson.mrp =  data[i]['mrp'];
              xmlList.add(xmljson);
              _total = _total + int.parse(data[i]['current_price'])*int.parse(quantityList[i]);
            }

            print(_total.toString());

            print(jsonEncode(xmlList));

            setState(() {
              _loading = true;
            });
            Map<String, String> headers = {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            };
            final msg = jsonEncode({
              "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
              "id": _userId,
              "order_id": order_id.toString(),
              "total_amount": _total.toString(),
              "product": xmlList,
            });

            var response = await http.post(
              URL+"edit_order",
              body: msg,
              headers: headers,
            );


            print(msg);
            if (response.statusCode == 200) {
              setState(() {
                _loading = false;
              });
              var data = json.decode(response.body);
              Fluttertoast.showToast(
                  msg: 'Message: ' + data['message'].toString());
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                '/order-list',
                arguments: <String, String>{
                  'member_id': "",

                },
              );
              print(data);
            } else {
              setState(() {
                _loading = false;
              });
              print(response.body);

              Fluttertoast.showToast(msg: 'Error');
            }

      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.all(15),
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
          'SUBMIT',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
