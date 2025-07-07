import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/pokemon.dart';

class ApiRequest {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['API_URL'] ?? '';

  Future<Pokemon> fetchPokemonOfTheDay() async {
    debugPrint('Fetching Pokémon of the day from: $baseUrl/daily_pokemon');
    final response = await _dio.get('$baseUrl/daily_pokemon');
    debugPrint('$response');
    return Pokemon.fromJson(response.data);
  }
}
