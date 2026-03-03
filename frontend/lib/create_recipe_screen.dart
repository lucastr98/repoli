import 'package:flutter/material.dart';
import 'api_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class IngredientRow {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  String? selectedUnit;
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ApiService _apiService = ApiService();
  late List<String> _unitOptions;
  bool _isSubmitting = false;
  List<IngredientRow> _ingredients = [];

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final units = await _apiService.getUnits();
    setState(() {
      _unitOptions = units;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitRecipe() async {
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    // setState(() {
    //   _isSubmitting = true;
    // });

    // try {
    //   await _apiService.createRecipe(
    //     _titleController.text,
    //     _contentController.text,
    //   );

    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Recipe created successfully!'),
    //         backgroundColor: Colors.green,
    //       ),
    //     );
    //     Navigator.pop(context, true);
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Error: $e'),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isSubmitting = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
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
      ),
    );
  }

  // --- Component Methods ---

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

  Widget _buildInstructionsField() {
    return TextFormField(
      controller: _contentController,
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

  // --- Ingredient Methods ---
  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientRow());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
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
        ..._ingredients
            .asMap()
            .entries
            .map((entry) => _buildIngredientRow(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildIngredientRow(int index, IngredientRow ingredient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Amount (Float)
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: ingredient.amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Qty', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          // Unit Dropdown
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: ingredient.selectedUnit,
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
            child: TextFormField(
              controller: ingredient.productController,
              decoration: const InputDecoration(
                  labelText: 'Ingredient', border: OutlineInputBorder()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _removeIngredient(index),
          ),
        ],
      ),
    );
  }
}
