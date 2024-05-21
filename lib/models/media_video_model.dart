import 'package:flutter_downloader/flutter_downloader.dart';

class MediaVideoModel {
  final int id;
  final String description;
  final List<String> sources;
  final String subtitle;
  final String thumb;
  final String title;
  final int fileSize;
  String? sourceFilePath;
  String? taskId;
  DownloadTaskStatus downloadTaskStatus;
  int progress;

  MediaVideoModel({
    required this.id,
    required this.description,
    required this.sources,
    required this.subtitle,
    required this.thumb,
    required this.title,
    this.fileSize = 0,
    this.sourceFilePath,
    this.taskId,
    this.downloadTaskStatus = DownloadTaskStatus.undefined,
    this.progress = 0,
  });

  MediaVideoModel copyWith({
    int? id,
    String? description,
    List<String>? sources,
    String? subtitle,
    String? thumb,
    String? title,
    int? fileSize,
    String? sourceFilePath,
    String? taskId,
    DownloadTaskStatus? downloadTaskStatus,
    int? progress,
  }) =>
      MediaVideoModel(
        id: id ?? this.id,
        description: description ?? this.description,
        sources: sources ?? this.sources,
        subtitle: subtitle ?? this.subtitle,
        thumb: thumb ?? this.thumb,
        title: title ?? this.title,
        fileSize: fileSize ?? this.fileSize,
        sourceFilePath: sourceFilePath ?? this.sourceFilePath,
        taskId: taskId ?? this.taskId,
        downloadTaskStatus: downloadTaskStatus ?? this.downloadTaskStatus,
        progress: progress ?? this.progress,
      );

  factory MediaVideoModel.fromJson(Map<String, dynamic> json) => MediaVideoModel(
        id: json["id"],
        description: json["description"],
        sources: List<String>.from(json["sources"].map((x) => x)),
        subtitle: json["subtitle"],
        thumb: json["thumb"],
        title: json["title"],
      );

  factory MediaVideoModel.fromLocalJson(Map<String, dynamic> json) => MediaVideoModel(
        id: json["id"],
        description: json["description"],
        sources: [json["sources"] as String],
        subtitle: json["subtitle"],
        thumb: json["thumb"],
        title: json["title"],
        fileSize: json["fileSize"],
        sourceFilePath: json["sourceFilePath"],
        taskId: json['taskId'],
        downloadTaskStatus: DownloadTaskStatus.fromInt(json['downloadTaskStatus']),
        progress: json['progress'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "sources": List<dynamic>.from(sources.map((x) => x)),
        "subtitle": subtitle,
        "thumb": thumb,
        "title": title,
        "fileSize": fileSize,
        "sourceFilePath": sourceFilePath,
        "taskId": taskId,
        "downloadTaskStatus": downloadTaskStatus.index,
        "progress": progress,
      };

  Map<String, dynamic> toLocalJson() => {
    "id": id,
    "description": description,
    "sources": List<dynamic>.from(sources.map((x) => x)),
    "subtitle": subtitle,
    "thumb": thumb,
    "title": title,
    "fileSize": fileSize,
    "sourceFilePath": sourceFilePath,
    "taskId": taskId,
    "downloadTaskStatus": downloadTaskStatus.index,
    "progress": progress,
  };
}
