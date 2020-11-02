import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'model/note.dart';


class AnotacaoHelper {

  static final String FILE_DB = "my_notes.db";
  static final String TABLE_NAME = "notes";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database _db;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal() {}

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicializarDB();
    }
    return _db;
  }

  _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE $TABLE_NAME (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR, description TEXT, date DATETIME)";
    await db.execute(sql);
  }

  inicializarDB() async {
    final pathDB = await getDatabasesPath();
    final localDB = join(pathDB, FILE_DB);

    var db = await openDatabase(localDB, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> salvarAnotacao(Note note) async {
    var banco = await db;
    int id = await banco.insert(TABLE_NAME, note.toMap());

    return id;
  }

  Future<int> atualizarAnotacao(Note note) async {
    var banco = await db;
    return await banco.update(
        TABLE_NAME,
        note.toMap(),
        where: "id = ?",
        whereArgs: [note.id]
    );
  }

  Future<List> listarAnotacoes() async {
    var banco = await db;
    String sql = "SELECT * FROM $TABLE_NAME ORDER BY date DESC";
    List notes = await banco.rawQuery(sql);
    return notes;
  }

  removerAnotacao(int id) async {
    var banco = await db;
    return await banco.delete(
        TABLE_NAME,
        where: "id = ?",
        whereArgs: [id]);
  }
}