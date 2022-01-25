import 'dart:async';


import 'package:glen_lms/modal/product_modal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' ;


class DatabaseHelper2 {
  static final DatabaseHelper2 _instance = new DatabaseHelper2.internal();

  factory DatabaseHelper2() => _instance;

  final String tableNote = 'ProductTable';
  final String columnId = 'id';
  final String columnProductId = 'product_id';
  final String columnCategoryId = 'category_id';
  final String columnSubCategoryId = 'sub_category_id';
  final String columnSapId = 'sap_id';
  final String columnProductName = 'product_name';
  final String columnModalNo = 'model_no';
  final String columnCurrentPrice = 'current_price';
  final String columnMop = 'mop';
  final String columnImage = 'image';
  final String columnQuantity= 'quantity';
  final String columnStock= 'stock';
  final String columnMrp= 'mrp';

  static Database _db1;

  DatabaseHelper2.internal();

  Future<Database> get db1 async {
    if (_db1 != null) {
      return _db1;
    }
    _db1 = await initDb();

    return _db1;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'product.db');

//    await deleteDatabase(path); // just for testing

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableNote($columnId INTEGER PRIMARY KEY, $columnProductId TEXT,$columnCategoryId TEXT, $columnSubCategoryId TEXT, $columnSapId TEXT, $columnProductName TEXT, $columnModalNo TEXT, $columnCurrentPrice TEXT,$columnMop TEXT, $columnImage TEXT,$columnQuantity TEXT, $columnStock TEXT, $columnMrp TEXT)');
  }

  Future<int> saveProduct(ProductModal modal) async {
    var dbClient = await db1;
    var result = await dbClient.insert(tableNote, modal.toMap());
//    var result = await dbClient.rawInsert(
//        'INSERT INTO $tableNote ($columnTitle, $columnDescription) VALUES (\'${note.title}\', \'${note.description}\')');

    return result;
  }

  Future<List> getAllProducts() async {
    var dbClient = await db1;
    var result = await dbClient.query(tableNote, columns: [columnId, columnProductId,columnCategoryId, columnSubCategoryId, columnSapId, columnProductName, columnModalNo, columnCurrentPrice,columnMop, columnImage, columnQuantity, columnStock, columnMrp]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote');

    return result.toList();
  }

  Future<int> getProductCount(id) async {
    var dbClient = await db1;
    return Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $tableNote WHERE $columnProductId=$id'));
  }

  Future<ProductModal> getNote(String id) async {
    var dbClient = await db1;
    List<Map> result = await dbClient.query(tableNote,
        columns: [columnId,columnProductId, columnCategoryId, columnSubCategoryId, columnSapId, columnProductName, columnModalNo, columnCurrentPrice,columnMop, columnImage, columnQuantity, columnStock, columnMrp],
        where: '$columnProductId = ?',
        whereArgs: [id]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote WHERE $columnId = $id');

    if (result.length > 0) {

      return new ProductModal.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteProduct(int id) async {
    var dbClient = await db1;
    return await dbClient.delete(tableNote, where: '$columnId = ?', whereArgs: [id]);
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
  }
  Future<int> deleteAllProduct() async {
    var dbClient = await db1;
    return await dbClient.delete(tableNote);
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
  }

  Future<int> updateNote(ProductModal modal) async {
    var dbClient = await db1;
    return await dbClient.update(tableNote, modal.toMap(), where: "$columnId = ?", whereArgs: [modal.id]);
//    return await dbClient.rawUpdate(
//        'UPDATE $tableNote SET $columnTitle = \'${note.title}\', $columnDescription = \'${note.description}\' WHERE $columnId = ${note.id}');
  }

  Future close() async {
    var dbClient = await db1;
    return dbClient.close();
  }
}
