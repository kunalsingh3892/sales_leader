import 'dart:io';
import 'package:glen_lms/components/image_upload.dart';
import 'package:glen_lms/constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';

import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_button/group_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';

class AddCompetitorPromotion extends StatefulWidget {

  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<AddCompetitorPromotion> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final cmtController = TextEditingController();
  final compNameController = TextEditingController();
  Axis direction = Axis.horizontal;

  String _dropdownValue = 'Select Visit Type';
  bool suggest = false;
  bool show = false;
  String _address="";


  String cityData = "";
  var dealerData;
  var _cmt;
  var finalDate, finalDate2;
  var _userId;
  var dealerJson;
  Future _dealerData;
  String selectedDealer="";
  var status="success";
  List<Object> images1 = List<Object>();
  Future<File> _imageFile;
  @override
  void initState() {
    super.initState();
    setState(() {
      images.length=11;
      images1.add("Add Image");

    });
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      _dealerData = _getDealerCategories();

    });
  }
  Future _onAddImageClick(int index) async {
    setState(() {
      _imageFile = ImagePicker.pickImage(source: ImageSource.camera,  imageQuality:1,
          maxHeight: 640,
          maxWidth: 480);
      if(_imageFile!=null)
        getFileImage(index);
    });
  }
  Future _onAddImageClick1(int index) async {
    setState(() {
      _imageFile = ImagePicker.pickImage(source: ImageSource.gallery,
          maxHeight: 600,
          maxWidth: 800,
          imageQuality: 30);

      if(_imageFile!=null)
        getFileImage(index);
    });
  }
  List<File> files = [];
  void getFileImage(int index) async {
//    var dir = await path_provider.getTemporaryDirectory();


    if(images1.length!=11) {
      _imageFile.then((file) async {
        setState(() {
          print(index.toString());
          ImageUploadModel imageUpload = new ImageUploadModel();
          imageUpload.isUploaded = false;
          imageUpload.uploading = false;
          imageUpload.imageFile = file;
          imageUpload.imageUrl = '';
          images1.replaceRange(index + 1, index + 1, [imageUpload]);


          if(imageUpload.imageFile!=null)
            files.add(imageUpload.imageFile);
          print(files);
        });
      });
    }else{
      Fluttertoast.showToast(msg:  "You can add only 10 images");
    }
  }
  void _showPicker2(context,int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library,color: Color(0xff9b56ff),),
                      title: new Text('Photo Library',style:TextStyle(color: Color(0xff9b56ff)),),
                      onTap: () {
                        _onAddImageClick1( index);
                        Navigator.of(context).pop();
                      }),
                  /*new ListTile(
                    leading: new Icon(Icons.photo_camera,color: Color(0xff9b56ff),),
                    title: new Text('Camera',style:TextStyle(color: Color(0xff9b56ff)),),
                    onTap: () {
                      _onAddImageClick(index);
                      Navigator.of(context).pop();
                    },
                  ),*/
                ],
              ),
            ),
          );
        }
    );
  }
  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      primary: false,
      childAspectRatio: 1,
      children: List.generate(images1.length, (index) {
        if (images1[index] is ImageUploadModel) {
          ImageUploadModel uploadModel = images1[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                uploadModel.imageFile!=null?Image.file(
                  uploadModel.imageFile,
                  width: 300,
                  height: 300,
                ):Container(),
                Positioned(
                  right: 5,
                  top: 5,
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      size: 20,
                      color: Color(0xff9e54f8),
                    ),
                    onTap: () {
                      setState(() {
                        images1.replaceRange(index-1, index + 1, ['Add Image']);
                        files.remove(uploadModel.imageFile);
                        print(files);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Card(
            child: IconButton(
              icon: Icon(Icons.add_circle,color:Color(0xff9e54f8) ,),
              onPressed: () {
                if(images1.length!=11) {
                  print(index.toString());
                  _showPicker2(context, index);
                }
                else{
                  Fluttertoast.showToast(msg:  "You can add only 10 images");
                }
              },
            ),
          );
        }
      }),
    );
  }
  Future _getDealerCategories() async {
    var response = await http.post(
     URL+"getdealerlists",
      body: {
        "auth_key": "VrdoCRJjhZMVcl3PIsNdM",
        "id":_userId,
        "type":"Both"
      },
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['dealer_list'];
      if (mounted) {
        setState(() {
          dealerData = jsonEncode(result);

          dealerJson = JsonDecoder().convert(dealerData);
          /* _dealer =
              (json).map<Dealer>((item) => Dealer.fromJson(item)).toList();*/
          print(dealerJson.toString());
          /*   List<String> item = _dealer.map((Dealer map) {
            for (int i = 0; i < _dealer.length; i++) {
              if (selectedDealer == map.firm_name) {
                _type = map.id;

                print(selectedDealer);
                return map.id;
              }
            }
          }).toList();
          if (selectedDealer == "") {
            selectedDealer = _dealer[0].firm_name;
          }*/
        });
      }

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }


  Widget _submitButton() {
    return InkWell(
      onTap: () async {

        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();

          setState(() {
            _loading = true;
          });

         /* List<File> files = [];
          for (int i = 0; i < images.length; i++) {
            final path = await FlutterAbsolutePath.getAbsolutePath(images[i].identifier);
            files.add(File(path));
          }
*/

          var uri = Uri.parse(
              URL+'save_competition_promotion');
          final uploadRequest = http.MultipartRequest('POST', uri);

          for (int i = 0; i < files.length; i++) {
            final mimeTypeData =
            lookupMimeType(files[i].path, headerBytes: [0xFF, 0xD8]).split('/');

            final file = await http.MultipartFile.fromPath('images[$i]', files[i].path,
                contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
            uploadRequest.files.add(file);
          }



          uploadRequest.fields['auth_key'] = "VrdoCRJjhZMVcl3PIsNdM";
          uploadRequest.fields['id'] = _userId;
          uploadRequest.fields['name'] = compNameController.text;
          uploadRequest.fields['location'] = addressController.text;
          uploadRequest.fields['comments'] =cmtController.text!=null? cmtController.text:"";
          //uploadRequest.files.add(file);
          print(uploadRequest);
          try {
            final streamedResponse = await uploadRequest.send();
            final response =
            await http.Response.fromStream(streamedResponse);
            if (response.statusCode == 200) {
              setState(() {
                _loading = false;
              });
              var data = json.decode(response.body);
              Fluttertoast.showToast(msg: 'Message: ' + data['message'].toString());
              Navigator.pushNamed(
                context,
                '/dashboard',
              );
            }
          } catch (e) {
            print(e);
          }


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


  /*_getCurrentLocation() async {
    Position position =
    await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placeMarks[0];
    setState(() {
      _address =
          place.name +
              ', ' +
              place.subLocality +
              ', ' +
              place.locality +
              ' - ' +
              place.postalCode;

      addressController.text=_address;
    });

  }*/
  getUserLocation() async {//call this async method from whereever you need

    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
      myLocation = null;
    }
    //  currentLocation = myLocation;
    final coordinates = new Coordinates(
        myLocation.latitude, myLocation.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        coordinates);
    var first = addresses.first;
    print( '${first.addressLine},');
    addressController.text= first.addressLine.toString();

    return first;
  }
  Widget _addressTextBox() {
    return Container(
      // height: 80,
      margin: new EdgeInsets.only(left: 15, right: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Theme(
          data: Theme.of(context).copyWith(
            cursorColor: Color(0xff9b56ff),
            hintColor: Colors.transparent,
          ),
          child: InkWell(
            onTap: (){
              print("fkrwkrj");
              getUserLocation();
            },
            child: TextFormField(
                 maxLines: 4,
              enabled: false,
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Colors.grey,

                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.gps_fixed,
                      color: Color(0xff9b56ff),
                      size: 16,
                    ),
                   /* onPressed: () {
                      print("fkrwkrj");
                      getUserLocation();
                     // _getCurrentLocation();
                    },*/
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontFamily: "WorkSansLight"),
                  hintText: "Enter Address"),
              controller: addressController,
               minLines: 1,
              //Normal textInputField will be displayed
              cursorColor: Color(0xff9b56ff),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if (value.isEmpty) {
                  return "Please Enter Address";
                }
                return null;
              },
              onSaved: (String value) {
                _cmt = value;
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _commentTextBox() {
    return Container(
      height: 80,
      margin: new EdgeInsets.only(left: 15, right: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Theme(
          data: Theme.of(context).copyWith(
            cursorColor: Color(0xff9b56ff),
            hintColor: Colors.transparent,
          ),
          child: TextFormField(
            maxLines: 10,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                hintStyle: TextStyle(
                    color: Colors.grey[400], fontFamily: "WorkSansLight"),
                hintText: "Enter Comment"),
            controller: cmtController,
            minLines: 10,
            //Normal textInputField will be displayed
            cursorColor: Color(0xff9b56ff),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            validator: (value) {
              if (value.isEmpty) {
                return "Please Enter Comment";
              }
              return null;
            },
            onSaved: (String value) {
              _cmt = value;
            },
          ),
        ),
      ),
    );
  }

  Widget _firmTextBox() {
    return Container(
      margin: new EdgeInsets.only(left: 15, right: 15),
      //  height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: compNameController,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xff9b56ff),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Competitor Name';
            }
            return null;
          },
          onSaved: (String value) {
            compNameController.text = value;
          },
          decoration: InputDecoration(
            /* labelText: 'Title',
            labelStyle: TextStyle(color: Colors.black),*/
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
            hintStyle:
            TextStyle(color: Colors.grey[400], fontFamily: "WorkSansLight"),
            hintText: "Add Competitor Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Asset> images = List<Asset>();
  Future<void> pickImages() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarTitle: "Add Competition Promotion",
          useDetailsView: true,
        ),
      );
    } on Exception catch (e) {
      print(e);
    }

    setState(()  {
      images = resultList;


    });
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Add Competition Promotion',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[],
          //  backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Form(
            key: _formKey,
            child: ListView(children: <Widget>[
              Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),

                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "COMPETITOR PROMOTIONS",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color(0xfffb4d6d),
                              fontSize: 20,

                              wordSpacing: 1,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "COMPETITOR NAME",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            // fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    _firmTextBox(),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "LOCATION",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            // fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    _addressTextBox(),


                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "COMMENTS",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            // fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    _commentTextBox(),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "ATTACHMENT",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            // fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Container( padding: const EdgeInsets.only(left: 16,right: 16),child: buildGridView()),
                   /* Container(
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        children: <Widget>[
                          ClipOval(
                            child: Material(
                              color:Color(0xff9b56ff),// button color
                              child: InkWell(
                                splashColor:Color(0xfffb4d6d), // inkwell color
                                child: SizedBox(width: 56, height: 56, child: Icon(Icons.camera_alt,color: Colors.white,)),
                                onTap: () {
                                  show =true;
                                  pickImages();
                                },
                              ),
                            ),
                          ),
                          show?GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            padding: EdgeInsets.all(5),
                            children: List.generate(images.length, (index) {
                              Asset asset = images[index];
                              return AssetThumb(
                                asset: asset,
                                width: 300,
                                height: 300,
                              );
                            }),
                          ):Container(),

                        ],
                      ),
                    ),*/

                    SizedBox(
                      height: 30,
                    ),
                    _submitButton()
                  ],
                ),
              ),
            ]),
          ),
          // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ),
    );
  }

}


