import 'package:servicestack/servicestack.dart';

import 'dart:convert';
class OrderJson implements IConvertible{
  String product_id;
  String sap_id;
  String category_id;
  String sub_category_id;
  String product_name;
  String model_no;
  String current_price;
  String quantity;
  String image;
  String mrp;

  OrderJson(
      {
        this.product_id,
        this.sap_id,
        this.category_id,
        this.sub_category_id,
        this.product_name,
        this.model_no,
        this.current_price,
        this.quantity,
        this.image,
        this.mrp
      });

  OrderJson.fromJson(Map<String, dynamic> json)
  {
    fromMap(json);
  }

  fromMap(Map<String, dynamic> json) {
    product_id = json['product_id'];
    sap_id = json['sap_id'];
    category_id = json['category_id'];
    sub_category_id = json['sub_category_id'];
    product_name = json['product_name'];
    model_no = json['model_no'];
    current_price = json['current_price'];
    quantity = json['quantity'];
    image = json['image'];
    mrp = json['mrp'];
    return this;
  }

  Map<String, dynamic> toJson() =>{
    'product_id' : product_id,
    'sap_id' : sap_id,
    'category_id' : category_id,
    'sub_category_id' : sub_category_id,
    'product_name' : product_name,
    'model_no' : model_no,
    'current_price' : current_price,
    'quantity' : quantity,
    'image' : image,
    'mrp' : mrp,
  };

  @override
  TypeContext context;

}