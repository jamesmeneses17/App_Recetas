import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_model.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe;

  RecipeFormScreen({this.recipe});

  @override
  _RecipeFormScreenState createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _titleController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<TextEditingController> _ingredientControllers = [];
  List<TextEditingController> _stepControllers = [];

  XFile? _selectedImage;
  String _imageURL = ''; // Almacena la URL de la imagen

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _caloriesController.text = widget.recipe!.calories.toString();
      _timeController.text = widget.recipe!.time.toString();
      _descriptionController.text = widget.recipe!.description;
      _imageURL =
          widget.recipe!.image ?? ''; // Usar la URL de la imagen existente

      widget.recipe!.ingredients.forEach((ingredient) {
        _ingredientControllers.add(TextEditingController(text: ingredient));
      });
      widget.recipe!.steps.forEach((step) {
        _stepControllers.add(TextEditingController(text: step));
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _caloriesController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _ingredientControllers.forEach((controller) => controller.dispose());
    _stepControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _uploadImageAndSaveURL() async {
    if (_selectedImage == null) return;

    String userId = FirebaseAuth.instance.currentUser!.uid;
    String imagePath =
        'users/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child(imagePath);

    try {
      if (kIsWeb) {
        await storageRef.putData(await _selectedImage!.readAsBytes());
      } else {
        await storageRef.putFile(File(_selectedImage!.path));
      }

      String downloadURL = await storageRef.getDownloadURL();

      setState(() {
        _imageURL =
            downloadURL; // Actualizar la URL solo si se sube una nueva imagen
      });
    } catch (e) {
      print("Error al subir imagen: $e");
    }
  }

  void _saveRecipe() {
    final String title = _titleController.text;
    final int calories = int.tryParse(_caloriesController.text) ?? 0;
    final int time = int.tryParse(_timeController.text) ?? 0;
    final String description = _descriptionController.text;

    List<String> ingredients = _ingredientControllers
        .map((controller) => controller.text)
        .where((text) => text.isNotEmpty)
        .toList();

    List<String> steps = _stepControllers
        .map((controller) => controller.text)
        .where((text) => text.isNotEmpty)
        .toList();

    final updatedRecipe = Recipe(
      title: title,
      calories: calories,
      time: time,
      description: description,
      ingredients: ingredients,
      steps: steps,
      image:
          _imageURL, // Usar la URL existente si no se selecciona una nueva imagen
      rating: widget.recipe?.rating ?? 0, // Mantener la calificación existente
    );

    Navigator.pop(context, updatedRecipe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe != null ? 'Editar Receta' : 'Agregar Receta'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Título de la comida'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Seleccionar Imagen'),
              ),
              if (_selectedImage != null)
                kIsWeb
                    ? Image.network(_selectedImage!.path, height: 200)
                    : Image.file(File(_selectedImage!.path), height: 200)
              else if (_imageURL.isNotEmpty)
                Image.network(_imageURL, height: 200),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _uploadImageAndSaveURL,
                child: Text('Subir Imagen'),
              ),
              SizedBox(height: 16),
              Text(
                'NUTRICIÓN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _caloriesController,
                decoration: InputDecoration(labelText: 'Calorías'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _timeController,
                decoration: InputDecoration(
                    labelText: 'Tiempo de preparación (minutos)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Breve Descripción'),
              ),
              SizedBox(height: 16),
              Text(
                'INGREDIENTES',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Column(
                children: _ingredientControllers
                    .map((controller) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: TextField(
                            controller: controller,
                            decoration:
                                InputDecoration(labelText: 'Ingrediente'),
                          ),
                        ))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: _addIngredientField,
                child: Text('Agregar Ingrediente'),
              ),
              SizedBox(height: 16),
              Text(
                'PREPARACIÓN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Column(
                children: _stepControllers
                    .map((controller) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                                labelText: 'Paso de Preparación'),
                          ),
                        ))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: _addStepField,
                child: Text('Agregar Paso de Preparación'),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveRecipe,
                    child: Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }
}
