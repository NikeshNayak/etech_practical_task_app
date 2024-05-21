import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etech_practical_task_app/utils/constants.dart';

class RemoteApiService {
  final dio = Dio();

  Future<dynamic> fetchMedias() async {
    try {
      final response = await dio.get(baseUrl, queryParameters: {
        'id': '1FEOTw_ioZ4SR4Iq5UxqsqcEgKAg3bNtX',
      });
      if (response.statusCode == 200) {
        return json.decode(response.data);
      } else {
        throw Exception('Failed to load medias');
      }
    } on DioException catch (err) {
      print('Dio Exception');
      print(err);
      rethrow;
    } catch (err) {
      print('Exception');
      print(err);
      rethrow;
    }
  }

  Future<int> fetchFileSize(String imageUrl) async {
    int fileSize = 0;
    try {
      final response = await dio.head(imageUrl);
      if (response.headers.value(Headers.contentLengthHeader) != null) {
        fileSize = int.parse(response.headers.value(Headers.contentLengthHeader)!);
      }
    } catch (e) {
      print(e);
    }
    return fileSize;
  }
}
