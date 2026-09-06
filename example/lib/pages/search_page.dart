import 'package:dio/dio.dart';
import 'package:example/models/post.dart';
import 'package:flutter/material.dart';
import 'package:reactive_flutter/reactive_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _ctrl = TextEditingController();
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),
  );

  // ✅ ReactiveSearch wired to JSONPlaceholder
  late final ReactiveSearch<Post> _search = ReactiveSearch<Post>(
    debounceMs: 500,
    minLength: 2,
    fetcher: (String query) async {
      try {
        final Response<List<dynamic>> response = await _dio.get(
          '/posts',
          queryParameters: {'q': query},
        );
        return response.data?.map((e) => Post.fromMap(e)).toList() ?? [];
      } on DioException catch (e) {
        throw e.error ?? e.message ?? e.toString();
      }
    },
  );

  @override
  void dispose() {
    _ctrl.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reactive Search')),
      body: Watch(
        builder: () {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 10),
            child: Column(
              spacing: 10,
              children: [
                // ── Search field ──────────────────────────────────────────
                TextField(
                  controller: _ctrl,
                  onChanged: _search.onChanged,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _ctrl.clear();
                              _search.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // ── Results ───────────────────────────────────────────────
                Expanded(
                  child: Watch(
                    builder: () {
                      final SearchState<Post> s = _search.state;

                      if (s.isIdle) {
                        return const _CenterMsg(
                          icon: Icons.search,
                          text: 'Type at least 2 characters',
                        );
                      }

                      if (s.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (s.hasError) {
                        return _CenterMsg(
                          icon: Icons.error_outline,
                          text: s.error!,
                        );
                      }

                      if (s.isEmpty) {
                        return _CenterMsg(
                          icon: Icons.mood_bad,
                          text: 'No results for "${s.query}"',
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Text(
                              '${s.results.length} results for "${s.query}"',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: s.results.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.only(bottom: 40),
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                Post post = s.results[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(
                                      post.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      post.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 10);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CenterMsg extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CenterMsg({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
