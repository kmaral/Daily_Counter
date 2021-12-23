import 'package:intl/intl.dart';
import 'package:my_counter/models/CounterInfo.dart';
import 'package:my_counter/models/CounterInfoHistory.dart';
import 'package:my_counter/models/ResetCounterInfo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

final String tableCounters = 'countersList';
final String columncounterId = 'counterId';
final String columncounterName = 'counterName';
final String columncountNumber = 'counter';
final String columncreatedDateTime = 'createdtimeStamp';
final String columnlasttimestamp = 'lasttimeStamp';
final String columnisDeleted = 'isDeleted';
final String columnArchivetimestamp = 'archiveOn';

//CounterHistory
final String tableCounterHistory = 'countersListHistory';
final String columnhistoryId = 'historyid';
//ResetCounterHistory
final String tableResetCounterHistory = 'counterResetHistory';
final String columnResetCounterId = 'resetId';
final String columnIsCounterreset = 'isCounterreseted';
final String columnresetCounter = 'resetCounter';
final String columncounterendtimestamp = 'endtimeStamp';

class CounterDBHelper {
  static Database _database;
  static CounterDBHelper _counterDBHelper;

  CounterDBHelper._createInstance();
  factory CounterDBHelper() {
    if (_counterDBHelper == null) {
      _counterDBHelper = CounterDBHelper._createInstance();
    }
    return _counterDBHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "dailyCounters.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableCounters ( 
         $columncounterId integer primary key autoincrement, 
          $columncounterName text not null,
          $columncountNumber integer not null,
          $columncreatedDateTime text not null,
          $columnlasttimestamp text not null,
          $columnisDeleted integer not null,
          $columnArchivetimestamp text not null
          )
        ''');
        db.execute('''
          create table $tableCounterHistory ( 
         $columnhistoryId integer primary key autoincrement, 
         $columncounterId integer, 
          $columncountNumber text not null,
          $columnlasttimestamp text not null)
        ''');
        db.execute('''
          create table $tableResetCounterHistory ( 
         $columnResetCounterId integer primary key autoincrement, 
         $columncounterId integer, 
          $columnresetCounter integer not null,
          $columnIsCounterreset integer not null,
          $columncounterendtimestamp text not null)
        ''');
      },
    );
    return database;
  }

  Future<int> insertCounters(CounterInfo counterInfo) async {
    var db = await this.database;

    int result = await db.insert(tableCounters, counterInfo.toMap());
    print('result : $result');
    return result;
  }

  void insertResetCounters(
      int counterId, int _counter, String enddatetime, int isReset) async {
    var db = await this.database;
    var resetCounterInfo = ResetCounterInfo(
        counterId: counterId,
        resetCounter: _counter,
        isCounterreseted: isReset,
        endtimeStamp: enddatetime);
    int result =
        await db.insert(tableResetCounterHistory, resetCounterInfo.toMap());
    print('result : $result');
  }

  _insertCounterHistory(
      int counterId, String _counter, String lastdatetime) async {
    var db = await this.database;
    var counterHistorynfo = CounterInfoHistory(
        counterId: counterId, counter: _counter, lasttimeStamp: lastdatetime);
    int result =
        await db.insert(tableCounterHistory, counterHistorynfo.toMap());
    print('result : $result');
  }

  Future<List<CounterInfo>> getCounters() async {
    List<CounterInfo> _counters = [];
    var result;
    var db = await this.database;
    result = await db.query(
      tableCounters,
      where: '$columnisDeleted = ?',
      whereArgs: [1],
      orderBy: "createdtimeStamp DESC",
    );
    if (result != null) {
      result.forEach((element) {
        var counterInfo = CounterInfo.fromMap(element);
        _counters.add(counterInfo);
        print(counterInfo.counterId.toString() +
            "" +
            counterInfo.counterName +
            " " +
            counterInfo.isDeleted.toString() +
            " " +
            counterInfo.archiveOn +
            " " +
            counterInfo.createdtimeStamp);
      });
    }
    return _counters;
  }

  Future<List<CounterInfo>> getArchiveCounters() async {
    List<CounterInfo> _counters = [];
    var result;
    var db = await this.database;
    result = await db.query(
      tableCounters,
      where: '$columnisDeleted = ?',
      whereArgs: [0],
      orderBy: "archiveOn DESC",
    );
    if (result != null) {
      result.forEach((element) {
        var counterInfo = CounterInfo.fromMap(element);
        _counters.add(counterInfo);
        print(counterInfo.counterId.toString() +
            "" +
            counterInfo.counterName +
            " " +
            counterInfo.isDeleted.toString() +
            " " +
            counterInfo.archiveOn +
            " " +
            counterInfo.createdtimeStamp);
      });
    }
    return _counters;
  }

  Future<List<ResetCounterInfo>> getResetCounters(int counterId) async {
    List<ResetCounterInfo> _resetCounters = [];
    var result;
    final db = await database;
    result = await db.query(
      tableResetCounterHistory,
      where: '$columncounterId = ?',
      whereArgs: [counterId],
      orderBy: "endtimeStamp DESC",
    );
    if (result != null) {
      result.forEach((element) {
        var resetCounterInfo = ResetCounterInfo.fromMap(element);
        _resetCounters.add(resetCounterInfo);
        print(_resetCounters[0].counterId);
      });
    }

    return _resetCounters;
  }

  Future<List<CounterInfoHistory>> getHistoryCounters(int counterId) async {
    List<CounterInfoHistory> _historyCounters = [];
    var result;
    var db = await this.database;
    result = await db.query(
      tableCounterHistory,
      where: '$columncounterId = ?',
      whereArgs: [counterId],
      orderBy: "historyid DESC",
    );
    if (result != null) {
      result.forEach((element) {
        var historyCounterInfo = CounterInfoHistory.fromMap(element);
        _historyCounters.add(historyCounterInfo);
      });
    }
    return _historyCounters;
  }

  Future<List<CounterInfo>> getCountersById() async {
    List<CounterInfo> _counters = [];
    var result;
    var db = await this.database;
    result = await db.query(tableCounters);
    if (result != null) {
      result.forEach((element) {
        var counterInfo = CounterInfo.fromMap(element);
        _counters.add(counterInfo);
      });
    }
    return _counters;
  }

  Future<int> delete(int counterId) async {
    final db = await database;
    int resultdelete = 0;

    resultdelete = await db
        .delete(tableCounters, where: 'counterId = ?', whereArgs: [counterId]);
    if (resultdelete > 0) {
      int historyResult = await db.delete(tableCounterHistory,
          where: 'counterId = ?', whereArgs: [counterId]);

      if (historyResult > 0) {
        int resultcounter = await db.delete(tableResetCounterHistory,
            where: 'counterId = ?', whereArgs: [counterId]);
        if (resultcounter > 0) {
          return resultcounter;
        }
        return historyResult;
      }

      var result;

      result = await db.query(tableCounters);
      if (result != null) {
        result.forEach((element) {
          var counterInfo = CounterInfo.fromMap(element);
          print(counterInfo.counterId);
        });
      }
    }
    return resultdelete;
  }

  Future<List<CounterInfo>> getcountersById(int counterId) async {
    List<CounterInfo> _counters = [];
    final db = await database;
    var result = await db.query(tableCounters,
        where: '$columncounterId = ?', whereArgs: [counterId]);
    if (result != null) {
      result.forEach((element) {
        var counterInfo = CounterInfo.fromMap(element);
        _counters.add(counterInfo);
      });
    }
    return _counters;
  }

  Future<int> incrementCounter(
      int counterId, int counter, String lasttimestamp) async {
    DateTime timestamp = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    var db = await this.database;
    int updateCount = await db.rawUpdate('''
    UPDATE $tableCounters
    SET $columncountNumber = ?, $columnlasttimestamp = ?
    WHERE $columncounterId = ?
    ''', [counter, lasttimestamp, counterId]);
    _insertCounterHistory(
        counterId, counter.toString() + " (+)", lasttimestamp);
    updateResetCounter(counterId, counter, formatter.format(timestamp));
    return updateCount;
  }

  Future<int> decrementCounter(
      int counterId, int counter, String lasttimestamp) async {
    DateTime timestamp = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    var db = await this.database;
    int updateCount = await db.rawUpdate('''
    UPDATE $tableCounters
    SET $columncountNumber = ?, $columnlasttimestamp = ?
    WHERE $columncounterId = ?
    ''', [counter, lasttimestamp, counterId]);
    _insertCounterHistory(
        counterId, counter.toString() + " (-)", lasttimestamp);
    updateResetCounter(counterId, counter, formatter.format(timestamp));
    return updateCount;
  }

  Future<int> updateCounterNumber(int counterId, int counterNumber,
      String lasttimestamp, String value) async {
    var db = await this.database;
    int updateCount = await db.rawUpdate('''
    UPDATE $tableCounters
    SET $columncountNumber = ?, $columnlasttimestamp = ?
    WHERE $columncounterId = ?
    ''', [counterNumber, lasttimestamp, counterId]);
    _insertCounterHistory(
        counterId, counterNumber.toString() + value, lasttimestamp);
    return updateCount;
  }

  Future<int> updateCounters(
      int counterId, String counterName, String lasttimestamp) async {
    var db = await this.database;
    int updateCount = await db.rawUpdate('''
    UPDATE $tableCounters
    SET $columncounterName = ?, $columnlasttimestamp = ?
    WHERE $columncounterId = ?
    ''', [counterName, lasttimestamp, counterId]);

    return updateCount;
  }

  Future<int> updateCountersDateTime(int counterId, String createtimestamp,
      String lasttimestamp, int counter) async {
    var db = await this.database;
    int updateCount = await db.rawUpdate('''
    UPDATE $tableCounters
    SET $columncreatedDateTime = ?, $columnlasttimestamp = ?,$columncountNumber=?
    WHERE $columncounterId = ?
    ''', [createtimestamp, lasttimestamp, counter, counterId]);

    return updateCount;
  }

  Future<int> updateArchive(int counterId, String archiveOn) async {
    var db = await this.database;
    int updateCount = await db.rawUpdate('''
    UPDATE $tableCounters
    SET $columnisDeleted = ?, $columnArchivetimestamp = ?
    WHERE $columncounterId = ?
    ''', [0, archiveOn, counterId]);

    return updateCount;
  }

  Future<int> updateReset(int counterId, int isReset) async {
    var db = await this.database;
    int updateCount = await db.rawUpdate('''
    UPDATE $tableResetCounterHistory
    SET $columnIsCounterreset = ?
    WHERE $columncounterId = ?''', [0, counterId]);
    return updateCount;
  }

  Future<int> updateResetCounterTimestamp1(
      int counterId, int counterNumber) async {
    var db = await this.database;
    int updateCount = await db.rawUpdate('''
    UPDATE $tableResetCounterHistory
    SET $columnresetCounter = ?
    WHERE $columncounterId = ? and $columnIsCounterreset = ?''',
        [counterNumber, counterId, 1]);
    return updateCount;
  }

  Future<int> updateResetCounter(
      int counterId, int counterNumber, String endTimestamp) async {
    var db = await this.database;
    int updateCount = await db.rawUpdate('''
    UPDATE $tableResetCounterHistory
    SET $columnresetCounter = ?,$columncounterendtimestamp=?
    WHERE $columncounterId = ? and $columnIsCounterreset = ?''',
        [counterNumber, endTimestamp, counterId, 1]);

    return updateCount;
  }
}
