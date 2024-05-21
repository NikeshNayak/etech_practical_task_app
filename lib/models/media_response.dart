import 'dart:convert';

import 'media_video_model.dart';

MediaResponse mediaResponseFromJson(String str) => MediaResponse.fromJson(json.decode(str));

String mediaResponseToJson(MediaResponse data) => json.encode(data.toJson());

class MediaResponse {
  final List<MediaCategoryModel> categories;

  MediaResponse({
    required this.categories,
  });

  factory MediaResponse.fromJson(Map<String, dynamic> json) => MediaResponse(
        categories: List<MediaCategoryModel>.from(json["categories"].map((x) => MediaCategoryModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
      };
}

class MediaCategoryModel {
  final String name;
  final List<MediaVideoModel> videos;

  MediaCategoryModel({
    required this.name,
    required this.videos,
  });

  factory MediaCategoryModel.fromJson(Map<String, dynamic> json) => MediaCategoryModel(
        name: json["name"],
        videos: List<MediaVideoModel>.from(json["videos"].map((x) => MediaVideoModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "videos": List<dynamic>.from(videos.map((x) => x.toJson())),
      };
}
