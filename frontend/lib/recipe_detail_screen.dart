import 'package:flutter/material.dart';
import 'api_service.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => recipe.numberOfServings.value > 1
                      ? recipe.numberOfServings.value--
                      : null,
                ),
                ValueListenableBuilder<int>(
                  valueListenable: recipe.numberOfServings,
                  builder: (_, value, __) => Text('$value'),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => recipe.numberOfServings.value++,
                ),
                Text('Servings', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ingredients',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  ingredient.quantity == null
                      ? '${ingredient.unit} ${ingredient.name}'
                      : '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.instructions.replaceAll('\\n', '\n'),
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
