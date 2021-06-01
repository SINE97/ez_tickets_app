import 'package:hooks_riverpod/hooks_riverpod.dart';

//Providers
import 'all_providers.dart';

//Services
import '../services/repositories/movies_repository.dart';

//Enums
import '../enums/movie_type_enum.dart';

//Models
import '../models/genre_model.dart';
import '../models/movie_model.dart';
import '../models/movie_role_model.dart';

final moviesFuture = FutureProvider.family.autoDispose<List<MovieModel>, MovieType?>(
  (ref, movieType) async {
    final _moviesProvider = ref.watch(moviesProvider);

    final moviesList = await _moviesProvider.getAllMovies(
      movieType: movieType,
    );

    return moviesList;
  },
);

final selectedMovieProvider = StateProvider<MovieModel>((ref) {
  return MovieModel.initial();
});

final leftMovieProvider = StateProvider<MovieModel>((ref) {
  return MovieModel.initial();
});

final rightMovieProvider = StateProvider<MovieModel>((ref) {
  return MovieModel.initial();
});

class MoviesProvider {
  final MoviesRepository _moviesRepository;

  MoviesProvider(this._moviesRepository);

  Future<List<MovieModel>> getAllMovies({
    MovieType? movieType,
  }) async {
    final Map<String, String>? queryParams = {
      if (movieType != null) "movie_type": movieType.toJson,
    };
    return await _moviesRepository.fetchAll(queryParameters: queryParams);
  }

  Future<MovieModel> getMovieById({
    required int movieId,
  }) async {
    return await _moviesRepository.fetchOne(movieId: movieId);
  }

  Future<List<MovieRoleModel>> getMovieRoles({
    required int movieId,
  }) async {
    return await _moviesRepository.fetchMovieRoles(movieId: movieId);
  }

  Future<MovieModel> uploadNewMovie({
    required String title,
    required int year,
    required String summary,
    required String trailerUrl,
    required String posterUrl,
    required double rating,
    required MovieType movieType,
    required List<MovieRoleModel> movieRoles,
    required List<GenreModel> movieGenres,
  }) async {
    final movie = MovieModel(
      movieId: null,
      title: title,
      year: year,
      summary: summary,
      trailerUrl: trailerUrl,
      posterUrl: posterUrl,
      rating: rating,
      genres: movieGenres,
      movieType: movieType,
    );
    final roles =
        movieRoles.map((movieRole) => movieRole.toCustomJson()).toList();
    final data = <String, dynamic>{
      ...movie.toJson(),
      "roles": roles,
    };
    final movieId = await _moviesRepository.create(data: data);
    return movie.copyWith(movieId: movieId);
  }

  Future<String> editMovie({
    required MovieModel movie,
    String? title,
    int? year,
    String? summary,
    String? trailerUrl,
    String? posterUrl,
    double? rating,
    MovieType? movieType,
  }) async {
    final data = movie.toUpdateJson(
      title: title,
      year: year,
      summary: summary,
      trailerUrl: trailerUrl,
      posterUrl: posterUrl,
      rating: rating,
      movieType: movieType,
    );
    if (data.isEmpty) return "Nothing to update!";
    return await _moviesRepository.update(movieId: movie.movieId!, data: data);
  }

  Future<String> removeMovie({
    required int movieId,
  }) async {
    return await _moviesRepository.delete(movieId: movieId);
  }

  void cancelNetworkRequest(){
    _moviesRepository.cancelRequests();
  }
}
