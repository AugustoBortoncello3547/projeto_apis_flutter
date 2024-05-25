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
    final article = widget.article;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notícia',
          style: TextStyle(
            color: Colors.white, // Define a cor do texto
            fontSize: 20, // Tamanho da fonte
            fontWeight: FontWeight.bold, // Peso da fonte
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(0, 108, 255, 1.0),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article?.urlToImage != null)
                Image.network(
                  article!.urlToImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              const SizedBox(height: 20),
              Text(
                article?.title ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'By ${article?.author ?? 'Autor desconhecido'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                article?.publishedAt ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                article?.description ?? '',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                article?.content ?? '',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
