import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_apis_flutter/config/config.dart';
import 'dart:convert';

import 'package:projeto_apis_flutter/model/article.dart';
import 'package:projeto_apis_flutter/model/news_response.dart';
import 'package:projeto_apis_flutter/screens/article_detail.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Article>> futureArticles;
  int defaultPageSize = 50;

  Future<List<Article>> buscar(String busca) {
    var buscaParseada = busca.isNotEmpty ? busca : "a";
    var url = Uri.https('newsapi.org', '/v2/everything', {
      'q': buscaParseada,
      'from': "2024-04-22",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Pesquisar artigo...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                setState(() {
                  futureArticles = buscar(value);
                });
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
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

                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ArticleDetail(article: article),
                                ),
                              );
                            },
                            title: Text(article!.title),
                            subtitle: Text(article.description),
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
