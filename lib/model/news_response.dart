import 'package:projeto_apis_flutter/model/article.dart';

class NewsResponse {
  NewsResponse(
      {required this.status,
      required this.totalResults,
      required this.articles});

  String status;
  int totalResults;
  List articles;

  factory NewsResponse.fromJson(Map<String, dynamic> json) => NewsResponse(
      status: json['status'],
      totalResults: json['totalResults'],
      articles: json['articles']);
}
