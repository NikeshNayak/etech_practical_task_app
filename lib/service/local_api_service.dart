import 'package:etech_practical_task_app/models/media_video_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalAPIService {
  static late Database database;

  static const String _DATABASE_NAME = 'etech_practical_task.db';
  static const String _TABLE_MEDIAS = 'etech_medias';
  static const String _COLUMN_ID = 'id';
  static const String _COLUMN_TITLE = 'title';
  static const String _COLUMN_SUBTITLE = 'subtitle';
  static const String _COLUMN_THUMB = 'thumb';
  static const String _COLUMN_DESC = 'description';
  static const String _COLUMN_SOURCE = 'sources';
  static const String _COLUMN_FILEPATH = 'sourceFilePath';
  static const String _COLUMN_FILESIZE = 'fileSize';
  static const String _COLUMN_TASKID = 'taskId';
  static const String _COLUMN_DOWNLOADTASKSTATUS = 'downloadTaskStatus';
  static const String _COLUMN_PROGRESS = 'progress';

  Future<void> initDB() async {
    try {
      database = await openDatabase(
        join(await getDatabasesPath(), _DATABASE_NAME),
        // When the database is first created, create a table to store dogs.
        onCreate: (db, version) {
          // Run the CREATE TABLE statement on the database.
          return db.execute(
            'CREATE TABLE $_TABLE_MEDIAS($_COLUMN_ID INTEGER PRIMARY KEY, $_COLUMN_TITLE TEXT, $_COLUMN_SUBTITLE TEXT, $_COLUMN_THUMB TEXT, $_COLUMN_DESC TEXT, $_COLUMN_SOURCE TEXT, $_COLUMN_FILEPATH TEXT, $_COLUMN_FILESIZE INTEGER, $_COLUMN_TASKID TEXT, $_COLUMN_DOWNLOADTASKSTATUS INTEGER, $_COLUMN_PROGRESS INTEGER)',
          );
        },
        // Set the version. This executes the onCreate function and provides a
        // path to perform database upgrades and downgrades.
        version: 1,
      );
    } on DatabaseException catch (err) {
      print('Database Exception');
      print(err);
      rethrow;
    } catch (err) {
      print('Exception');
      print(err);
      rethrow;
    }
  }

  Future<void> insertMedia(MediaVideoModel video) async {
    try {
      final db = database;
      await db.insert(_TABLE_MEDIAS, {
        _COLUMN_ID: video.id,
        _COLUMN_TITLE: video.title,
        _COLUMN_SUBTITLE: video.subtitle,
        _COLUMN_DESC: video.description,
        _COLUMN_THUMB: video.thumb,
        _COLUMN_SOURCE: video.sources.first,
        _COLUMN_FILESIZE: video.fileSize,
        _COLUMN_FILEPATH: '',
        _COLUMN_TASKID: '',
        _COLUMN_DOWNLOADTASKSTATUS: video.downloadTaskStatus.index,
        _COLUMN_PROGRESS: video.progress,
      });
    } on DatabaseException catch (err) {
      print('Database Exception');
      print(err);
      rethrow;
    } catch (err) {
      print('Exception');
      print(err);
      rethrow;
    }
  }

  Future<MediaVideoModel?> isMediaExists(int id) async {
    try {
      final db = database;
      final medias = await db.query(_TABLE_MEDIAS, where: '$_COLUMN_ID = ?', whereArgs: [id]);
      return medias.isNotEmpty ? MediaVideoModel.fromLocalJson(medias.first) : null;
    } on DatabaseException catch (err) {
      print('Database Exception');
      print(err);
      rethrow;
    } catch (err) {
      print('Exception');
      print(err);
      rethrow;
    }
  }

  Future<MediaVideoModel?> fetchVideoByTaskId(String taskId) async {
    try {
      final db = database;
      final medias = await db.query(_TABLE_MEDIAS, where: '$_COLUMN_ID = ?', whereArgs: [taskId]);
      return medias.isNotEmpty ? MediaVideoModel.fromLocalJson(medias.first) : null;
    } on DatabaseException catch (err) {
      print('Database Exception');
      print(err);
      rethrow;
    } catch (err) {
      print('Exception');
      print(err);
      rethrow;
    }
  }

  Future<List<MediaVideoModel>> getAllMedias() async {
    try {
      final db = database;
      // Query the table for all The medias.
      final List<Map<String, dynamic>> maps = await db.query(_TABLE_MEDIAS, orderBy: _COLUMN_ID);

      return maps.isNotEmpty
          ? List.generate(maps.length, (i) {
              return MediaVideoModel.fromLocalJson(maps[i]);
            })
          : [];
    } on DatabaseException catch (err) {
      print('Database Exception');
      print(err);
      rethrow;
    } catch (err) {
      print('Exception');
      print(err);
      rethrow;
    }
  }

  Future<bool> updateMediaDownloadStart(int videoId, String taskId, String filePath) async {
    try {
      final db = database;

      int affectedRows = await db.update(
        _TABLE_MEDIAS,
        {
          _COLUMN_TASKID: taskId,
          _COLUMN_FILEPATH: filePath,
        },
        where: '$_COLUMN_ID = ?',
        whereArgs: [videoId],
      );
      return affectedRows > 0;
    } on DatabaseException catch (err) {
      print('Database Exception');
      print(err);
      rethrow;
    } catch (err) {
      print('Exception');
      print(err);
      rethrow;
    }
  }

  Future<bool> updateMediaDownloadProgress(String taskId, int downloadTaskStatus, int progress) async {
    try {
      final db = database;

      int affectedRows = await db.update(
        _TABLE_MEDIAS,
        {
          _COLUMN_DOWNLOADTASKSTATUS: downloadTaskStatus,
          _COLUMN_PROGRESS: progress,
        },
        where: '$_COLUMN_TASKID = ?',
        whereArgs: [taskId],
      );
      return affectedRows > 0;
    } on DatabaseException catch (err) {
      print('Database Exception');
      print(err);
      rethrow;
    } catch (err) {
      print('Exception');
      print(err);
      rethrow;
    }
  }

  Future<bool> resumeMediaDownloadProgress(int videoId, String newTaskId, int downloadTaskStatus, int progress) async {
    try {
      final db = database;

      int affectedRows = await db.update(
        _TABLE_MEDIAS,
        {
          _COLUMN_TASKID: newTaskId,
          _COLUMN_DOWNLOADTASKSTATUS: downloadTaskStatus,
          _COLUMN_PROGRESS: progress,
        },
        where: '$_COLUMN_ID = ?',
        whereArgs: [videoId],
      );
      return affectedRows > 0;
    } on DatabaseException catch (err) {
      print('Database Exception');
      print(err);
      rethrow;
    } catch (err) {
      print('Exception');
      print(err);
      rethrow;
    }
  }
}
