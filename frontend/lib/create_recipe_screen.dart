import 'package:flutter/material.dart';
import 'api_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class IngredientRow {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  String? selectedUnit;

  bool isEmpty() {
    return productNameController.text.trim().isEmpty &&
        quantityController.text.trim().isEmpty &&
        (selectedUnit == null || selectedUnit!.trim().isEmpty);
  }

  bool isValid(List<String> ingredientOptions, List<String> unitOptions) {
    bool validQuantity = quantityController.text.isEmpty ||
        double.tryParse(quantityController.text.trim()) != null;
    bool validProductName =
        ingredientOptions.contains(productNameController.text.trim());
    bool validUnit =
        selectedUnit != null && unitOptions.contains(selectedUnit!);
    return validQuantity && validProductName && validUnit;
  }
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _instructionsController = TextEditingController();
  final ApiService _apiService = ApiService();
  late Future<void> _initIngredientRowOptions;
  late List<String> _unitOptions;
  late List<String> _ingredientOptions;
  bool _isSubmitting = false;
  List<IngredientRow> _ingredients = [];

  @override
  void initState() {
    super.initState();
    _initIngredientRowOptions = _loadIngredientRowOptions();
    _addIngredient();
  }

  Future<void> _loadIngredientRowOptions() async {
    await Future.wait([_loadUnits(), _loadIngredients()]);
  }

  Future<void> _loadUnits() async {
    final units = await _apiService.getUnits();
    setState(() {
      _unitOptions = units;
    });
  }

  Future<void> _loadIngredients() async {
    final ingredients = await _apiService.getIngredients();
    setState(() {
      _ingredientOptions = ingredients;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _submitRecipe() async {
    final nonEmptyIngredients =
        _ingredients.where((ing) => !ing.isEmpty()).toList();

    if (nonEmptyIngredients.isEmpty) {
      _showErrorSnackBar('Please add at least one ingredient.');
      return;
    }

    List<String> errorMessages = [];
    for (var i = 0; i < nonEmptyIngredients.length; i++) {
      final ing = nonEmptyIngredients[i];
      if (!ing.isValid(_ingredientOptions, _unitOptions)) {
        errorMessages.add(
            "Row ${i + 1}: Quantity = ${ing.quantityController.text}, Unit = ${ing.selectedUnit}, Ingredient = ${ing.productNameController.text}");
      }
    }

    if (errorMessages.isNotEmpty) {
      _showErrorSnackBar(
          "The following ingredients are invalid:\n${errorMessages.join('\n')}");
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _apiService.createRecipe(
        _titleController.text,
        _ingredients
            .map((ing) => Ingredient(
                  name: ing.productNameController.text,
                  quantity: double.tryParse(ing.quantityController.text) ?? 0,
                  unit: ing.selectedUnit ?? '',
                ))
            .toList(),
        _instructionsController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<void>(
        future: _initIngredientRowOptions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildIngredientSection(),
                  const SizedBox(height: 16),
                  _buildInstructionsField(),
                  const SizedBox(height: 16),
                  _buildSubmitButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('New Recipe'),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title',
        hintText: 'Enter title...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter a title' : null,
    );
  }

  Widget _buildIngredientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ingredients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._ingredients.asMap().entries.map((entry) =>
            _buildIngredientRow(entry.key, entry.value, _ingredients.length)),
      ],
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientRow());
    });
  }

  Widget _buildIngredientRow(
      int index, IngredientRow ingredient, int totalIngredients) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Amount (Float)
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: ingredient.quantityController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Quantity', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          // Unit Dropdown
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              initialValue: ingredient.selectedUnit,
              items: _unitOptions
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (val) => setState(() => ingredient.selectedUnit = val),
              decoration: const InputDecoration(
                  labelText: 'Unit', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          // Product Name
          Expanded(
            flex: 3,
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _ingredientOptions.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                ingredient.productNameController.text = selection;
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Ingredient',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (String value) {
                    onFieldSubmitted();
                  },
                );
              },
            ),
          ),
          if (totalIngredients > 1)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeIngredient(index),
            ),
        ],
      ),
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Widget _buildInstructionsField() {
    return TextFormField(
      controller: _instructionsController,
      maxLines: 12,
      decoration: const InputDecoration(
        labelText: 'Instructions',
        hintText: 'Enter instructions...',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      validator: (value) => (value == null || value.isEmpty)
          ? 'Please enter the instructions'
          : null,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitRecipe,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _isSubmitting
          ? _buildLoader()
          : const Text('Save Recipe', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildLoader() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
