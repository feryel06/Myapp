import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/contact.model.dart';

class ContactService {
  static final ContactService instance = ContactService._init();
  static Database? _database;

  final List<Contact> _webInMemoryContacts = [
    Contact(id: 1, nom: 'Mohamed Ben Ali', tel: '98 123 456'),
    Contact(id: 2, nom: 'Sarra Trabelsi', tel: '55 987 654'),
    Contact(id: 3, nom: 'Ahmed Gharbi', tel: '22 456 789'),
  ];
  int _webNextId = 4;

  ContactService._init();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('contacts.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final pathName = join(dbPath, filePath);

    return await openDatabase(
      pathName,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        tel TEXT NOT NULL
      )
    ''');

    await db.insert('contacts', {'nom': 'Mohamed Ben Ali', 'tel': '98 123 456'});
    await db.insert('contacts', {'nom': 'Sarra Trabelsi', 'tel': '55 987 654'});
    await db.insert('contacts', {'nom': 'Ahmed Gharbi', 'tel': '22 456 789'});
  }

  Future<List<Contact>> getContacts() async {
    if (kIsWeb) {
      return List.from(_webInMemoryContacts);
    }
    final db = await database;
    if (db == null) return List.from(_webInMemoryContacts);

    final maps = await db.query('contacts', orderBy: 'nom ASC');
    return maps.map((map) => Contact.fromMap(map)).toList();
  }

  Future<int> insertContact(Contact contact) async {
    if (kIsWeb) {
      contact.id = _webNextId++;
      _webInMemoryContacts.add(contact);
      return contact.id!;
    }
    final db = await database;
    if (db == null) {
      contact.id = _webNextId++;
      _webInMemoryContacts.add(contact);
      return contact.id!;
    }
    return await db.insert('contacts', contact.toMap());
  }

  Future<int> updateContact(Contact contact) async {
    if (kIsWeb) {
      final index = _webInMemoryContacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _webInMemoryContacts[index] = contact;
        return 1;
      }
      return 0;
    }
    final db = await database;
    if (db == null) {
      final index = _webInMemoryContacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _webInMemoryContacts[index] = contact;
        return 1;
      }
      return 0;
    }
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    if (kIsWeb) {
      _webInMemoryContacts.removeWhere((c) => c.id == id);
      return 1;
    }
    final db = await database;
    if (db == null) {
      _webInMemoryContacts.removeWhere((c) => c.id == id);
      return 1;
    }
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
