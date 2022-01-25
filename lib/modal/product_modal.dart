class ProductModal {
  int _id;
  String _product_id;
  String _category_id;
  String _sub_category_id;
  String _sap_id;
  String _product_name;
  String _model_no;
  String _current_price;
  String _mop;
  String _image;
  String _quantity;
  String _stock;
  String _mrp;

  ProductModal(
      this._product_id,
      this._category_id,
      this._sub_category_id,
      this._sap_id,
      this._product_name,
      this._model_no,
      this._current_price,
      this._mop,
      this._image,
      this._quantity,
      this._stock,
      this._mrp,
      );

  ProductModal.map(dynamic obj) {
    this._id = obj['id'];
    this._product_id = obj['product_id'];
    this._category_id = obj['category_id'];
    this._sub_category_id = obj['sub_category_id'];
    this._sap_id = obj['sap_id'];
    this._product_name = obj['product_name'];
    this._model_no = obj['model_no'];
    this._current_price = obj['current_price'];
    this._mop = obj['mop'];
    this._image = obj['image'];
    this._quantity = obj['quantity'];
    this._stock = obj['stock'];
    this._mrp = obj['mrp'];
  }

  int get id => _id;
  String get product_id => _product_id;
  String get category_id => _category_id;
  String get sub_category_id => _sub_category_id;
  String get sap_id => _sap_id;
  String get product_name => _product_name;
  String get model_no => _model_no;
  String get current_price => _current_price;
  String get mop => _mop;
  String get image => _image;
  String get quantity => _quantity;
  String get stock => _stock;
  String get mrp => _mrp;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['product_id'] = _product_id;
    map['category_id'] = _category_id;
    map['sub_category_id'] = _sub_category_id;
    map['sap_id'] = _sap_id;
    map['product_name'] = _product_name;
    map['model_no'] = _model_no;
    map['current_price'] = _current_price;
    map['mop'] = _mop;
    map['image'] = _image;
    map['quantity'] = _quantity;
    map['stock'] = _stock;
    map['mrp'] = _mrp;

    return map;
  }

  ProductModal.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._product_id = map['product_id'];
    this._category_id = map['category_id'];
    this._sub_category_id = map['sub_category_id'];
    this._sap_id = map['sap_id'];
    this._product_name = map['product_name'];
    this._model_no = map['model_no'];
    this._current_price = map['current_price'];
    this._mop = map['mop'];
    this._image = map['image'];
    this._quantity = map['quantity'];
    this._stock = map['stock'];
    this._mrp = map['mrp'];
  }
}
