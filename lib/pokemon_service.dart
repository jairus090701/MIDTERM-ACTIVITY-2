
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'pokemon.dart';

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  PokemonService({http.Client? client})
      : _client = client ?? http.Client();

  // Fetch the Pokémon list once when requested.
  Future<List<PokemonSummary>> fetchPokemonList() async {
    final uri = Uri.parse(
      '$_baseUrl/pokemon?limit=20&offset=0',
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      _checkStatus(response);

      final decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      final results = decoded['results'] as List<dynamic>? ?? [];

      return results
          .map(
            (item) => PokemonSummary.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (error) {
      if (error is TimeoutException) {
        throw Exception('The request timed out. Please try again.');
      }

      if (error is http.ClientException) {
        throw Exception(
          'Could not connect to the API. Check your internet.',
        );
      }

      if (error is FormatException) {
        throw Exception(
          'The API returned data that could not be read.',
        );
      }

      rethrow;
    }
  }

  Future<PokemonDetails> fetchPokemonDetails(int id) async {
    final uri = Uri.parse('$_baseUrl/pokemon/$id');

    try {
      final response = await _client.get(uri).timeout(_timeout);

      _checkStatus(response);

      final decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      return PokemonDetails.fromJson(decoded);
    } catch (error) {
      if (error is TimeoutException) {
        throw Exception(
          'The request timed out. Waiting for the next update.',
        );
      }

      if (error is http.ClientException) {
        throw Exception(
          'No internet connection. Waiting for the next update.',
        );
      }

      if (error is FormatException) {
        throw Exception(
          'The API returned data that could not be read.',
        );
      }

      rethrow;
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'API request failed (HTTP ${response.statusCode}).',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

Stream<PokemonUpdate> pokemonUpdateStream(
  PokemonService service,
) async* {
  var id = 1;

  while (true) {
    try {
      final pokemon = await service.fetchPokemonDetails(id);
      yield PokemonUpdate.success(pokemon);
    } catch (error) {
      yield PokemonUpdate.failure(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }

    id = id >= 151 ? 1 : id + 1;

    await Future<void>.delayed(
      const Duration(seconds: 5),
    );
  }
}

class PokemonUpdate {
  final PokemonDetails? pokemon;
  final String? errorMessage;

  const PokemonUpdate._({
    this.pokemon,
    this.errorMessage,
  });

  factory PokemonUpdate.success(PokemonDetails pokemon) {
    return PokemonUpdate._(pokemon: pokemon);
  }

  factory PokemonUpdate.failure(String message) {
    return PokemonUpdate._(errorMessage: message);
  }

  bool get hasError => errorMessage != null;
}
