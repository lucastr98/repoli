import 'dart:convert';
import 'package:http/http.dart' as http;

class Recipe {
  final String title;
  final String instructions;
  final List<Ingredient> ingredients;

  Recipe({
    required this.title,
    required this.instructions,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'],
      instructions: json['instructions'],
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((ingredient) => Ingredient.fromJson(ingredient))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'instructions': instructions,
      'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
    };
  }
}

class Ingredient {
  final String name;
  final double? quantity;
  final String unit;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      quantity: json['quantity'] == null ? null : (json['quantity'] as num).toDouble(),
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  Future<List<Recipe>> getRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/recipes'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<Recipe> getRecipe(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/recipes/$id'));

    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load recipe');
    }
  }

//   Future<Recipe> createRecipe(String title, String content) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/recipes'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'title': title, 'content': content}),
//     );

//     if (response.statusCode == 200) {
//       return Recipe.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to create recipe');
//     }
//   }
}
