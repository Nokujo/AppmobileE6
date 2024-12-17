import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieDetailsScreen extends StatefulWidget {
  final String imdbID;

  const MovieDetailsScreen({super.key, required this.imdbID});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  Map<String, dynamic>? movieDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    const apiKey = 'f41866d6';
    final response = await http.get(
      Uri.parse('http://www.omdbapi.com/?apikey=$apiKey&i=${widget.imdbID}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        movieDetails = json.decode(response.body);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movieDetails?['Title'] ?? 'Movie Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0), 
              child: movieDetails != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,   
                children: [
                 if (movieDetails!['Poster'] != 'N/A') 
                  Center(
                    child: Image.network(
                      movieDetails!['Poster'],
                      height: 300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movieDetails!['Title'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text('Year: ${movieDetails!['Year']}'),
                  Text('Runtime: ${movieDetails!['Runtime']}'),
                  Text('Genre: ${movieDetails!['Genre']}'),
                  Text('Director: ${movieDetails!['Director']}'),
                  Text('Plot: ${movieDetails!['Plot']}'),
                  Text('Rating: ${movieDetails!['imdbRating']}'),
                ],
              )
              : const Center(child: Text('No movie details available')),
            ),
    );
  }
}
