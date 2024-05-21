// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:path/path.dart';
//
// class HomePageNew extends StatefulWidget {
//   @override
//   _HomePage createState() => _HomePage();
// }
//
// class _HomePage extends State<HomePageNew> {
//   VideoModel myModel = new VideoModel();
//
//   VideoDownloader downloader;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     myModel.fetchVideoListFromDatabase();
//     super.initState();
//     this.downloader = new VideoDownloader();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     this.downloader = new VideoDownloader();
//     return new Scaffold(
//       backgroundColor: Colors.grey,
//       appBar: new AppBar(
//         title: new Text(
//           'Multiple Downloader Demo',
//           style: new TextStyle(color: Colors.white),
//         ),
//         actions: <Widget>[
//           new IconButton(
//             icon: new Icon(
//               Icons.add,
//               color: Colors.black,
//             ),
//
//           ),
//         ],
//         backgroundColor: Colors.green,
//       ),
//       body: ScopedModel<VideoModel>(
//         model: myModel,
//         child: _buildListView(),
//       ),
//     );
//   }
//
//   _buildListView() {
//     return ScopedModelDescendant<VideoModel>(
//       builder: (BuildContext context, Widget child, VideoModel model) {
//         final userList = model.users;
//         return ListView.builder(
//           itemBuilder: (context, index) => InkWell(
//             splashColor: Colors.blue[300],
//             child: _buildListTile(userList[index], index),
//             onTap: () {
//               print("Video Name: ${userList[index].videoName}");
//             },
//           ),
//           itemCount: userList.length,
//         );
//       },
//     );
//   }
//
//   _buildListTile(VideoModel userModel, int index) {
//     return Card(
//       child: ListTile(
//         leading: Icon(Icons.video_label),
//         title: Text(userModel.videoName),
//         trailing: new ScopedModelDescendant<VideoModel>(builder:
//             (BuildContext context, Widget child, VideoModel videosModel) {
//           final isList = videosModel.users;
//           if (isList[index].state == VideoeState.downloading) {
//             print("Progress Icon");
//             return new Container(
//                 height: 32.0,
//                 width: 32.0,
//                 child: new Padding(
//                   padding: EdgeInsets.all(6.0),
//                   child: new CircularProgressIndicator(
//                       strokeWidth: 2.0, value: videosModel.downloadProgress),
//                 ));
//           } else if (isList[index].state == VideoeState.toDownload) {
//             if (isList[index].videoLocalURL == "" &&
//                 isList[index].videoLocalURL.length == 0) {
//               print("Download Icon");
//               return new Container(
//                   height: 32.0,
//                   width: 32.0,
//                   child: new IconButton(
//                       icon: new Icon(Icons.cloud_download),
//                       onPressed: () {
//                         setState(() {
//                           Globals.videoID = isList[index].videoID.toString();
//                           downloader.performDownloadVideo(
//                               isList[index].videoLiveURL,
//                               isList[index].videoName,
//                               isList[index]);
//                         });
//                       }));
//             } else {
//               print("Play Icon");
//               return new IconButton(
//                   icon: new Icon(Icons.play_arrow),
//                   onPressed: () {
//                     print(
//                         "Going to play Video ${isList[index].videoName} from ${isList[index].videoLocalURL}");
//                   });
//             }
//           } else {
//             print("Play Default Icon");
//             return new IconButton(
//                 icon: new Icon(Icons.play_arrow),
//                 onPressed: () {
//                   // Ellipsis
//                   print(
//                       "Going to play Video ${videosModel.videoName} from ${videosModel.videoLocalURL}");
//                 });
//           }
//         }),
//       ),
//     );
//   }
// }
//
// class DownloadInfo {
//   VideoModel model;
//   String taskId;
//   String filePath;
//
//   DownloadInfo({this.model, this.taskId, this.filePath});
// }
//
// class VideoDownloader {
//   List<DownloadInfo> _downloadInfoList;
//
//   VideoDownloader() {
//     this._downloadInfoList = new List();
//     FlutterDownloader.registerCallback((id, status, progress) {
//       DownloadInfo downloadInfo = this.getDownloadInfoFromTaskId(id);
//       if (downloadInfo != null) {
//         if (status == DownloadTaskStatus.running) {
//           downloadInfo.model.setState(VideoeState.downloading);
//           downloadInfo.model.setDownloadProgress(progress / 100.0);
//         } else if (status == DownloadTaskStatus.complete) {
//           downloadInfo.model.setState(VideoeState.downloaded);
//           downloadInfo.model.setDownloadProgress(1.0);
//         } else {
//           downloadInfo.model.setState(VideoeState.toDownload);
//           downloadInfo.model.setDownloadProgress(0.0);
//         }
//       }
//       print(
//           'Download task ($id) is in status ($status) and process ($progress)');
//       if (progress == 100) {
//         DatabaseHelper.updateLocalVideoPath(
//             "${Globals.filePath}${"/" + Globals.fileName}", Globals.videoID);
//       }
//     });
//   }
//
//   Future<void> performDownloadVideo(
//       String liveURL, String videoName, VideoModel video) async {
//     var link = liveURL;
//     var path = await getVideosDirectoryPath();
//     var filename = videoName + ".mp4";
//
//     print("Downloading $link as $filename in $path");
//     Globals.filePath = path;
//     Globals.fileName = filename;
//
//     String taskId = await FlutterDownloader.enqueue(
//       url: link,
//       savedDir: path,
//       fileName: filename,
//       showNotification: true,
//     );
//
//     return _downloadInfoList.add(new DownloadInfo(
//       taskId: taskId,
//       model: video,
//       filePath: join(path, filename),
//     ));
//   }
//
//   Future<void> onComplete(DownloadInfo downloadInfo) async {
//     downloadInfo.model.setLocalFilePath(downloadInfo.filePath);
//   }
//
//   DownloadInfo getDownloadInfoFromTaskId(String taskId) {
//     if (this._downloadInfoList.length < 1) return null;
//     return this
//         ._downloadInfoList
//         .firstWhere((dli) => dli.taskId == taskId, orElse: () => null);
//   }
//
//   static Future<String> getVideosDirectoryPath() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final String videosPath = join(directory.path, "videos");
//     // Creating directory
//     await new Directory(videosPath).create(recursive: true);
//     return videosPath;
//   }
// }
//
//
// This is Model Class
//
// import 'dart:convert';
//
// import 'package:dowload_sample/HomePage.dart';
// import 'package:dowload_sample/database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:scoped_model/scoped_model.dart';
//
// enum VideoeState { toDownload, downloading, downloaded, playing, paused }
//
// class VideoModel extends Model {
//   String videoID = null;
//   String videoName = null;
//   String videoLiveURL = null;
//   String videoLocalURL;
//   VideoeState state;
//   double downloadProgress;
//   String localFilePath;
//
//   VideoeState get state1 => this.state ?? VideoeState.toDownload;
//
//   VideoModel(
//       {this.videoID,
//         @required this.videoName,
//         @required this.videoLiveURL,
//         @required this.videoLocalURL});
//
//   VideoModel.map(dynamic obj) {
//     this.videoID = obj["videoID"];
//     this.videoName = obj["videoName"];
//     this.videoLiveURL = obj["videoLiveURL"];
//     this.videoLocalURL = obj["videoLocalURL"];
//     this.state = VideoeState.toDownload;
//     this.downloadProgress = 0.0;
//   }
//
//
//   void setState(VideoeState state) {
//     this.state = state;
//     notifyListeners();
//   }
//
//
//   List<VideoModel> _userList = [];
//
//   List<VideoModel> get users => _userList;
//
//   set _users(List<VideoModel> value) {
//     _userList = value;
//     notifyListeners();
//   }
//
//   double get downloadProgress1 => this.downloadProgress ?? 0.0;
//
//   void setDownloadProgress(double x) {
//     this.downloadProgress = x;
//     notifyListeners();
//   }
//
//   String get localFilePath1 => this.localFilePath;
//
//   void setLocalFilePath(String filePath) {
//     if (filePath == null) {
//       return;
//     }
//     this.localFilePath = filePath;
//     if (this.state == VideoeState.downloading ||
//         this.state == VideoeState.toDownload) {
//       this.state = VideoeState.downloaded;
//     }
//     notifyListeners();
//   }
//
//   Map<String, dynamic> toMap() {
//     var map = new Map<String, dynamic>();
//     map["videoID"] = videoID;
//     map["videoName"] = videoName;
//     map["videoLiveURL"] = videoLiveURL;
//     map["videoLocalURL"] = videoLocalURL;
//     return map;
//   }
//
//   //Fetch data from the local data base
//   Future<List<VideoModel>> fetchVideoListFromDatabase() async {
//     DatabaseHelper dbHelper = DatabaseHelper();
//     _users = await dbHelper.getAllVideoList();
//     print("Length ${_userList.length}");
//     notifyListeners();
//     return _userList;
//   }
//
// }