import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'recipe_model.dart';
import 'recipe_form_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe recipe;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
  }

  Future<void> _refreshRecipe() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference userRecipes = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recipes');

    QuerySnapshot snapshot = await userRecipes
        .where('title', isEqualTo: recipe.title)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        recipe =
            Recipe.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      });
    }
  }

  Future<void> _updateRating(double newRating) async {
    setState(() {
      recipe.rating = newRating;
    });

    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference userRecipes = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recipes');

    await userRecipes
        .where('title', isEqualTo: recipe.title)
        .limit(1)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'rating': newRating});
      }
    });
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      recipe.isFavorite = !recipe.isFavorite;
    });

    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference userRecipes = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recipes');

    await userRecipes
        .where('title', isEqualTo: recipe.title)
        .limit(1)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'isFavorite': recipe.isFavorite});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: recipe.image != null && recipe.image!.isNotEmpty
                          ? Image.network(
                              recipe.image!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'Error al cargar la imagen',
                                  style: TextStyle(color: Colors.red),
                                );
                              },
                            )
                          : Image.asset(
                              'assets/arroz.jpeg',
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingBar.builder(
                          initialRating: recipe.rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20.0, 
                          itemPadding: EdgeInsets.symmetric(
                              horizontal:
                                  2.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            _updateRating(rating);
                          },
                        ),
                        SizedBox(
                            width:
                                8), 
                        Column(
                          children: [
                            IconButton(
                              iconSize:
                                  24.0, 
                              icon: Icon(
                                recipe.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.redAccent,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                            Text(
                              "Agregar a favoritos",
                              style: TextStyle(
                                  fontSize: 10), // Reduce el tamaño del texto
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 16),
                    // Sección de Nutrición y Preparación
                    DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            indicatorColor: Colors.red,
                            labelColor: Colors.red,
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(text: 'Nutrición'),
                              Tab(text: 'Preparación'),
                            ],
                          ),
                          SizedBox(
                            height: 200,
                            child: TabBarView(
                              children: [
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Icon(
                                                    Icons.local_fire_department,
                                                    color: Colors.redAccent),
                                                Text(
                                                  '${recipe.calories} CAL',
                                                  style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Icon(Icons.access_time,
                                                    color: Colors.orange),
                                                Text(
                                                  '${recipe.time} min',
                                                  style: TextStyle(
                                                      color: Colors.orange,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Container(
                                          width: double.infinity,
                                          child: Text(
                                            recipe.description,
                                            style: TextStyle(fontSize: 16),
                                            maxLines: null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Preparación
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ingredientes:',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: recipe.ingredients
                                              .map((ingredient) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '•',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.orange,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      ingredient,
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Pasos de Preparación:',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: recipe.steps
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            String step = entry.value;
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Text(
                                                '${index + 1}. $step',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botón para Editar receta en la parte inferior
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                final updatedRecipe = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeFormScreen(recipe: recipe),
                  ),
                );

                if (updatedRecipe != null) {
                  // Mantener el estado de isFavorite y rating
                  updatedRecipe.isFavorite = recipe.isFavorite;
                  updatedRecipe.rating = recipe.rating;

                  // Guardar cambios en Firebase
                  String uid = FirebaseAuth.instance.currentUser!.uid;
                  CollectionReference userRecipes = FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('recipes');

                  await userRecipes
                      .where('title', isEqualTo: recipe.title)
                      .get()
                      .then((snapshot) {
                    for (DocumentSnapshot ds in snapshot.docs) {
                      ds.reference.update(updatedRecipe.toMap());
                    }
                  });

                  // Refrescar la receta desde Firestore
                  await _refreshRecipe();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child:
                  const Text('Editar receta', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
