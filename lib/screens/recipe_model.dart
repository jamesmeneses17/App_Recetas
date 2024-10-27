class Recipe {
  String title;
  int calories;
  int time;
  String description;
  List<String> ingredients;
  List<String> steps;
  String? image;
  double rating;
  bool isFavorite;

  Recipe({
    required this.title,
    required this.calories,
    required this.time,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.image,
    this.rating = 0.0,
    this.isFavorite = false, // Valor predeterminado como `false`
  });

  // Métodos para serialización a Map y de-serialización desde Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'calories': calories,
      'time': time,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'image': image,
      'rating': rating,
      'isFavorite': isFavorite,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      title: map['title'],
      calories: map['calories'],
      time: map['time'],
      description: map['description'],
      ingredients: List<String>.from(map['ingredients']),
      steps: List<String>.from(map['steps']),
      image: map['image'],
      rating: map['rating']?.toDouble() ?? 0.0,
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
