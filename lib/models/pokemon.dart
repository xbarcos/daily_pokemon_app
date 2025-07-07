class Pokemon {
  final String name;
  final String image;

  Pokemon({required this.name, required this.image});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'].toUpperCase(),
      image: json['image'],
    );
  }
}
