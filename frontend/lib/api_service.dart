import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Recipe {
  final int? id;
  final String title;
  final String instructions;
  final ValueNotifier<int> numberOfServings;
  final List<Ingredient> ingredients;

  Recipe({
    this.id,
    required this.title,
    required this.instructions,
    required this.numberOfServings,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      instructions: json['instructions'],
      numberOfServings: ValueNotifier<int>(json['number_of_servings']),
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((ingredient) => Ingredient.fromJson(ingredient))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'instructions': instructions,
      'number_of_servings': numberOfServings.value,
      'ingredients':
          ingredients.map((ingredient) => ingredient.toJson()).toList(),
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
      quantity: json['quantity'] == null
          ? null
          : (json['quantity'] as num).toDouble(),
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

  Future<void> createRecipe(String title, List<Ingredient> ingredients,
      String instructions, int numberOfServings) async {
    final recipe = Recipe(
      title: title,
      instructions: instructions,
      numberOfServings: ValueNotifier<int>(numberOfServings),
      ingredients: ingredients,
    );
    final response = await http.post(
      Uri.parse('$baseUrl/recipe'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(recipe.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create recipe');
    }
  }

  Future<void> deleteRecipe(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/recipes/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete recipe');
    }
  }

  Future<List<String>> getUnits() async {
    final response = await http.get(Uri.parse('$baseUrl/units'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => json.toString()).toList();
    } else {
      throw Exception('Failed to load units');
    }
  }

  Future<List<String>> getIngredients() async {
    final response = await http.get(Uri.parse('$baseUrl/ingredients'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => json.toString()).toList();
    } else {
      throw Exception('Failed to load ingredients');
    }
  }
}
