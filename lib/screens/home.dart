import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_apis_flutter/config/config.dart';
import 'dart:convert';

import 'package:projeto_apis_flutter/model/article.dart';
import 'package:projeto_apis_flutter/model/news_response.dart';
import 'package:projeto_apis_flutter/screens/article_detail.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Article>> futureArticles;
  int defaultPageSize = 50;

  Future<List<Article>> buscar(String busca) {
    var buscaParseada = busca.isNotEmpty ? busca : "technology";
    var url = Uri.https('newsapi.org', '/v2/everything', {
      'q': buscaParseada,
      'from': "2024-05-22",
      "pageSize": defaultPageSize.toString(),
      'sortBy': 'popularity',
      'apiKey': Config.apiKey
    });

    return http.get(url).then((value) {
      if (value.statusCode == 200) {
        final resp = jsonDecode(value.body) as Map<String, dynamic>;
        final newsResp = NewsResponse.fromJson(resp);
        return newsResp.articles.map((regArticle) {
          return Article.fromJson(regArticle);
        }).toList();
      } else {
        throw Exception('Buscar vários articles: Erro chamada HTTP');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    futureArticles = buscar("");
  }

  //Validar se a URL é valida, pois existem diversos links com tipos de imagens
  bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        (url.endsWith('.png') ||
            url.endsWith('.jpg') ||
            url.endsWith('.jpeg') ||
            url.endsWith('.webp'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notícias',
          style: TextStyle(
            color: Colors.white, // Define a cor do texto
            fontSize: 20, // Tamanho da fonte
            fontWeight: FontWeight.bold, // Peso da fonte
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(0, 108, 255, 1.0),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar artigo...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (value) {
                  setState(() {
                    futureArticles = buscar(value);
                  });
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: FutureBuilder<List<Article>>(
                  future: futureArticles,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Houve um erro: ${snapshot.error}'),
                      );
                    } else {
                      final listaArticles = snapshot.data;

                      return ListView.builder(
                        itemCount: listaArticles?.length,
                        itemBuilder: (context, index) {
                          final article = listaArticles?[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ArticleDetail(article: article),
                                  ),
                                );
                              },
                              leading: isValidImageUrl(article?.urlToImage)
                                  ? Image.network(article!.urlToImage!,
                                      width: 50, fit: BoxFit.cover)
                                  : const Icon(Icons.image, size: 50),
                              title: Text(article!.title ?? ''),
                              subtitle: Text(
                                article.description ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
