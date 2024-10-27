import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_model.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> recipes = [];
  List<Recipe> filteredRecipes = [];
  List<int> _selectedRecipes = [];
  int _selectedIndex = 0;
  String searchQuery = "";
  bool showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadRecipesFromFirestore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshRecipes(); // Recargar las recetas cada vez que regresa a esta pantalla
  }

  Future<void> _loadRecipesFromFirestore() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    CollectionReference userRecipes = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recipes');

    QuerySnapshot snapshot = await userRecipes.get();
    setState(() {
      recipes = snapshot.docs
          .map((doc) => Recipe.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      filteredRecipes = recipes;
    });
  }

  Future<void> _refreshRecipes() async {
    await _loadRecipesFromFirestore();
  }

  Future<void> _saveRecipeToFirestore(Recipe recipe) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    CollectionReference userRecipes = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recipes');

    await userRecipes.add(recipe.toMap());
  }

  void _filterRecipes(String query) {
    List<Recipe> results = [];
    if (query.isNotEmpty) {
      results = recipes.where((recipe) {
        return recipe.ingredients.any((ingredient) =>
            ingredient.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    } else {
      results = recipes;
    }

    if (showFavoritesOnly) {
      results = results.where((recipe) => recipe.isFavorite).toList();
    }

    setState(() {
      searchQuery = query;
      filteredRecipes = results;
    });
  }

  void _toggleFavoritesFilter() {
    setState(() {
      showFavoritesOnly = !showFavoritesOnly;
    });
    _filterRecipes(searchQuery); // Actualizar la lista filtrada
  }

  Future<void> _deleteSelectedRecipes() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference userRecipes = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recipes');

    List<Future> deleteFutures = [];
    for (int index in _selectedRecipes) {
      final recipe = recipes[index];
      deleteFutures.add(userRecipes
          .where('title', isEqualTo: recipe.title)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      }));
    }

    await Future.wait(deleteFutures);

    setState(() {
      _selectedRecipes.sort((a, b) => b.compareTo(a));
      for (int index in _selectedRecipes) {
        recipes.removeAt(index);
      }
      filteredRecipes = recipes;
      _selectedRecipes.clear();
    });
  }

  void _openRecipeDetail(Recipe recipe) async {
    final updatedRecipe = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );

    if (updatedRecipe != null) {
      await _refreshRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas'),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false, // Oculta la flecha de regreso
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.orange),
                        hintText: 'Buscar por ingredientes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        _filterRecipes(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      showFavoritesOnly
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: showFavoritesOnly ? Colors.orange : Colors.grey,
                    ),
                    onPressed: _toggleFavoritesFilter,
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredRecipes.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = filteredRecipes[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: GestureDetector(
                            onTap: () => _openRecipeDetail(recipe),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 4,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(15.0)),
                                    child: recipe.image != null &&
                                            recipe.image!.isNotEmpty
                                        ? Image.network(
                                            recipe.image!,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Text(
                                                'Error al cargar la imagen',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/arroz.jpeg',
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Checkbox(
                                      value: _selectedRecipes.contains(index),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedRecipes.add(index);
                                          } else {
                                            _selectedRecipes.remove(index);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            bottom: Radius.circular(15.0)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              recipe.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time,
                                                  color: Colors.orange),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${recipe.time} min',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(Icons.local_fire_department,
                                                  color: Colors.red),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${recipe.calories} Cal',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No tienes recetas guardadas. Usa el botón + para agregar una nueva receta.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedRecipes.isNotEmpty)
            FloatingActionButton(
              onPressed: () {
                _showDeleteConfirmation();
              },
              child: const Icon(Icons.delete),
              backgroundColor: Colors.red,
              tooltip: 'Eliminar recetas seleccionadas',
            ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              final newRecipe = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeFormScreen()),
              );
              if (newRecipe != null) {
                setState(() {
                  recipes.add(newRecipe);
                });
                _saveRecipeToFirestore(newRecipe);
                _refreshRecipes();
              }
            },
            child: const Icon(Icons.add),
            backgroundColor: Colors.green,
            tooltip: 'Agregar receta',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar las recetas seleccionadas?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteSelectedRecipes();
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
