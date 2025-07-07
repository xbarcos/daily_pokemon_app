import '../helper/local_storage.dart';

class CoinRewarder {
  static const int maxErrors = 5;
  
  static int coinsGiven(int wrongGuesses) {
    return (maxErrors - wrongGuesses) * 10;
  }

  static Future<int> rewardCoinsBasedOnErrors(int wrongGuesses) async {
    if (wrongGuesses < 0 || wrongGuesses > maxErrors) {
      throw ArgumentError('wrongGuesses deve estar entre 0 e $maxErrors');
    }

    int coinsToGive = coinsGiven(wrongGuesses);
    print('Calculando moedas a serem dadas: $coinsToGive');

    if (coinsToGive <= 0) {      
      return 0;
    }

    await LocalStorage.addCoins(coinsToGive);

    return coinsToGive;
  }
}
