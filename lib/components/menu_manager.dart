// lib/components/menu_manager.dart
import 'menu_model.dart';
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
        quantity: '1',
        category: 'breakfast',
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
      ),
      MenuItem.fromData(
        name: 'Pongal (or) Kitchadi',
        price: 40.00,
        quantity: '250 grm',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Vada',
        price: 10.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Poori',
        price: 30.00,
        quantity: '2',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Plain Dosa',
        price: 40.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Masala Dosa',
        price: 50.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Onion Dosa',
        price: 50.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Podi Dosa',
        price: 50.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Paneer Dosa',
        price: 70.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Mushroom Dosa',
        price: 70.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Babycorn Dosa',
        price: 70.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Ghee Dosa',
        price: 70.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Rava Dosa',
        price: 60.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Rava Masala Dosa',
        price: 60.00,
        quantity: '1',
        category: 'breakfast',
      ),
      MenuItem.fromData(
        name: 'Egg Dosa',
        price: 50.00,
        quantity: '1',
        category: 'breakfast',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Dosa',
        price: 70.00,
        quantity: '1',
        category: 'breakfast',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Kari Dosa',
        price: 100.00,
        quantity: '1',
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
        name: 'Verity Rice / Poriyal',
        price: 60.00,
        quantity: '1',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Chappathi With Kurma',
        price: 40.00,
        quantity: '1',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Paratha With Kurma',
        price: 40.00,
        quantity: '1',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Chilly Paratha With Raitha',
        price: 70.00,
        quantity: '300 grm',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Veg Briyani / Raitha',
        price: 80.00,
        quantity: '450 grm',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Veg Fried Rice / Noodles',
        price: 90.00,
        quantity: '400 grm',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Gobi Fried Rice / Noodles',
        price: 90.00,
        quantity: '400 grm',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Mushroom Fried Rice / Noodles',
        price: 90.00,
        quantity: '400 grm',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Paneer Fried Rice / Noodles',
        price: 100.00,
        quantity: '400 grm',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Egg Fried Rice / Noodles',
        price: 100.00,
        quantity: '400 grm',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Fried Rice / Noodles',
        price: 110.00,
        quantity: '400 grm',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chilly Chicken',
        price: 130.00,
        quantity: '150 grm',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Manchuriyar',
        price: 130.00,
        quantity: '150 grm',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Dragon Chicken',
        price: 150.00,
        quantity: '150 grm',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Garlic Chicken',
        price: 150.00,
        quantity: '150 grm',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Lollypop',
        price: 120.00,
        quantity: '4 pc',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken 65',
        price: 120.00,
        quantity: '150 grm',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Veg Kothu Paratha',
        price: 80.00,
        quantity: '300 grm',
        category: 'lunch',
      ),
      MenuItem.fromData(
        name: 'Chicken Kothu Paratha',
        price: 100.00,
        quantity: '300 grm',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Chicken Briyani/egg/rittha/birinjai',
        price: 130.00,
        quantity: '1',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Single Omblet',
        price: 15.00,
        quantity: '1 egg',
        category: 'lunch',
        isVeg: false,
      ),
      MenuItem.fromData(
        name: 'Double Omblet',
        price: 25.00,
        quantity: '2 egg',
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
        name: 'Nandu Omblet',
        price: 40.00,
        quantity: '1 egg',
        category: 'lunch',
        isVeg: false,
      ),
    ]);
  }
}