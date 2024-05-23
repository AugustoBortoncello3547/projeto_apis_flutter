import 'package:flutter/material.dart';
import 'package:projeto_apis_flutter/model/article.dart';

class ArticleDetail extends StatefulWidget {
  const ArticleDetail({super.key, required this.article});

  final Article? article;

  @override
  _ArticleDetailState createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Article"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [Text(widget.article!.title)],
          )),
    );
  }
}
