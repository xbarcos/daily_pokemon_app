import 'package:daily_pokemon_app/api/api_request.dart';
import 'package:daily_pokemon_app/helper/coin_rewarder.dart';
import 'package:daily_pokemon_app/helper/local_storage.dart';
import 'package:daily_pokemon_app/widgets/coins_text.dart';
import 'package:daily_pokemon_app/widgets/restart_button.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pokemon.dart';
import 'package:flutter/scheduler.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Future<Pokemon> _futurePokemon;
  Set<String> guessedLetters = {};
  int wrongGuesses = 0;
  final int maxErrors = 5;
  String todayKey = DateTime.now().toIso8601String().substring(0, 10);
  bool hasRewardGiven = false;
  int coinBalance = 0;
  bool coinsGiven = false;

  @override
  void initState() {
    super.initState();
    _futurePokemon = ApiRequest().fetchPokemonOfTheDay();
    _loadLocalState();
    _loadCoinBalance();
  }

  void _loadCoinBalance() async {
    final coins = await LocalStorage.getCoins();
    debugPrint('Current coin balance: $coins');
    setState(() {
      coinBalance = coins;
    });
  }

  void _giveCoinsIfEligible(Pokemon pokemon) async {
    final gaveCoins = await LocalStorage.getGameState('coins_given_$todayKey');
    if (gaveCoins == 'true') return;
    await LocalStorage.saveGameState('coins_given_$todayKey', 'true');
    await CoinRewarder.rewardCoinsBasedOnErrors(wrongGuesses);
    setState(() {
      coinsGiven = true;
    });
  }

  void _loadLocalState() async {
    final savedGuesses = await LocalStorage.getGameState('guesses_$todayKey');
    final savedErrors = await LocalStorage.getGameState('errors_$todayKey');
    final gaveCoins = await LocalStorage.getGameState('coins_given_$todayKey');
    if (gaveCoins == 'true') {
      coinsGiven = true;
    }

    if (savedGuesses != null) {
      setState(() {
        guessedLetters = savedGuesses.split(',').toSet();
      });
    }
    if (savedErrors != null) {
      setState(() {
        wrongGuesses = int.tryParse(savedErrors) ?? 0;
      });
    }
  }

  void _guessLetter(String letter, Pokemon pokemon) {
    if (guessedLetters.contains(letter)) return;

    setState(() {
      guessedLetters.add(letter);
      if (!pokemon.name.toUpperCase().contains(letter)) {
        wrongGuesses++;
      }
    });

    LocalStorage.saveGameState('guesses_$todayKey', guessedLetters.join(','));
    LocalStorage.saveGameState('errors_$todayKey', wrongGuesses.toString());
  }

  Widget _buildWord(Pokemon pokemon) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children:
          pokemon.name
              .toUpperCase()
              .split('')
              .map(
                (c) => Container(
                  padding: const EdgeInsets.all(8),
                  width: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade800, width: 2),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      guessedLetters.contains(c) ? c : '',
                      style: GoogleFonts.pressStart2p(fontSize: 16),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildKeyboard(Pokemon pokemon) {
    final alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          alphabet.map((letter) {
            final disabled =
                guessedLetters.contains(letter) ||
                wrongGuesses >= maxErrors ||
                _isGameWon(pokemon);

            return ElevatedButton(
              onPressed: disabled ? null : () => _guessLetter(letter, pokemon),
              style: ElevatedButton.styleFrom(
                backgroundColor: disabled ? Colors.grey : Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              child: Text(
                letter,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
    );
  }

  bool _isGameWon(Pokemon pokemon) => pokemon.name
      .toUpperCase()
      .split('')
      .every((c) => guessedLetters.contains(c));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pokemon>(
      future: _futurePokemon,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Erro ao carregar Pokémon: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Nenhum Pokémon encontrado.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final pokemon = snapshot.data!;
        final gameOver = wrongGuesses >= maxErrors;
        final gameWon = _isGameWon(pokemon);
        final reveal = gameOver || gameWon;
        
        if (_isGameWon(pokemon) && !coinsGiven) {
          _giveCoinsIfEligible(pokemon);
          _loadCoinBalance();
        }

        return Scaffold(
          backgroundColor: Colors.yellow[100],
          appBar: AppBar(
            title: Text(
              'Pokémon do Dia',
              style: GoogleFonts.pressStart2p(fontSize: 14),
            ),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            centerTitle: true,
            leading: ResetButton(
              isGameWon: _isGameWon(pokemon),
              onReset: () {
                setState(() {
                  _loadCoinBalance();
                  guessedLetters.clear();
                  wrongGuesses = 0;
                  coinsGiven = false;
                  _futurePokemon = ApiRequest().fetchPokemonOfTheDay();
                  LocalStorage.clearGameState(todayKey);
                });
              },
            ),
            actions: [CoinsText(value: coinBalance)],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ColorFiltered(
                      colorFilter:
                          reveal
                              ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.dst,
                              )
                              : const ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                      child: CachedNetworkImage(
                        imageUrl: pokemon.image,
                        width: 180,
                        height: 180,
                      ),
                    ),
                  ),
                ),

                if (gameOver && !gameWon) ...[
                  const SizedBox(height: 24),
                  Text(
                    "Fim de jogo! Você perdeu!",
                    style: GoogleFonts.pressStart2p(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                _buildWord(pokemon),
                const SizedBox(height: 16),
                Text(
                  'Erros: $wrongGuesses / $maxErrors',
                  style: GoogleFonts.pressStart2p(fontSize: 12),
                ),
                const SizedBox(height: 24),
                _buildKeyboard(pokemon),
                const SizedBox(height: 24),
                if (gameWon) ...[
                  Text(
                    "Você acertou! Era ${pokemon.name.toUpperCase()}",
                    style: GoogleFonts.pressStart2p(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Você ganhou ${CoinRewarder.coinsGiven(wrongGuesses)} moedas!",
                    style: GoogleFonts.pressStart2p(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
