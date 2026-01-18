// lib/components/menu_manager.dart
import 'menu_model.dart';
import 'menu_data.dart';
import 'package:flutter/foundation.dart';

class MenuManager {
  static final MenuManager _instance = MenuManager._internal();

  factory MenuManager() {
    return _instance;
  }

  MenuManager._internal() {
    _initializeMenuItems();
  }

  final List<MenuItem> _allMenuItems = [];
  final List<VoidCallback> _listeners = [];

  List<MenuItem> get allMenuItems => List.unmodifiable(_allMenuItems);

  List<MenuItem> get activeMenuItems =>
      _allMenuItems.where((item) => item.isActive && item.isAvailable).toList();

  List<MenuItem> get breakfastItems =>
      activeMenuItems.where((item) => item.category == 'breakfast').toList();

  List<MenuItem> get lunchItems =>
      activeMenuItems.where((item) => item.category == 'lunch').toList();

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void toggleItemAvailability(String itemId, bool isActive) {
    final itemIndex = _allMenuItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      _allMenuItems[itemIndex].isActive = isActive;
      notifyListeners();
    }
  }

  void toggleItemStock(String itemId, bool isAvailable) {
    final itemIndex = _allMenuItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      _allMenuItems[itemIndex].isAvailable = isAvailable;
      notifyListeners();
    }
  }

  void _initializeMenuItems() {
    // Clear existing items
    _allMenuItems.clear();

    // Breakfast Items
    _allMenuItems.addAll([
      MenuItem.fromData(
        name: 'Idly',
        price: 10.00,
        quantity: '1 piece',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Pongal (or) Khichdi',
        price: 40.00,
        quantity: '250 g',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Vada',
        price: 10.00,
        quantity: '1 piece',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Poori',
        price: 30.00,
        quantity: '2 pieces',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Plain Dosa',
        price: 40.00,
        quantity: '-',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Masala Dosa',
        price: 50.00,
        quantity: '-',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Onion Dosa',
        price: 50.00,
        quantity: '-',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Podi Dosa',
        price: 50.00,
        quantity: '-',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Paneer Dosa',
        price: 70.00,
        quantity: '-',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Mushroom Dosa',
        price: 70.00,
        quantity: '-',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Baby corn Dosa',
        price: 70.00,
        quantity: '-',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Ghee Dosa',
        price: 70.00,
        quantity: '-',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Rava Dosa',
        price: 50.00,
        quantity: '-',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Rava Masala Dosa',
        price: 60.00,
        quantity: '-',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Egg Dosa',
        price: 50.00,
        quantity: '-',
        category: 'breakfast',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Dosa',
        price: 70.00,
        quantity: '-',
        category: 'breakfast',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Kari Dosa',
        price: 100.00,
        quantity: '-',
        category: 'breakfast',
      ),
    ]);

    // Lunch Items
    _allMenuItems.addAll([
      MenuItem.fromData(
        name: 'Veg Meals',
        price: 80.00,
        quantity: '1',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Mini Meals',
        price: 90.00,
        quantity: '1',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Variety Rice / Poriyal',
        price: 60.00,
        quantity: '-',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Chapati with Kurma',
        price: 40.00,
        quantity: '2 pieces',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Parotta with Kurma',
        price: 40.00,
        quantity: '2 pieces',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Chilli Parotta with Raita',
        price: 70.00,
        quantity: '300 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Veg Biryani / Raita',
        price: 80.00,
        quantity: '450 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Chicken Biryani (with Egg/Raita/Brinjal)',
        price: 130.00,
        quantity: '-',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Veg Fried Rice',
        price: 80.00,
        quantity: '400 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Veg Noodles',
        price: 80.00,
        quantity: '400 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Gobi Fried Rice',
        price: 90.00,
        quantity: '400 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Gobi Noodles',
        price: 90.00,
        quantity: '400 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Mushroom Fried Rice',
        price: 90.00,
        quantity: '400 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Mushroom Noodles',
        price: 90.00,
        quantity: '400 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Paneer Fried Rice',
        price: 100.00,
        quantity: '400 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Paneer Noodles',
        price: 100.00,
        quantity: '400 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Egg Fried Rice',
        price: 100.00,
        quantity: '400 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Egg Noodles',
        price: 100.00,
        quantity: '400 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Fried Rice',
        price: 110.00,
        quantity: '400 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Noodles',
        price: 110.00,
        quantity: '400 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chilli Chicken',
        price: 130.00,
        quantity: '150 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Manchurian',
        price: 130.00,
        quantity: '150 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Dragon Chicken',
        price: 150.00,
        quantity: '150 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Garlic Chicken',
        price: 150.00,
        quantity: '150 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Lollipop',
        price: 150.00,
        quantity: '4 pieces',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken 65',
        price: 120.00,
        quantity: '150 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Veg Kothu Parotta',
        price: 60.00,
        quantity: '300 g',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Egg Kothu Parotta',
        price: 80.00,
        quantity: '300 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Kothu Parotta',
        price: 100.00,
        quantity: '300 g',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Single Omelette',
        price: 15.00,
        quantity: '1 egg',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Double Omelette',
        price: 25.00,
        quantity: '2 eggs',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Kalaki',
        price: 20.00,
        quantity: '1 egg',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Nandu (Crab) Omelette',
        price: 40.00,
        quantity: '1 egg',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Omelette',
        price: 40.00,
        quantity: '1 egg',
        category: 'lunch',
        isVeg: false,
      ),
    ]);
  }
}
