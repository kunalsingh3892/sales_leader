import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glen_lms/components/heading.dart';

import 'package:glen_lms/modal/product_helper.dart';
import 'package:glen_lms/modal/product_modal.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class ProductList extends StatefulWidget {
  final Object argument;

  const ProductList({Key key, this.argument}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<ProductList>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  var _userId;
  Future<dynamic> _products;
  final searchController = TextEditingController();
  List<TextEditingController> _controllers = new List();
  var quantity;
  DatabaseHelper2 db1 = new DatabaseHelper2();
  int count;

bool show=false;
  List<Region> _region = [];
  List<City> _city = [];
  Future _stateData;
  Future _cityData;
  Future _dealerData;
  String selectedRegion;
  String selectedCity="";

  String catData = "";
  String cityData = "";
  var _type;
  String _type1;
  String query="";
  String orderType="";


  @override
  void initState() {
    super.initState();
    if(widget.argument!=null) {
      var encodedJson = json.encode(widget.argument);
      var data = json.decode(encodedJson);
      _type = data['category_id'];
      _type1 = data['sub_category_id'];
      selectedRegion = data['selectedS'];
      selectedCity = data['selectedC'];
      query = data['query'];

      print(_type);
      print(_type1);
      print(query);
    }
    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }
  Future _getStateCategories() async {
    var response = await http.post(
      URL+"getcategorylist",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['category_list'];
      if (mounted) {
        setState(() {
          catData = jsonEncode(result);

          final json = JsonDecoder().convert(catData);
          _region =
              (json).map<Region>((item) => Region.fromJson(item)).toList();
          List<String> item = _region.map((Region map) {
            for (int i = 0; i < _region.length; i++) {
              if (selectedRegion == map.THIRD_LEVEL_NAME) {
                _type = map.THIRD_LEVEL_ID;

                print(selectedRegion);
                return map.THIRD_LEVEL_ID;
              }
            }
          }).toList();
          _type = _region[0].THIRD_LEVEL_ID;
          print(_type);
            selectedRegion = _region[0].THIRD_LEVEL_NAME;


          if(_type!="") {
         //   _products = _leadData(_type,"");
            _cityData = _getCityCategories(_type);
          }

        });
      }

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }
  TextStyle smallText = GoogleFonts.robotoSlab(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  TextStyle normaText = GoogleFonts.robotoSlab(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  TextStyle smallText2 = GoogleFonts.robotoSlab(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.white
  );
  Future _getCityCategories(type) async {
    setState(() {
      _loading = true;
    });
    var response = await http.post(
      URL+"getsubcategorylist",
      body: {"auth_key": "VrdoCRJjhZMVcl3PIsNdM", "category_id": type.toString()},
      headers: {
        "Accept": "application/json",
      },
    );
    print(jsonEncode({"auth_key": "VrdoCRJjhZMVcl3PIsNdM", "category_id": type.toString()}));
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      var data = json.decode(response.body);
      var result = data['sub_category_list'];
      print(result);
      if(result.length!=[]) {
        setState(() {
          cityData = jsonEncode(result);

          final json = JsonDecoder().convert(cityData);
          _city = (json).map<City>((item) => City.fromJson(item)).toList();
          List<String> item = _city.map((City map) {
            for (int i = 0; i < _city.length; i++) {
              if (selectedCity == map.FOURTH_LEVEL_NAME) {
                _type1 = map.FOURTH_LEVEL_ID;
                /*if (selectedCity == "" || selectedCity == null) {
                  selectedCity = _city[0].FOURTH_LEVEL_ID;
                }
*/
                return map.FOURTH_LEVEL_ID;
              }
            }
          }).toList();
          //  if(selectedCity==""||selectedCity==null){
          selectedCity = _city[0].FOURTH_LEVEL_NAME;
          _type1 = _city[0].FOURTH_LEVEL_ID;
          _products = _leadData(_type,_type1);
          //  }
        });
      }

      return result;
    } else {
      setState(() {
        _loading = false;
      });
      throw Exception('Something went wrong');
    }
  }
  Future _leadData(type,subType) async {
    var response = await http.post(
      URL+"getproductlist",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "category_id":type,
        "sub_category_id":subType,
        "search_key":query

      },
      headers: {
        "Accept": "application/json",
      },
    );
    print({
      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      "category_id":type,
      "sub_category_id":subType,
      "search_key":query
    });
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
      orderType = prefs.getString('orderType').toString();
      print(orderType.toString());
      if(widget.argument!=null)
        _products = _leadData(_type,_type1);
      else
        _stateData= _getStateCategories();

    });
  }

  final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      borderSide: BorderSide(
        color: Color(0xff9b56ff),
      ));
  Widget _emptyCart() {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 80,
              width: 80,
              margin: const EdgeInsets.only(bottom: 20),
              child: Icon(Icons.hourglass_empty,color: Color(0xff9b56ff),),
            ),
            Text(
              "No Products Yet!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _networkImage(url) {
    return Image(
      image: CachedNetworkImageProvider(url),
    );
  }


  Widget leadList1() {
    return FutureBuilder(
      future: _products,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          bool errorCode = snapshot.data['success'];
          var response = snapshot.data['product_list'];
          if (errorCode == true) {
            return  ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: response.length,
              itemBuilder: (BuildContext context, int index) {
                _controllers.add(new TextEditingController());
                return Column(
                    children: <Widget>[ Padding(
                    padding: EdgeInsets.fromLTRB(15, 8, 0, 8),
                    child: Row(
                        children: <Widget>[
                          /*Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Card(
                              child: Container(
                                height: MediaQuery.of(context).size.width/4.5,
                                width: MediaQuery.of(context).size.width/4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: _networkImage(
                                    response[index]['image'],
                                  ),
                                ),
                              ),
                            ),
                          ),*/
                          Flexible(
                            child:
                            Container(
                              padding: EdgeInsets.only(left: 0.0, right: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    response[index]['products_name'],
                                    style: TextStyle(
//                    fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      orderType=="order"? Text(
                                        "Average Unit Price: \u20B9 " +
                                            response[index]['current_price']
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ):Text(
                                        "MOP: \u20B9 " +
                                            response[index]['mop']
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      /*SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          "(MOP: " + "\u20B9 " + response[index]['mop'].toString()+")",
                                          style: TextStyle(
                                             *//* decoration: TextDecoration
                                                  .lineThrough,*//*
                                              color: Colors.grey[700])),
*/

                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            height: 30,

                                            padding: EdgeInsets.only(right: 10),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Theme(
                                                data: Theme.of(context).copyWith(
                                                  cursorColor: Color(0xff9b56ff),
                                                  hintColor: Colors.transparent,
                                                ),
                                                child: TextFormField(
                                                  enabled: true,
                                                  controller:  _controllers[index],
                                                  maxLines: 1,
                                                  decoration: InputDecoration(
                                                      contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(2.0),
                                                        borderSide: BorderSide(
                                                          color: Color(0xFFe3e3e3),
                                                        ),
                                                      ),
                                                     /* focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: BorderSide(
                                                          color: Color(0xFFe3e3e3),
                                                        ),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: BorderSide(
                                                          color: Color(0xFFe3e3e3),
                                                        ),
                                                      ),
                                                      disabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: BorderSide(
                                                          color: Color(0xFFe3e3e3),
                                                        ),
                                                      ),
*/

                                                      counterText: "",
                                                      hintText: "Enter Quantity",
                                                      hintStyle: TextStyle(
                                                          color: Colors.grey[500],
                                                          fontFamily: "WorkSansLight"),
                                                      fillColor: Color(0xfff3f3f4),
                                                      filled: true),
                                                  keyboardType: TextInputType.number,
                                                  style: normaText,

                                                  cursorColor: Color(0xFF000000),
                                                  textCapitalization: TextCapitalization.none,

                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Please enter quantity';
                                                    }
                                                    return null;
                                                  },
                                                  onSaved: (String value) {
                                                    _controllers[index]
                                                        .text = value;
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5.0),
                                       /* Row(
                                          children: <Widget>[
                                            Container(),
                                            Spacer(),


                                          ],
                                        ),*/
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: (){
                                              if(_controllers[index].text!="") {
                                                db1.saveProduct(
                                                    ProductModal(
                                                      response[index]['id']
                                                          .toString(),
                                                      response[index]['category_id']
                                                          .toString(),
                                                      response[index]['sub_category_id']
                                                          .toString(),
                                                      response[index]['sap_id'],
                                                      response[index]['products_name'],
                                                      response[index]['model_no'],
                                                      response[index]['current_price']
                                                          .toString(),
                                                      response[index]['mop']
                                                          .toString(),
                                                      response[index]['image'],
                                                      _controllers[index].text,
                                                      response[index]['stock']
                                                          .toString(),
                                                      response[index]['mrp']
                                                          .toString(),
                                                    )).then((_) {
                                                  if (query == "") {
                                                    Navigator.pop(
                                                        context, 'save');
                                                  } else {
                                                    Navigator.pop(
                                                        context, 'save');
                                                    Navigator.pop(
                                                        context, 'save');
                                                    Navigator.pop(
                                                        context, 'save');
                                                  }
                                                });
                                              }
                                              else{
                                                Fluttertoast.showToast(
                                                    msg: "Please enter quantity");
                                              }
                                            },
                                            child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10, horizontal: 25),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    color: Color(0xff9b56ff)

                                                ),
                                                child:
                                                Text(
                                                  "ADD",
                                                  // snapshot.data['cart_quantity'] > 0 ? 'Go to Basket' : 'Add to Basket',
                                                  style: smallText2,
                                                )

                                            ),
                                          ),
                                        ),
                                      ]
                                  ),


                                 /* SizedBox(height: 5.0),

                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Stock: "+response[index]['stock'].toString(),
                                        style: TextStyle(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      SizedBox(width: 10.0),

                                    ],
                                  ),*/


                                ],

                              ),
                            ),
                          ),
                        ],
                      ),

                  ),
                Divider(),
                    ]
                );
              },
            );
          } else {
            return _emptyCart();
          }
        } else {
          return Center(child: Container(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: Text(
          'Products',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              print(_type);
              print(_type1);
              showSearch(context: context, delegate: ProductSearch(_type,_type1,selectedRegion,selectedCity),query:'');
            },
          ),
        ],
        //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
          children: <Widget>[
            SizedBox(height: 20,),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: deviceSize.width * 0.04),
              child: Row(
                  children: <Widget>[

                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only( right: 5),
                        padding: EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Padding(
                            padding: EdgeInsets.only(right: 0, left: 3),
                            child: new DropdownButton<String>(
                              isExpanded: true,
                              hint: new Text(
                                "Select Category",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              icon: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xff9b56ff),
                                ),
                              ),
                              value: selectedRegion,
                              isDense: true,
                              onChanged: (String newValue) {
                                setState(() {
                                  selectedRegion = newValue;
                                  List<String> item = _region.map((Region map) {
                                    for (int i = 0; i < _region.length; i++) {
                                      if (selectedRegion == map.THIRD_LEVEL_NAME) {
                                        _type = map.THIRD_LEVEL_ID;
                                        return map.THIRD_LEVEL_ID;
                                      }
                                    }
                                  }).toList();
                                  _cityData = _getCityCategories(_type);
                                  _products = _leadData(_type,"");
                                });
                              },
                              items: _region.map((Region map) {
                                return new DropdownMenuItem<String>(
                                  value: map.THIRD_LEVEL_NAME,
                                  child: new Text(map.THIRD_LEVEL_NAME,
                                      style: new TextStyle(color: Colors.black)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 5),
                        height: 40,
                        padding: EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Padding(
                            padding: EdgeInsets.only(right: 0, left: 3),
                            child: new DropdownButton<String>(
                              isExpanded: true,
                              hint: new Text("Select Subcategory",
                                  style: TextStyle(color: Colors.grey[400])),
                              icon: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xff9b56ff),
                                ),
                              ),
                              value: selectedCity,
                              isDense: true,
                              onChanged: (String newValue) {
                                setState(() {
                                  selectedCity = newValue;
                                  List<String> item = _city.map((City map) {
                                    for (int i = 0; i < _city.length; i++) {
                                      if (selectedCity == map.FOURTH_LEVEL_NAME) {
                                        _type1 = map.FOURTH_LEVEL_ID;
                                        return map.FOURTH_LEVEL_ID;
                                      }
                                    }
                                  }).toList();
                                  _products = _leadData(_type,_type1);
                                });
                              },
                              items: _city.map((City map) {
                                return new DropdownMenuItem<String>(
                                  value: map.FOURTH_LEVEL_NAME,
                                  child: new Text(map.FOURTH_LEVEL_NAME,
                                      style: new TextStyle(color: Colors.black)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),

            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20,bottom: 20),
                child: leadList1(),
              ),
            ),
          ]),
    );
  }
  void foo(response) async {
    count = await db1.getProductCount(response);
    print(count);
  }
}
class Region {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;

  Region({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME});

  factory Region.fromJson(Map<String, dynamic> json) {
    return new Region(
        THIRD_LEVEL_ID: json['id'].toString(),
        THIRD_LEVEL_NAME: json['category_name']);
  }
}

class City {
  final String FOURTH_LEVEL_ID;
  final String FOURTH_LEVEL_NAME;

  City({this.FOURTH_LEVEL_ID, this.FOURTH_LEVEL_NAME});

  factory City.fromJson(Map<String, dynamic> json) {
    return new City(
        FOURTH_LEVEL_ID: json['id'].toString(),
        FOURTH_LEVEL_NAME: json['sub_category_name']);
  }
}

class ProductSearch extends SearchDelegate<String> {

  var _categoryId;
  var _subCategoryId;
  var _selectedC;
  var _selectedS;
  ProductSearch(this._categoryId,this._subCategoryId,this._selectedC,this._selectedS);

  final recentproducts = [];
  Future _productList(query) async {
    print(_categoryId);
    print(_subCategoryId);
    var response = await http.post(
      URL+"searchproductlist",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "search_key":query
      },
      headers: {
        "Accept": "application/json",
      },
    );
    print({
      "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
      "search_key":query
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      //var result = data['Response'];
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
    if (query.length<1) {
      return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            showResults(context);
          },
          leading: Icon(Icons.category),
          title: Text(
            recentproducts[index],
            style:
            TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
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
                /*  Navigator.of(context).pop();
                  Navigator.of(context).pop();*/
                  Navigator.pushNamed(
                    context,
                    '/product-list',
                    arguments: <String, String>{
                      'category_id': snapshot.data['product_list'][index]['category_id'].toString(),
                      'sub_category_id': snapshot.data['product_list'][index]['sub_category_id'].toString(),
                      'selectedS': _selectedS,
                      'selectedC': _selectedC,
                      'query': query,
                    },
                  );
                },
               // leading: Container(padding: const EdgeInsets.only(top: 10, bottom: 10),child: Container()),
                title: Text(
                  snapshot.data['success'] == true
                      ? snapshot.data['product_list'][index]['products_name']
                      : recentproducts,
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
              ),
              itemCount: snapshot.data['success'] == true
                  ? snapshot.data['product_list'].length
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

    if (query.length<1) {
      return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            showResults(context);
          },
          leading: Icon(Icons.category),
          title: Text(
            recentproducts[index],
            style:
            TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
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
                 /* Navigator.of(context).pop();
                  Navigator.of(context).pop();*/
                  Navigator.pushNamed(
                    context,
                    '/product-list',
                    arguments: <String, String>{
                      'category_id': snapshot.data['product_list'][index]['category_id'].toString(),
                      'sub_category_id': snapshot.data['product_list'][index]['sub_category_id'].toString(),
                      'selectedS': _selectedS,
                      'selectedC': _selectedC,
                      'query': query,
                    },
                  );
                },
                //leading: Container(padding: const EdgeInsets.only(top: 10, bottom: 10),child: Container()),
                title: Text(
                  snapshot.data['success'] == true
                      ? snapshot.data['product_list'][index]['products_name']
                      : recentproducts,
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
              ),
              itemCount: snapshot.data['success'] == true
                  ? snapshot.data['product_list'].length
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